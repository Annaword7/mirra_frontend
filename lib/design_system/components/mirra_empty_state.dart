import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/app_button.dart';

/// The single empty-state primitive (Design Review Initiative 5): a centered
/// icon + headline + optional body + optional CTA. Replaces the message-less
/// gray skeleton "empty gallery" widgets that read as perpetual loading, plus
/// the several bespoke empty cards. **Loading** grids use `SkeletonGrid`;
/// **empty** screens use this.
class MirraEmptyState extends StatelessWidget {
  const MirraEmptyState({
    super.key,
    required this.icon,
    required this.headline,
    this.body,
    this.ctaLabel,
    this.onCta,
    this.padding = const EdgeInsets.all(32.0),
  });

  final IconData icon;
  final String headline;
  final String? body;

  /// Optional CTA. Rendered as a primary `AppButton` only when both [ctaLabel]
  /// and [onCta] are provided.
  final String? ctaLabel;
  final VoidCallback? onCta;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final hasCta = ctaLabel != null && onCta != null;

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 56.0, color: theme.secondaryText),
            const SizedBox(height: 16.0),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: theme.titleMedium.override(
                fontFamily: theme.titleMediumFamily,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                useGoogleFonts: !theme.titleMediumIsCustom,
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
                  lineHeight: 1.4,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ],
            if (hasCta) ...[
              const SizedBox(height: 24.0),
              AppButton(
                label: ctaLabel!,
                onPressed: onCta!,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
