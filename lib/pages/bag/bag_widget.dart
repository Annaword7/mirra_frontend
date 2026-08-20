import '/design_system/foundations/image_thumb.dart';
import '/design_system/components/screen_loader.dart';
import 'dart:async';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/database/database.dart';
import '/flutter_flow/analytics_service.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/profile_summary_card.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/pro_pill.dart';
import '/domain/care_planning/care_planning_service.dart';
import '/domain/cosmetic_bag/cosmetic_bag_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/plural.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/paywall/paywallpage/paywallpage_widget.dart';
import '/pages/care_review/care_review_widget.dart';
import '/pages/onboarding_quiz/onboarding_quiz_widget.dart' show kPregnancyPregnantOrNursing;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// «Косметичка» (M3c, контекст «Понимание продукта», Architecture v1).
///
/// Курируемый набор «чем я реально пользуюсь»: 3 бесплатных слота
/// (4-й — Pro), добавление из своих сканов, CTA на разбор и сборку режима.
/// Сама логика режима — на сервере; экран только владеет набором.
class BagWidget extends StatefulWidget {
  const BagWidget({super.key});

  static String routeName = 'Bag';
  static String routePath = '/bag';

  @override
  State<BagWidget> createState() => _BagWidgetState();
}

class _BagWidgetState extends State<BagWidget> {
  bool _loading = true;
  List<BagItemsRow> _items = [];
  Map<int, ImagesRow> _images = {};
  UsersRow? _profile;
  // Последний собранный режим (GET care/regimen/current) — для сводки
  // совместимости и детекта «состав косметички изменился». Грузится отдельно:
  // это сетевой вызов к бэкенду, экран не должен его ждать.
  // Стартуем из сессионного кэша: при повторном открытии экрана статус готов
  // сразу, «проверяем» показывается только когда режим правда не загружен.
  Map<String, dynamic>? _regimen = CarePlanningService.instance.cachedRegimen;
  bool _regimenLoading = !CarePlanningService.instance.hasCurrentRegimen;

  /// Колонки images, которые нужны косметичке. Разбор состава и тексты анализа
  /// здесь не выводятся, а весят в разы больше остального.
  static const _imageColumns = 'id,image_url,product_name,brand';

