import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import '/app_state.dart';

class FeedbackService {
  static Future<String> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return 'unknown';
    }
  }

  static Future<bool> shouldShowPrompt() async {
    final state = FFAppState();

    // 1. Feature flag
    if (!state.feedbackCollectorEnabled) return false;

    // 2. Already submitted a review
    if (state.feedbackReviewSubmitted) return false;

    // 3. iOS only
    if (!Platform.isIOS) return false;

    // 4. Banner dismissed — only reset on a new app version
    if (state.feedbackBannerDismissed) {
      final version = await _appVersion();
      if (state.feedbackLastShownVersion == version) return false;
      // New version → reset dismissal so prompt can show again
      state.feedbackBannerDismissed = false;
    }

    // 5. 14-day gate from first launch (or last time prompt was shown)
    final now = DateTime.now().millisecondsSinceEpoch;
    final ref = state.feedbackLastShownMs > 0
        ? state.feedbackLastShownMs
        : state.feedbackFirstLaunchMs;
    if (ref > 0) {
      final daysPassed = (now - ref) / (1000 * 60 * 60 * 24);
      if (daysPassed < 14) return false;
    }

    return true;
  }

  static Future<void> recordShown() async {
    final state = FFAppState();
    state.feedbackLastShownMs = DateTime.now().millisecondsSinceEpoch;
    state.feedbackLastShownVersion = await _appVersion();
  }

  static void recordFirstLaunchIfNeeded() {
    final state = FFAppState();
    if (state.feedbackFirstLaunchMs == 0) {
      state.feedbackFirstLaunchMs = DateTime.now().millisecondsSinceEpoch;
    }
  }
}
