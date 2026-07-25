import 'dart:math';
import 'dart:ui' as ui;
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/foundations/score_status.dart';
import 'package:flutter/material.dart';

// ─── Radar data models ────────────────────────────────────

/// One ingredient plotted on an axis. INCI position drives the radius
/// (edge = top of the list = high concentration; center = trace); colour
/// and fill encode dose status (actives) or severity (issues).
class _DotData {
  const _DotData({
    required this.pos,
    required this.radius,
    required this.color,
    required this.filled,
  });
  final int pos; // INCI position (1 = first)
  final double radius; // px
  final Color color;
  final bool filled; // false = hollow (decorative / trace amount)
}

class _AxisData {
  const _AxisData(
      {required this.label, required this.score, this.dots = const []});
  final String label;
  final double score; // 0–100
  final List<_DotData> dots;
}

double _axisScore(dynamic section) {
  if (section == null) return 0.0;
  final raw = section['score'];
  return raw is num ? raw.toDouble() : 0.0;
}

// ─── CustomPainter ────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  const _RadarPainter(this.axes, {this.onePercentPos, this.totalInci = 25});
  final List<_AxisData> axes; // exactly 5, clockwise from top
  final int? onePercentPos; // INCI position where the ≤1% zone starts
  final int totalInci; // total ingredient count (radial scale)

  // INCI position → radial fraction (edge 0.95 = pos 1; center 0.05 = last).
  double _posToT(int pos) {
    final n = totalInci < 2 ? 25 : totalInci;
    final frac = ((pos - 1) / (n - 1)).clamp(0.0, 1.0);
    return (0.95 - frac * 0.90).clamp(0.05, 0.95);
  }

  // Polar → cartesian along axis i at fraction t (0 = center, 1 = edge)
  Offset _pt(Offset c, double r, List<double> angles, int i, double t) {
    final a = angles[i];
    return c + Offset(cos(a) * r * t, sin(a) * r * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 44.0;
    final n = axes.length;
    final angles = List.generate(n, (i) => -pi / 2 + 2 * pi * i / n);
    Offset ap(int i, double t) => _pt(center, radius, angles, i, t);

    // ── 1. Grid rings ──────────────────────────────────────
    final gridP = Paint()
      ..color = const Color(0x14000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final t in [0.25, 0.5, 0.75, 1.0]) {
      final path = Path();
      for (int i = 0; i < n; i++) {
        final p = ap(i, t);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, gridP);
    }

    // ── 2. Axis lines ─────────────────────────────────────
    final axisP = Paint()
      ..color = const Color(0x1A000000)
      ..strokeWidth = 0.8;
    for (int i = 0; i < n; i++) {
      canvas.drawLine(center, ap(i, 1.0), axisP);
    }

    // ── 3. Score polygon ──────────────────────────────────
    final fillP = Paint()
      ..color = const Color(0x284E7FE8)
      ..style = PaintingStyle.fill;
    final strokeP = Paint()
      ..color = const Color(0xFF3B6FCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    final poly = Path();
    for (int i = 0; i < n; i++) {
      final t = (axes[i].score / 100.0).clamp(0.0, 1.0);
      final p = ap(i, t);
      i == 0 ? poly.moveTo(p.dx, p.dy) : poly.lineTo(p.dx, p.dy);
    }
    poly.close();
    canvas.drawPath(poly, fillP);
    canvas.drawPath(poly, strokeP);

    final vtxP = Paint()..color = const Color(0xFF3B6FCC);
    for (int i = 0; i < n; i++) {
      final t = (axes[i].score / 100.0).clamp(0.0, 1.0);
      canvas.drawCircle(ap(i, t), 3.5, vtxP);
    }

    // ── 4. 1% line ring (concentration threshold for the dots) ─────
    if (onePercentPos != null) {
      final rRing = radius * _posToT(onePercentPos!);
      _drawDashedCircle(
        canvas,
        center,
        rRing,
        Paint()
          ..color = const Color(0xCCF9A825)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      _drawText(
        canvas,
        '1%',
        const TextStyle(
          fontSize: 8,
          color: Color(0xFFB8860B),
          fontWeight: FontWeight.w700,
        ),
        center + Offset(3, -rRing - 11),
      );
    }

    // ── 5. Ingredient dots ────────────────────────────────
    for (int i = 0; i < n; i++) {
      for (final dot in axes[i].dots) {
        final dc = ap(i, _posToT(dot.pos));
        if (dot.filled) {
          canvas.drawCircle(dc, dot.radius,
              Paint()..color = dot.color.withValues(alpha: 0.22));
        }
        canvas.drawCircle(
          dc,
          dot.radius,
          Paint()
            ..color = dot.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }

    // ── 6. Axis labels ────────────────────────────────────
    final lblStyle = const TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      color: Color(0xFF445588),
      height: 1.25,
    );
    final scoreStyle = const TextStyle(
      fontSize: 9,
      color: Color(0xFF667799),
      fontWeight: FontWeight.w600,
    );
    // Per-axis label distance (fraction of radius). Axis 0 = Safety (top).
    const labelDist = [1.36, 1.22, 1.22, 1.22, 1.22];

    for (int i = 0; i < n; i++) {
      final lp = ap(i, labelDist[i]);
      final cosA = cos(angles[i]);

      final lblTp = TextPainter(
        text: TextSpan(text: axes[i].label, style: lblStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      final scoreTp = TextPainter(
        text: TextSpan(text: '${axes[i].score.round()}', style: scoreStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      // Horizontal alignment based on which side of the radar the axis is on:
      //   right side (cosA > 0.3): left-align — text starts at lp.x
      //   left side  (cosA < -0.3): right-align — text ends at lp.x
      //   top/bottom (|cosA| ≤ 0.3): centered around lp.x
      double xOff(double w) {
        if (cosA > 0.3) return 0;
        if (cosA < -0.3) return -w;
        return -w / 2;
      }

      lblTp.paint(canvas, lp + Offset(xOff(lblTp.width), -lblTp.height / 2));

      // Score directly below the label, same horizontal alignment
      final scoreTop = lp.dy + lblTp.height / 2 + 2;
      scoreTp.paint(canvas, Offset(lp.dx + xOff(scoreTp.width), scoreTop));
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double r, Paint p) {
    if (r <= 0) return;
    const dash = 4.0, gap = 3.5;
    final count = (2 * pi * r / (dash + gap)).floor().clamp(8, 240);
    final step = 2 * pi / count;
    final sweep = step * dash / (dash + gap);
    final rect = Rect.fromCircle(center: center, radius: r);
    for (int i = 0; i < count; i++) {
      canvas.drawArc(rect, i * step, sweep, false, p);
    }
  }

  void _drawText(Canvas canvas, String text, TextStyle style, Offset origin) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, origin);
  }

  void _drawCentered(Canvas canvas, String text, TextStyle style, Offset center) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_RadarPainter old) => true;
}

// ─── Radar legend ─────────────────────────────────────────

class _RadarLegend extends StatelessWidget {
  const _RadarLegend({required this.showOnePercent});
  final bool showOnePercent;

  @override
  Widget build(BuildContext context) {
    String t(String k) => FFLocalizations.of(context).getText(k);
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendItem(
          child: Container(
            width: 24,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0x284E7FE8),
              border: Border.all(color: const Color(0xFF3B6FCC), width: 1.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          label: t('radar_score'),
        ),
        _LegendItem(
          child: _dot(12, kStatusWorking, true),
          label: t('radar_working'),
        ),
        _LegendItem(
          child: _dot(12, kStatusBorderline, true),
          label: t('radar_borderline'),
        ),
        _LegendItem(
          child: _dot(12, kStatusDecorative, false),
          label: t('radar_trace'),
        ),
        _LegendItem(
          child: _dot(12, const Color(0xFFE53935), true),
          label: t('radar_issue'),
        ),
        if (showOnePercent)
          _LegendItem(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsets.only(right: 2),
                    width: 4,
                    height: 1.8,
                    color: const Color(0xFFB8860B),
                  ),
              ],
            ),
            label: t('radar_one_percent'),
          ),
      ],
    );
  }

  static Widget _dot(double size, Color color, bool filled) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color.withValues(alpha: 0.22) : Colors.transparent,
          border: Border.all(color: color, width: 1.4),
        ),
      );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.child, required this.label});
  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF667799))),
      ],
    );
  }
}

