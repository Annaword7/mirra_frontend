import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/plural.dart';
import 'card_data.dart';
import 'card_labels.dart';
import 'card_tokens.dart';

/// Просьба раскрыть состав и показать подсказку по ингредиенту: так плашка
/// беременности ведёт к своему компоненту в списке.
class CardCompositionController extends ChangeNotifier {
  String? _reveal;

  String? takeReveal() {
    final name = _reveal;
    _reveal = null;
    return name;
  }

  void reveal(String name) {
    _reveal = name;
    notifyListeners();
  }
}

/// Секция «Состав»: счётчики, свёрнутый список, по тапу подсказка.
///
/// Ингредиенты идут сплошным текстом через запятую в порядке INCI. Выделение
/// только заливкой: полезные successBg, вредные errorBg, внимание info,
/// нейтральные без заливки. После последнего компонента выше 1 % пунктир с
/// подписью. Тап по слову раскрывает плашку под списком: название, вид,
/// причина подсветки и текст: подсказка модели, при беременности текст про
/// противопоказание, у нейтральных описание из словаря ингредиентов.
class CardComposition extends StatefulWidget {
  const CardComposition({
    super.key,
    required this.card,
    required this.pregnant,
    this.controller,
  });

  final ProductCard card;
  final bool pregnant;
  final CardCompositionController? controller;

  @override
  State<CardComposition> createState() => _CardCompositionState();
}

class _CardCompositionState extends State<CardComposition> {
  bool _expanded = false;

  /// Выбранный ингредиент по позиции: дубликаты имён в составе бывают.
  int? _selected;

