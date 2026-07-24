import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// The PRO upgrade CTA (home hero): a glossy pill built only from the design
/// scheme's colours — the brand `primary` blue and white. A light-blue→primary
/// gradient (the light stop is primary tinted toward white), a soft blue glow,
/// white crown + label, and a single white gloss sweep shortly after the screen
/// appears. Honors reduce-motion (static) and scales down slightly on press.
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

  static final BorderRadius _shape = BorderRadius.circular(999.0);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final primary = FlutterFlowTheme.of(context).primary;
    // Lighter blue = primary tinted toward white (stays within blue + white).
    final lightBlue = Color.lerp(primary, Colors.white, 0.30)!;

    // The gradient surface + label. The gloss sweep is applied here and then
    // clipped to the pill shape below (so it never shows in the corners).
    Widget surface = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightBlue, primary],
        ),
        borderRadius: _shape,
        border: Border.all(color: const Color(0x40FFFFFF), width: 1.0),
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
              ),
            ),
          ],
        ),
      ),
    );

    if (!reduceMotion) {
      // Bright gloss streak sweeps across once, shortly after the screen
      // appears — then the pill stays static (gradient + blue glow).
      surface = surface.animate().shimmer(
            delay: 500.ms,
            duration: 1500.ms,
            color: const Color(0xCCFFFFFF),
            angle: 0.4,
          );
    }

    // Clip the gradient + gloss to the rounded shape; carry the glow on an
    // outer box so the shadow isn't clipped away.
    final pill = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _shape,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.5),
            blurRadius: 20.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: _shape, child: surface),
    );

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
