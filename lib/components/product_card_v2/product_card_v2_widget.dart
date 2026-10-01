import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/domain/client_card/client_card_service.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/score_breakdown/score_breakdown_widget.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/design_system/components/selectable_row.dart';
import '/design_system/foundations/score_status.dart';
import '/item_card/ingridients/ingridients_widget.dart';
import '/paywall/show_paywall.dart';

/// Карточка продукта v3: вердикт первым, но никогда без слов, и каждый факт
/// один раз.
///
/// Порядок блоков повторяет вопросы человека, который только что отсканировал
/// свой продукт (ТЗ «Карточка продукта v3», 01.10.2026):
///  1. ответ: «для вашей кожи» с меткой подходит / с оговоркой / не подходит,
///     абзац «что это за продукт на самом деле» (четвёртое предложение
///     написано для кожи этого человека), цель из профиля, кольцо со скором
///     состава. Профиль пуст: чипы «какая у вас кожа?» прямо здесь, ответ
///     сразу пишется в users
///  2. состав: один список INCI с подсветкой, линией 1 % и пометками в
///     строках. Обещания с упаковки, статусы доз и замечания живут здесь
///  3. цифры: оси свёрнуты, строка честности, строка нейтральности,
///     «спросить о продукте»
///  4. дальше: проверить следующий, на полку
///  5. «разбор глубже» (Pro): дозы против порога для всех активов,
///     замечания без адресата, уверенность целиком и [deepExtras]
///
/// Ни один блок не говорит «продукт не работает»: только позиция, доза,
/// порог. Число никогда не стоит одно, только рядом с абзацем. Имя приложения
/// впервые звучит в блоке «Цифры».
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
    this.userSkinGoals = const [],
    this.isPro = false,
    this.pregnancyRelevant = false,
    this.spfLine,
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

  /// Профиль кожи из users: тип (dry / oily / combination / normal),
  /// чувствительность, склонность к акне, цели. null = профиль пуст.
  final String? userSkinType;
  final bool userIsSensitive;
  final bool userIsAcneProne;
  final List<String> userSkinGoals;

  /// Whether the pro layer (full MEC table, confidence, deep extras) is visible
  /// and how many questions the card answers.
  final bool isPro;

  /// В профиле указана беременность или кормление. Спокойный вердикт («можно»)
  /// показываем только им — остальным он отвечает на незаданный вопрос. А вот
  /// предупреждение видно всем независимо от профиля: прятать риск нельзя.
  final bool pregnancyRelevant;

  /// SPF одной строкой под ответом: тип фильтров, широкий спектр, список.
  final String? spfLine;

  /// Блоки, уезжающие внутрь «Разбора глубже» (экспертный текст, «как
  /// использовать»). Хозяин экрана решает, что туда сложить.
  final List<Widget> deepExtras;

  /// Действия блока «дальше». null — блок не показывается.
  final VoidCallback? onScanNext;
  final Future<void> Function()? onToggleBag;
  final bool inBag;
  final int? bagCount;

  @override
  State<ProductCardV2Widget> createState() => _ProductCardV2WidgetState();
}

class _ProductCardV2WidgetState extends State<ProductCardV2Widget> {
  /// Профиль кожи. Стартует из users, тап по чипу или строке в листе меняет
  /// его здесь и тут же пишет в users: спрашиваем там, где нужен ответ, и
  /// записываем один раз.
  String? _skinType;
  bool _sensitive = false;
  bool _acneProne = false;

  /// После первого тапа асинхронно подъехавший профиль не перебивает выбор.
  bool _profileTouched = false;

  bool _proExpanded = false;

  /// Методика проверки на беременность раскрыта (по умолчанию — ссылкой).
  bool _pregHowExpanded = false;

  /// Тап по кольцу прокручивает к блоку «Цифры».
  final GlobalKey _numbersKey = GlobalKey();

  /// «Спросить о продукте»: один диалог на карточку, в памяти виджета.
  final TextEditingController _askController = TextEditingController();
  String? _askAnswer;
  Set<String> _askCited = const {};
  bool _askLoading = false;
  bool _askError = false;
  int _askCount = 0;

