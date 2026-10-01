import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/design_system/foundations/score_status.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Состав продукта как один информативный список.
///
/// Тот же поток «Aqua, Glycerin, …» с подсветкой, что и раньше, но каждый
/// факт о компоненте живёт в его строке, а не в отдельном блоке:
///  - зелёный фон: актив в рабочей дозе; серый: актив ниже рабочей дозы или
///    без данных о пороге; красный: компонент с замечанием;
///  - «✦» перед названием: компонент стоит за обещанием с упаковки;
///  - тап по ингредиенту раскрывает подсказку под списком: позиция, выше или
///    ниже линии, оценка дозы против порога, статус словами, описание;
///  - линия 1 % проведена прямо в списке и подписана по тому, как найдена:
///    по маркеру («таких не бывает больше 1 %») или по концу базы формулы;
///  - ингредиенты, которые процитировал ответ «спросить о продукте»,
///    подчёркнуты.
///
/// Иконок статуса нет: цвет и слова в подсказке говорят то же самое, а знак
/// «?» в кружке читался как загадка. Правило «порядок = количество» не
/// объясняется словами: линия и позиция в подсказке показывают его на своём
/// продукте.
class IngridientsWidget extends StatefulWidget {
  const IngridientsWidget({
    super.key,
    required this.inci,
    this.linePos,
    this.lineMarker,
    this.lineBasis,
    this.topIngredients = const [],
    this.issues = const [],
    this.promised = const {},
    this.citedNames = const {},
    this.initiallySelected,
  });

  /// INCI по позициям (1-based = index + 1).
  final List<String> inci;
  final int? linePos;
  final String? lineMarker;

  /// Как найдена линия: 'marker' (консервант, загуститель) или 'structure'
  /// (конец базы формулы). null у старых разборов, там линия всегда по маркеру.
  final String? lineBasis;
  final List<ImageTopIngredientsRow> topIngredients;
  final List<ImageIngredientIssuesRow> issues;

  /// Имя актива (в нижнем регистре) → подпись обещания, за которым он стоит.
  final Map<String, String> promised;

  /// Имена, процитированные в ответе «спросить о продукте».
  final Set<String> citedNames;

  /// Ингредиент, раскрытый при первом показе (обычно первый обещанный).
  final String? initiallySelected;

  @override
  State<IngridientsWidget> createState() => _IngridientsWidgetState();
}

class _IngridientsWidgetState extends State<IngridientsWidget> {
  static const _greenText = Color(0xFF1B5E20);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _redText = Color(0xFFB71C1C);
  static const _redBg = Color(0xFFFFEBEE);
  static const _greyBg = Color(0xFFEEEEEE);
  static const _cited = Color(0xFF1E9E86);

  /// Выбранный ингредиент — по позиции, а не по имени: дубликаты в списке
  /// бывают (Aqua дважды у двухфазных средств).
  int? _selectedIndex;
  final List<TapGestureRecognizer> _recognizers = [];

