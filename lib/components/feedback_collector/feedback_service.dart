import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import '/app_state.dart';
import '/auth/supabase_auth/auth_util.dart';

class FeedbackService {
  static Future<String> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return 'unknown';
    }
  }

  /// Resets per-user feedback fields when a different user is detected on this device.
  static void _resetIfUserChanged(FFAppState state) {
    final userId = currentUserUid;
    if (userId.isEmpty || state.feedbackUserId == userId) return;
    state.feedbackUserId = userId;
    state.feedbackReviewSubmitted = false;
    state.feedbackBannerDismissed = false;
    state.feedbackLastShownMs = 0;
    state.feedbackLastShownVersion = '';
  }

  static Future<bool> shouldShowPrompt(FFAppState state) async {
    if (!state.feedbackCollectorEnabled) return false;
    if (!Platform.isIOS) return false;

    _resetIfUserChanged(state);

    if (state.feedbackReviewSubmitted) return false;

    if (state.feedbackBannerDismissed) {
      final version = await _appVersion();
      if (state.feedbackLastShownVersion == version) return false;
      state.feedbackBannerDismissed = false;
    }

    // New user (never shown) → show immediately after first scan
    if (state.feedbackLastShownMs == 0) return true;

    // Returning user → 14-day cooldown from last shown
    final daysPassed =
        (DateTime.now().millisecondsSinceEpoch - state.feedbackLastShownMs) /
            (1000 * 60 * 60 * 24);

    return daysPassed >= 14;
  }

  /// ✅ ВАЖНО: state тоже передаётся, не создаётся новый
  static Future<void> recordShown(FFAppState state) async {
    state.feedbackLastShownMs = DateTime.now().millisecondsSinceEpoch;
    state.feedbackLastShownVersion = await _appVersion();
  }
}