  static const int _freeQuestions = 3;

  /// Типы кожи, которые принимает профиль (как в анкете онбординга).
  static const _profileTypes = ['dry', 'oily', 'combination', 'normal'];

  @override
  void initState() {
    super.initState();
    _adoptProfile();
  }

  @override
  void didUpdateWidget(covariant ProductCardV2Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Профиль грузится на экране асинхронно и может прийти после первого
    // кадра. Берём его, пока человек не выбрал тип сам.
    final changed = widget.userSkinType != oldWidget.userSkinType ||
        widget.userIsSensitive != oldWidget.userIsSensitive ||
        widget.userIsAcneProne != oldWidget.userIsAcneProne;
    if (changed && !_profileTouched) _adoptProfile();
  }

  void _adoptProfile() {
    _skinType = (widget.userSkinType ?? '').isEmpty ? null : widget.userSkinType;
    _sensitive = widget.userIsSensitive;
    _acneProne = widget.userIsAcneProne;
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

  String _goalLabel(String goal) {
    final l = _t('cb_goal_$goal');
    return l.isEmpty ? goal : l;
  }

  // ── Text style helpers ────────────────────────────────────────────────────

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

  // ── Derived data ──────────────────────────────────────────────────────────

  Map<String, dynamic> get _confidence {
    final raw = widget.image.saConfidence;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  Map<String, dynamic> get _scoringLog {
    final raw = widget.image.saScoringLog;
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

  Map<String, Map<String, dynamic>> get _goalSupport {
    final raw = widget.image.saGoalSupport;
    if (raw is! Map) return const {};
    return {
      for (final e in raw.entries)
        if (e.value is Map)
          '${e.key}': Map<String, dynamic>.from(e.value as Map),
    };
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

  /// Как найдена линия (marker / structure). Лежит в sa_scoring_log у
  /// разборов с октября 2026; у старых линия всегда по маркеру.
  String? get _lineBasis {
    final line = _scoringLog['one_percent_line'];
    return line is Map ? line['basis'] as String? : null;
  }

  /// Распознано меньше 70 % состава: оценка приблизительная, в кольце
  /// диапазон вместо точки.
  bool get _incomplete {
    final total = widget.image.saIngredientsTotal ?? 0;
    final recognized = widget.image.saIngredientsRecognized ?? 0;
    return total > 0 && recognized / total < 0.7;
  }

  List<int>? get _compositeRange {
    final range = _confidence['composite_range'];
    if (range is List && range.length == 2 && range.every((v) => v is num)) {
      return [(range[0] as num).round(), (range[1] as num).round()];
    }
    return null;
  }

  static bool _sameIngredient(String a, String b) {
    final x = a.toLowerCase().trim();
    final y = b.toLowerCase().trim();
    if (x.isEmpty || y.isEmpty) return false;
    return x == y || x.contains(y) || y.contains(x);
  }

  /// Позиция по имени в самом списке состава — та же, что видит человек в
  /// блоке ниже. Точное совпадение важнее частичного.
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

  /// Обещанный компонент ниже рабочей дозы — с него начинается чтение списка
  /// и он же герой подсказки «почему не считается».
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

  // ── Профиль и персональный ответ ──────────────────────────────────────────

  bool get _hasProfile => _skinType != null || _sensitive || _acneProne;

  ImageSkinCompatibilityRow? _compatRow(String skinType) {
    for (final row in widget.skinCompatibility) {
      if (row.skinType == skinType) return row;
    }
    return null;
  }

  /// Персональный балл: худший из применимых строк (тип кожи,
  /// чувствительность, акне). Честнее среднего: претензия к одной черте кожи
  /// не растворяется в хорошей оценке для другой.
  int? get _personalScore {
    final scores = <int>[
      for (final type in [
        if (_skinType != null) _skinType!,
        if (_sensitive) 'sensitive',
        if (_acneProne) 'acne_prone',
      ])
        if (_compatRow(type) != null) _compatRow(type)!.compatibilityScore,
    ];
    if (scores.isEmpty) return null;
    return scores.reduce(min);
  }

  /// Метка под строкой «для вашей кожи». Пороги из ТЗ: 60 и выше подходит,
  /// 40–59 с оговоркой, ниже 40 не подходит.
  ({String text, Color color})? get _fitLabel {
    final score = _personalScore;
    if (score == null) return null;
    if (score >= 60) return (text: _t('cardv2_fit_good'), color: kScoreA);
    if (score >= 40) return (text: _t('cardv2_fit_caveat'), color: kScoreD);
    return (text: _t('cardv2_fit_bad'), color: kScoreF);
  }

  /// Вариант четвёртого предложения. Чувствительность важнее типа: претензии
  /// абзаца чаще всего про неё.
  String? get _personalKey =>
      _sensitive ? 'sensitive' : (_acneProne ? 'acne_prone' : _skinType);

  String get _profileLabel => [
        if (_skinType != null) _skinTypeLabel(_skinType!),
        if (_sensitive) _skinTypeLabel('sensitive'),
        if (_acneProne) _skinTypeLabel('acne_prone'),
      ].map((s) => s.toLowerCase()).join(', ');

  /// Абзац «что это за продукт на самом деле». Предложения 1–3 общие,
  /// четвёртое для кожи этого человека. У старых разборов без абзаца
  /// остаётся короткое резюме.
  String get _paragraph {
    final general = widget.image.plainVerdictGeneral;
    if (general.isEmpty) return widget.image.saQuickSummary ?? '';
    final body = general.take(3).toList();
    final key = _personalKey;
    final fourth = (key == null ? null : widget.image.plainVerdictFor(key)) ??
        (general.length > 3 ? general[3] : null);
    if (fourth != null) body.add(fourth);
    return body.join(' ');
  }

  /// Цель из профиля одной строкой: что её поддерживает и насколько.
  String? get _goalLine {
    final goal = widget.userSkinGoals.firstOrNull;
    if (goal == null) return null;
    final support = _goalSupport[goal];
    final score = (support?['score'] as num?)?.round();
    if (score == null) return null;
    final label = _goalLabel(goal).toLowerCase();
    final best = _parseEvidence(support!['evidence'])
        .where((e) => e.status != 'decorative')
        .firstOrNull;
    final pos = best == null ? null : (_positionByName(best.name) ?? best.position);
    if (best != null && pos != null) {
      return _t('cardv2_goal_with')
          .replaceAll('{goal}', label)
          .replaceAll('{name}', best.name)
          .replaceAll('{pos}', '$pos')
          .replaceAll('{total}', '${_inciList.length}')
          .replaceAll('{score}', '$score');
    }
    return _t('cardv2_goal_plain')
        .replaceAll('{goal}', label)
        .replaceAll('{score}', '$score');
  }

  Future<void> _saveSkinType(String type) async {
    HapticFeedback.lightImpact();
    setState(() {
      _profileTouched = true;
      _skinType = type;
    });
    unawaited(AnalyticsService.instance.trackProductSkin(skinName: type));
    try {
      await ClientCardService.instance.updateAnamnesis(skinType: type);
    } catch (e) {
      debugPrint('card: skin type not saved: $e');
    }
  }

  Future<void> _saveFlags({bool? sensitive, bool? acneProne}) async {
    HapticFeedback.lightImpact();
    setState(() {
      _profileTouched = true;
      if (sensitive != null) _sensitive = sensitive;
      if (acneProne != null) _acneProne = acneProne;
    });
    try {
      await ClientCardService.instance
          .updateAnamnesis(sensitive: sensitive, acneProne: acneProne);
    } catch (e) {
      debugPrint('card: skin flags not saved: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnswer(theme),
        _buildWhy(theme),
        _buildNumbers(theme),
        if (widget.onScanNext != null || widget.onToggleBag != null)
          _buildNextBottle(theme),
        if (widget.isPro) _buildProLayer(theme),
      ],
    );
  }

  // ── 1. Ответ ──────────────────────────────────────────────────────────────

  Widget _buildAnswer(FlutterFlowTheme theme) {
    final paragraph = _paragraph;
    final goalLine = _goalLine;
    final pregnancy = _buildPregnancy(theme);
    final spf = widget.spfLine;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: Container(
        key: const Key('cardv2_answer'),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.alternate,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasProfile) ...[
              _buildProfileRow(theme),
              const SizedBox(height: 12),
            ],
            if (paragraph.isNotEmpty)
              Text(paragraph, style: _body(theme, size: 15).copyWith(height: 1.4)),
            if (!_hasProfile) ...[
              const SizedBox(height: 14),
              _buildSkinChips(theme),
            ],
            if (goalLine != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(goalLine, style: _small(theme)),
              ),
            if (pregnancy != null) pregnancy,
            if (spf != null && spf.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.wb_sunny_rounded,
                          size: 16, color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(spf, style: _small(theme, color: theme.primaryText)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildRing(theme),
          ],
        ),
      ),
    );
  }

  /// «Для вашей кожи: сухая, чувствительная · изменить» и метка.
  Widget _buildProfileRow(FlutterFlowTheme theme) {
    final fit = _fitLabel;
    final score = _personalScore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: _small(theme),
                  children: [
                    TextSpan(text: '${_t('cardv2_for_your_skin')}: '),
                    TextSpan(
                      text: _profileLabel,
                      style: TextStyle(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _openProfileSheet,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  _t('cardv2_change'),
                  style: _small(theme,
                      color: theme.primary, weight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        if (fit != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fit.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  fit.text,
                  style: _small(theme, color: fit.color, weight: FontWeight.w700),
                ),
              ),
              if (score != null) ...[
                const SizedBox(width: 8),
                Text(
                  _t('cardv2_fit_score').replaceAll('{score}', '$score'),
                  style: _small(theme),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  /// Профиль пуст: спрашиваем здесь, где нужен ответ.
  Widget _buildSkinChips(FlutterFlowTheme theme) {
    final chipLabel = _small(theme, color: theme.primaryText, weight: FontWeight.w600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_t('cardv2_skin_ask'), style: _section(theme)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in _profileTypes)
              ChoiceChip(
                label: Text(_skinTypeLabel(type), style: chipLabel),
                selected: _skinType == type,
                showCheckmark: false,
                backgroundColor: theme.surfaceMuted,
                selectedColor: theme.primary.withOpacity(0.18),
                side: BorderSide.none,
                onSelected: (_) => _saveSkinType(type),
              ),
            FilterChip(
              label: Text(_skinTypeLabel('sensitive'), style: chipLabel),
              selected: _sensitive,
              showCheckmark: false,
              backgroundColor: theme.surfaceMuted,
              selectedColor: theme.primary.withOpacity(0.18),
              side: BorderSide.none,
              onSelected: (v) => _saveFlags(sensitive: v),
            ),
          ],
        ),
      ],
    );
  }

  /// Лист «изменить»: типы кожи с баллами совместимости и два флага. Каждый
  /// выбор пишется в профиль; тип закрывает лист, флаги остаются в нём.
  Future<void> _openProfileSheet() async {
    final theme = FlutterFlowTheme.of(context);
    String? scoreOf(String type) {
      final row = _compatRow(type);
      return row == null ? null : '${row.compatibilityScore}';
    }

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
                  for (final type in _profileTypes) ...[
                    SelectableRow(
                      label: _skinTypeLabel(type),
                      value: scoreOf(type),
                      selected: _skinType == type,
                      onTap: () {
                        unawaited(_saveSkinType(type));
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 4),
                  SelectableRow(
                    label: _skinTypeLabel('sensitive'),
                    value: scoreOf('sensitive'),
                    selected: _sensitive,
                    onTap: () {
                      unawaited(_saveFlags(sensitive: !_sensitive));
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  SelectableRow(
                    label: _skinTypeLabel('acne_prone'),
                    value: scoreOf('acne_prone'),
                    selected: _acneProne,
                    onTap: () {
                      unawaited(_saveFlags(acneProne: !_acneProne));
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Кольцо со скором состава: одно число на всех, его можно сравнивать между
  /// продуктами. Тап ведёт к осям. При неполном составе в кольце диапазон.
  Widget _buildRing(FlutterFlowTheme theme) {
    final score = widget.image.saCompositeScore?.round();
    if (score == null) return const SizedBox.shrink();
    final range = _compositeRange;
    // Состав неполный: в кольце диапазон вместо точки.
    final rangeText =
        _incomplete && range != null ? '${range[0]}–${range[1]}' : null;
    final color = semanticScoreColor(score);

    return InkWell(
      onTap: _scrollToNumbers,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 34,
            lineWidth: 7,
            percent: (score / 100.0).clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.12),
            progressColor: color,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animateFromLastPercent: true,
            center: Text(
              rangeText ?? '$score',
              style: theme.headlineSmall.override(
                fontFamily: theme.headlineSmallFamily,
                color: color,
                fontSize: rangeText != null ? 13 : 22,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w700,
                useGoogleFonts: !theme.headlineSmallIsCustom,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t('cardv2_formula_score'),
                    style: _body(theme, weight: FontWeight.w600)),
                if (rangeText != null)
                  Text(_t('cardv2_approx'), style: _small(theme)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(_t('score_axes_title'),
                          style: _small(theme, color: theme.primary)),
                    ),
                    Icon(Icons.expand_more, size: 16, color: theme.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToNumbers() {
    final ctx = _numbersKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.05,
    );
  }

  // ── Pregnancy ─────────────────────────────────────────────────────────────

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

  /// Беременность одной строкой в ответе. Предупреждение видно всем: человек
  /// мог не заполнить профиль, а ретиноид от этого никуда не делся. «Можно»
  /// только тем, кто спрашивал. Методика под ссылкой, а не абзацем.
  Widget? _buildPregnancy(FlutterFlowTheme theme) {
    final safe = widget.image.saPregnancySafe;
    if (safe == null) return null;
    final flags = _pregFlags;
    final ok = safe && flags.isEmpty;
    if (ok && !widget.pregnancyRelevant) return null;
    final accent = ok ? kScoreA : kScoreD;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                  size: 16,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  flags.isEmpty
                      ? (ok ? _t('preg_safe') : _t('preg_caution'))
                      : '${_t('preg_caution')} ${_t('preg_contains')} '
                          '${flags.map((f) => _pregClassLabel('${f['class']}')).join(', ')}',
                  style: _small(theme,
                      color: theme.primaryText, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 2, 0, 0),
            child: InkWell(
              onTap: () => setState(() => _pregHowExpanded = !_pregHowExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_t('preg_how_title'),
                        style: _small(theme, weight: FontWeight.w600)),
                    Icon(
                      _pregHowExpanded ? Icons.expand_less : Icons.expand_more,
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
              padding: const EdgeInsetsDirectional.fromSTEB(24, 2, 0, 0),
              child: Text(_t('preg_how_body'),
                  style: _small(theme).copyWith(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // ── 2. Состав ─────────────────────────────────────────────────────────────

  /// Один список INCI с пометками в строках. Раскрыт по умолчанию обещанный
  /// компонент ниже дозы, если такой есть: с него начинается вовлечение.
  /// Обещание без единого компонента — одной строкой под списком.
  Widget _buildWhy(FlutterFlowTheme theme) {
    final inci = _inciList;
    if (inci.isEmpty) return const SizedBox.shrink();

    final promised = <String, String>{};
    String? firstPromised;
    final unsupported = <String>[];
    for (final row in _promiseRows) {
      if (row.evidence.isEmpty) {
        unsupported.add(_claimLabel(row.claimKey));
        continue;
      }
      for (final e in row.evidence) {
        promised.putIfAbsent(
            e.name.toLowerCase().trim(), () => _claimLabel(row.claimKey));
        firstPromised ??= e.name;
      }
    }
    final initial = _weakPromisedName ?? firstPromised;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_incomplete)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kScoreD.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: kScoreD),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_t('cardv2_incomplete'),
                          style: _small(theme, color: theme.primaryText)),
                    ),
                  ],
                ),
              ),
            ),
          IngridientsWidget(
            inci: inci,
            linePos: _linePos,
            lineMarker: widget.image.saOnePercentLineMarker,
            lineBasis: _lineBasis,
            topIngredients: widget.topIngredients,
            issues: widget.ingredientIssues,
            promised: promised,
            citedNames: _askCited,
            initiallySelected: initial,
          ),
          for (final claim in unsupported)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _t('cardv2_claim_no_component').replaceAll('{claim}', claim),
                style: _small(theme),
              ),
            ),
        ],
      ),
    );
  }

  // ── 3. Цифры ──────────────────────────────────────────────────────────────

  /// Оси свёрнуты, строка честности, строка нейтральности, «спросить».
  /// Первое место, где в карточке звучит имя приложения.
  Widget _buildNumbers(FlutterFlowTheme theme) {
    return Column(
      key: _numbersKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScoreBreakdownWidget(
          scoringLog: widget.image.saScoringLog,
          topIngredients: widget.topIngredients,
          ingredientIssues: widget.ingredientIssues,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHonesty(theme),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_t('cardv2_neutrality'), style: _small(theme)),
              ),
            ],
          ),
        ),
        _buildAsk(theme),
      ],
    );
  }