  /// Описания из словаря: имя → текст (null = искали, не нашли).
  final Map<String, String?> _dictionary = {};
  String? _loadingKey;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onReveal);
  }

  @override
  void didUpdateWidget(covariant CardComposition old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?.removeListener(_onReveal);
      widget.controller?.addListener(_onReveal);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onReveal);
    super.dispose();
  }

  void _onReveal() {
    final name = widget.controller?.takeReveal();
    if (name == null) return;
    final index = widget.card.ingredients.indexWhere((i) => _norm(i.name) == _norm(name));
    if (index < 0) return;
    setState(() {
      _expanded = true;
      _selected = index;
    });
    _ensureDictionary(widget.card.ingredients[index]);
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  static String _norm(String s) => s.toLowerCase().trim();

  String _kindOf(CardIngredient i) => i.kindFor(pregnant: widget.pregnant);

  Color? _fill(FlutterFlowTheme theme, String kind) => switch (kind) {
        'good' => theme.successBg,
        'bad' => theme.errorBg,
        'warn' => theme.info,
        _ => null,
      };

  void _select(int index) {
    setState(() => _selected = _selected == index ? null : index);
    if (_selected != null) _ensureDictionary(widget.card.ingredients[index]);
  }

  /// Описание из словаря нужно только там, где нет своей подсказки.
  Future<void> _ensureDictionary(CardIngredient ing) async {
    if (ing.tip != null || (widget.pregnant && ing.pregnancyClass != null)) return;
    final key = _norm(ing.name);
    if (_dictionary.containsKey(key) || _loadingKey == key) return;
    setState(() => _loadingKey = key);
    String? text;
    try {
      final lang = FFLocalizations.of(context).languageCode;
      final data = await SupaFlow.client
          .rpc('get_ingredient_data', params: {'p_inci_name': ing.name});
      final efficacy = (data is Map) ? data['efficacy'] : null;
      if (efficacy is Map) {
        text = (efficacy['description_$lang'] ?? efficacy['description_en']) as String?;
      }
    } catch (e) {
      debugPrint('[card] dictionary lookup failed for ${ing.name}: $e');
    }
    if (!mounted) return;
    setState(() {
      // Хвост «—» от пустого третьего предложения в словаре не показываем.
      final clean = (text ?? '').replaceAll(RegExp(r'\s*[—–]\s*$'), '').trim();
      _dictionary[key] = clean.isEmpty ? null : clean;
      if (_loadingKey == key) _loadingKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final items = widget.card.ingredients;
    final counts = <String, int>{'good': 0, 'bad': 0, 'warn': 0};
    for (final i in items) {
      final k = _kindOf(i);
      if (counts.containsKey(k)) counts[k] = counts[k]! + 1;
    }

    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardSectionTitle(_t('card_composition')),
          const SizedBox(height: 14),
          Row(
            children: [
              _counter(theme, counts['good']!, _t('card_count_good'), theme.successBg),
              const SizedBox(width: 8),
              _counter(theme, counts['bad']!, _t('card_count_bad'), theme.errorBg),
              const SizedBox(width: 8),
              _counter(theme, counts['warn']!, _t('card_count_warn'), theme.info),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            pluralText(context, 'card_components', items.length),
            style: cardText(theme, size: 13, color: theme.secondaryText, lining: true),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            _list(theme),
          ],
          const SizedBox(height: 14),
          _toggleButton(theme),
        ],
      ),
    );
  }

  Widget _counter(FlutterFlowTheme theme, int n, String label, Color bg) => Expanded(
        child: Container(
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$n',
                  style: cardText(theme, size: 22, weight: FontWeight.w600, height: 1.1, lining: true)),
              const SizedBox(height: 2),
              Text(label, style: cardText(theme, size: 12)),
            ],
          ),
        ),
      );

  Widget _toggleButton(FlutterFlowTheme theme) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            _expanded = !_expanded;
            if (!_expanded) _selected = null;
          }),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: theme.border, width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _t(_expanded ? 'card_collapse' : 'card_expand'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: cardText(theme, size: 15, weight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18),
              ],
            ),
          ),
        ),
      );

  Widget _list(FlutterFlowTheme theme) {
    final items = widget.card.ingredients;
    final line = widget.card.linePosition;
    final aboveCount = line == null ? items.length : (line - 1).clamp(0, items.length);
    final above = items.sublist(0, aboveCount);
    final below = items.sublist(aboveCount);
    final selected = _selected == null ? null : items[_selected!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _paragraph(theme, above, offset: 0),
        if (below.isNotEmpty) ...[
          const SizedBox(height: 12),
          _lineDivider(theme),
          const SizedBox(height: 12),
          _paragraph(theme, below, offset: aboveCount),
        ],
        const SizedBox(height: 12),
        if (selected != null)
          _tip(theme, selected)
        else
          Text(_t('card_tap_hint'), style: cardText(theme, size: 12, color: theme.secondaryText)),
      ],
    );
  }

  Widget _paragraph(FlutterFlowTheme theme, List<CardIngredient> part, {required int offset}) {
    final base = cardText(theme, size: 13, height: 1.75);
    final spans = <InlineSpan>[];
    for (var i = 0; i < part.length; i++) {
      final index = offset + i;
      final ing = part[i];
      final kind = _kindOf(ing);
      final isSelected = _selected == index;
      final fill = _fill(theme, kind);
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: GestureDetector(
          onTap: () => _select(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected && fill == null ? theme.divider : fill,
              borderRadius: BorderRadius.circular(4),
              border: isSelected ? Border.all(color: theme.primaryText, width: 1.5) : null,
            ),
            child: Text(ing.name, style: base),
          ),
        ),
      ));
      if (i < part.length - 1) spans.add(TextSpan(text: ', ', style: base));
    }
    return Text.rich(TextSpan(children: spans), style: base);
  }

  Widget _lineDivider(FlutterFlowTheme theme) => Row(
        children: [
          Expanded(child: _Dashes(color: theme.textDisabled)),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _t('card_below_one_percent'),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: cardText(theme, size: 11, weight: FontWeight.w700,
                    color: theme.secondaryText, letterSpacing: 0.2),
              ),
            ),
          ),
          Expanded(child: _Dashes(color: theme.textDisabled)),
        ],
      );

  Widget _tip(FlutterFlowTheme theme, CardIngredient ing) {
    final kind = _kindOf(ing);
    final pregnancyHit = widget.pregnant && ing.pregnancyClass != null;
    final key = _norm(ing.name);
    final loading = _loadingKey == key;

    String? text;
    if (pregnancyHit) {
      text = _t('card_pregnancy_tip');
    } else if (ing.tip != null) {
      text = ing.tip;
    } else if (_dictionary.containsKey(key)) {
      text = _dictionary[key] ?? (kind == 'plain' ? _t('card_plain_tip') : _t('card_no_description'));
    } else if (!loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDictionary(ing));
    }

    final reason = pregnancyHit ? _t('card_reason_pregnancy') : _t(reasonLabelKey(ing.reason));
    final addressees = ing.forWhom.isEmpty
        ? ''
        : ing.forWhom.contains('all')
            ? _t('card_for_all')
            : ing.forWhom.map((s) => _skinLabel(s).toLowerCase()).join(', ');
    final reasonLine = [
      if (reason.isNotEmpty) reason,
      if (addressees.isNotEmpty) '${_t('card_matters_for')} $addressees',
    ].join(' · ');

    final bg = _fill(theme, kind) ?? CardTokens.surfaceMuted;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(ing.name, style: cardText(theme, size: 14, weight: FontWeight.w600)),
                    Text(_t(kindLabelKey(kind)), style: cardText(theme, size: 12)),
                  ],
                ),
                if (reasonLine.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(reasonLine, style: cardText(theme, size: 12, color: theme.secondaryText)),
                ],
                const SizedBox(height: 4),
                if (text != null)
                  Text(text, style: cardText(theme, size: 13, height: 1.45))
                else
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () => setState(() => _selected = null),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.close, size: 16, color: theme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  String _skinLabel(String type) {
    final l = _t('skin_$type');
    return l.isEmpty ? type : l;
  }
}

/// Пунктир линии 1 %: у Flutter нет пунктирной границы из коробки.
class _Dashes extends StatelessWidget {
  const _Dashes({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 1.5,
        child: CustomPaint(painter: _DashPainter(color)),
      );
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    const dash = 4.0, gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset((x + dash).clamp(0, size.width), size.height / 2), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
