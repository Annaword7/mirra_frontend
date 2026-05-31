import 'dart:math';
import 'dart:ui' as ui;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

Color _scoreColor(double score) {
  if (score >= 75) return const Color(0xFF1B5E20);
  if (score >= 65) return const Color(0xFF43A047);
  if (score >= 55) return const Color(0xFFC0CA33);
  if (score >= 45) return const Color(0xFFFFB300);
  if (score >= 35) return const Color(0xFFFF7043);
  return const Color(0xFFD32F2F);
}

// ─── Radar data models ────────────────────────────────────

class _DotData {
  const _DotData({
    required this.pos,
    required this.tier,
    required this.isIssue,
  });
  final int pos;   // position in INCI list (1 = first = high concentration)
  final int tier;  // 1–5, drives dot radius
  final bool isIssue; // false = efficacy active (green), true = safety issue (red)
}

class _AxisData {
  const _AxisData({required this.label, required this.score, this.dots = const []});
  final String label;
  final double score; // 0–100
  final List<_DotData> dots;
}

// ─── Parsing helpers ──────────────────────────────────────

List<_DotData> _parseEfficacyDots(dynamic section) {
  if (section == null) return [];
  final factors = section['key_factors'];
  if (factors is! List) return [];

  final posRe = RegExp(r'pos #(\d+)');
  final tierRe = RegExp(r'(?:tier|strength) (\d+)');
  final dots = <_DotData>[];

  for (final f in factors) {
    final s = f.toString();
    final posM = posRe.firstMatch(s);
    final tierM = tierRe.firstMatch(s);
    if (posM != null && tierM != null) {
      dots.add(_DotData(
        pos: int.parse(posM.group(1)!),
        tier: int.parse(tierM.group(1)!),
        isIssue: false,
      ));
    }
  }
  return dots;
}

List<_DotData> _parseSafetyDots(dynamic section) {
  if (section == null) return [];
  final factors = section['key_factors'];
  if (factors is! List) return [];

  final posRe = RegExp(r'pos #(\d+)');
  final dots = <_DotData>[];

  for (final f in factors) {
    final s = f.toString();
    if (s.contains('(+')) continue; // positive factor, no dot
    final posM = posRe.firstMatch(s);
    if (posM != null) {
      dots.add(_DotData(
        pos: int.parse(posM.group(1)!),
        tier: 3, // safety issues carry no tier metadata
        isIssue: true,
      ));
    }
  }
  return dots;
}

double _axisScore(dynamic section) {
  if (section == null) return 0.0;
  final raw = section['score'];
  return raw is num ? raw.toDouble() : 0.0;
}

// ─── CustomPainter ────────────────────────────────────────

class _RadarPainter extends CustomPainter {
  const _RadarPainter(this.axes);
  final List<_AxisData> axes; // exactly 5, clockwise from top

  static const _maxPos = 25.0; // pos >= this → near center

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

    // ── 2. Ring % labels (on axis 0) ──────────────────────
    final pctStyle = const TextStyle(fontSize: 7.5, color: Color(0x66000000));
    for (final t in [0.25, 0.5, 0.75]) {
      final p = ap(0, t) + const Offset(5, -8);
      _drawText(canvas, '${(t * 100).round()}', pctStyle, p);
    }

    // ── 3. Axis lines ─────────────────────────────────────
    final axisP = Paint()
      ..color = const Color(0x1A000000)
      ..strokeWidth = 0.8;
    for (int i = 0; i < n; i++) {
      canvas.drawLine(center, ap(i, 1.0), axisP);
    }

    // ── 4. Score polygon ──────────────────────────────────
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

    // score vertex dots
    final vtxP = Paint()..color = const Color(0xFF3B6FCC);
    for (int i = 0; i < n; i++) {
      final t = (axes[i].score / 100.0).clamp(0.0, 1.0);
      canvas.drawCircle(ap(i, t), 3.5, vtxP);
    }

