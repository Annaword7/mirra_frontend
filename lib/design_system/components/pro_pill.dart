import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// The single PRO badge pill (Design Review Initiative 10): a `primary`-filled,
/// fully-rounded pill with a bold Plus-Jakarta-Sans label and an optional
/// leading icon. Replaces the divergent "PRO" / "UPGRADE TO PRO" badges on the
/// paywall page and the confirmation sheet.
class ProPill extends StatelessWidget {
  const ProPill({
    super.key,
    required this.label,
    this.icon,
    this.contentColor,
    this.height,
    this.fontSize = 12.0,
    this.letterSpacing = 1.0,
    this.padding =
        const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
  });

  final String label;
  final IconData? icon;

  /// Icon + text color. Defaults to `alternate`.
  final Color? contentColor;

  final double? height;
  final double fontSize;
  final double letterSpacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final fg = contentColor ?? theme.alternate;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 16.0),
              const SizedBox(width: 6.0),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: fg,
                fontSize: fontSize,
                letterSpacing: letterSpacing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
