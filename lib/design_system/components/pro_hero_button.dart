import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// The "aurora glow" PRO upgrade CTA (home hero): a brand blue→violet gradient
/// pill with a small crown, a soft violet glow, and a single bright gloss sweep
/// shortly after the screen appears — enticing to tap. Honors reduce-motion
/// (static) and scales down slightly on press.
class ProHeroButton extends StatefulWidget {
  const ProHeroButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<ProHeroButton> createState() => _ProHeroButtonState();
}

class _ProHeroButtonState extends State<ProHeroButton> {
  bool _pressed = false;

  // Aurora palette — brand blue → violet.
  static const _blue = Color(0xFF5C85D9);
  static const _mid = Color(0xFF6F7FE0);
  static const _violet = Color(0xFF9489F5);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget pill = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue, _mid, _violet],
        ),
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(color: const Color(0x40FFFFFF), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _violet.withValues(alpha: 0.5),
            blurRadius: 20.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 11.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.crown,
                size: 14.0, color: Colors.white),
            const SizedBox(width: 9.0),
            Text(
              widget.label,
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.w800,
                fontSize: 15.0,
                letterSpacing: 0.2,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Color(0x47141432),
                    blurRadius: 2.0,
                    offset: Offset(0.0, 1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!reduceMotion) {
      // Bright gloss streak sweeps across once, shortly after the screen
      // appears — then the pill stays static (gradient + violet glow).
      pill = pill.animate().shimmer(
            delay: 500.ms,
            duration: 1500.ms,
            color: const Color(0xCCFFFFFF),
            angle: 0.4,
          );
    }

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: pill,
        ),
      ),
    );
  }
}
