import 'dart:math';
import 'package:flutter/material.dart';
import '/backend/supabase/database/tables/image_top_ingredients.dart';
import '/flutter_flow/internationalization.dart';

// ── Colour palette by dose-status ─────────────────────────────────────────
const _kWorking = Color(0xFFFFB300);    // amber  — активно работает
const _kBorderline = Color(0xFF78909C); // steel  — на грани
const _kDecorative = Color(0xFF90A4AE); // muted  — декоративный
const _kUnknown = Color(0xFFBDBDBD);    // grey   — статус неизвестен

Color _statusColor(String? status) => switch (status) {
      'working' => _kWorking,
      'borderline' => _kBorderline,
      'decorative' => _kDecorative,
      _ => _kUnknown,
    };

String _statusLabel(BuildContext context, String? status) {
  final loc = FFLocalizations.of(context);
  return switch (status) {
    'working' => loc.getText('ib_status_working'),
    'borderline' => loc.getText('ib_status_borderline'),
    'decorative' => loc.getText('ib_status_decorative'),
    _ => '',
  };
}

// ── Parse "~2%" / "2-5%" / "5%" into a mid-point double 0..100 ───────────
double _parseConc(String? raw) {
  if (raw == null || raw.isEmpty) return 0;
  final digits = RegExp(r'[\d.]+').allMatches(raw).map((m) => double.tryParse(m.group(0)!) ?? 0).toList();
  if (digits.isEmpty) return 0;
  return digits.length == 1 ? digits[0] : (digits[0] + digits[1]) / 2;
}

// ── Per-bubble state ───────────────────────────────────────────────────────
class _Bubble {
  _Bubble({
    required this.name,
    required this.status,
    required this.conc,
    required this.radius,
    required this.color,
    required this.phase,
    required this.freqX,
    required this.freqY,
    required this.ampX,
    required this.ampY,
    required this.baseX,
    required this.baseY,
  });

  final String name;
  final String? status;
  final double conc;
  final double radius;
  final Color color;

  // sine-wave params for gentle drift
  final double phase;
  final double freqX, freqY;
  final double ampX, ampY;
  double baseX, baseY;

  Offset position(double t) => Offset(
        baseX + sin(t * freqX + phase) * ampX,
        baseY + cos(t * freqY + phase * 1.3) * ampY,
      );
}

// ── Widget ─────────────────────────────────────────────────────────────────
class IngredientBubblesWidget extends StatefulWidget {
  const IngredientBubblesWidget({
    super.key,
    required this.ingredients,
    this.height = 340,
  });

  final List<ImageTopIngredientsRow> ingredients;
  final double height;

  @override
  State<IngredientBubblesWidget> createState() => _IngredientBubblesWidgetState();
}

