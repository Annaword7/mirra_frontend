import 'dart:io';
import '/app_state.dart';
import '/auth/supabase_auth/auth_util.dart';

/// Номера удачных сканов, на которых показывается просилка. Первый порог —
/// второй скан: первый разбор всегда забирает мягкий пейволл. Дальше пороги
/// растут вместе с вовлечённостью: кому хватило на 50 разборов, тому есть что
/// сказать. Четыре показа за жизнь установки — с запасом под лимит Apple на
/// три запроса оценки в год.
const List<int> kFeedbackScanMilestones = [2, 10, 30, 50];

class FeedbackService {
  /// Resets per-user feedback fields when a different user is detected on this device.
  static void _resetIfUserChanged(FFAppState state) {
    final userId = currentUserUid;
    if (userId.isEmpty || state.feedbackUserId == userId) return;
    state.feedbackUserId = userId;
    state.feedbackReviewSubmitted = false;
    state.feedbackLastPromptScans = 0;
  }

  /// Локально и без календаря, как у мягкого пейволла: показать, когда счётчик
  /// удачных сканов дошёл до порога, на котором ещё не спрашивали. Сравнение
  /// через «>=», а не «==»: если показ на пороге не случился (ушли с карточки
  /// за три секунды), он не теряется, а ждёт следующего скана.
  static bool shouldShowPrompt(FFAppState state) {
    if (!Platform.isIOS) return false;

    _resetIfUserChanged(state);

    if (state.feedbackReviewSubmitted) return false;

    return milestoneDue(
      lastPromptScans: state.feedbackLastPromptScans,
      scans: state.successfulScans,
    );
  }

  /// Есть ли порог, пройденный после последнего показа. Вынесено из
  /// [shouldShowPrompt], чтобы проверять таблицей без Supabase и prefs.
  static bool milestoneDue({required int lastPromptScans, required int scans}) =>
      kFeedbackScanMilestones.any((m) => m > lastPromptScans && m <= scans);

  /// Зафиксировать показ: следующий раз — на следующем пороге.
  static void recordShown(FFAppState state) {
    state.feedbackLastPromptScans = state.successfulScans;
  }
}
