import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// The "candy foil" PRO upgrade CTA (home hero): a warm pearlescent-gold pill
/// with a small crown, a soft gold glow, and a bright gloss sweep that runs
/// across it — enticing to tap. Honors reduce-motion (static when set) and
/// scales down slightly on press.
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

  // Candy-foil palette (warm pearlescent gold), derived from the brand pastels.
  static const _cream = Color(0xFFF2EBB4);
  static const _peach = Color(0xFFF4CFBC);
  static const _gold = Color(0xFFE7B24C);
  static const _lightGold = Color(0xFFFFF3CF);
  static const _ink = Color(0xFF5A3B12); // warm brown text on the light foil
  static const _crownInk = Color(0xFF7A5218);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget pill = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cream, _peach, _lightGold, _gold, _peach, _cream],
        ),
        borderRadius: BorderRadius.circular(999.0),
        border: Border.all(color: const Color(0x8CFFFFFF), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.42),
            blurRadius: 18.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 11.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.crown, size: 14.0, color: _crownInk),
            const SizedBox(width: 9.0),
            Text(
              widget.label,
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.w800,
                fontSize: 15.0,
                letterSpacing: 0.2,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );

    if (!reduceMotion) {
      // Bright gloss streak sweeping across, with a pause between passes.
      pill = pill
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            delay: 900.ms,
            duration: 2200.ms,
            color: const Color(0xE6FFFFFF),
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
