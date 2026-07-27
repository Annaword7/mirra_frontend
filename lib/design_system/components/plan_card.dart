import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';

/// One paywall subscription plan card (Design Review Initiative 10): dark
/// surface, primary border when [selected], optional top ribbon (annual "BEST
/// VALUE"), title + store price row, right-aligned "≈ N / month" equivalent,
/// optional savings line, and a shimmering Continue CTA. Replaces the two
/// ~340-line hand-rolled weekly/annual cards in `paywallpage_widget`.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.title,
    required this.priceString,
    required this.perMonthPrice,
    required this.approxSign,
    required this.perMonthSuffix,
    required this.ctaLabel,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
    this.ribbonLabel,
    this.savingsLabel,
  });

  final String title;

  /// Localized store price (e.g. "US$39.99").
  final String priceString;

  /// Pre-formatted monthly-equivalent number (e.g. "3.33").
  final String perMonthPrice;

  /// The " ≈ " and "/ month" fragments (each card has its own i18n keys).
  final String approxSign;
  final String perMonthSuffix;

  final String ctaLabel;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onContinue;

  /// Optional band across the top (e.g. "BEST VALUE" on annual).
  final String? ribbonLabel;

  /// Optional highlighted line above the equivalent price ("TWO MONTHS FREE").
  final String? savingsLabel;

  // Paywall dark-surface palette (the page shell uses #0C1A35; cards sit a
  // step lighter). Kept as named constants — the color-token track is paused.
  static const Color _cardBg = Color(0xFF132444);
  static final Color _borderIdle = Colors.white.withValues(alpha: 0.12);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final accentStyle = theme.bodyMedium.override(
      font: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontStyle: theme.bodyMedium.fontStyle,
      ),
      color: theme.primary,
      fontSize: 16.0,
      letterSpacing: 1.0,
      fontWeight: FontWeight.w600,
      fontStyle: theme.bodyMedium.fontStyle,
    );

    final titleStyle = theme.titleMedium.override(
      fontFamily: theme.titleMediumFamily,
      color: Colors.white,
      letterSpacing: 0.0,
      fontWeight: FontWeight.w600,
      lineHeight: 1.2,
      useGoogleFonts: !theme.titleMediumIsCustom,
    );

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onSelect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: selected ? theme.primary : _borderIdle,
              width: 2.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ribbonLabel != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        12.0, 6.0, 12.0, 6.0),
                    child: Text(
                      ribbonLabel!,
                      textAlign: TextAlign.center,
                      style: theme.labelSmall.override(
                        fontFamily: theme.labelSmallFamily,
                        color: theme.alternate,
                        fontSize: 12.0,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts: !theme.labelSmallIsCustom,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    10.0, 16.0, 10.0, 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: titleStyle),
                        Text(priceString, style: titleStyle),
                      ].divide(const SizedBox(width: 12.0)),
                    ),
                    if (savingsLabel != null)
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Text(
                              savingsLabel!,
                              textAlign: TextAlign.center,
                              style: accentStyle,
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (final fragment in [
                          approxSign,
                          perMonthPrice,
                          perMonthSuffix,
                        ])
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Text(
                              fragment,
                              textAlign: TextAlign.center,
                              style: accentStyle,
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 12.0, 0.0, 0.0),
                      child: AppButton(
                        label: ctaLabel,
                        onPressed: onContinue,
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
                            duration: 1800.ms,
                            color: Colors.white.withValues(alpha: 0.3),
                            angle: 0.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