    // ── 5. Ingredient dots ────────────────────────────────
    for (int i = 0; i < n; i++) {
      for (final dot in axes[i].dots) {
        // pos 1 → t≈0.95 (far, high concentration)
        // pos 25+ → t≈0.05 (near center, trace)
        final t = ((_maxPos - dot.pos) / (_maxPos - 1)).clamp(0.05, 0.95);
        final dc = ap(i, t);
        final dr = (dot.tier * 2.8 + 2.5).clamp(5.0, 17.0);
        final color = dot.isIssue ? const Color(0xFFE53935) : const Color(0xFF2E7D32);

        canvas.drawCircle(dc, dr,
            Paint()..color = color.withValues(alpha: 0.22));
        canvas.drawCircle(
            dc,
            dr,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6);
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
    for (int i = 0; i < n; i++) {
      // Place label slightly beyond the axis tip
      final lp = ap(i, 1.22);
      _drawCentered(canvas, axes[i].label, lblStyle, lp);
      final sp = ap(i, 1.36);
      _drawCentered(canvas, '${axes[i].score.round()}', scoreStyle, sp);
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
  bool shouldRepaint(_RadarPainter old) => false;
}

// ─── Radar legend ─────────────────────────────────────────

class _RadarLegend extends StatelessWidget {
  const _RadarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendItem(
          child: Container(
            width: 24, height: 10,
            decoration: BoxDecoration(
              color: const Color(0x284E7FE8),
              border: Border.all(color: const Color(0xFF3B6FCC), width: 1.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          label: 'Score',
        ),
        _LegendItem(
          child: _tierDots(const Color(0xFF2E7D32)),
          label: 'Active (tier 3→5)',
        ),
        _LegendItem(
          child: _tierDots(const Color(0xFFE53935)),
          label: 'Issue',
        ),
        _LegendItem(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(10, const Color(0xFF2E7D32)),
              const SizedBox(width: 2),
              const Text('←', style: TextStyle(fontSize: 8, color: Color(0xFF888888))),
              const SizedBox(width: 2),
              _dot(10, const Color(0xFF2E7D32)),
            ],
          ),
          label: 'Edge=top of formula',
        ),
      ],
    );
  }

  static Widget _tierDots(Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(11.3, color), // tier 3: 2.8*3+2.5=11.0
          const SizedBox(width: 2),
          _dot(13.7, color), // tier 4: 2.8*4+2.5=13.7
          const SizedBox(width: 2),
          _dot(16.5, color), // tier 5: 2.8*5+2.5=16.5
        ],
      );

  static Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.22),
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
        Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF667799))),
      ],
    );
  }
}

// ─── Main widget ──────────────────────────────────────────

class ScoreBreakdownWidget extends StatelessWidget {
  const ScoreBreakdownWidget({super.key, required this.scoringLog});

  final dynamic scoringLog;

