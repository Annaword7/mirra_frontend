import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'ingridients_model.dart';
export 'ingridients_model.dart';

/// New Component Gen
class IngridientsWidget extends StatefulWidget {
  const IngridientsWidget({
    super.key,
    this.ingridients,
    this.topIngredients = const [],
    this.issueIngredients = const [],
  });

  final String? ingridients;
  final List<String> topIngredients;
  final List<String> issueIngredients;

  @override
  State<IngridientsWidget> createState() => _IngridientsWidgetState();
}

class _IngridientsWidgetState extends State<IngridientsWidget> {
  late IngridientsModel _model;

  static const _greenText = Color(0xFF1B5E20);
  static const _greenBg   = Color(0xFFE8F5E9);
  static const _redText   = Color(0xFFB71C1C);
  static const _redBg     = Color(0xFFFFEBEE);

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IngridientsModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.ingridients ?? '';
    final greenSet = widget.topIngredients
        .map((s) => s.toLowerCase().trim())
        .toSet();
    final redSet = widget.issueIngredients
        .map((s) => s.toLowerCase().trim())
        .toSet();

    final hasHighlights = greenSet.isNotEmpty || redSet.isNotEmpty;

    final tokens = raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Build flat list of spans: token + separator
    final spans = <InlineSpan>[];
    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final key = token.toLowerCase();
      final isGreen = greenSet.contains(key);
      final isRed   = redSet.contains(key);

      if (isGreen) {
        spans.add(TextSpan(
          text: token,
          style: TextStyle(
            color: _greenText,
            backgroundColor: _greenBg,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ));
      } else if (isRed) {
        spans.add(TextSpan(
          text: token,
          style: TextStyle(
            color: _redText,
            backgroundColor: _redBg,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ));
      } else {
        spans.add(TextSpan(text: token));
      }

      if (i < tokens.length - 1) {
        spans.add(const TextSpan(text: ', '));
      }
    }

    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    final baseStyle = bodyMedium.override(
          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
          color: FlutterFlowTheme.of(context).secondaryText,
          fontSize: (bodyMedium.fontSize ?? 14) * 0.8,
          letterSpacing: 1.0,
          useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
        ).copyWith(height: 1.6);

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FFLocalizations.of(context).getText(
                '11yiut5a' /* Ingredients (INCI) */,
              ),
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily:
                        FlutterFlowTheme.of(context).titleMediumFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleMediumIsCustom,
                  ),
            ),
            if (tokens.isEmpty)
              Text('-', style: baseStyle)
            else
              Text.rich(
                TextSpan(children: spans),
                style: baseStyle,
              ),
            if (hasHighlights)
              Row(
                children: [
                  _LegendDot(color: _greenBg, textColor: _greenText,
                      label: FFLocalizations.of(context).getText('inci_legend_active')),
                  const SizedBox(width: 12),
                  _LegendDot(color: _redBg, textColor: _redText,
                      label: FFLocalizations.of(context).getText('inci_legend_issues')),
                ],
              ),
          ].divide(const SizedBox(height: 12.0)),
        ),
      ),
    );
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
