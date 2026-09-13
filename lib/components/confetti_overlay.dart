import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A one-shot confetti burst, drawn behind a celebratory sheet.
///
/// Hand-rolled rather than pulled in as a dependency: it is one painter and one
/// controller, and it takes the app's palette instead of shipping its own.
/// Purely decorative — wrap it in an [IgnorePointer] so taps reach the barrier
/// underneath.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.colors,
    this.pieceCount = 44,
  });

  final List<Color> colors;
  final int pieceCount;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _pieces = List.generate(
      widget.pieceCount,
      (_) => _Piece.random(random, widget.colors),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
  }

  @override
  void dispose() {
    // The burst plays once and stops; without this the ticker outlives the
    // sheet and keeps the route awake.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _ConfettiPainter(_pieces, _controller.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.drift,
    required this.size,
    required this.color,
    required this.spin,
    required this.tilt,
  });

  /// Horizontal start, as a fraction of the width.
  final double x;

  /// Fraction of the timeline to wait before falling, so pieces don't move as
  /// one sheet.
  final double delay;

  /// Sideways travel over the fall, as a fraction of the width.
  final double drift;
  final double size;
  final Color color;
  final double spin;
  final double tilt;

  factory _Piece.random(math.Random r, List<Color> palette) => _Piece(
        x: r.nextDouble(),
        delay: r.nextDouble() * 0.35,
        drift: (r.nextDouble() - 0.5) * 0.35,
        size: 6 + r.nextDouble() * 7,
        color: palette[r.nextInt(palette.length)],
        spin: 2 + r.nextDouble() * 5,
        tilt: r.nextDouble() * math.pi,
      );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final local =
          ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0).toDouble();
      if (local <= 0) continue;

      // Accelerating fall, starting just above the top edge and ending below
      // the bottom one so nothing visibly pops out of existence.
      final y = -0.1 + Curves.easeInQuad.transform(local) * 1.25;
      final x = p.x + p.drift * local;
      final fade = local < 0.7 ? 1.0 : 1 - (local - 0.7) / 0.3;
      paint.color = p.color.withValues(alpha: fade.clamp(0.0, 1.0).toDouble());

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(p.tilt + p.spin * local);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