  @override
  Widget build(BuildContext context) {
    if (scoringLog == null) return const SizedBox.shrink();

    final Map<String, dynamic> log;
    try {
      log = Map<String, dynamic>.from(scoringLog as Map);
    } catch (_) {
      return const SizedBox.shrink();
    }

    final lang = FFLocalizations.of(context).languageCode;
    final theme = FlutterFlowTheme.of(context);

    // Build the 5 radar axes in order: Safety, Efficacy, Stability, Non-Comed., UX
    final axes = [
      _AxisData(
        label: lang == 'ru' ? 'Безопас.' : lang == 'es' ? 'Seguridad' : 'Safety',
        score: _axisScore(log['safety']),
        dots: _parseSafetyDots(log['safety']),
      ),
      _AxisData(
        label: lang == 'ru' ? 'Эффект.' : lang == 'es' ? 'Eficacia' : 'Efficacy',
        score: _axisScore(log['efficacy']),
        dots: _parseEfficacyDots(log['efficacy']),
      ),
      _AxisData(
        label: lang == 'ru' ? 'Стабил.' : lang == 'es' ? 'Estabilidad' : 'Stability',
        score: _axisScore(log['stability']),
      ),
      _AxisData(
        label: lang == 'ru' ? 'Некомед.' : lang == 'es' ? 'No Comed.' : 'Non-Comed.',
        score: _axisScore(log['comedogenicity']),
      ),
      _AxisData(
        label: 'UX',
        score: _axisScore(log['user_experience']),
      ),
    ];

    final sections = [
      _SectionDef(
        key: 'safety',
        label: lang == 'ru' ? 'Безопасность' : lang == 'es' ? 'Seguridad' : 'Safety',
        icon: Icons.shield_outlined,
      ),
      _SectionDef(
        key: 'efficacy',
        label: lang == 'ru' ? 'Эффективность' : lang == 'es' ? 'Eficacia' : 'Efficacy',
        icon: Icons.science_outlined,
      ),
      _SectionDef(
        key: 'stability',
        label: lang == 'ru' ? 'Стабильность' : lang == 'es' ? 'Estabilidad' : 'Stability',
        icon: Icons.thermostat_outlined,
      ),
      _SectionDef(
        key: 'comedogenicity',
        label: lang == 'ru' ? 'Некомедогенность' : lang == 'es' ? 'No Comedogénico' : 'Non-Comedogenic',
        icon: Icons.face_retouching_natural_outlined,
      ),
      _SectionDef(
        key: 'user_experience',
        label: lang == 'ru' ? 'Опыт применения' : lang == 'es' ? 'Experiencia' : 'User Experience',
        icon: Icons.spa_outlined,
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Radar chart ───────────────────────────────
          SizedBox(
            height: 270,
            child: CustomPaint(
              painter: _RadarPainter(axes),
              size: Size.infinite,
            ),
          ),
          const _RadarLegend(),
          const Divider(height: 28, thickness: 0.5),

          // ── Детали анализа ────────────────────────────
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: theme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                lang == 'ru'
                    ? 'Детали анализа'
                    : lang == 'es'
                        ? 'Detalles del análisis'
                        : 'Score Breakdown',
                style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: theme.primaryText,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts: !theme.titleSmallIsCustom,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sections.map((s) => _buildSection(context, s, log[s.key])),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, _SectionDef def, dynamic data) {
    if (data == null) return const SizedBox.shrink();

    final Map<String, dynamic> section;
    try {
      section = Map<String, dynamic>.from(data as Map);
    } catch (_) {
      return const SizedBox.shrink();
    }

    final rawScore = section['score'];
    final double score = rawScore is num ? rawScore.toDouble() : 0.0;
    final factors = section['key_factors'];
    final List<String> keyFactors =
        factors is List ? factors.map((e) => e.toString()).toList() : [];

    final color = _scoreColor(score);
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(def.icon, size: 14, color: theme.secondaryText),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  def.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.secondaryText,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Text(
                '${score.round()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            percent: (score / 100.0).clamp(0.0, 1.0),
            lineHeight: 6.0,
            backgroundColor: color.withValues(alpha: 0.12),
            progressColor: color,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            animation: true,
          ),
          if (keyFactors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: keyFactors.map((f) => _FactorChip(text: f)).toList(),
            ),
          ],
          const Divider(height: 24, thickness: 0.5),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────

class _SectionDef {
  const _SectionDef({required this.key, required this.label, required this.icon});
  final String key;
  final String label;
  final IconData icon;
}

class _FactorChip extends StatelessWidget {
  const _FactorChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final bool positive = text.contains('(+');
    final bool negative = text.contains('(-');

    final bgColor = positive
        ? const Color(0xFFE8F5E9)
        : negative
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFF0F4FF);
    final textColor = positive
        ? const Color(0xFF2E7D32)
        : negative
            ? const Color(0xFFC62828)
            : const Color(0xFF445588);
    final icon = positive
        ? Icons.add_circle_outline
        : negative
            ? Icons.remove_circle_outline
            : Icons.info_outline;

    String label = text;
    if (label.length > 48) label = '${label.substring(0, 46)}…';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: textColor,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
