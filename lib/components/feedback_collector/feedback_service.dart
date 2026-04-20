import 'dart:io';
import 'package:flutter/foundation.dart';
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

    if (!state.feedbackCollectorEnabled) return false;
    if (state.feedbackReviewSubmitted) return false;
    if (!Platform.isIOS) return false;

    if (state.feedbackBannerDismissed) {
      final version = await _appVersion();
      if (state.feedbackLastShownVersion == version) return false;
      state.feedbackBannerDismissed = false;
    }

    // New user (never shown) → show immediately after first scan
    if (state.feedbackLastShownMs == 0) return true;

    // Returning user → 14-day cooldown from last shown
    final daysPassed = (DateTime.now().millisecondsSinceEpoch - state.feedbackLastShownMs)
        / (1000 * 60 * 60 * 24);
    return daysPassed >= 14;
  }

  static Future<void> recordShown() async {
    final state = FFAppState();
    state.feedbackLastShownMs = DateTime.now().millisecondsSinceEpoch;
    state.feedbackLastShownVersion = await _appVersion();
  }
}