class _IngredientBubblesWidgetState extends State<IngredientBubblesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  List<_Bubble> _bubbles = [];
  int? _tapped;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _layout();
  }

  @override
  void didUpdateWidget(IngredientBubblesWidget old) {
    super.didUpdateWidget(old);
    if (old.ingredients != widget.ingredients) _layout();
  }

  void _layout() {
    final rng = Random(42);
    final w = MediaQuery.sizeOf(context).width;
    final h = widget.height;

    final items = widget.ingredients.take(18).toList();

    // Radius: biggest for working, scale by concentration if known
    double _r(ImageTopIngredientsRow ing, int idx) {
      double base = 28.0 - idx * 0.8;
      final conc = _parseConc(ing.estimatedConcentration);
      if (conc > 0) base = (conc.clamp(0.5, 25) / 25 * 38 + 18).toDouble();
      if (ing.status == 'working') base *= 1.15;
      return base.clamp(16.0, 52.0);
    }

    // Precompute radii, then sort biggest-first so large bubbles sit at
    // the centre and small ones spiral outward.
    final ranked = [
      for (int i = 0; i < items.length; i++) (ing: items[i], r: _r(items[i], i)),
    ]..sort((a, b) => b.r.compareTo(a.r));

    final n = ranked.length;
    final cx = w / 2;
    final cy = h / 2;
    final maxDist = min(w, h) / 2 - 40;
    const goldenAngle = 2.399963; // radians — even areal spread

    _bubbles = List.generate(n, (i) {
      final ing = ranked[i].ing;
      final r = ranked[i].r;
      // sqrt spacing → uniform density; biggest (i=0) lands near centre.
      final dist = maxDist * sqrt(i / max(1, n - 1));
      final angle = i * goldenAngle;
      final bx = cx + cos(angle) * dist + (rng.nextDouble() * 10 - 5);
      final by = cy + sin(angle) * dist + (rng.nextDouble() * 10 - 5);

      return _Bubble(
        name: ing.ingredientName,
        status: ing.status,
        conc: _parseConc(ing.estimatedConcentration),
        radius: r,
        color: _statusColor(ing.status),
        phase: rng.nextDouble() * pi * 2,
        freqX: 0.24 + rng.nextDouble() * 0.14,
        freqY: 0.20 + rng.nextDouble() * 0.14,
        ampX: 6 + rng.nextDouble() * 8,
        ampY: 5 + rng.nextDouble() * 7,
        baseX: bx,
        baseY: by,
      );
    });

    setState(() {});
  }

  void _onTap(Offset local) {
    int? hit;
    double best = double.infinity;
    for (int i = 0; i < _bubbles.length; i++) {
      final b = _bubbles[i];
      final t = _ctrl.value * 60;
      final dist = (b.position(t) - local).distance;
      if (dist < b.radius + 8 && dist < best) {
        best = dist;
        hit = i;
      }
    }
    setState(() => _tapped = (hit == _tapped) ? null : hit);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bubbles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value * 60;
          return GestureDetector(
            onTapDown: (d) => _onTap(d.localPosition),
            child: CustomPaint(
              painter: _BubblePainter(
                bubbles: _bubbles,
                t: t,
                tapped: _tapped,
              ),
              child: _tapped != null
                  ? _Tooltip(
                      bubble: _bubbles[_tapped!],
                      t: t,
                      canvasSize: Size(MediaQuery.sizeOf(context).width, widget.height),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────
class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.bubbles, required this.t, this.tapped});

  final List<_Bubble> bubbles;
  final double t;
  final int? tapped;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < bubbles.length; i++) {
      final b = bubbles[i];
      final pos = b.position(t);
      final selected = tapped == i;

      // glow / shadow
      final glowPaint = Paint()
        ..color = b.color.withOpacity(selected ? 0.28 : 0.12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, selected ? 18 : 10);
      canvas.drawCircle(pos, b.radius + (selected ? 10 : 4), glowPaint);

      // bubble fill — translucent gradient
      final fillPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.0,
          colors: [
            Color.lerp(Colors.white, b.color, 0.45)!,
            b.color.withOpacity(0.75),
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: b.radius));
      canvas.drawCircle(pos, b.radius, fillPaint);

      // border
      final borderPaint = Paint()
        ..color = selected ? b.color : b.color.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2.0 : 1.0;
      canvas.drawCircle(pos, b.radius, borderPaint);

      // inner specular highlight
      final specPaint = Paint()
        ..color = Colors.white.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(
        pos + Offset(-b.radius * 0.28, -b.radius * 0.28),
        b.radius * 0.3,
        specPaint,
      );

      // label inside bubble (only if big enough)
      if (b.radius >= 22) {
        _drawText(canvas, b.name.split(' ').first, pos, b.radius, b.color);
      }
    }
  }

  void _drawText(
      Canvas canvas, String text, Offset center, double r, Color bubbleColor) {
    // Dark ink derived from the bubble hue — readable on the light fill.
    final ink = Color.lerp(bubbleColor, const Color(0xFF1A1A1A), 0.7)!;
    final maxW = r * 1.7; // stay inside the circle

    TextPainter build(double size, {double? bound}) => TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w700,
              color: ink,
              letterSpacing: -0.2,
              shadows: const [Shadow(color: Color(0xCCFFFFFF), blurRadius: 3)],
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          maxLines: 1,
          ellipsis: '…',
        )..layout(maxWidth: bound ?? double.infinity);

    // Measure the natural single-line width, then shrink the font to fit.
    double size = r * 0.42;
    final natural = build(size);
    if (natural.width > maxW) {
      size = (size * maxW / natural.width).clamp(7.0, r * 0.42);
    }
    // Final constrained layout — ellipsizes only if still too wide at the floor.
    final tp = build(size, bound: maxW);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_BubblePainter old) =>
      old.t != t || old.tapped != tapped;
}

// ── Tooltip overlay ────────────────────────────────────────────────────────
class _Tooltip extends StatelessWidget {
  const _Tooltip({
    required this.bubble,
    required this.t,
    required this.canvasSize,
  });

  final _Bubble bubble;
  final double t;
  final Size canvasSize;

  @override
  Widget build(BuildContext context) {
    final pos = bubble.position(t);
    final tipW = 180.0;
    final tipH = 72.0;
    var left = pos.dx - tipW / 2;
    var top = pos.dy - bubble.radius - tipH - 10;
    if (left < 8) left = 8;
    if (left + tipW > canvasSize.width - 8) left = canvasSize.width - tipW - 8;
    if (top < 8) top = pos.dy + bubble.radius + 10;

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: tipW,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: bubble.color.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: bubble.color.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bubble.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: bubble.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel(context, bubble.status),
                        style: TextStyle(
                          fontSize: 12,
                          color: bubble.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (bubble.conc > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '~${bubble.conc.toStringAsFixed(bubble.conc < 1 ? 1 : 0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
