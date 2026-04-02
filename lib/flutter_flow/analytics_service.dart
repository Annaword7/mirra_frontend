import 'package:firebase_analytics/firebase_analytics.dart';

/// Singleton analytics service wrapping FirebaseAnalytics.
/// Usage: AnalyticsService.instance.trackCardOpened(source: 'home');
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ── Authentication ────────────────────────────────────────────────────────

  Future<void> trackSignUp({String method = 'email'}) =>
      _analytics.logSignUp(signUpMethod: method);

  Future<void> trackLogin({String method = 'email'}) =>
      _analytics.logLogin(loginMethod: method);

  Future<void> trackAnonSessionStarted() =>
      _log('anon_session_started');

  Future<void> trackAnonConverted() =>
      _log('anon_converted');

  // ── Analysis ──────────────────────────────────────────────────────────────

  Future<void> trackAnalysisStarted({required String source}) =>
      _log('analysis_started', {'source': source}); // source: camera | gallery

  Future<void> trackAnalysisCompleted({
    required int imageId,
    required double score,
    String? productType,
  }) =>
      _log('analysis_completed', {
        'image_id': imageId,
        'score': score.round(),
        if (productType != null) 'product_type': productType,
      });

  Future<void> trackAnalysisFailed({String? reason}) =>
      _log('analysis_failed', {if (reason != null) 'reason': reason});

  // ── Product card ──────────────────────────────────────────────────────────

  Future<void> trackCardOpened({
    required int imageId,
    required String source, // home | toprated | favorites | board | search
  }) =>
      _log('card_opened', {'image_id': imageId, 'source': source});

  Future<void> trackIngredientsTabOpened({required int imageId}) =>
      _log('ingredients_tab_opened', {'image_id': imageId});

  // ── Share ─────────────────────────────────────────────────────────────────

  Future<void> trackShareLinkTapped({required int imageId}) =>
      _log('share_link_tapped', {'image_id': imageId});

  Future<void> trackShareCardCreated({
    required int imageId,
    required String format, // story | square
  }) =>
      _log('share_card_created', {'image_id': imageId, 'format': format});

  // ── Boards ────────────────────────────────────────────────────────────────

  Future<void> trackBoardCreated() =>
      _log('board_created');

  Future<void> trackProductAddedToBoard({required int imageId}) =>
      _log('product_added_to_board', {'image_id': imageId});

  // ── Favourites ────────────────────────────────────────────────────────────

  Future<void> trackFavouriteAdded({required int imageId}) =>
      _log('favourite_added', {'image_id': imageId});

  Future<void> trackFavouriteRemoved({required int imageId}) =>
      _log('favourite_removed', {'image_id': imageId});

  // ── Upgrade ───────────────────────────────────────────────────────────────

  Future<void> trackUpgradePromptShown({required String trigger}) =>
      _log('upgrade_prompt_shown', {'trigger': trigger});

  Future<void> trackUpgradePromptTapped({required String trigger}) =>
      _log('upgrade_prompt_tapped', {'trigger': trigger});

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _log(String name,
      [Map<String, Object>? parameters]) =>
      _analytics.logEvent(name: name, parameters: parameters);
}
