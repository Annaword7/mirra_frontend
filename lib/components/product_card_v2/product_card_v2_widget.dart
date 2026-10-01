import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/score_breakdown/score_breakdown_widget.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/design_system/components/selectable_row.dart';
import '/design_system/components/settings_row.dart';
import '/item_card/ingridients/ingridients_widget.dart';
import '/paywall/show_paywall.dart';

/// Product card v2: карточка, в которой вывод делает читатель.
///
/// Порядок блоков повторяет путь мысли человека, который только что
/// отсканировал СВОЙ продукт (документ V, состояния S0–S6):
///  1. правило: состав с подсветкой, подсказками по тапу и линией 1 % —
///     «порядок показывает количество»
///  2. чего ожидать: один список эффектов — обещания с упаковки, неозвученные
///     плюсы (goal_support) и неозвученные минусы (замечания). Зелёный =
///     позитивный и подкреплённый составом, красный = негативный или обещанный
///     без подтверждения; тап раскрывает компоненты
///  3. пауза: одна фраза, снимающая вину («дело в составе, не в вашей коже»)
///  4. почему этому можно верить: честность разбора, нейтральность — и только
///     здесь кольцо со скором, оси (свёрнуты) и «спросить карточку»
///  5. кому подходит, кому нет: тип кожи, предупреждения с адресатами,
///     беременность, SPF
///  6. следующая баночка: сканировать ещё / на полку
///  7. «разбор глубже»: доза против MEC для всех активов, информационные
///     замечания, уверенность целиком и всё, что передали в [deepExtras]
///
/// Ни один блок не говорит «продукт не работает»: только позиция, доза, порог.
/// Слово «M!RRA» впервые звучит в блоке 4. Скор не поднимается выше него.
///
/// Тап по типу кожи — эфемерный просмотр: пересобирает вердикт локально и
/// никогда не пишет в профиль (онбординг — единственный источник правды).
class ProductCardV2Widget extends StatefulWidget {
  const ProductCardV2Widget({
    super.key,
    required this.image,
    required this.skinCompatibility,
    required this.topIngredients,
    required this.ingredientIssues,
    this.userSkinType,
    this.userIsSensitive = false,
    this.userIsAcneProne = false,
    this.isPro = false,
    this.pregnancyRelevant = false,
    this.profileCta,
    this.spfBlock,
    this.deepExtras = const [],
    this.onScanNext,
    this.onToggleBag,
    this.inBag = false,
    this.bagCount,
  });

  final ImagesRow image;
  final List<ImageSkinCompatibilityRow> skinCompatibility;
  final List<ImageTopIngredientsRow> topIngredients;
  final List<ImageIngredientIssuesRow> ingredientIssues;

  /// Skin type from the user's onboarding profile (null = cold start).
  final String? userSkinType;

  /// Sensitivity / acne flags from onboarding — surface warnings addressed to
  /// 'sensitive' / 'acne_prone' even when a different skin-type row is selected.
  final bool userIsSensitive;
  final bool userIsAcneProne;

  /// Whether the pro layer (full MEC table, confidence, deep extras) is visible
  /// and how many questions the card answers.
  final bool isPro;

  /// В профиле указана беременность или кормление. Спокойный вердикт («можно»)
  /// показываем только им — остальным он отвечает на незаданный вопрос. А вот
  /// предупреждение видно всем независимо от профиля: прятать риск нельзя.
  final bool pregnancyRelevant;

  /// Приглашение заполнить профиль. Стоит в блоке «кому подходит»: вопрос
  /// «а для какой кожи?» к этому моменту уже возник, и просьба уместна.
  final Widget? profileCta;

  /// Блок SPF от хозяина экрана — тоже «для кого», живёт в блоке фита.
  final Widget? spfBlock;

  /// Блоки, уезжающие внутрь «Разбора глубже» (состав с подсветкой, экспертный
  /// текст, «как использовать»). Хозяин экрана решает, что туда сложить.
  final List<Widget> deepExtras;

  /// Действия блока «следующая баночка». null — блок не показывается.
  final VoidCallback? onScanNext;
  final Future<void> Function()? onToggleBag;
  final bool inBag;
  final int? bagCount;

  @override
  State<ProductCardV2Widget> createState() => _ProductCardV2WidgetState();
}

class _ProductCardV2WidgetState extends State<ProductCardV2Widget> {
  /// Ephemeral viewing context: starts from the profile, changed by taps.
  /// Never persisted — a cosmetologist can flip through types per client.
  String? _selectedSkinType;
  bool _proExpanded = false;

  /// Методика проверки на беременность раскрыта (по умолчанию — ссылкой).
  bool _pregHowExpanded = false;

  /// «Спросить карточку»: один диалог на карточку, в памяти виджета.
  final TextEditingController _askController = TextEditingController();
  String? _askAnswer;
  Set<String> _askCited = const {};
  bool _askLoading = false;
  bool _askError = false;
  int _askCount = 0;

  /// Set once the user taps a matrix row. After that, an async profile load
  /// must not override their manual preview (onboarding stays the cold-start
  /// default; taps are ephemeral and win locally).
  bool _userTouchedMatrix = false;

  static const int _freeQuestions = 3;

  @override
  void initState() {
    super.initState();
    _selectedSkinType = widget.userSkinType;
  }