  /// Вердикт «безопасно при беременности» по продуктам набора. Живёт отдельно:
  /// колонку добавляет миграция 20260730_pregnancy_verdict, и там, где она ещё
  /// не применена, запрос обязан провалиться сам по себе, а не утащить за собой
  /// всю загрузку косметички.
  Map<int, bool> _pregnancySafe = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  Future<void> _load() async {
    try {
      final items = await CosmeticBagService.instance.items();
      final ids = items.map((i) => i.imageId).whereType<int>().toList();
      // Продукты и профиль независимы — тянем их разом, а не друг за другом.
      final results = await Future.wait([
        if (ids.isNotEmpty)
          ImagesTable().queryRows(
            queryFn: (q) => q.inFilterOrNull('id', ids),
            columns: _imageColumns,
          )
        else
          Future.value(<ImagesRow>[]),
        if (currentUserUid.isNotEmpty)
          UsersTable().queryRows(queryFn: (q) => q.eqOrNull('id', currentUserUid))
        else
          Future.value(<UsersRow>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _items = items;
        _images = {
          for (final r in (results[0] as List<ImagesRow>)) r.id: r
        };
        _profile = (results[1] as List<UsersRow>).firstOrNull;
        _loading = false;
      });
      unawaited(_loadRegimen());
      unawaited(_loadPregnancy(ids));
    } catch (e) {
      debugPrint('bag load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPregnancy(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      final rows = await ImagesTable().queryRows(
        queryFn: (q) => q.inFilterOrNull('id', ids),
        columns: 'id,sa_pregnancy_safe',
      );
      if (!mounted) return;
      setState(() {
        _pregnancySafe = {
          for (final r in rows)
            if (r.saPregnancySafe != null) r.id: r.saPregnancySafe!
        };
      });
    } catch (e) {
      debugPrint('bag: pregnancy verdicts unavailable: $e');
    }
  }

  /// Сводка совместимости догружается после отрисовки набора: экран остаётся
  /// быстрым, а карточка сама переключается из «проверяем» в результат. Если
  /// режим уже загружен в этой сессии, он отдаётся из кэша — без сети и без
  /// мигания статуса при каждом открытии экрана.
  /// Ошибка не критична — сводка просто останется «не проверено».
  Future<void> _loadRegimen() async {
    final cached = CarePlanningService.instance.hasCurrentRegimen;
    if (mounted && !cached) setState(() => _regimenLoading = true);
    Map<String, dynamic>? regimen;
    try {
      regimen = await CarePlanningService.instance.currentRegimen();
    } catch (e) {
      debugPrint('bag: current regimen fetch failed: $e');
    }
    if (!mounted) return;
    setState(() {
      _regimen = regimen;
      _regimenLoading = false;
    });
  }

  int get _slotCount {
    // Pro: все продукты + пустой слот «добавить».
    if (FFAppState().isprouser) return _items.length + 1;
    // Free: пока есть свободные слоты — ровно три.
    if (_items.length < kFreeBagSlots) return kFreeBagSlots;
    // Лимит выбран — добавляем слот с замком, иначе упереться в потолок можно
    // только вслепую: свободных слотов нет и нажать не на что.
    if (_items.length == kFreeBagSlots) return kFreeBagSlots + 1;
    // Продуктов больше лимита (набирали на Pro, подписка кончилась) —
    // показываем и лишние: разбор их не учитывает, и это должно быть видно.
    return _items.length;
  }

  /// Продукт сверх бесплатного лимита: в разбор не идёт, пока нет Pro.
  bool _overLimit(int index) =>
      !FFAppState().isprouser && index >= kFreeBagSlots;

  void _openPaywall({String trigger = 'bag_add_from_bag'}) {
    HapticFeedback.lightImpact();
    unawaited(
        AnalyticsService.instance.trackUpgradePromptTapped(trigger: trigger));
    context.pushNamed(PaywallpageWidget.routeName);
  }

  Future<void> _addFlow() async {
    HapticFeedback.lightImpact();
    // Пейволл: 4-й продукт — Pro (коммерческое правило).
    if (!FFAppState().isprouser && _items.length >= kFreeBagSlots) {
      _openPaywall();
      return;
    }
    final inBag = _items.map((i) => i.imageId).whereType<int>().toSet();
    final scans = await ImagesTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user', currentUserUid)
          .not('sa_analyzed_at', 'is', null)
          .order('id', ascending: false),
      limit: 50,
      columns: _imageColumns,
    );
    final candidates =
        scans.where((s) => !inBag.contains(s.id)).toList();
    if (!mounted) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickScanSheet(
        candidates: candidates,
        title: _t('cb_add_from_products'),
        emptyText: _t('cb_bag_empty'),
      ),
    );
    if (picked == null) return;
    await CosmeticBagService.instance.add(picked);
    _load();
  }

  Future<void> _remove(int imageId) async {
    HapticFeedback.lightImpact();
    await CosmeticBagService.instance.remove(imageId);
    _load();
  }

  Set<int> get _bagSet =>
      _items.map((i) => i.imageId).whereType<int>().toSet();

  List<dynamic> get _regimenWarnings =>
      (_regimen?['warnings'] as List?) ?? const [];

  /// Набор, из которого собран текущий режим (сервер запоминает его при
  /// составлении). Продукты без фактов состава в режим не попадают, поэтому
  /// восстанавливать состав по назначениям нельзя — сводка врала бы
  /// «набор изменился» на каждом открытии.
  Set<int>? get _composedSet {
    final ids = _regimen?['source_image_ids'];
    if (ids is! List) return null;
    return ids.map((e) => e is int ? e : int.tryParse('$e')).whereType<int>().toSet();
  }

  bool get _compatStale {
    if (_regimen == null) return false;
    final composed = _composedSet;
    if (composed == null) return false;
    final bag = _bagSet;
    return composed.length != bag.length || !composed.containsAll(bag);
  }

  /// Сводка совместимости над продуктами: состояние последней проверки
  /// + заметная кнопка. Заменяет прежнюю кнопку внизу экрана.
  Widget _compatCard(FlutterFlowTheme theme) {
    if (_items.length < 2) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          _t('cb_compat_need_more'),
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
      );
    }

    final hasRegimen = _regimen != null;
    final warnings = _regimenWarnings.length;
    final stale = _compatStale;

    final Color accent;
    final IconData icon;
    final String status;
    final String button;
    if (_regimenLoading) {
      accent = theme.primary;
      icon = Icons.hourglass_empty_rounded;
      status = _t('cb_compat_loading');
      button = _t('cb_compat_open');
    } else if (!hasRegimen) {
      accent = theme.primary;
      icon = Icons.rule_rounded;
      status = _t('cb_compat_unchecked');
      button = _t('cb_compat_check');
    } else if (stale) {
      accent = const Color(0xFFFFB300);
      icon = Icons.sync_problem_rounded;
      status = _t('cb_compat_stale');
      button = _t('cb_compat_recalc');
    } else if (warnings > 0) {
      accent = const Color(0xFFFFB300);
      icon = Icons.info_rounded;
      status = pluralText(context, 'cb_compat_warnings', warnings);
      button = _t('cb_compat_open');
    } else {
      accent = const Color(0xFF1B5E20);
      icon = Icons.check_circle_rounded;
      status = _t('cb_compat_ok');
      button = _t('cb_compat_open');
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('cb_compat_title'),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: button,
            onPressed: () async {
              await context.pushNamed(CareReviewWidget.routeName);
              if (mounted) _load();
            },
          ),
        ],
      ),
    );
  }

  /// Сводка по беременности над набором: только для тех, кто отметил это в
  /// анкете — остальным она отвечает на незаданный вопрос. Считается по
  /// продуктам с вычисленным вердиктом (sa_pregnancy_safe != null); полная
  /// методика — на карточке продукта.
  Widget _pregnancySummary(FlutterFlowTheme theme) {
    if (_profile?.pregnancyStatus != kPregnancyPregnantOrNursing) {
      return const SizedBox.shrink();
    }
    final computed = _items
        .map((it) => _pregnancySafe[it.imageId])
        .whereType<bool>()
        .toList();
    if (computed.isEmpty) return const SizedBox.shrink();
    final caution = computed.where((safe) => !safe).length;
    final ok = caution == 0;
    final accent = ok ? const Color(0xFF1B5E20) : const Color(0xFFFFB300);
    final text = ok
        ? _t('preg_bag_all_safe')
        : pluralText(context, 'preg_bag_caution', caution);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            size: 18,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final filled = _items.length;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _t('cb_bag_title'),
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: Colors.black,
            letterSpacing: 0,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
      ),
      bottomNavigationBar: const NavbarWidget(activePage: 3),
      body: _loading
          ? const ScreenLoader(hasAppBar: true, hasBottomNavBar: true)
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              children: [
                // «Твой профиль»: саммари онбординга, тап → квиз (изменить).
                ProfileSummaryCard(
                    profileRow: _profile, returnTo: BagWidget.routeName),
                Text(
                  _t('bag_subtitle'),
                  style: const TextStyle(color: Colors.black54, fontSize: 13.5),
                ),
                const SizedBox(height: 16),
                _compatCard(theme),
                _pregnancySummary(theme),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // Слот вытянут так, чтобы область под фото была 3:4
                  // (kThumbAspect) с учётом подписи снизу: снимки продуктов
                  // вертикальные, в квадрате от них оставался средний обрезок.
                  childAspectRatio: 0.63,
                  children: [
                    for (var i = 0; i < _slotCount; i++)
                      i < filled
                          ? _FilledSlot(
                              image: _images[_items[i].imageId],
                              onRemove: () => _remove(_items[i].imageId!),
                              overLimit: _overLimit(i),
                              onLockedTap: () =>
                                  _openPaywall(trigger: 'bag_over_limit'),
                              lockedHint: _t('cb_slot_over_limit'),
                            )
                          : _EmptySlot(
                              primary: theme.primary,
                              locked: !FFAppState().isprouser &&
                                  i >= kFreeBagSlots,
                              onTap: _addFlow,
                            ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  const _FilledSlot({
    required this.image,
    required this.onRemove,
    this.overLimit = false,
    this.onLockedTap,
    this.lockedHint = '',
  });
  final ImagesRow? image;
  final VoidCallback onRemove;

  /// Продукт сверх бесплатного лимита: остаётся в наборе, но в разбор не идёт.
  final bool overLimit;
  final VoidCallback? onLockedTap;
  final String lockedHint;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                children: [
                  Expanded(
                    child: (image != null && image!.imageUrl.isNotEmpty)
                        ? Image(
                            image: thumbProvider(image!.imageUrl, width: 400),
                            width: double.infinity,
                            fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFF2F2F2),
                            child: const Center(
                              child: Icon(Icons.spa_outlined,
                                  color: Colors.black38),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      image?.productName ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x22000000), blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: Colors.black54),
            ),
          ),
        ),
        // Сверх лимита: продукт виден, но помечен как не участвующий в разборе.
        if (overLimit)
          Positioned.fill(
            child: GestureDetector(
              onTap: onLockedTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ProPill(
                      label: 'PRO',
                      fontSize: 10,
                      padding: EdgeInsetsDirectional.fromSTEB(10, 4, 10, 4),
                    ),
                    if (lockedHint.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        lockedHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.25,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({
    required this.primary,
    required this.locked,
    required this.onTap,
  });
  final Color primary;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // Закрытый слот — не «отключённый» серый, а приглашение: та же
          // подсветка primary, что у карточек Косметички.
          color: locked
              ? primary.withValues(alpha: 0.06)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: locked
                ? primary.withValues(alpha: 0.35)
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: locked ? primary.withValues(alpha: 0.55) : primary,
              size: 28,
            ),
            // Фирменный бейдж вместо замка с подписью: он уже говорит «нужен
            // Pro» одним взглядом и совпадает с пейволлом.
            if (locked) ...[
              const SizedBox(height: 8),
              const ProPill(
                label: 'PRO',
                fontSize: 10,
                padding: EdgeInsetsDirectional.fromSTEB(10, 4, 10, 4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PickScanSheet extends StatelessWidget {
  const _PickScanSheet({
    required this.candidates,
    required this.title,
    required this.emptyText,
  });
  final List<ImagesRow> candidates;
  final String title;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
            ),
            const SizedBox(height: 12),
            if (candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(emptyText,
                    style: const TextStyle(color: Colors.black54)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                // Три в ряд, а не четыре: под фото нужна подпись — по одному
                // снимку продукт не узнаётся, особенно среди похожих флаконов.
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.58,
                  children: [
                    for (final img in candidates)
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(img.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: img.imageUrl.isNotEmpty
                                    ? Image(
                                        image: thumbProvider(img.imageUrl,
                                            width: 200),
                                        width: double.infinity,
                                        fit: BoxFit.cover)
                                    : Container(
                                        color: const Color(0xFFF2F2F2)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            if ((img.brand ?? '').isNotEmpty)
                              Text(
                                img.brand!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black45),
                              ),
                            Text(
                              img.productName ?? '—',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
