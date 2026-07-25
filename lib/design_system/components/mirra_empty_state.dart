import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/app_button.dart';

/// The single empty-state primitive (Design Review Initiative 5): a centered
/// icon + headline + optional body + optional CTA. Modeled on the app's best
/// existing empty state (the collections empty), so it can replace the
/// message-less gray "empty gallery" skeletons and standardize future empties.
/// **Loading** grids use `SkeletonGrid`; **empty** screens use this.
class MirraEmptyState extends StatelessWidget {
  const MirraEmptyState({
    super.key,
    required this.icon,
    required this.headline,
    this.body,
    this.ctaLabel,
    this.onCta,
    this.ctaIcon,
    this.ctaFullWidth = true,
    this.iconColor,
    this.tintedBadge = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 32.0),
  });

  final IconData icon;
  final String headline;
  final String? body;

  /// Optional CTA. Rendered as a primary `AppButton` only when both [ctaLabel]
  /// and [onCta] are provided.
  final String? ctaLabel;
  final VoidCallback? onCta;
  final IconData? ctaIcon;
  final bool ctaFullWidth;

  /// Accent for the icon / badge. Defaults to `primary`.
  final Color? iconColor;

  /// When true, the icon sits in a layered tinted circular badge; otherwise a
  /// plain 56px icon.
  final bool tintedBadge;

  final EdgeInsetsGeometry padding;

  Widget _leading(FlutterFlowTheme theme) {
    final color = iconColor ?? theme.primary;
    if (!tintedBadge) {
      return Icon(icon, size: 56.0, color: color);
    }
    return SizedBox(
      width: 140.0,
      height: 140.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140.0,
            height: 140.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.06),
            ),
          ),
          Container(
            width: 96.0,
            height: 96.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.11),
            ),
          ),
          Icon(icon, size: 48.0, color: color),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final hasCta = ctaLabel != null && onCta != null;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _leading(theme),
            const SizedBox(height: 24.0),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: theme.headlineMedium.override(
                fontFamily: theme.headlineMediumFamily,
                color: theme.primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                useGoogleFonts: !theme.headlineMediumIsCustom,
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 8.0),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ],
            if (hasCta) ...[
              const SizedBox(height: 32.0),
              AppButton(
                label: ctaLabel!,
                onPressed: onCta!,
                icon: ctaIcon,
                fullWidth: ctaFullWidth,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
