import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// One premium-feature row (Design Review Initiative 10): a circular icon badge
/// + a label. Data-drives the 8 hand-repeated rows in `premium_features_list`
/// and the 4 in `paywall_confirmation`. Colors are configurable so the same
/// component serves the dark paywall (white text) and the confirmation sheet
/// (`secondaryText`).
class FeatureRow extends StatelessWidget {
  const FeatureRow({
    super.key,
    required this.icon,
    required this.label,
    this.faIcon = false,
    this.iconSize = 20.0,
    this.badgeColor,
    this.iconColor,
    this.textColor,
    this.fontSize = 15.0,
    this.lineHeight = 1.3,
  });

  final IconData icon;
  final String label;

  /// Render the glyph with FontAwesome ([FaIcon]) instead of a Material [Icon].
  final bool faIcon;
  final double iconSize;

  /// Circle fill. Defaults to `primary`.
  final Color? badgeColor;

  /// Glyph color. Defaults to `alternate`.
  final Color? iconColor;

  /// Label color. Defaults to white (dark paywall surface).
  final Color? textColor;

  final double fontSize;
  final double lineHeight;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final glyphColor = iconColor ?? theme.alternate;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: badgeColor ?? theme.primary,
            shape: BoxShape.circle,
          ),
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: faIcon
                ? FaIcon(icon, color: glyphColor, size: iconSize)
                : Icon(icon, color: glyphColor, size: iconSize),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: textColor ?? Colors.white,
              fontSize: fontSize,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
              lineHeight: lineHeight,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ),
      ],
    );
  }
}