  /// Описания из справочника: имя → текст (null = искали, не нашли).
  final Map<String, String?> _dictionary = {};
  String? _loadingKey;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _indexOf(widget.initiallySelected);
  }

  @override
  void didUpdateWidget(covariant IngridientsWidget old) {
    super.didUpdateWidget(old);
    // Ответ «спросить о продукте» назвал ингредиенты — открываем первый из
    // них: так ответ и список читаются вместе.
    if (widget.citedNames != old.citedNames && widget.citedNames.isNotEmpty) {
      for (final name in widget.citedNames) {
        final i = _indexOf(name);
        if (i != null) {
          _selectedIndex = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  static String _norm(String s) => s.toLowerCase().trim();

  static bool _same(String a, String b) {
    final x = _norm(a);
    final y = _norm(b);
    if (x.isEmpty || y.isEmpty) return false;
    return x == y || x.contains(y) || y.contains(x);
  }

  int? _indexOf(String? name) {
    if (name == null || name.isEmpty) return null;
    for (var i = 0; i < widget.inci.length; i++) {
      if (_norm(widget.inci[i]) == _norm(name)) return i;
    }
    for (var i = 0; i < widget.inci.length; i++) {
      if (_same(widget.inci[i], name)) return i;
    }
    return null;
  }

  ImageTopIngredientsRow? _activeFor(String token) {
    for (final ing in widget.topIngredients) {
      if (_norm(ing.ingredientName) == _norm(token)) return ing;
    }
    for (final ing in widget.topIngredients) {
      if (_same(ing.ingredientName, token)) return ing;
    }
    return null;
  }

  ImageIngredientIssuesRow? _issueFor(String token) {
    for (final issue in widget.issues) {
      if (_same(issue.ingredientName, token)) return issue;
    }
    return null;
  }

  String? _promiseFor(String token) {
    final direct = widget.promised[_norm(token)];
    if (direct != null) return direct;
    for (final entry in widget.promised.entries) {
      if (_same(entry.key, token)) return entry.value;
    }
    return null;
  }

  bool _isCited(String token) =>
      widget.citedNames.any((n) => _same(n, token));

  bool _belowLine(int index) =>
      widget.linePos != null && index + 1 >= widget.linePos!;

  /// Зелёный только у актива в рабочей (или пограничной) дозе. Без статуса
  /// порог неизвестен, и обещать дозу нечем: серый.
  static bool _inDose(ImageTopIngredientsRow active) =>
      active.status == 'working' || active.status == 'borderline';

  /// Замечание → ощущение на коже. Спирты и жёсткие ПАВ адресованы сухой
  /// коже, это сухость; эфирные масла адресованы чувствительной, это
  /// раздражение. Замечания без адресата (эко, регуляторика) не про кожу.
  static String? _effectKey(ImageIngredientIssuesRow issue) {
    switch (issue.issueType) {
      case 'comedogenic':
        return 'cardv2_effect_breakouts';
      case 'irritant':
        return issue.relevantFor.contains('dry')
            ? 'cardv2_effect_dryness'
            : 'cardv2_effect_irritation';
      case 'fragrance':
      case 'allergen':
      case 'formaldehyde_releaser':
        return 'cardv2_effect_irritation';
      case 'controversial':
        return 'cardv2_effect_controversial';
      default:
        return null;
    }
  }

  void _select(int index) {
    setState(() => _selectedIndex = _selectedIndex == index ? null : index);
    if (_selectedIndex != null) _ensureDictionary(widget.inci[index]);
  }

  /// Описание из справочника ингредиентов — только когда своего текста нет.
  Future<void> _ensureDictionary(String name) async {
    final key = _norm(name);
    if (_dictionary.containsKey(key) || _loadingKey == key) return;
    if (_activeFor(name)?.description?.isNotEmpty == true) return;
    if (_issueFor(name)?.description?.isNotEmpty == true) return;
    setState(() => _loadingKey = key);
    String? text;
    try {
      final lang = FFLocalizations.of(context).languageCode;
      final data = await SupaFlow.client
          .rpc('get_ingredient_data', params: {'p_inci_name': name});
      final efficacy = (data is Map) ? data['efficacy'] : null;
      if (efficacy is Map) {
        text = (efficacy['description_$lang'] ?? efficacy['description_en'])
            as String?;
      }
    } catch (e) {
      debugPrint('[inci] dictionary lookup failed for $name: $e');
    }
    if (!mounted) return;
    setState(() {
      _dictionary[key] = (text ?? '').trim().isEmpty ? null : text!.trim();
      if (_loadingKey == key) _loadingKey = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final inci = widget.inci;
    if (inci.isEmpty) return const SizedBox.shrink();

    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final linePos = widget.linePos;
    final aboveCount =
        linePos == null ? inci.length : (linePos - 1).clamp(0, inci.length);
    final selected = _selectedIndex;
    final selectedAbove = selected != null && selected < aboveCount;

    final bodyMedium = theme.bodyMedium;
    final baseStyle = bodyMedium
        .override(
          fontFamily: theme.bodyMediumFamily,
          color: theme.primaryText,
          fontSize: (bodyMedium.fontSize ?? 14) * 0.85,
          letterSpacing: 0.6,
          useGoogleFonts: !theme.bodyMediumIsCustom,
        )
        .copyWith(height: 1.7);
    final dimStyle = baseStyle.copyWith(color: theme.secondaryText);

    final hasPromise = widget.promised.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.alternate,
        borderRadius: BorderRadius.circular(24.0),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('cardv2_rule_title'),
            style: theme.titleMedium.override(
              fontFamily: theme.titleMediumFamily,
              color: theme.primaryText,
              fontSize: 16,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(children: _spans(0, aboveCount, baseStyle)),
            style: baseStyle,
          ),
          if (selectedAbove) _hint(theme, selected),
          if (linePos != null && aboveCount < inci.length) ...[
            const SizedBox(height: 12),
            _lineDivider(theme),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(children: _spans(aboveCount, inci.length, dimStyle)),
              style: dimStyle,
            ),
            if (selected != null && !selectedAbove) _hint(theme, selected),
          ],
          if (linePos == null) ...[
            const SizedBox(height: 8),
            Text(_t('cardv2_rule_no_line'), style: _small(theme)),
          ],
          const SizedBox(height: 12),
          // Легенда одна на всю карточку, здесь, под списком.
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _LegendDot(
                  color: _greenBg,
                  textColor: _greenText,
                  label: _t('inci_legend_active')),
              _LegendDot(
                  color: _greyBg,
                  textColor: kStatusDecorative,
                  label: _t('inci_legend_below')),
              _LegendDot(
                  color: _redBg,
                  textColor: _redText,
                  label: _t('inci_legend_issues')),
              if (hasPromise)
                Text(
                  '✦ ${_t('inci_legend_promise')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _greenText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (selected == null)
                Text(_t('inci_hint_tap'), style: _small(theme)),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _small(FlutterFlowTheme theme, {Color? color}) =>
      theme.bodySmall.override(
        fontFamily: theme.bodySmallFamily,
        color: color ?? theme.secondaryText,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.bodySmallIsCustom,
      );

  List<InlineSpan> _spans(int from, int to, TextStyle base) {
    final spans = <InlineSpan>[];
    for (var i = from; i < to; i++) {
      final token = widget.inci[i];
      final active = _activeFor(token);
      final issue = _issueFor(token);
      final promise = _promiseFor(token);
      final cited = _isCited(token);
      final isSelected = _selectedIndex == i;

      Color? bg;
      Color? fg;
      FontWeight? weight;
      if (issue != null) {
        bg = _redBg;
        fg = _redText;
        weight = FontWeight.w700;
      } else if (active != null) {
        final inDose = _inDose(active);
        bg = inDose ? _greenBg : _greyBg;
        fg = inDose ? _greenText : kStatusDecorative;
        weight = FontWeight.w700;
      }
      if (cited) fg = _cited;

      final recognizer = TapGestureRecognizer()..onTap = () => _select(i);
      _recognizers.add(recognizer);

      spans.add(TextSpan(
        text: promise != null ? '✦ $token' : token,
        recognizer: recognizer,
        style: base.copyWith(
          color: fg,
          backgroundColor: bg,
          fontWeight: weight,
          decoration: isSelected || cited
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: cited ? _cited : (fg ?? base.color),
          decorationThickness: isSelected ? 2.0 : 1.0,
        ),
      ));
      if (i < to - 1) spans.add(const TextSpan(text: ', '));
    }
    return spans;
  }

  /// Линия 1 % с подписью, откуда она взялась. По маркеру: консерванта или
  /// загустителя не бывает больше 1 %. По структуре: здесь кончается база
  /// формулы, и у старых разборов без признака линия всегда по маркеру.
  Widget _lineDivider(FlutterFlowTheme theme) {
    final marker = (widget.lineMarker ?? '').trim();
    final byStructure = widget.lineBasis == 'structure' || marker.isEmpty;
    final caption = byStructure
        ? _t('inci_line_structure_caption')
        : _t('inci_line_marker_caption').replaceAll('{marker}', marker);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.primaryText, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _t('cardv2_one_percent_line'),
                style: _small(theme, color: theme.primaryText)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(child: Divider(color: theme.primaryText, thickness: 1)),
          ],
        ),
        const SizedBox(height: 4),
        Text(caption, style: _small(theme)),
      ],
    );
  }

  /// Подсказка под блоком: что это, где стоит, сколько его и за что отвечает.
  Widget _hint(FlutterFlowTheme theme, int index) {
    final token = widget.inci[index];
    final active = _activeFor(token);
    final issue = _issueFor(token);
    final promise = _promiseFor(token);
    final key = _norm(token);
    final loading = _loadingKey == key;
    final total = widget.inci.length;

    final facts = <String>[
      _t('cardv2_position_of')
          .replaceAll('{pos}', '${index + 1}')
          .replaceAll('{total}', '$total'),
      if (widget.linePos != null)
        _belowLine(index) ? _t('cardv2_layer_below') : _t('cardv2_layer_above'),
      if (active?.estimatedConcentration?.isNotEmpty == true &&
          active!.status != 'decorative')
        '~${active.estimatedConcentration}',
      if (active != null)
        active.mec != null
            ? _t('cardv2_dose_needed').replaceAll('{mec}', '${active.mec}')
            : _t('inci_threshold_unknown'),
      if (active?.status != null) _t('cardv2_status_${active!.status}'),
    ];

    String? description = active?.description;
    if (description == null || description.isEmpty) {
      description = issue?.description;
    }
    if (description == null || description.isEmpty) {
      description = _dictionary[key];
      if (!_dictionary.containsKey(key) && !loading) {
        // Первый показ (например, выбранный по умолчанию) — дотягиваем текст.
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _ensureDictionary(token));
      }
    }

    final accent = issue != null
        ? _redText
        : active != null
            ? (_inDose(active) ? _greenText : kStatusDecorative)
            : theme.secondaryText;

    final effectKey = issue == null ? null : _effectKey(issue);
    final addressees = issue == null || issue.relevantFor.isEmpty
        ? null
        : issue.relevantFor.contains('all')
            ? _t('cardv2_for_all')
            : issue.relevantFor.map(_skinLabel).join(', ');
    final issueLine = [
      if (effectKey != null) _t(effectKey),
      if (addressees != null) '${_t('cardv2_matters_for')} $addressees',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    token,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _selectedIndex = null),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child:
                        Icon(Icons.close, size: 16, color: theme.secondaryText),
                  ),
                ),
              ],
            ),
            Text(facts.join(' · '), style: _small(theme)),
            if (promise != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '✦ ${_t('inci_hint_promise').replaceAll('{claim}', promise)}',
                  style: _small(theme, color: _greenText)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            if (active?.status == 'decorative')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_t('cardv2_decorative_note'), style: _small(theme)),
              ),
            if (issueLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(issueLine, style: _small(theme, color: _redText)),
              ),
            const SizedBox(height: 6),
            if (loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: theme.primary),
              )
            else
              Text(
                description ?? _t('inci_hint_no_description'),
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  fontSize: 14,
                  color: description == null
                      ? theme.secondaryText
                      : theme.primaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _skinLabel(String type) {
    final l = _t('skin_$type');
    return l.isEmpty ? type : l;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.textColor,
    required this.label,
  });
  final Color color;
  final Color textColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: textColor, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