// ─── Main widget ──────────────────────────────────────────

class ScoreBreakdownWidget extends StatelessWidget {
  const ScoreBreakdownWidget({
    super.key,
    required this.scoringLog,
    this.topIngredients = const [],
    this.ingredientIssues = const [],
    this.inciList = const [],
    this.onePercentLinePos,
  });

  final dynamic scoringLog;
  final List<ImageTopIngredientsRow> topIngredients;
  final List<ImageIngredientIssuesRow> ingredientIssues;
  final List<String> inciList; // INCI names in position order (issue lookup)
  final int? onePercentLinePos;

  @override
  Widget build(BuildContext context) {
    if (scoringLog == null) return const SizedBox.shrink();

    final Map<String, dynamic> log;
    try {
      log = Map<String, dynamic>.from(scoringLog as Map);
    } catch (_) {
      return const SizedBox.shrink();
    }

    String tr(String k) => FFLocalizations.of(context).getText(k);

    // Active dots (efficacy axis) — coloured by dose status, sized by contribution.
    final activeDots = <_DotData>[];
    for (final ing in topIngredients) {
      final pos = ing.inciPosition;
      if (pos == null) continue;
      // Dose-status colors from the shared foundation (working green /
      // borderline amber / decorative & unknown grey); decorative is hollow.
      final c = statusColor(ing.status);
      final filled = ing.status != 'decorative';
      final contrib = ing.efficacyContribution ?? 0;
      activeDots.add(_DotData(
        pos: pos,
        radius: (6.0 + contrib / 100.0 * 10.0).clamp(6.0, 16.0),
        color: c,
        filled: filled,
      ));
    }

    // Issue dots (safety axis) — position resolved via the INCI list, size by severity.
    final issueDots = <_DotData>[];
    for (final issue in ingredientIssues) {
      final idx = inciList.indexWhere(
          (nm) => nm.toLowerCase() == issue.ingredientName.toLowerCase());
      if (idx < 0) continue;
      final high = issue.severity == 'high';
      issueDots.add(_DotData(
        pos: idx + 1,
        radius: high ? 14.0 : 10.0,
        color: high ? const Color(0xFFC62828) : const Color(0xFFE53935),
        filled: true,
      ));
    }

    // 5 radar axes in order: Safety, Efficacy, Stability, Non-Comed., Experience.
    // Labels reuse the localized dim_* keys (all 11 app languages).
    final axes = [
      _AxisData(
        label: tr('dim_safety'),
        score: _axisScore(log['safety']),
        dots: issueDots,
      ),
      _AxisData(
        label: tr('dim_efficacy'),
        score: _axisScore(log['efficacy']),
        dots: activeDots,
      ),
      _AxisData(
        label: tr('dim_stability'),
        score: _axisScore(log['stability']),
      ),
      _AxisData(
        label: tr('dim_pore_safety'),
        score: _axisScore(log['comedogenicity']),
      ),
      _AxisData(
        label: tr('dim_experience'),
        score: _axisScore(log['user_experience']),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 270,
            child: CustomPaint(
              painter: _RadarPainter(
                axes,
                onePercentPos: onePercentLinePos,
                totalInci: inciList.length,
              ),
              size: Size.infinite,
            ),
          ),
          _RadarLegend(showOnePercent: onePercentLinePos != null),
        ],
      ),
    );
  }
}