  @override
  void didUpdateWidget(covariant ProductCardV2Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Profile may arrive after the first build (loaded asynchronously on the
    // page). Adopt it as the viewing context only until the user previews a
    // type manually.
    if (widget.userSkinType != oldWidget.userSkinType && !_userTouchedMatrix) {
      _selectedSkinType = widget.userSkinType;
    }
  }

  @override
  void dispose() {
    _askController.dispose();
    super.dispose();
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  String _skinTypeLabel(String skinType) {
    final label = _t('skin_$skinType');
    return label.isEmpty ? skinType : label;
  }

  String _claimLabel(String claimKey) {
    final l = _t('cardv2_claim_$claimKey');
    return l.isEmpty ? claimKey : l;
  }

  // ── Severity / fit palette (single light theme; the app has no dark mode) ──
  static const Color _goodColor = Color(0xFF1B5E20); // green
  static const Color _warnColor = Color(0xFFFFB300); // amber
  static const Color _badColor = Color(0xFFD32F2F); // red

  Color _fitColor(int score) {
    if (score >= 75) return _goodColor;
    if (score >= 60) return _warnColor;
    return _badColor;
  }

  // ── Text style helpers for the new blocks ─────────────────────────────────

  TextStyle _section(FlutterFlowTheme t) => t.labelMedium.override(
        fontFamily: t.labelMediumFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        useGoogleFonts: !t.labelMediumIsCustom,
      );

  TextStyle _body(FlutterFlowTheme t,
          {double size = 14, FontWeight? weight, Color? color}) =>
      t.bodyMedium.override(
        fontFamily: t.bodyMediumFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.0,
        useGoogleFonts: !t.bodyMediumIsCustom,
      );

  TextStyle _small(FlutterFlowTheme t, {Color? color, FontWeight? weight}) =>
      t.bodySmall.override(
        fontFamily: t.bodySmallFamily,
        color: color ?? t.secondaryText,
        fontWeight: weight,
        letterSpacing: 0.0,
        useGoogleFonts: !t.bodySmallIsCustom,
      );

  Widget _sectionTitle(FlutterFlowTheme t, String text) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
        child: Text(text, style: _section(t)),
      );

  // ── Derived data ──────────────────────────────────────────────────────────

  ImageSkinCompatibilityRow? get _selectedRow {
    if (_selectedSkinType == null) return null;
    for (final row in widget.skinCompatibility) {
      if (row.skinType == _selectedSkinType) return row;
    }
    return null;
  }

  /// Warnings relevant to the selected skin type; all warnings on cold start.
  List<ImageIngredientIssuesRow> get _visibleWarnings {
    final issues = widget.ingredientIssues
        .where((i) => i.relevantFor.isNotEmpty) // [] = informational (pro only)
        .toList();
    final type = _selectedSkinType;
    if (type == null) return issues; // cold start — show all
    return issues.where((i) {
      final rf = i.relevantFor;
      return rf.contains('all') ||
          rf.contains(type) ||
          (widget.userIsSensitive && rf.contains('sensitive')) ||
          (widget.userIsAcneProne && rf.contains('acne_prone'));
    }).toList();
  }

  Map<String, dynamic> get _confidence {
    final raw = widget.image.saConfidence;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  List<Map<String, dynamic>> get _claimAudit {
    final raw = widget.image.saClaimAudit;
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  /// INCI positions in order. Prefers the backend's pre-parsed array (which
  /// keeps multi-part names like "1,2-Hexanediol" intact); falls back to a
  /// client split that does NOT break on the comma inside "1,2-…"/"2,3-…".
  List<String> get _inciList {
    final stored = widget.image.saInciList;
    if (stored.isNotEmpty) {
      return stored.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return (widget.image.ingredients ?? '')
        .split(RegExp(r',(?!\s*\d)|\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  int? get _linePos => widget.image.saOnePercentLinePos;

  static bool _sameIngredient(String a, String b) {
    final x = a.toLowerCase().trim();
    final y = b.toLowerCase().trim();
    if (x.isEmpty || y.isEmpty) return false;
    return x == y || x.contains(y) || y.contains(x);
  }

  /// Позиция по имени в самом списке состава — та же, что видит человек в
  /// блоке выше. Точное совпадение важнее частичного.
  int? _positionByName(String name) {
    final inci = _inciList;
    final key = name.toLowerCase().trim();
    for (var i = 0; i < inci.length; i++) {
      if (inci[i].toLowerCase().trim() == key) return i + 1;
    }
    for (var i = 0; i < inci.length; i++) {
      if (_sameIngredient(inci[i], name)) return i + 1;
    }
    return null;
  }

  ImageTopIngredientsRow? _activeByName(String name) {
    for (final ing in widget.topIngredients) {
      if (_sameIngredient(ing.ingredientName, name)) return ing;
    }
    return null;
  }

  /// evidence из claim audit / goal support: объекты {ingredient, position,
  /// status}; старые анализы могли хранить просто строки.
  static List<_Evidence> _parseEvidence(dynamic raw) {
    if (raw is! List) return const [];
    final out = <_Evidence>[];
    for (final e in raw) {
      if (e is String && e.trim().isNotEmpty) {
        out.add(_Evidence(name: e.trim()));
      } else if (e is Map) {
        final n = e['ingredient'] ?? e['name'];
        if (n is String && n.trim().isNotEmpty) {
          out.add(_Evidence(
            name: n.trim(),
            position: (e['position'] as num?)?.toInt(),
            status: e['status'] as String?,
          ));
        }
      }
    }
    // Рабочие — первыми: именно они объясняют эффект.
    out.sort((a, b) => a.rank.compareTo(b.rank));
    return out;
  }

  /// Обещание с упаковки → компоненты, которые должны его выполнять.
  List<_PromiseRow> get _promiseRows => [
        for (final claim in _claimAudit)
          _PromiseRow(
            claimKey: claim['claim'] as String? ?? '',
            verdict: claim['verdict'] as String? ?? 'unsupported',
            evidence: _parseEvidence(claim['evidence']),
          ),
      ];

  /// Обещанный компонент ниже рабочей дозы — герой паузы и подсказки.
  String? get _weakPromisedName {
    for (final status in const ['decorative', 'borderline']) {
      for (final row in _promiseRows) {
        for (final e in row.evidence) {
          if ((e.status ?? _activeByName(e.name)?.status) == status) {
            return e.name;
          }
        }
      }
    }
    if (_claimAudit.isEmpty) {
      // Обещаний нет — любой декоративный актив всё равно объясняет прошлое.
      for (final ing in widget.topIngredients) {
        if (ing.status == 'decorative') return ing.ingredientName;
      }
    }
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final pause = _buildPause(theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRule(theme),
        _buildExpectations(theme),
        if (pause != null) pause,
        _buildTrustAndVerdict(theme),
        _buildFitGroup(theme),
        if (widget.onScanNext != null || widget.onToggleBag != null)
          _buildNextBottle(theme),
        if (widget.isPro) _buildProLayer(theme),
      ],
    );
  }

  // ── 1. Правило: состав с линией 1 % ───────────────────────────────────────

  /// Один список вместо колбы и нумерации: тот же поток INCI с подсветкой,
  /// но каждый ингредиент нажимается, обещанные активы помечены, первый из них
  /// раскрыт сразу, а линия 1 % проведена прямо в списке.
  Widget _buildRule(FlutterFlowTheme theme) {
    final inci = _inciList;
    if (inci.isEmpty) return const SizedBox.shrink();

    final promised = <String, String>{};
    String? firstPromised;
    for (final row in _promiseRows) {
      for (final e in row.evidence) {
        promised.putIfAbsent(
            e.name.toLowerCase().trim(), () => _claimLabel(row.claimKey));
        firstPromised ??= e.name;
      }
    }
    // Раскрыт по умолчанию компонент ниже дозы, если такой есть: с него
    // начинается вовлечение. Иначе — первый обещанный.
    final initial = _weakPromisedName ?? firstPromised;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: IngridientsWidget(
        inci: inci,
        linePos: _linePos,
        lineMarker: widget.image.saOnePercentLineMarker,
        topIngredients: widget.topIngredients,
        issues: widget.ingredientIssues,
        promised: promised,
        citedNames: _askCited,
        initiallySelected: initial,
      ),
    );
  }

  // ── 2. Чего ожидать ──────────────────────────────────────────────

  /// Обещание с упаковки → цель, которую движок считает в goal_support.
  static const _claimToGoal = {
    'hydration': 'hydration',
    'barrier': 'barrier',
    'anti_aging_lifting': 'anti_aging',
    'brightening': 'pigmentation',
    'pores': 'pores',
    'acne': 'acne',
  };

  Map<String, Map<String, dynamic>> get _goalSupport {
    final raw = widget.image.saGoalSupport;
    if (raw is! Map) return const {};
    return {
      for (final e in raw.entries)
        if (e.value is Map)
          '${e.key}': Map<String, dynamic>.from(e.value as Map),
    };
  }

  String _goalLabel(String goal) {
    final l = _t('cb_goal_$goal');
    return l.isEmpty ? goal : l;
  }

  /// Чего можно ждать сверх обещанного: цели, которые формула поддерживает
  /// (goal_support ≥ 50), но упаковка о них молчит.
  List<({String goal, int score, List<String> evidence})> get _unclaimedGoods {
    final claimed = _claimAudit
        .map((c) => _claimToGoal[c['claim']])
        .whereType<String>()
        .toSet();
    final out = <({String goal, int score, List<String> evidence})>[];
    for (final e in _goalSupport.entries) {
      if (claimed.contains(e.key)) continue;
      final score = (e.value['score'] as num?)?.round() ?? 0;
      if (score < 50) continue;
      final ev = _parseEvidence(e.value['evidence'])
          .where((x) => x.status != 'decorative')
          .map((x) => x.name)
          .toList();
      out.add((goal: e.key, score: score, evidence: ev));
    }
    out.sort((a, b) => b.score.compareTo(a.score));
    return out;
  }

  /// Замечание движка → ощущение на коже, о котором упаковка не предупреждает.
  static String? _effectOf(ImageIngredientIssuesRow issue) {
    switch (issue.issueType) {
      case 'comedogenic':
        return 'breakouts';
      case 'irritant':
        // Спирты и жёсткие ПАВ адресованы сухой коже — это сухость; эфирные
        // масла адресованы только чувствительной — это раздражение.
        return issue.relevantFor.contains('dry') ? 'dryness' : 'irritation';
      case 'fragrance':
      case 'allergen':
      case 'formaldehyde_releaser':
        return 'irritation';
      case 'controversial':
        return 'controversial';
      default:
        return null; // informational (eco/regulatory) — не про кожу
    }
  }

  static const _effectOrder = [
    'breakouts',
    'dryness',
    'irritation',
    'controversial',
  ];

  /// Чего не обещали, но видно по составу: замечания, сгруппированные по
  /// эффекту, с компонентами-виновниками и адресатами.
  List<({String effect, List<String> ingredients, Set<String> forWhom})>
      get _unclaimedBads {
    final groups = <String, ({List<String> ingredients, Set<String> forWhom})>{};
    for (final issue in widget.ingredientIssues) {
      if (issue.relevantFor.isEmpty) continue;
      final effect = _effectOf(issue);
      if (effect == null) continue;
      final g = groups.putIfAbsent(
          effect, () => (ingredients: <String>[], forWhom: <String>{}));
      if (!g.ingredients.contains(issue.ingredientName)) {
        g.ingredients.add(issue.ingredientName);
      }
      g.forWhom.addAll(issue.relevantFor);
    }
    return [
      for (final k in _effectOrder)
        if (groups.containsKey(k))
          (
            effect: k,
            ingredients: groups[k]!.ingredients,
            forWhom: groups[k]!.forWhom,
          ),
    ];
  }

  String _forWhomLabel(Set<String> types) => types.contains('all')
      ? _t('cardv2_for_all')
      : types.map(_skinTypeLabel).join(', ');

  /// Раскрытые строки «чего ожидать» (ключ эффекта).
  final Set<String> _expandedEffects = {};

  /// Один список ожиданий. Правило цвета: позитивный и подкреплённый составом —
  /// зелёный; негативный — красный; позитивный, но не подкреплённый (обещание
  /// без компонента в дозе) — тоже красный. Тап раскрывает, какие компоненты
  /// дают эффект, или что подтверждения в составе нет.
  List<_Expectation> get _expectations {
    final total = _inciList.length;
    final linePos = _linePos;
    final out = <_Expectation>[];

    // Обещания с упаковки.
    for (final row in _promiseRows) {
      // Подкреплено — вердикт движка «supported» ИЛИ хотя бы один компонент
      // в рабочей дозе: движок ставит «слабо» одиночному рабочему активу
      // (35 баллов из порога 55), а для читателя рабочая доза и есть
      // подтверждение. Объясняют рабочие компоненты; нет — показываем, что
      // есть, вместе с его позицией и дозой.
      final hasWorking = row.evidence.any((e) =>
          (e.status ?? _activeByName(e.name)?.status) == 'working');
      final backed = row.verdict == 'supported' || hasWorking;
      final shown = backed
          ? row.evidence.where((e) => e.status != 'decorative').toList()
          : row.evidence;
      final lines = <String>[_t('cardv2_expect_claimed')];
      if (shown.isNotEmpty) {
        lines.add(_t('cardv2_reality_thanks')
            .replaceAll('{names}', shown.take(3).map((e) => e.name).join(', ')));
        final best = shown.first;
        final active = _activeByName(best.name);
        final pos = _positionByName(best.name) ?? best.position;
        final status = best.status ?? active?.status;
        final where = <String>[
          if (pos != null)
            _t('cardv2_position_of')
                .replaceAll('{pos}', '$pos')
                .replaceAll('{total}', '$total'),
          if (pos != null && linePos != null)
            pos < linePos
                ? _t('cardv2_layer_above')
                : _t('cardv2_layer_below'),
          if (active?.mec != null)
            _t('cardv2_dose_needed').replaceAll('{mec}', '${active!.mec}'),
          if (status != null) _t('cardv2_status_$status'),
        ];
        if (where.isNotEmpty) lines.add(where.join(' · '));
        if (!backed) {
          lines.add(status == 'decorative'
              ? _t('cardv2_decorative_note')
              : _t('cardv2_verdict_${row.verdict}'));
        }
      } else {
        lines.add(_t('cardv2_expect_not_backed'));
      }
      out.add(_Expectation(
        key: 'claim_${row.claimKey}',
        title: _claimLabel(row.claimKey),
        good: backed,
        lines: lines,
      ));
    }

    // Чего ещё можно ждать: формула умеет, упаковка молчит.
    for (final g in _unclaimedGoods) {
      out.add(_Expectation(
        key: 'goal_${g.goal}',
        title: _goalLabel(g.goal),
        good: true,
        lines: [
          if (g.evidence.isNotEmpty)
            _t('cardv2_reality_thanks')
                .replaceAll('{names}', g.evidence.take(3).join(', ')),
        ],
      ));
    }

    // Чего не обещали, но видно по составу.
    for (final b in _unclaimedBads) {
      out.add(_Expectation(
        key: 'bad_${b.effect}',
        title: _t('cardv2_effect_${b.effect}'),
        good: false,
        lines: [
          _t('cardv2_reality_because')
              .replaceAll('{names}', b.ingredients.take(4).join(', ')),
          '${_t('cardv2_matters_for')} ${_forWhomLabel(b.forWhom)}',
        ],
      ));
    }
    return out;
  }

  Widget _buildExpectations(FlutterFlowTheme theme) {
    final items = _expectations;
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, _t('cardv2_expect_title')),
        for (final e in items) _expectationRow(theme, e),
      ],
    );
  }

  Widget _expectationRow(FlutterFlowTheme theme, _Expectation e) {
    final color = e.good ? _goodColor : _badColor;
    final expanded = _expandedEffects.contains(e.key);
    return InkWell(
      onTap: () => setState(() {
        if (!_expandedEffects.remove(e.key)) _expandedEffects.add(e.key);
      }),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(
                e.good
                    ? Icons.check_circle_rounded
                    : Icons.remove_circle_rounded,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title,
                      style: _body(theme, weight: FontWeight.w600, color: color)),
                  if (expanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final l in e.lines)
                            Text(l, style: _small(theme)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: theme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Пауза ──────────────────────────────────────────────────────────────

  /// Одна фраза без карточки и без цифр. Вариант зависит от блока 2: есть
  /// обещанный актив ниже дозы — снимаем вину; всё в дозе — направляем к фиту.
  Widget? _buildPause(FlutterFlowTheme theme) {
    final weak = _weakPromisedName;
    final String text;
    if (weak != null) {
      text = _t('cardv2_pause_decorative').replaceAll('{active}', weak);
    } else if (_claimAudit.isNotEmpty) {
      text = _t('cardv2_pause_ok');
    } else {
      return null;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 0, 0),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.primary.withOpacity(0.5), width: 2),
          ),
        ),
        child: Text(
          text,
          style: theme.bodyMedium.override(
            fontFamily: theme.bodyMediumFamily,
            fontSize: 15,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodyMediumIsCustom,
          ),
        ),
      ),
    );
  }

