// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math';
import 'dart:ui';

class AnimatedPaywallBg extends StatefulWidget {
  const AnimatedPaywallBg({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  State<AnimatedPaywallBg> createState() => _AnimatedPaywallBgState();
}

class _AnimatedPaywallBgState extends State<AnimatedPaywallBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final rng = Random();
    _particles = List.generate(25, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        speed: 0.03 + rng.nextDouble() * 0.09,
        size: 1.5 + rng.nextDouble() * 2.5,
        opacity: 0.15 + rng.nextDouble() * 0.45,
        freq: 0.5 + rng.nextDouble() * 1.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final pulse = sin(t * 2 * pi);

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: dark gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF060D1E),
                      Color(0xFF0C1D45),
                      Color(0xFF180F3A),
                    ],
                    stops: [0.0, 0.55, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Layer 2: glow orbs
              // Orb 1 — blue, top right
              Positioned(
                top: -40 + pulse * 8,
                right: -30 + pulse * 6,
                child: _GlowOrb(
                  size: 200 + pulse * 20,
                  color: const Color(0xFF5C85D9).withOpacity(0.18),
                  blurSigma: 60,
                ),
              ),

              // Orb 2 — purple, bottom left
              Positioned(
                bottom: 80 - pulse * 10,
                left: -60 + pulse * 8,
                child: _GlowOrb(
                  size: 280 - pulse * 15,
                  color: const Color(0xFF9489F5).withOpacity(0.15),
                  blurSigma: 80,
                ),
              ),

              // Orb 3 — teal, center right
              Positioned(
                top: MediaQuery.of(context).size.height * 0.38 + pulse * 12,
                right: MediaQuery.of(context).size.width * 0.05,
                child: _GlowOrb(
                  size: 150 + pulse * 12,
                  color: const Color(0xFF39D2C0).withOpacity(0.12),
                  blurSigma: 50,
                ),
              ),

              // Layer 3: floating particles
              CustomPaint(
                painter: _ParticlePainter(t, _particles),
                size: Size.infinite,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.blurSigma,
  });

  final double size;
  final Color color;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.freq,
  });

  final double x;
  final double y;
  final double speed;
  final double size;
  final double opacity;
  final double freq;
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter(this.value, this.particles);

  final double value;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dy = ((p.y - value * p.speed) % 1.0 + 1.0) % 1.0;
      final dx = p.x + sin(value * 2 * pi * p.freq) * 0.04;
      final paint = Paint()
        ..color = Colors.white.withOpacity(p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
