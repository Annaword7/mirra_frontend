import '/design_system/foundations/layout.dart';
import '/design_system/foundations/image_thumb.dart';
import '/design_system/components/screen_loader.dart';
import '/backend/supabase/database/database.dart';
import '/design_system/components/app_button.dart';
import '/domain/care_planning/care_planning_service.dart';
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
  List<dynamic> _goalCoverage = const [];
  Map<String, dynamic> _review = const {};
  Map<int, ImagesRow> _images = {};
  /// null — пользователь ещё не трогал раздел замечаний (по умолчанию он
  /// раскрыт только при противопоказании).
  bool? _warningsExpanded;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _compose();
    });
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  Future<void> _applyRegimen({
    required String? regimenId,
    required String status,
    required List<dynamic> prescriptions,
    required List<dynamic> warnings,
    List<dynamic> goalCoverage = const [],
    Map<String, dynamic>? review,
  }) async {
    // Плюс продукты из предупреждений: исключённые противопоказанием не стали
    // назначениями, но их название нужно показать в замечании.
    final ids = [
      ...prescriptions.map((p) => p['image_id']),
      ...warnings.map((w) => w['product_id']),
    ].whereType<int>().toSet().toList();
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
      _goalCoverage = goalCoverage;
      _review = review ?? const {};
      _loading = false;
    });
  }

  /// Набор = содержимое Косметички (курируемое «чем я пользуюсь») — image_ids
  /// не передаём, сервер берёт bag_items сам. Команда идемпотентна: при
  /// неизменном составе сервер отдаёт уже собранный режим, поэтому повторное
  /// открытие разбора ничего не пересчитывает.
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
      // Режим мог быть пересобран — сводка совместимости в Косметичке
      // перестала быть актуальной.
      CarePlanningService.instance.invalidateCare();
      final map = (resp.jsonBody as Map).cast<String, dynamic>();
      await _applyRegimen(
        regimenId: map['regimen_id'] as String?,
        status: (map['status'] as String?) ?? 'proposed',
        prescriptions: (map['prescriptions'] as List?) ?? const [],
        warnings: (map['warnings'] as List?) ?? const [],
        goalCoverage: (map['goal_coverage'] as List?) ?? const [],
        review: (map['review'] as Map?)?.cast<String, dynamic>(),
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
      CarePlanningService.instance.invalidateCare();
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

  /// Средства сеанса: с директивой на эту часть дня либо «в любое время».
  /// Порядок нанесения — sort_order (инвариант 9 с сервера).
  List<dynamic> _sessionProducts(String part) {
    final items = _activePrescriptions
        .where((p) =>
            (p['directive']?['part_of_day'] ?? 'any') == part ||
            (p['directive']?['part_of_day'] ?? 'any') == 'any')
        .toList();
    items.sort((a, b) =>
        ((a['sort_order'] as num?) ?? 0).compareTo((b['sort_order'] as num?) ?? 0));
    return items;
  }

  /// «3×/нед» для средств реже ежедневного; для ежедневных частота не пишется.
  String? _freqLabel(dynamic p) {
    final days = (p['directive']?['days_per_week'] as num?)?.toInt() ?? 7;
    if (days >= 7) return null;
    return _t('care_freq_week').replaceAll('{n}', '$days');
  }

  List<dynamic> get _queued =>
      _prescriptions.where((p) => p['status'] == 'queued').toList();

  String _reasonLabel(String? reason) {
    if (reason == null) return '';
    if (reason.startsWith('duplicate_active')) return _t('care_reason_duplicate');
    if (reason.startsWith('duplicate_base_step')) {
      return _t('care_reason_base_step');
    }
    if (reason == 'preference_fragrance_free') {
      return _t('care_reason_pref_fragrance');
    }
    if (reason == 'preference_max_steps') return _t('care_reason_pref_steps');
    return reason;
  }

  // ── Смысловые блоки разбора ───────────────────────────────────────────────

  List<dynamic> get _activePrescriptions =>
      _prescriptions.where((p) => p['status'] == 'active').toList();

  /// Миниатюра средства по image_id (фото пользователя, иначе каталожное).
  ///
  /// Рамка вертикальная (3:4, см. [kThumbAspect]): снимки продуктов — вытянутые
  /// вертикали вплоть до 1:2, и в квадрате они либо обрезались до неузнаваемого
  /// фрагмента, либо вписывались тонкой полоской. В вертикальной рамке обрезка
  /// съедает пустой фон сверху и снизу, а сам флакон занимает всю миниатюру.
  Widget _thumb(int? id, {double size = 44, bool dim = false}) {
    final img = id == null ? null : _images[id];
    final url = img == null
        ? ''
        : (img.imageUrl.isNotEmpty ? img.imageUrl : (img.catalogImageUrl ?? ''));
    final width = size * kThumbAspect;
    Widget child = url.isNotEmpty
        ? Image(
            image: thumbProvider(url, width: 200),
            width: width,
            height: size,
            fit: BoxFit.cover,
          )
        : Container(
            width: width,
            height: size,
            color: const Color(0xFFF2F2F2),
            child: const Icon(Icons.spa_outlined,
                color: Colors.black38, size: 20),
          );
    Widget w = ClipRRect(borderRadius: BorderRadius.circular(10), child: child);
    return dim ? Opacity(opacity: 0.45, child: w) : w;
  }

  Widget _thumbRow(List<int> ids, {bool dim = false, double size = 44}) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: ids.map((id) => _thumb(id, size: size, dim: dim)).toList(),
      );

  static const _goalKeys = {
    'acne': 'cb_goal_acne',
    'pigmentation': 'cb_goal_pigmentation',
    'barrier': 'cb_goal_barrier',
    'anti_aging': 'cb_goal_anti_aging',
    'hydration': 'cb_goal_hydration',
    'pores': 'cb_goal_pores',
  };
  String _goalLabel(String g) {
    final k = _goalKeys[g];
    return k != null ? _t(k) : g;
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 17)),
      );

  /// Цели, которые набор закрывает: цель → средства. Незакрытые цели живут в
  /// «Чего не хватает», здесь не дублируются.
  Widget _goalsBlock() {
    final covered = _goalCoverage.where((g) => g['covered'] == true).toList();
    if (covered.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(_t('cb_sec_goals')),
          ...covered.map((g) {
            final ids = ((g['product_ids'] as List?) ?? const [])
                .map((e) => e is int ? e : int.tryParse('$e'))
                .whereType<int>()
                .toList();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: Color(0xFF1B5E20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_goalLabel('${g['goal']}'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 6),
                        _thumbRow(ids, size: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Балл совместимости (детерминированный) плюс резюме разбора — если бэкенд
  /// успел его написать; без резюме карточка остаётся осмысленной.
  Widget _scoreCard(FlutterFlowTheme theme) {
    final score = (_review['score'] as num?)?.toInt();
    if (score == null) return const SizedBox.shrink();
    final level = (_review['level'] ?? 'good').toString();
    final (accent, levelKey) = switch (level) {
      'conflict' => (const Color(0xFFC62828), 'cb_level_conflict'),
      'caution' => (const Color(0xFFE65100), 'cb_level_caution'),
      _ => (const Color(0xFF1B5E20), 'cb_level_good'),
    };
    final summary = (_review['summary'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$score',
                  style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 34,
                      height: 1.1)),
              const Padding(
                padding: EdgeInsets.only(left: 2, bottom: 4),
                child: Text('/100',
                    style: TextStyle(color: Colors.black38, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t('cb_compat_title'),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                    Text(_t(levelKey),
                        style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(summary,
                style: const TextStyle(
                    color: Colors.black87, fontSize: 14, height: 1.35)),
          ],
        ],
      ),
    );
  }

  /// Сеанс ухода: средства в порядке нанесения с частотой. Никаких эффектов —
  /// разбор отвечает на «что и когда», а не «как работает каждый ингредиент».
  Widget _sessionBlock(String part, FlutterFlowTheme theme) {
    final items = _sessionProducts(part);
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(part == 'am' ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: theme.primary, size: 20),
              const SizedBox(width: 8),
              Text(_t(part == 'am' ? 'cb_sec_am' : 'cb_sec_pm'),
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 17)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((e) => _SessionItem(
                step: e.key + 1,
                title: (e.value['title'] ?? '—').toString(),
                freqLabel: _freqLabel(e.value),
                thumb: _thumb(e.value['image_id'] as int?),
                primary: theme.primary,
              )),
        ],
      ),
    );
  }

  /// Пробелы набора: базовые шаги и незакрытые цели (коды с сервера).
  Widget _gapsBlock() {
    final gaps = (_review['gaps'] as List?) ?? const [];
    if (gaps.isEmpty) return const SizedBox.shrink();
    String label(dynamic g) {
      final subject = '${g['subject']}';
      if (g['kind'] == 'goal') {
        return _t('cb_gap_goal').replaceAll('{goal}', _goalLabel(subject));
      }
      return switch (subject) {
        'cleanser' => _t('cb_gap_cleanser'),
        'moisturizer' => _t('cb_gap_moisturizer'),
        'sunscreen' => _t('cb_gap_sunscreen'),
        _ => subject,
      };
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(_t('cb_sec_gaps')),
          ...gaps.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.remove_circle_outline,
                        size: 18, color: Colors.black38),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(label(g),
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 14)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Советы: текст с бэкенда, а если его нет (сбой генерации) — те же выводы,
  /// собранные из кодов совета локально.
  List<String> _adviceLines() {
    final advice = ((_review['advice'] as List?) ?? const [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    if (advice.isNotEmpty) return advice;

    String titleOf(dynamic id) =>
        _prescriptions.firstWhere((p) => p['image_id'] == id,
            orElse: () => const {})['title']?.toString() ??
        '';
    final out = <String>[];
    for (final t in (_review['tips'] as List?) ?? const []) {
      final ids = ((t['product_ids'] as List?) ?? const []).toList();
      switch ('${t['kind']}') {
        case 'alternate':
        case 'combine':
          if (ids.length < 2) break;
          out.add(_t(t['kind'] == 'alternate'
                  ? 'cb_tip_alternate'
                  : 'cb_tip_combine')
              .replaceAll('{a}', titleOf(ids[0]))
              .replaceAll('{b}', titleOf(ids[1])));
        case 'spf_daily':
          out.add(_t('cb_tip_spf_daily'));
        case 'introduce_one':
          out.add(_t('cb_tip_introduce_one'));
      }
    }
    return out;
  }

  Widget _adviceBlock(FlutterFlowTheme theme) {
    final lines = _adviceLines();
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(_t('cb_sec_tips')),
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        size: 16, color: theme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(line,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.35)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  (Color, Color, IconData) _sevStyle(String severity) => switch (severity) {
        'hard' => (const Color(0xFFFDECEA), const Color(0xFFC62828),
            Icons.error_rounded),
        'strong' => (const Color(0xFFFFF4E5), const Color(0xFFE65100),
            Icons.warning_rounded),
        _ => (const Color(0xFFF3F4F6), const Color(0xFF6B7280),
            Icons.info_rounded),
      };

  /// Локализованный текст предупреждения по subject правила (fallback — сырой
  /// explanation с бэкенда).
  String _warnText(dynamic w) {
    if (w['kind']?.toString() == 'missing_spf') {
      return _t('warn_missing_spf');
    }
    // Взаимодействие активов: у правила нет subject — текст собирается из пары
    // классов, иначе с бэкенда пришёл бы английский explanation.
    if (w['kind']?.toString() == 'interaction_warn') {
      final classes = ((w['classes'] as List?) ?? const [])
          .map((c) => _classLabel(c.toString()))
          .toList();
      if (classes.length >= 2) {
        return _t('cb_warn_interaction')
            .replaceAll('{a}', classes[0])
            .replaceAll('{b}', classes[1]);
      }
    }
    const keys = {
      'retinoid': 'warn_expl_retinoid',
      'hydroquinone': 'warn_expl_hydroquinone',
      'arbutin': 'warn_expl_arbutin',
      'bha': 'warn_expl_bha',
      'fragrance': 'warn_expl_fragrance',
      'drying_alcohols': 'warn_expl_drying_alcohols',
      'fungal_triggers': 'warn_expl_fungal_triggers',
    };
    final subject = w['subject']?.toString();
    final key = subject != null ? keys[subject] : null;
    if (key != null) return _t(key);
    return w['explanation']?.toString() ?? '';
  }

  /// Название класса актива для текста замечания.
  String _classLabel(String cls) {
    const keys = {
      'aha': 'cb_class_aha',
      'pha': 'cb_class_pha',
      'bha': 'cb_concern_bha',
      'vitamin_c': 'cb_class_vitamin_c',
      'niacinamide': 'cb_class_niacinamide',
      'benzoyl_peroxide': 'cb_class_benzoyl_peroxide',
      'azelaic': 'cb_class_azelaic',
      'retinoid': 'cb_concern_retinoid',
      'hydroquinone': 'cb_concern_hydroquinone',
      'arbutin': 'cb_concern_arbutin',
    };
    final key = keys[cls];
    return key != null ? _t(key) : cls;
  }

  static const _severityRank = {'hard': 0, 'strong': 1, 'advisory': 2};

  int _rankOf(List<dynamic> group) => group
      .map((w) => _severityRank[(w['severity'] ?? 'advisory').toString()] ?? 2)
      .reduce((a, b) => a < b ? a : b);

  String _severityOf(List<dynamic> group) =>
      _severityRank.entries.firstWhere((s) => s.value == _rankOf(group)).key;

  /// Замечания разбора — один сворачиваемый раздел: шапка в цвете самого
  /// строгого замечания, внутри группы по средствам (и группа уровня набора:
  /// нет SPF, взаимодействия активов). Раздел раскрыт сразу, если есть
  /// противопоказание — прятать его за тапом нельзя.
  Widget _warningsBlock() {
    if (_warnings.isEmpty) return const SizedBox.shrink();
    final groups = <Object, List<dynamic>>{};
    for (final w in _warnings) {
      final key = w['product_id'] is int ? w['product_id'] as int : 'general';
      groups.putIfAbsent(key, () => []).add(w);
    }
    final entries = groups.entries.toList()
      ..sort((a, b) => _rankOf(a.value).compareTo(_rankOf(b.value)));
    final (bg, fg, icon) = _sevStyle(_severityOf(_warnings));
    final expanded = _warningsExpanded ?? _severityOf(_warnings) == 'hard';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _warningsExpanded = !expanded),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_t('cb_sec_warnings')} · ${_warnings.length}',
                        style: TextStyle(
                            color: fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: fg,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.map((e) {
                  final product =
                      e.key is int ? _images[e.key]?.productName : null;
                  return _WarningGroup(
                    title: (product != null && product.isNotEmpty)
                        ? product
                        : _t('cb_warn_general'),
                    texts:
                        e.value.map(_warnText).where((t) => t.isNotEmpty).toList(),
                    style: _sevStyle(_severityOf(e.value)),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
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
          ? const ScreenLoader(hasAppBar: true)
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _compose)
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        children: [
                          _scoreCard(theme),
                          _warningsBlock(),
                          _sessionBlock('am', theme),
                          _sessionBlock('pm', theme),
                          _gapsBlock(),
                          _adviceBlock(theme),
                          _goalsBlock(),
                          if (_queued.isNotEmpty) ...[
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

/// Замечания одного средства (или всего набора) под его названием.
class _WarningGroup extends StatelessWidget {
  const _WarningGroup({
    required this.title,
    required this.texts,
    required this.style,
  });
  final String title;
  final List<String> texts;
  final (Color, Color, IconData) style;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = style;
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
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                ...texts.map((t) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(t,
                          style: TextStyle(
                              color: fg, fontSize: 13, height: 1.35)),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Шаг сеанса: порядок нанесения, средство, частота. Без эффектов и разборов —
/// они живут на карточке продукта, не здесь.
class _SessionItem extends StatelessWidget {
  const _SessionItem({
    required this.step,
    required this.title,
    required this.freqLabel,
    required this.thumb,
    required this.primary,
  });
  final int step;
  final String title;
  final String? freqLabel;
  final Widget thumb;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text('$step',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          thumb,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                if (freqLabel != null) ...[
                  const SizedBox(height: 3),
                  Text(freqLabel!,
                      style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
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
                  ? Image(
                      image: thumbProvider(image!.imageUrl, width: 200),
                      width: 40 * kThumbAspect,
                      height: 40,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 40 * kThumbAspect,
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
