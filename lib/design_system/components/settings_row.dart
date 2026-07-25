import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// One settings/profile row (Design Review Initiative 9): a tappable
/// `primaryBackground` pill (55h, r16) with a leading icon + label, an optional
/// trailing current-value, and a chevron. Collapses the ~7 hand-copied profile
/// rows. Fires a light haptic on tap.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingValue,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Optional current value shown before the chevron (e.g. the selected region).
  final String? trailingValue;

  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 55.0,
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 8.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(icon, color: iconColor ?? theme.primaryText, size: 24.0),
                    const SizedBox(width: 12.0),
                    Text(
                      label,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: labelColor ?? theme.primaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingValue != null) ...[
                const SizedBox(width: 8.0),
                Text(
                  trailingValue!,
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
              ],
              const SizedBox(width: 8.0),
              Icon(Icons.chevron_right, color: theme.secondaryText, size: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
