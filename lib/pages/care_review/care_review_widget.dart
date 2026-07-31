import '/backend/supabase/database/database.dart';
import '/design_system/components/app_button.dart';
import '/domain/care_planning/care_planning_service.dart';
import '/domain/cosmetic_bag/cosmetic_bag_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// «Разбор косметички» (M3b, контекст «Назначение ухода», Architecture v1).
///
/// Экран — проекция предложенного Режима: назначения с директивами и
/// обоснованиями, предупреждения, очередь введения, команда ПринятьРежим.
/// Никакой логики: составление и инварианты — на сервере.
class CareReviewWidget extends StatefulWidget {
  const CareReviewWidget({super.key});

  static String routeName = 'CareReview';
  static String routePath = '/careReview';

  @override
  State<CareReviewWidget> createState() => _CareReviewWidgetState();
}

class _CareReviewWidgetState extends State<CareReviewWidget> {
  bool _loading = true;
  String? _error;
  String? _regimenId;
  String _regimenStatus = 'proposed';
  List<dynamic> _prescriptions = [];
  List<dynamic> _warnings = [];
  Map<int, ImagesRow> _images = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  /// Открытие разбора: если режим уже собран и состав Косметички не изменился —
  /// показываем его без пересчёта; пересобираем только когда состав изменился
  /// или режима ещё нет. Сам compose детерминированный, но каждый вызов плодит
  /// запись режима — поэтому не гоняем его на каждый вход.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await CarePlanningService.instance.current();
      if (resp.succeeded && resp.jsonBody is Map) {
        final map = (resp.jsonBody as Map).cast<String, dynamic>();
        final regimen = (map['regimen'] as Map?)?.cast<String, dynamic>();
        final prescriptions = (map['prescriptions'] as List?) ?? const [];
        if (regimen != null && prescriptions.isNotEmpty) {
          final bag = await _bagImageIds();
          final composed = _composedSet(prescriptions, regimen);
          final unchanged =
              composed.length == bag.length && composed.containsAll(bag);
          if (unchanged) {
            await _applyRegimen(
              regimenId: regimen['id'] as String?,
              status: (regimen['status'] as String?) ?? 'proposed',
              prescriptions: prescriptions,
              warnings: (regimen['warnings'] as List?) ?? const [],
            );
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('care: current fetch failed, recomposing: $e');
    }
    await _compose();
  }

  Future<Set<int>> _bagImageIds() async {
    final items = await CosmeticBagService.instance.items();
    return items.map((i) => i.imageId).whereType<int>().toSet();
  }

  /// Продукты, из которых собран режим: назначения плюс исключённые
  /// противопоказанием (они не сохраняются как назначения). Совпадение с
  /// составом Косметички = «ничего не менялось».
  Set<int> _composedSet(
      List<dynamic> prescriptions, Map<String, dynamic> regimen) {
    final s = <int>{};
    for (final p in prescriptions) {
      final id = p is Map ? p['image_id'] : null;
      if (id is int) s.add(id);
    }
    for (final w in (regimen['warnings'] as List?) ?? const []) {
      final id = w is Map ? w['product_id'] : null;
      if (id is int) s.add(id);
    }
    return s;
  }

  Future<void> _applyRegimen({
    required String? regimenId,
    required String status,
    required List<dynamic> prescriptions,
    required List<dynamic> warnings,
  }) async {
    final ids =
        prescriptions.map((p) => p['image_id']).whereType<int>().toSet().toList();
    var images = <int, ImagesRow>{};
    if (ids.isNotEmpty) {
      final rows = await ImagesTable().queryRows(
        queryFn: (q) => q.inFilterOrNull('id', ids),
      );
      images = {for (final r in rows) r.id: r};
    }
    if (!mounted) return;
    setState(() {
      _images = images;
      _regimenId = regimenId;
      _regimenStatus = status;
      _prescriptions = prescriptions;
      _warnings = warnings;
      _loading = false;
    });
  }

  /// Набор = содержимое Косметички (курируемое «чем я пользуюсь») —
  /// image_ids не передаём, сервер берёт bag_items сам.
  Future<void> _compose() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await CarePlanningService.instance.compose(null);
      if (resp.statusCode == 422) {
        setState(() {
          _loading = false;
          _error = _t('care_empty_bag');
        });
        return;
      }
      if (!resp.succeeded) {
        throw Exception('compose failed: ${resp.statusCode}');
      }
      final map = (resp.jsonBody as Map).cast<String, dynamic>();
      await _applyRegimen(
        regimenId: map['regimen_id'] as String?,
        status: 'proposed',
        prescriptions: (map['prescriptions'] as List?) ?? const [],
        warnings: (map['warnings'] as List?) ?? const [],
      );
    } catch (e) {
      debugPrint('care compose failed: $e');
      if (mounted)

        setState(() {
          _loading = false;
          _error = _t('care_error');
        });
    }
  }

  Future<void> _accept() async {
    final id = _regimenId;
    if (id == null) return;
    final resp = await CarePlanningService.instance.accept(id);
    if (!mounted) return;
    if (resp.succeeded) {
      setState(() => _regimenStatus = 'accepted');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_t('care_accepted'))));
      context.goNamed('Routine');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_t('care_error'))));
    }
  }

  // ── Данные для секций ────────────────────────────────────────────────────

  List<dynamic> _active(String part) => _prescriptions
      .where((p) =>
          p['status'] == 'active' &&
          ((p['directive']?['part_of_day'] ?? 'any') == part ||
              (p['directive']?['part_of_day'] ?? 'any') == 'any'))
      .toList();

  List<dynamic> get _queued =>
      _prescriptions.where((p) => p['status'] == 'queued').toList();

  String _reasonLabel(String? reason) {
    if (reason == null) return '';
    if (reason.startsWith('duplicate_active')) return _t('care_reason_duplicate');
    if (reason == 'preference_fragrance_free') {
      return _t('care_reason_pref_fragrance');
    }
    if (reason == 'preference_max_steps') return _t('care_reason_pref_steps');
    return reason;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _t('care_review_title'),
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: Colors.black,
            letterSpacing: 0,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _compose)
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        children: [
                          if (_warnings.isNotEmpty) ...[
                            ..._warnings.map((w) => _WarningCard(
                                  warning: w,
                                  productName: _images[w['product_id']]
                                      ?.productName,
                                )),
                            const SizedBox(height: 16),
                          ],
                          _Section(
                            title: _t('cb_sec_am'),
                            icon: Icons.wb_sunny_rounded,
                            items: _active('am'),
                            images: _images,
                            primary: theme.primary,
                            freqTemplate: _t('care_freq_week'),
                          ),
                          const SizedBox(height: 20),
                          _Section(
                            title: _t('cb_sec_pm'),
                            icon: Icons.nightlight_round,
                            items: _active('pm'),
                            images: _images,
                            primary: theme.primary,
                            freqTemplate: _t('care_freq_week'),
                          ),
                          if (_queued.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              _t('care_queue_title'),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _t('care_queue_sub'),
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            ..._queued.map((p) => _QueuedCard(
                                  prescription: p,
                                  image: _images[p['image_id']],
                                  reason:
                                      _reasonLabel(p['status_reason'] as String?),
                                )),
                          ],
                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: _loading || _error != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: AppButton(
                  label: _regimenStatus == 'accepted'
                      ? _t('care_accepted')
                      : _t('care_accept'),
                  onPressed: _regimenStatus == 'proposed' ? _accept : null,
                ),
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.items,
    required this.images,
    required this.primary,
    required this.freqTemplate,
  });
  final String title;
  final IconData icon;
  final List<dynamic> items;
  final Map<int, ImagesRow> images;
  final Color primary;
  final String freqTemplate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((p) {
          final img = images[p['image_id']];
          final days = (p['directive']?['days_per_week'] as num?)?.toInt() ?? 7;
          return _PrescriptionCard(
            prescription: p,
            image: img,
            primary: primary,
            freqLabel: days >= 7
                ? null
                : freqTemplate.replaceAll('{n}', '$days'),
          );
        }),
      ],
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({
    required this.prescription,
    required this.image,
    required this.primary,
    required this.freqLabel,
  });
  final dynamic prescription;
  final ImagesRow? image;
  final Color primary;
  final String? freqLabel;

  @override
  Widget build(BuildContext context) {
    final sortOrder = prescription['sort_order'];
    return GestureDetector(
      onTap: () => _showRationale(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Row(
          children: [
            if (sortOrder != null) ...[
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$sortOrder',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (image != null && image!.imageUrl.isNotEmpty)
                  ? Image.network(image!.imageUrl,
                      width: 44, height: 44, fit: BoxFit.cover)
                  : Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFFF2F2F2),
                      child: const Icon(Icons.spa_outlined,
                          color: Colors.black38, size: 20),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                prescription['title'] ?? '—',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (freqLabel != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  freqLabel!,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.chevron_right_rounded, color: Colors.black26),
            ),
          ],
        ),
      ),
    );
  }

  void _showRationale(BuildContext context) {
    final rationale = prescription['rationale'] as Map? ?? {};
    final directive = prescription['directive'] as Map? ?? {};
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prescription['title'] ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 12),
              if ((rationale['summary'] ?? '').toString().isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rationale['summary'].toString(),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in (prescription['active_classes'] as List? ?? []))
                    Chip(
                      label: Text(c.toString()),
                      visualDensity: VisualDensity.compact,
                    ),
                  if ((directive['avoid_same_day'] as List? ?? []).isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.swap_horiz_rounded, size: 16),
                      label: Text(
                        (directive['avoid_same_day'] as List).join(', '),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueuedCard extends StatelessWidget {
  const _QueuedCard({
    required this.prescription,
    required this.image,
    required this.reason,
  });
  final dynamic prescription;
  final ImagesRow? image;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: 0.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (image != null && image!.imageUrl.isNotEmpty)
                  ? Image.network(image!.imageUrl,
                      width: 40, height: 40, fit: BoxFit.cover)
                  : Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFFF2F2F2),
                      child: const Icon(Icons.spa_outlined,
                          color: Colors.black38, size: 18),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prescription['title'] ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (reason.isNotEmpty)
                  Text(
                    reason,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12.5),
                  ),
              ],
            ),
          ),
          const Icon(Icons.schedule_rounded, color: Colors.black26, size: 20),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.warning, required this.productName});
  final dynamic warning;
  final String? productName;

  /// Localize the knowledge-rule explanation by its subject (active class /
  /// formulation property). The backend `explanation` is English-only static
  /// data; the subject is a stable key. Falls back to the raw explanation for
  /// any subject without a localized string yet.
  String _localizedExplanation(BuildContext context) {
    const keys = {
      'retinoid': 'warn_expl_retinoid',
      'hydroquinone': 'warn_expl_hydroquinone',
      'arbutin': 'warn_expl_arbutin',
      'bha': 'warn_expl_bha',
      'fragrance': 'warn_expl_fragrance',
      'drying_alcohols': 'warn_expl_drying_alcohols',
      'fungal_triggers': 'warn_expl_fungal_triggers',
    };
    if (warning['kind']?.toString() == 'missing_spf') {
      return FFLocalizations.of(context).getText('warn_missing_spf');
    }
    final subject = warning['subject']?.toString();
    final key = subject != null ? keys[subject] : null;
    if (key != null) return FFLocalizations.of(context).getText(key);
    return warning['explanation']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final severity = warning['severity']?.toString() ?? 'advisory';
    final (bg, fg, icon) = switch (severity) {
      'hard' => (const Color(0xFFFDECEA), const Color(0xFFC62828),
          Icons.error_rounded),
      'strong' => (const Color(0xFFFFF4E5), const Color(0xFFE65100),
          Icons.warning_rounded),
      _ => (const Color(0xFFF3F4F6), const Color(0xFF6B7280),
          Icons.info_rounded),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (productName != null && productName!.isNotEmpty)
                  Text(
                    productName!,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                Text(
                  _localizedExplanation(context),
                  style: TextStyle(color: fg, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: FFLocalizations.of(context).getText('care_retry'),
              fullWidth: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
