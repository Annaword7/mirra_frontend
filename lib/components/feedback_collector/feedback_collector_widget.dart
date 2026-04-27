import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'negative_feedback_widget.dart';

class FeedbackCollectorWidget extends StatelessWidget {
  const FeedbackCollectorWidget({super.key});

  Future<String> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return 'unknown';
    }
  }

  Future<void> _dismiss(BuildContext context) async {
    FFAppState().feedbackBannerDismissed = true;
    FFAppState().feedbackLastShownVersion = await _appVersion();
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.alternate,
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withAlpha(40),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFEBF0FC),
                    const Color(0xFFCBDDFE),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28.0),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primary.withAlpha(20),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: -20,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primary.withAlpha(15),
                      ),
                    ),
                  ),
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Star icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.alternate,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withAlpha(30),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('✨', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        FFLocalizations.of(context).getText('fc_title'),
                        textAlign: TextAlign.start,
                        style: theme.headlineSmall.override(
                          fontFamily: theme.headlineSmallFamily,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.headlineSmallIsCustom,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        FFLocalizations.of(context).getText('fc_subtitle'),
                        textAlign: TextAlign.start,
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                          lineHeight: 1.4,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  // "Да, круто" — primary filled
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        await FirebaseAnalytics.instance.logEvent(name: 'feedback_positive');
                        FFAppState().feedbackReviewSubmitted = true;
                        FFAppState().feedbackLastShownVersion = await _appVersion();
                        final inAppReview = InAppReview.instance;
                        if (await inAppReview.isAvailable()) {
                          await inAppReview.requestReview();
                        } else {
                          await inAppReview.openStoreListing(
                              appStoreId: '6745415201');
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF5C85D9),
                              const Color(0xFF4A6FC7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5C85D9).withAlpha(80),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          height: 54,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                FFLocalizations.of(context).getText('fc_btn_positive'),
                                style: theme.titleSmall.override(
                                  fontFamily: theme.titleSmallFamily,
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.titleSmallIsCustom,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // "Нет, не очень" — ghost
                  TextButton(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await FirebaseAnalytics.instance.logEvent(name: 'feedback_negative');
                      FFAppState().feedbackBannerDismissed = true;
                      FFAppState().feedbackLastShownVersion = await _appVersion();
                      if (context.mounted) {
                        Navigator.pop(context);
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const NegativeFeedbackWidget(),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      FFLocalizations.of(context).getText('fc_btn_negative'),
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.primaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
