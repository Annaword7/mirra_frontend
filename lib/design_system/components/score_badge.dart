import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '/design_system/foundations/score_status.dart';

/// The product score badge (Design Review Initiative 7): a white pill showing a
/// circular grade ring + "N/100", colored by [semanticScoreColor]. Replaces the
/// two near-identical `_ScoreBadge` widgets in the product tiles; the only real
/// difference — tile A's extra score-colored glow — is now the [glow] flag
/// (review #4's accidental shadow drift becomes a deliberate variant). Renders a
/// neutral "···" placeholder when [score] is null.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score, this.glow = false});

  final double? score;

  /// Adds a score-colored glow shadow behind the pill (tile A).
  final bool glow;

  Widget _wrapper({required List<BoxShadow> shadows, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: shadows,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const baseShadow = BoxShadow(
      blurRadius: 8.0,
      color: Color(0x33000000),
      offset: Offset(0.0, 2.0),
    );

    if (score == null) {
      return _wrapper(
        shadows: const [baseShadow],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science_outlined, size: 18.0, color: Colors.grey.shade400),
            const SizedBox(width: 6.0),
            Text(
              '···',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    final c = semanticScoreColor(score!);
    return _wrapper(
      shadows: [
        baseShadow,
        if (glow)
          BoxShadow(
            blurRadius: 10.0,
            color: c.withValues(alpha: 0.35),
            offset: const Offset(0.0, 2.0),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 20.0,
            lineWidth: 3.5,
            percent: (score! / 100.0).clamp(0.0, 1.0),
            backgroundColor: c.withValues(alpha: 0.15),
            progressColor: c,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            center: Text(
              scoreGrade(score!),
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: c,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            '${score!.toStringAsFixed(0)}/100',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