  // ── 4. Почему этому можно верить → вердикт → спросить ─────────────────────

  Widget _buildTrustAndVerdict(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, _t('cardv2_trust_title')),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHonesty(theme),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_t('cardv2_neutrality'), style: _small(theme)),
              ),
            ],
          ),
        ),
        _sectionTitle(theme, _t('cardv2_verdict_title')),
        _buildVerdict(theme),
        ScoreBreakdownWidget(
          scoringLog: widget.image.saScoringLog,
          topIngredients: widget.topIngredients,
          ingredientIssues: widget.ingredientIssues,
        ),
        _buildAsk(theme),
      ],
    );
  }

  /// Из чего посчитана оценка: доля разобранного состава, уверенность,
  /// диапазон и первая причина. Полный список причин — в «Разборе глубже».
  Widget _buildHonesty(FlutterFlowTheme theme) {
    final total = widget.image.saIngredientsTotal ?? 0;
    final recognized = widget.image.saIngredientsRecognized ?? 0;
    final conf = _confidence;
    final level = widget.image.saConfidenceLevel ?? '${conf['level'] ?? ''}';
    final range = conf['composite_range'];
    final reasons =
        conf['reasons'] is List ? (conf['reasons'] as List) : const [];

    final parts = <String>[
      if (total > 0)
        _t('cardv2_based_on')
            .replaceAll('{percent}', '${(recognized / total * 100).round()}'),
      if (level.isNotEmpty && _t('cardv2_conf_$level').isNotEmpty)
        '${_t('cardv2_confidence_title')}: ${_t('cardv2_conf_$level')}',
      if (range is List && range.length == 2)
        _t('cardv2_range')
            .replaceAll('{lo}', '${range[0]}')
            .replaceAll('{hi}', '${range[1]}'),
    ];
    if (parts.isEmpty && reasons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parts.isNotEmpty) Text(parts.join(' · '), style: _small(theme)),
        if (reasons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('· ${reasons.first}', style: _small(theme)),
          ),
      ],
    );
  }

  Widget _buildVerdict(FlutterFlowTheme theme) {
    final row = _selectedRow;
    final verdictText = (row?.verdict?.isNotEmpty ?? false)
        ? row!.verdict!
        : (widget.image.saQuickSummary ?? '');
    final fitScore = row?.compatibilityScore ??
        (widget.image.saCompositeScore?.round() ?? 0);
    // Подпись под кольцом называет тип кожи, для которого посчитано число.
    final fitLabel =
        row != null ? _skinTypeLabel(row.skinType) : _t('cardv2_formula');
    final ringColor = _fitColor(fitScore);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.alternate,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              color: ringColor.withOpacity(0.28),
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.10),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated fit ring — re-animates to the new value on every matrix
            // tap (personalized score), never written to the profile.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ringColor.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircularPercentIndicator(
                    radius: 40,
                    lineWidth: 8,
                    percent: (fitScore / 100.0).clamp(0.0, 1.0),
                    backgroundColor: ringColor.withOpacity(0.12),
                    progressColor: ringColor,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animateFromLastPercent: true,
                    center: Text(
                      '$fitScore',
                      style: theme.headlineSmall.override(
                        fontFamily: theme.headlineSmallFamily,
                        color: ringColor,
                        fontSize: 24,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts: !theme.headlineSmallIsCustom,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 92,
                  child: Text(
                    fitLabel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.labelSmall.override(
                      fontFamily: theme.labelSmallFamily,
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.labelSmallIsCustom,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(verdictText, style: _body(theme)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Спросить карточку ─────────────────────────────────────────────────────

  List<String> get _askSuggestions {
    final weak = _weakPromisedName;
    final skin = _selectedSkinType ?? widget.userSkinType ?? 'sensitive';
    return [
      _t('cardv2_ask_q_score'),
      if (weak != null)
        _t('cardv2_ask_q_active').replaceAll('{active}', weak),
      _t('cardv2_ask_q_skin').replaceAll('{skin}', _skinTypeLabel(skin)),
    ];
  }

  bool get _askExhausted => !widget.isPro && _askCount >= _freeQuestions;

  Widget _buildAsk(FlutterFlowTheme theme) {
    final imageId = widget.image.id;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('cardv2_ask_title'), style: _section(theme)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final q in _askSuggestions)
                  ActionChip(
                    label: Text(q, style: _small(theme, color: theme.primaryText)),
                    backgroundColor: theme.alternate,
                    side: BorderSide(color: theme.primary.withOpacity(0.25)),
                    onPressed: _askLoading ? null : () => _ask(imageId, q),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _askController,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 500,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (v) => _ask(imageId, v),
                    style: _body(theme),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: _t('cardv2_ask_hint'),
                      hintStyle: _small(theme),
                      isDense: true,
                      filled: true,
                      fillColor: theme.alternate,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _askLoading
                      ? null
                      : () => _ask(imageId, _askController.text),
                  icon: _askLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: theme.primary),
                        )
                      : Icon(Icons.send_rounded, color: theme.primary),
                  tooltip: _t('cardv2_ask_send'),
                ),
              ],
            ),
            if (_askAnswer != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_askAnswer!, style: _body(theme)),
                    const SizedBox(height: 6),
                    Text(_t('cardv2_ask_disclaimer'), style: _small(theme)),
                  ],
                ),
              ),
            ],
            if (_askError) ...[
              const SizedBox(height: 8),
              Text(_t('cardv2_ask_error'),
                  style: _small(theme, color: _badColor)),
            ],
            if (!widget.isPro) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: _askExhausted
                    ? () {
                        unawaited(AnalyticsService.instance
                            .trackPremiumTap(from: 'card_ask'));
                        unawaited(showPaywall(context, from: 'card_ask'));
                      }
                    : null,
                child: Text(
                  _askExhausted
                      ? _t('cardv2_ask_pro')
                      : _t('cardv2_ask_left').replaceAll(
                          '{n}', '${_freeQuestions - _askCount}'),
                  style: _small(theme,
                      color: _askExhausted ? theme.primary : null,
                      weight: _askExhausted ? FontWeight.w600 : null),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _ask(int imageId, String rawQuestion) async {
    final question = rawQuestion.trim();
    if (question.isEmpty || _askLoading) return;
    if (_askExhausted) {
      unawaited(AnalyticsService.instance.trackPremiumTap(from: 'card_ask'));
      unawaited(showPaywall(context, from: 'card_ask'));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _askLoading = true;
      _askError = false;
      _askController.text = question;
    });
    try {
      final resp = await ProductAskCall.call(
        imageId: imageId,
        question: question,
        lang: FFLocalizations.of(context).languageCode,
        skinType: _selectedSkinType ?? widget.userSkinType,
        token: currentJwtToken,
      );
      if (!mounted) return;
      final answer = resp.succeeded && resp.statusCode == 200
          ? ProductAskCall.answer(resp.jsonBody)
          : null;
      if (answer == null || answer.isEmpty) {
        setState(() {
          _askError = true;
          _askLoading = false;
        });
        return;
      }
      setState(() {
        _askAnswer = answer;
        _askCited = (ProductAskCall.cited(resp.jsonBody) ?? const []).toSet();
        _askCount += 1;
        _askLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _askError = true;
        _askLoading = false;
      });
    }
  }

  // ── 5. Кому подходит, кому нет ────────────────────────────────────────────

  Widget _buildFitGroup(FlutterFlowTheme theme) {
    final warnings = _visibleWarnings;
    final hasAnything = widget.skinCompatibility.isNotEmpty ||
        widget.profileCta != null ||
        warnings.isNotEmpty ||
        widget.image.saPregnancySafe != null ||
        widget.spfBlock != null;
    if (!hasAnything) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, _t('cardv2_fit_title')),
        _buildFit(theme),
        if (widget.profileCta != null) widget.profileCta!,
        if (warnings.isNotEmpty) _buildWarnings(theme),
        _buildPregnancy(theme),
        if (widget.spfBlock != null) widget.spfBlock!,
      ],
    );
  }

  // ── Skin type matrix (tappable, ephemeral) ───────────────────────────────

  /// Тип кожи, для которого посчитана оценка: одна строка на карточке, выбор —
  /// в листе. В листе видны баллы всех типов сразу — то самое сравнение, ради
  /// которого раньше висела матрица на шесть строк.
  ///
  /// Выбор эфемерный: в профиль не пишется, косметолог так листает типы под
  /// каждого клиента.
  static const _skinTypeOrder = [
    'dry',
    'oily',
    'normal',
    'combination',
    'sensitive',
    'acne_prone',
  ];

  List<ImageSkinCompatibilityRow> get _orderedRows {
    // Порядок постоянный, а не по убыванию балла: иначе свой тип приходилось
    // бы искать заново на каждой карточке.
    return [...widget.skinCompatibility]..sort((a, b) {
        final ia = _skinTypeOrder.indexOf(a.skinType);
        final ib = _skinTypeOrder.indexOf(b.skinType);
        return (ia < 0 ? 99 : ia).compareTo(ib < 0 ? 99 : ib);
      });
  }

  Widget _buildFit(FlutterFlowTheme theme) {
    if (widget.skinCompatibility.isEmpty) return const SizedBox.shrink();
    final row = _selectedRow;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: SettingsRow(
        icon: Icons.face_retouching_natural,
        label: _t('cardv2_skin_type_row'),
        trailingValue:
            row != null ? _skinTypeLabel(row.skinType) : _t('cardv2_type_none'),
        surfaceColor: theme.surfaceMuted,
        onTap: _openSkinTypeSheet,
      ),
    );
  }

  Future<void> _openSkinTypeSheet() async {
    final theme = FlutterFlowTheme.of(context);
    final genericScore = widget.image.saCompositeScore?.round();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => MirraBottomSheet(
          surfaceColor: theme.alternate,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('cardv2_score_for_type'),
                    style: theme.headlineSmall.override(
                      fontFamily: theme.headlineSmallFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.headlineSmallIsCustom,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Первой строкой — оценка формулы без учёта типа: так из
                  // персонального расчёта есть дорога обратно.
                  SelectableRow(
                    label: _t('cardv2_type_none'),
                    value: genericScore != null ? '$genericScore' : null,
                    selected: _selectedSkinType == null,
                    onTap: () =>
                        _pickSkinType(sheetContext, setSheetState, null),
                  ),
                  for (final row in _orderedRows) ...[
                    const SizedBox(height: 8),
                    SelectableRow(
                      label: _skinTypeLabel(row.skinType),
                      value: '${row.compatibilityScore}',
                      selected: row.skinType == _selectedSkinType,
                      onTap: () => _pickSkinType(
                          sheetContext, setSheetState, row.skinType),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pickSkinType(
      BuildContext sheetContext, StateSetter setSheetState, String? skinType) {
    HapticFeedback.lightImpact();
    // `all` — строка «для всех типов кожи», то есть сброс выбора.
    unawaited(AnalyticsService.instance
        .trackProductSkin(skinName: skinType ?? 'all'));
    setState(() {
      _userTouchedMatrix = true;
      _selectedSkinType = skinType;
    });
    setSheetState(() {});
    // Лист закрывается сам: смотреть в нём после выбора не на что, а кольцо
    // за ним как раз переезжает на новое значение.
    Navigator.of(sheetContext).pop();
  }

  // ── Pregnancy safety ──────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _pregFlags {
    final raw = widget.image.saPregnancyFlags;
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  String _pregClassLabel(String cls) {
    const keys = {
      'retinoid': 'preg_class_retinoid',
      'hydroquinone': 'preg_class_hydroquinone',
      'arbutin': 'preg_class_arbutin',
      'bha': 'preg_class_bha',
    };
    final key = keys[cls];
    return key != null ? _t(key) : cls;
  }

  /// Product-intrinsic pregnancy verdict (backend knowledge.pregnancy_verdict).
  /// Only a limited set of contraindicated actives is screened — the always-on
  /// methodology block (preg_how_body) states that explicitly, so the badge is
  /// never read as a complete safety guarantee. Hidden until computed (null).
  Widget _buildPregnancy(FlutterFlowTheme theme) {
    final safe = widget.image.saPregnancySafe;
    if (safe == null) return const SizedBox.shrink();
    final flags = _pregFlags;
    final ok = safe && flags.isEmpty;
    // «Можно» показываем только тем, кто спрашивал: в профиле указана
    // беременность или кормление. Предупреждение — всем, кто открыл карточку:
    // человек мог не заполнить профиль, а ретиноид от этого никуда не делся.
    if (ok && !widget.pregnancyRelevant) return const SizedBox.shrink();
    final accent = ok ? _goodColor : _warnColor;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.30)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    ok ? _t('preg_safe') : _t('preg_caution'),
                    style: _body(theme, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (flags.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 6, 0, 0),
                child: Text(
                  '${_t('preg_contains')} '
                  '${flags.map((f) => _pregClassLabel('${f['class']}')).join(', ')}',
                  style: _small(theme, color: theme.primaryText),
                ),
              ),
            // Методика — под ссылкой, а не абзацем на девять строк. Она
            // отзывала обратно только что выданный ответ: сначала «можно»,
            // следом мелким шрифтом «но мы проверяем не всё».
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 8, 0, 0),
              child: InkWell(
                onTap: () =>
                    setState(() => _pregHowExpanded = !_pregHowExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _t('preg_how_title'),
                        style: theme.labelSmall.override(
                          fontFamily: theme.labelSmallFamily,
                          color: theme.secondaryText,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.labelSmallIsCustom,
                        ),
                      ),
                      Icon(
                        _pregHowExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                        color: theme.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_pregHowExpanded)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 2, 0, 0),
                child: Text(
                  _t('preg_how_body'),
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 12,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Warnings with addressees ──────────────────────────────────────────────

  Widget _buildWarnings(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Text(_t('cardv2_watch_out'), style: _section(theme)),
        ),
        ..._visibleWarnings.map((issue) {
          final addressees = issue.relevantFor.contains('all')
              ? _t('cardv2_for_all')
              : issue.relevantFor.map(_skinTypeLabel).join(', ');
          // Safety warnings are never paywalled: the ingredient name and its
          // addressees stay visible to everyone. Only the explanatory
          // description is reserved for Pro.
          final showDescription =
              widget.isPro && (issue.description ?? '').isNotEmpty;
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: issue.severity == 'high' ? _badColor : _warnColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${issue.ingredientName}'
                        '${showDescription ? ' — ${issue.description}' : ''}',
                        style: _body(theme),
                      ),
                      Text('${_t('cardv2_matters_for')} $addressees',
                          style: _small(theme)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── 6. Следующая баночка ──────────────────────────────────────────────────

  Widget _buildNextBottle(FlutterFlowTheme theme) {
    final count = widget.bagCount;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.alternate,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primary.withOpacity(0.18)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('cardv2_next_title'),
              style: theme.headlineSmall.override(
                fontFamily: theme.headlineSmallFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.headlineSmallIsCustom,
              ),
            ),
            const SizedBox(height: 6),
            Text(_t('cardv2_next_body'),
                style: _body(theme, color: theme.secondaryText)),
            const SizedBox(height: 14),
            if (widget.onScanNext != null)
              AppButton(
                label: _t('cardv2_next_scan'),
                icon: Icons.photo_camera_rounded,
                onPressed: widget.onScanNext,
              ),
            if (widget.onToggleBag != null) ...[
              const SizedBox(height: 8),
              AppButton(
                label: widget.inBag
                    ? _t('cardv2_next_bag_remove')
                    : _t('cardv2_next_bag_add'),
                icon: widget.inBag ? Icons.spa_outlined : Icons.spa_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: widget.onToggleBag,
              ),
            ],
            if (count != null && count > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _t('cardv2_next_bag_count').replaceAll('{n}', '$count'),
                  style: _small(theme),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 7. Pro layer: full MEC table, informational issues, confidence ───────

  Widget _buildProLayer(FlutterFlowTheme theme) {
    final conf = _confidence;
    final mecRows = widget.topIngredients
        .where((i) => i.status != null || i.mec != null)
        .toList();
    // Issues with no addressees are informational (not skin-type warnings) —
    // surfaced here in the pro layer rather than in the warnings block.
    final infoIssues =
        widget.ingredientIssues.where((i) => i.relevantFor.isEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
          child: InkWell(
            onTap: () => setState(() => _proExpanded = !_proExpanded),
            child: Row(
              children: [
                Text(_t('cardv2_pro_title'), style: _section(theme)),
                Icon(
                  _proExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.secondaryText,
                ),
              ],
            ),
          ),
        ),
        if (_proExpanded) ...[
          // Evidence vs MEC
          if (mecRows.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
              child: Text(_t('cardv2_evidence_title'), style: _section(theme)),
            ),
            ...mecRows.map((ing) {
              final mecText = ing.mec != null ? '≥ ${ing.mec}%' : '';
              final concText = ing.estimatedConcentration ?? '';
              final statusLabel =
                  ing.status == null ? '' : _t('cardv2_status_${ing.status}');
              return Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(ing.ingredientName,
                          style: _small(theme, color: theme.primaryText)),
                    ),
                    Text(
                      [
                        if (concText.isNotEmpty) '~$concText',
                        if (mecText.isNotEmpty) mecText,
                        if (statusLabel.isNotEmpty) statusLabel,
                      ].join(' · '),
                      style: _small(theme),
                    ),
                  ],
                ),
              );
            }),
          ],
          // Informational issues (no addressees) — same look as warnings but
          // with an info icon instead of the warning triangle.
          if (infoIssues.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
              child: Text(_t('cardv2_informational'), style: _section(theme)),
            ),
            ...infoIssues.map((issue) {
              return Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${issue.ingredientName}'
                        '${(issue.description ?? '').isNotEmpty ? ' — ${issue.description}' : ''}',
                        style: _body(theme),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          // Honest confidence, in full (the short form sits above the verdict).
          if (conf.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_t('cardv2_confidence_title')}: '
                      '${_t('cardv2_conf_${conf['level'] ?? 'medium'}')}',
                      style: _body(theme, size: 13, weight: FontWeight.w600),
                    ),
                    if (conf['composite_range'] is List &&
                        (conf['composite_range'] as List).length == 2)
                      Text(
                        '${(conf['composite_range'] as List)[0]} – '
                        '${(conf['composite_range'] as List)[1]}',
                        style: _small(theme),
                      ),
                    if (conf['reasons'] is List)
                      ...((conf['reasons'] as List)
                          .map((r) => Text('· $r', style: _small(theme)))),
                  ],
                ),
              ),
            ),
          // Блоки экрана, которым место в подробностях: состав с подсветкой,
          // экспертный текст, «как использовать». Их читают единицы, а в
          // основном потоке они занимали больше тысячи пикселей.
          ...widget.deepExtras,
        ],
      ],
    );
  }
}

/// Компонент-свидетель из claim audit / goal support.
class _Evidence {
  const _Evidence({required this.name, this.position, this.status});

  final String name;
  final int? position;

  /// working / borderline / decorative / null (нет в таблице доз).
  final String? status;

  int get rank => switch (status) {
        'working' => 0,
        'borderline' => 1,
        null => 2,
        _ => 3,
      };
}

/// Обещание с упаковки и компоненты, которые должны его выполнять.
class _PromiseRow {
  const _PromiseRow({
    required this.claimKey,
    required this.verdict,
    required this.evidence,
  });

  final String claimKey;
  final String verdict;
  final List<_Evidence> evidence;
}

/// Строка списка «чего ожидать».
class _Expectation {
  const _Expectation({
    required this.key,
    required this.title,
    required this.good,
    required this.lines,
  });

  final String key;
  final String title;

  /// Зелёный (позитивный и подкреплённый) или красный (всё остальное).
  final bool good;
  final List<String> lines;
}
