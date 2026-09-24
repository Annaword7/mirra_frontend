import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/design_system/foundations/score_status.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Из чего сложилась оценка: пять осей числами, свёрнутые под заголовком.
///
/// Раньше здесь был радар — пятиугольник без единиц измерения, который читался
/// как «график с работы»: значения осей приходилось угадывать по форме, а
/// легенда занимала три ряда чипов. Те же пять чисел списком отвечают на вопрос
/// «почему такая оценка» прямо: видно, где у формулы просадка.
///
/// Веса осей (композит — их взвешенная сумма) сюда пока не попадают: бэкенд их
/// считает, но в `sa_scoring_log` не сохраняет. Поэтому итог не суммируем и
/// сумму не показываем — обещать арифметику, которой нет под рукой, нельзя.
class ScoreBreakdownWidget extends StatefulWidget {
  const ScoreBreakdownWidget({
    super.key,
    required this.scoringLog,
    this.topIngredients = const [],
    this.ingredientIssues = const [],
  });

  final dynamic scoringLog;
  final List<ImageTopIngredientsRow> topIngredients;
  final List<ImageIngredientIssuesRow> ingredientIssues;

  @override
  State<ScoreBreakdownWidget> createState() => _ScoreBreakdownWidgetState();
}

class _ScoreBreakdownWidgetState extends State<ScoreBreakdownWidget> {
  /// Свёрнуто: к моменту, когда человек доходит до числа, он уже прошёл линию
  /// 1 % и позиции обещанных активов — объяснение оценки у него в голове.
  /// Пять осей цифрами здесь второй слой, по стрелке.
  bool _expanded = false;

  String _t(String key) => FFLocalizations.of(context).getText(key);

  /// Оси в постоянном порядке: так форма продукта узнаётся от карточки к
  /// карточке, а не пересобирается каждый раз заново.
  static const _axisKeys = <(String logKey, String labelKey)>[
    ('safety', 'dim_safety'),
    ('efficacy', 'dim_efficacy'),
    ('comedogenicity', 'dim_pore_safety'),
    ('stability', 'dim_stability'),
    ('user_experience', 'dim_experience'),
  ];

  double? _axisScore(Map<String, dynamic> log, String key) {
    final raw = log[key];
    if (raw is Map && raw['score'] is num) return (raw['score'] as num).toDouble();
    if (raw is num) return raw.toDouble();
    return null;
  }

  /// Ингредиент с наибольшим вкладом в эффективность — тот самый «главный
  /// плюс». Вклад считает бэкенд, он уже лежит в image_top_ingredients.
  ImageTopIngredientsRow? get _biggestPlus {
    ImageTopIngredientsRow? best;
    for (final ing in widget.topIngredients) {
      final c = ing.efficacyContribution;
      if (c == null || c <= 0) continue;
      if (best == null || c > (best.efficacyContribution ?? 0)) best = ing;
    }
    return best;
  }

  /// Самое тяжёлое замечание: сначала high, иначе первое из списка.
  ImageIngredientIssuesRow? get _biggestMinus {
    if (widget.ingredientIssues.isEmpty) return null;
    for (final issue in widget.ingredientIssues) {
      if (issue.severity == 'high') return issue;
    }
    return widget.ingredientIssues.first;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scoringLog == null) return const SizedBox.shrink();
    final Map<String, dynamic> log;
    try {
      log = Map<String, dynamic>.from(widget.scoringLog as Map);
    } catch (_) {
      return const SizedBox.shrink();
    }

    final theme = FlutterFlowTheme.of(context);
    final axes = [
      for (final (logKey, labelKey) in _axisKeys)
        if (_axisScore(log, logKey) != null)
          (label: _t(labelKey), score: _axisScore(log, logKey)!),
    ];
    if (axes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _t('score_axes_title'),
                      style: theme.labelMedium.override(
                        fontFamily: theme.labelMediumFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.labelMediumIsCustom,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 4),
            for (final axis in axes) _axisRow(theme, axis.label, axis.score),
            _plusMinus(theme),
          ],
        ],
      ),
    );
  }

  Widget _axisRow(FlutterFlowTheme theme, String label, double score) {
    final color = semanticScoreColor(score);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontSize: 13,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                color: theme.surfaceMuted,
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: (score / 100).clamp(0.0, 1.0),
                  child: Container(color: color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 26,
            child: Text(
              '${score.round()}',
              textAlign: TextAlign.right,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Что тянет оценку вверх и вниз. Не баллы: повклад отдельных ингредиентов в
  /// итоговое число бэкенд наружу не отдаёт, поэтому называем главное, а не
  /// придумываем «+18».
  Widget _plusMinus(FlutterFlowTheme theme) {
    final plus = _biggestPlus;
    final minus = _biggestMinus;
    if (plus == null && minus == null) return const SizedBox.shrink();

    Widget line(IconData icon, Color color, String caption, String value) =>
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                    children: [
                      TextSpan(text: '$caption  '),
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plus != null)
            line(
              Icons.arrow_upward_rounded,
              kStatusWorking,
              _t('score_axes_plus'),
              [
                plus.ingredientName,
                if (plus.status != null) _t('cardv2_status_${plus.status}'),
              ].where((s) => s.isNotEmpty).join(' · '),
            ),
          if (minus != null)
            line(
              Icons.arrow_downward_rounded,
              kScoreF,
              _t('score_axes_minus'),
              minus.ingredientName,
            ),
        ],
      ),
    );
  }
}