  /// «Распознано 24 из 28 компонентов · уверенность высокая · диапазон 55–69».
  /// Причины целиком — в «Разборе глубже».
  Widget _buildHonesty(FlutterFlowTheme theme) {
    final total = widget.image.saIngredientsTotal ?? 0;
    final recognized = widget.image.saIngredientsRecognized ?? 0;
    final conf = _confidence;
    final level = widget.image.saConfidenceLevel ?? '${conf['level'] ?? ''}';
    final range = _compositeRange;

    final parts = <String>[
      if (total > 0)
        _t('cardv2_recognized_of')
            .replaceAll('{n}', '$recognized')
            .replaceAll('{m}', '$total'),
      if (level.isNotEmpty && _t('cardv2_conf_$level').isNotEmpty)
        '${_t('cardv2_confidence_title').toLowerCase()}: ${_t('cardv2_conf_$level')}',
      if (range != null)
        _t('cardv2_range')
            .replaceAll('{lo}', '${range[0]}')
            .replaceAll('{hi}', '${range[1]}'),
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(parts.join(' · '), style: _small(theme));
  }

  // ── Спросить о продукте ───────────────────────────────────────────────────

  List<String> get _askSuggestions {
    final weak = _weakPromisedName;
    final skin = _personalKey ?? 'sensitive';
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
                  style: _small(theme, color: kScoreF)),
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
        skinType: _personalKey,
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

  // ── 4. Дальше ─────────────────────────────────────────────────────────────

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

  // ── 5. Разбор глубже (Pro) ────────────────────────────────────────────────

  Widget _buildProLayer(FlutterFlowTheme theme) {
    final conf = _confidence;
    final range = _compositeRange;
    final mecRows = widget.topIngredients
        .where((i) => i.status != null || i.mec != null)
        .toList();
    // Замечания без адресата — информационные (эко, регуляторика), не
    // предупреждения о коже: им место здесь.
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
                        '${(issue.description ?? '').isNotEmpty ? ': ${issue.description}' : ''}',
                        style: _body(theme),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          // Уверенность целиком (короткая форма стоит в «Цифрах»).
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
                    if (range != null)
                      Text('${range[0]}–${range[1]}', style: _small(theme)),
                    if (conf['reasons'] is List)
                      ...((conf['reasons'] as List)
                          .map((r) => Text('· $r', style: _small(theme)))),
                  ],
                ),
              ),
            ),
          // Экспертный текст и «как использовать»: их читают единицы, а в
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
