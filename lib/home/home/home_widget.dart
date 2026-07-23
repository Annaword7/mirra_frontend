import '/app_state.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/database/tables/product_prices.dart';
import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/design_system/components/app_button.dart';
import '/item_card/imagedetailed_main/imagedetailed_main_widget.dart';
import 'dart:async';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';

// Maps chip key → product_type values it covers (including legacy backend values).
const Map<String, List<String>> _kHomeCategoryTypes = {
  'serum': ['serum'],
  'toner': ['toner'],
  'moisturizer': ['moisturizer', 'treatment'],
  'mask': ['mask'],
  'cleanser': ['cleanser', 'exfoliant'],
  'sunscreen': ['sunscreen'],
  'eye_cream': ['eye_cream', 'eye_care'],
  'lip_balm': ['balm', 'lip_balm'],
  'makeup': [
    'foundation',
    'bb_cream',
    'cc_cream',
    'concealer',
    'powder',
    'blush',
    'mascara',
    'eyeliner',
    'lipstick',
    'lip_gloss',
    'primer',
    'highlighter',
    'bronzer',
    'eyeshadow',
  ],
};

// Localized chip labels for all category keys — independent of FlutterFlow keys.
// Category filter labels are centralized in kTranslationsMap as 'cat_<key>'.

// Ordered list of chip category keys (display order).
const List<String> _kHomeFilterChips = [
  'all',
  'serum',
  'toner',
  'moisturizer',
  'mask',
  'cleanser',
  'sunscreen',
  'eye_cream',
  'lip_balm',
  'makeup',
];

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  late HomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  GoRouter? _goRouter;
  String _lastLocation = '';

  Ticker? _autoScrollTicker;
  double _tickerLastElapsed = 0;

  void _startAutoScroll() {
    _autoScrollTicker?.dispose();
    _tickerLastElapsed = 0;
    _autoScrollTicker = createTicker((elapsed) {
      final dt = (elapsed.inMicroseconds - _tickerLastElapsed) / 1e6;
      _tickerLastElapsed = elapsed.inMicroseconds.toDouble();
      if (!_model.scrollController.hasClients) return;
      final pos = _model.scrollController.position;
      final next = pos.pixels + 114.0 * dt; // ~114 px/sec
      if (next >= pos.maxScrollExtent) {
        _model.scrollController.jumpTo(0);
      } else {
        _model.scrollController.jumpTo(next);
      }
    });
    _autoScrollTicker!.start();
  }

  void _stopAutoScroll() {
    _autoScrollTicker?.dispose();
    _autoScrollTicker = null;
  }

  void _toggleAutoScroll() {
    safeSetState(() {
      _model.autoScrollActive = !_model.autoScrollActive;
    });
    if (_model.autoScrollActive) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  Future<void> _refreshQuota() async {
    // Read quota from the server /quota endpoint, where the rolling 7-day
    // reset is already applied. Reading users.monthly_analyses_used /
    // last_reset_date directly shows a stale count until the next scan or cron.
    try {
      final resp = await GetScanQuotaCall.call(token: currentJwtToken);
      if (!mounted || !resp.succeeded) return;
      final body = resp.jsonBody;
      final used = GetScanQuotaCall.quotaUsed(body);
      final limit = GetScanQuotaCall.quotaLimit(body);
      final resetAt = DateTime.tryParse(GetScanQuotaCall.resetAt(body) ?? '');
      if (used != null) FFAppState().analysesused = used;
      if (limit != null && limit > 0) FFAppState().freeScanLimit = limit;
      // The quota widgets derive the reset moment as weekResetDate + 7 days,
      // so store the window start (reset_at - 7d) to preserve that convention.
      if (resetAt != null) {
        FFAppState().weekResetDate = resetAt.subtract(const Duration(days: 7));
      }
      safeSetState(() {});
    } catch (e) {
      debugPrint('Home: quota refresh failed: $e');
    }
  }

  void _onRouteChanged() {
    if (!mounted) return;
    final location = _goRouter?.routeInformationProvider.value.uri.path ?? '';
    if (_lastLocation != HomeWidget.routePath &&
        location == HomeWidget.routePath) {
      _refreshImages();
      _refreshQuota();
    }
    _lastLocation = location;
  }

  /// Flush the pre-login onboarding buffer to the user's row once, after auth.
  /// See OnboardingQuizWidget — answers are buffered locally pre-login and
  /// persisted here on the first authenticated entry to Home.
  Future<void> _flushOnboardingProfile() async {
    final app = FFAppState();
    if (!app.obPendingFlush || currentUserUid.isEmpty) return;
    try {
      await UsersTable().update(
        data: {
          'skin_type': app.obSkinType,
          'skin_sensitivity': app.obSensitive,
          'acne_prone': app.obAcneProne,
          'pregnancy_status': app.obPregnancy,
          'skin_goals': app.obGoals,
          'age_range': app.obAgeRange,
          'budget_range': app.obBudgetRange,
          'trusted_brands': app.obTrustedBrands,
          'onboarded': true,
        },
        matchingRows: (rows) => rows.eqOrNull('id', currentUserUid),
      );
      app.clearOnboardingBuffer();
    } catch (e) {
      debugPrint('Home initState: onboarding flush failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    _model.imagesFuture = _fetchImages();

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Refresh images on first load and subscribe to route changes
      // so deleted/updated items disappear when returning to Home.
      _goRouter = GoRouter.of(context);
      _lastLocation = _goRouter!.routeInformationProvider.value.uri.path;
      _goRouter!.routerDelegate.addListener(_onRouteChanged);
      await _flushOnboardingProfile();
      // Global runtime config — read once per session from app_config.
      try {
        final cfg = await AppConfigTable().queryRows(
          queryFn: (q) => q.inFilterOrNull('key', ['free_scan_limit', 'show_link_telegram']),
        );
        for (final row in cfg) {
          if (row.key == 'free_scan_limit') {
            final limit = row.intValue;
            if (limit != null && limit > 0) FFAppState().freeScanLimit = limit;
          } else if (row.key == 'show_link_telegram') {
            FFAppState().showLinkTelegram = (row.intValue ?? 1) != 0;
          }
        }
      } catch (e) {
        debugPrint('Home initState: app_config fetch failed: $e');
      }
      try {
        _model.usersanswer = await UsersTable().queryRows(
          queryFn: (q) => q.eqOrNull(
            'id',
            currentUserUid,
          ),
        );
      } catch (e) {
        debugPrint('Home initState: user query failed: $e');
        return;
      }
      if (!mounted) return;
      final profileImageUrl =
          _model.usersanswer?.firstOrNull?.profileImage ?? '';
      if (profileImageUrl.isNotEmpty) {
        FFAppState().userProfilePicture = profileImageUrl;
      }
      if ((_model.usersanswer ?? []).isNotEmpty) {
        try {
          _model.countrieshome = await CountriesTable().queryRows(
            queryFn: (q) => q.eqOrNull(
              'id',
              _model.usersanswer?.firstOrNull?.countryId,
            ),
          );
        } catch (e) {
          debugPrint('Home initState: countries query failed: $e');
        }
        if (!mounted) return;

        // Pro-статус берём строго из БД (subscription_plan) — это единственный
        // per-account источник правды (обновляется покупкой и RC-webhook'ом).
        // Раньше здесь был fallback на RevenueCat.isEntitled, но подписка Apple
        // привязана к Apple ID устройства, а не к аккаунту: fallback выдавал pro
        // ЛЮБОМУ профилю, вошедшему на устройстве с активной подпиской (в т.ч.
        // после logout и входа в другой аккаунт).
        FFAppState().isprouser =
            _model.usersanswer?.firstOrNull?.subscriptionPlan == 'premium';
        final userRow = _model.usersanswer?.firstOrNull;
        final countryRow = _model.countrieshome?.firstOrNull;

        FFAppState().countrycode = valueOrDefault<String>(
          countryRow?.nameEn,
          FFAppState().countrycode,
        );
        FFAppState().countrycodeiso = valueOrDefault<String>(
          countryRow?.code,
          FFAppState().countrycodeiso,
        );
        if (_model.imagesFuture != null &&
            FFAppState().countrycodeiso.isNotEmpty) {
          try {
            final images = await _model.imagesFuture!;
            await _loadPriceMap(images);
          } catch (e) {
            debugPrint('Home initState: images/price load failed: $e');
          }
        }
        FFAppState().spamlist =
            (userRow?.spamImages ?? []).toList().cast<int>();
        await _refreshQuota();
        safeSetState(() {});
      } else {
        if (!mounted) return;
        // Only bounce to login if truly unauthenticated. An authenticated user
        // whose row isn't ready yet must NOT be pushed to login — that
        // ping-pongs back to Home in a loop.
        if (currentUserUid.isEmpty) {
          context.pushNamed(LogInPageWidget.routeName);
        }
      }
    });

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<List<ImagesRow>> _fetchImages() => ImagesTable()
      .queryRows(
        columns:
            'id,image_url,product_name,brand,sa_composite_score,sa_best_for_tags,sa_scoring_log,created_at,product_type',
        queryFn: (q) => q
            .eqOrNull('user', currentUserUid)
            .order('created_at', ascending: false),
      )
      // Without a timeout a stalled request leaves the FutureBuilder on a
      // permanent spinner (no error → no Retry). Surface it as an error.
      .timeout(const Duration(seconds: 20));

  void _refreshImages() {
    _model.priceMap = {};
    final future = _fetchImages();
    safeSetState(() {
      _model.imagesFuture = future;
    });
    future.then((images) async {
      if (FFAppState().countrycodeiso.isNotEmpty && mounted) {
        await _loadPriceMap(images);
        if (mounted) safeSetState(() {});
      }
    }).catchError((_) {
      // Network error is already surfaced by the FutureBuilder error state.
    });
  }

  Future<void> _loadPriceMap(List<ImagesRow> images) async {
    final countryCode = FFAppState().countrycodeiso;
    if (countryCode.isEmpty || !mounted) return;

    final nameKeys = images
        .map((r) => (r.productName ?? '').toLowerCase().trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    if (nameKeys.isEmpty) return;

    final prices = await ProductPricesTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('country_code', countryCode)
          .inFilterOrNull('product_name_key', nameKeys),
    );

    if (!mounted) return;
    _model.priceMap = {
      for (final p in prices) '${p.productNameKey}|${p.brandKey}': p,
    };
  }

  List<String> _availableChips(List<ImagesRow> images) {
    final presentTypes = images.map((r) => r.productType ?? '').toSet();
    return _kHomeFilterChips.where((catKey) {
      if (catKey == 'all') return true;
      final types = _kHomeCategoryTypes[catKey] ?? [];
      return types.any((t) => presentTypes.contains(t));
    }).toList();
  }

  String _chipLabel(String catKey, String langCode) {
    final label = FFLocalizations.of(context).getText('cat_$catKey');
    return label.isEmpty ? catKey : label;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _goRouter?.routerDelegate.removeListener(_onRouteChanged);
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            FutureBuilder<List<ImagesRow>>(
              future: _model.imagesFuture,
              builder: (context, snapshot) {
                // Keep showing the last loaded list while a refresh is in
                // flight, so returning to Home doesn't blank to a spinner.
                if (snapshot.hasError && _model.loadedImages == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: FlutterFlowTheme.of(context).error, size: 48),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => _refreshImages(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData && _model.loadedImages == null) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  _model.loadedImages = snapshot.data;
                }
                List<ImagesRow> containerImagesRowList =
                    snapshot.data ?? _model.loadedImages!;

                return Container(
                  constraints: BoxConstraints(
                    maxWidth: 600.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _refreshImages();
                    },
                    child: RawScrollbar(
                      controller: _model.scrollController,
                      interactive: true,
                      thumbVisibility: false,
                      radius: const Radius.circular(6),
                      thickness: 4,
                      thumbColor: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.55),
                      child: SingleChildScrollView(
                        controller: _model.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 64.0, 0.0, 0.0),
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 20.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (!appState.isprouser)
                                                Flexible(
                                                    child: AppButton(
                                                  label: FFLocalizations.of(
                                                          context)
                                                      .getText(
                                                    'fjrdil62' /* Update to PRO */,
                                                  ),
                                                  icon: FontAwesomeIcons.crown,
                                                  size: AppButtonSize.sm,
                                                  fullWidth: false,
                                                  onPressed: () {
                                                    context.pushNamed(
                                                        PaywallpageWidget
                                                            .routeName);
                                                  },
                                                )),
                                            ].divide(SizedBox(width: 16.0)),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 20.0, 20.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'pmne5rlo' /* Hello,  */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.raleway(
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  fontSize: 28.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              valueOrDefault<String>(
                                                _model.usersanswer?.firstOrNull
                                                    ?.firstName,
                                                'user',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.raleway(
                                                      fontWeight: FontWeight.w700,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    fontSize: 28.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                  ProfileWidget.routeName);
                                            },
                                            child: Container(
                                              width: 45.0,
                                              height: 45.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              // ── Scan quota bar ─────────────────────────────
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 10.0, 20.0, 0.0),
                                child: _HomeQuotaBar(
                                  isPro: appState.isprouser,
                                  scansUsed: appState.analysesused,
                                  weekResetDate: appState.weekResetDate,
                                  weekLimit: appState.freeScanLimit,
                                ),
                              ),
                              // ── Care review entry (M3b) ───────────────────
                              if (containerImagesRowList.length >= 2)
                                Padding(
                                  padding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 12.0, 20.0, 0.0),
                                  child: InkWell(
                                    onTap: () => context.pushNamed(
                                        CareReviewWidget.routeName),
                                    borderRadius: BorderRadius.circular(14.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0, vertical: 12.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.auto_awesome_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 22.0),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                          'care_entry_title'),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                          'care_entry_sub'),
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                              Icons.chevron_right_rounded,
                                              color: Colors.black26),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (containerImagesRowList.length != 0)
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 27.0, 20.0, 0.0),
                                    child: Container(
                                      height: 30.0,
                                      decoration: BoxDecoration(),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'cnejp0mk' /* My Products */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.raleway(
                                                fontWeight: FontWeight.w700,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 21.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w700,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              // ── Filter chips ───────────────────────────────
                              if (containerImagesRowList.length != 0)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 5.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0, 20.0, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: _availableChips(
                                              containerImagesRowList)
                                          .map((catKey) {
                                        final isSelected =
                                            _model.selectedCategory == catKey;
                                        return Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 0, 8.0, 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              _model.selectedCategory = catKey;
                                              safeSetState(() {});
                                            },
                                            child: AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 150),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 18.0,
                                                  vertical: 8.0),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : FlutterFlowTheme.of(context).surfaceMuted,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(context).border,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Text(
                                                _chipLabel(
                                                    catKey,
                                                    FFLocalizations.of(context)
                                                        .languageCode),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodySmall
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmallFamily,
                                                      fontSize: 13.0,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : FlutterFlowTheme.of(context).primaryText,
                                                      letterSpacing: 0.0,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmallIsCustom,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: FutureBuilder<List<ImagesRow>>(
                                    future: _model.imagesFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError &&
                                          _model.loadedImages == null) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.error_outline,
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .error,
                                                  size: 48),
                                              const SizedBox(height: 16),
                                              TextButton(
                                                onPressed: () => _refreshImages(),
                                                child: const Text('Retry'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      if (!snapshot.hasData &&
                                          _model.loadedImages == null) {
                                        return Center(
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      final allRows = snapshot.data ??
                                          _model.loadedImages!;
                                      final List<ImagesRow>
                                          staggeredViewImagesRowList =
                                          _model.selectedCategory ==
                                                  'all'
                                              ? allRows
                                              : allRows
                                                  .where((r) =>
                                                      (_kHomeCategoryTypes[
                                                                  _model
                                                                      .selectedCategory] ??
                                                              [])
                                                          .contains(
                                                              r.productType ??
                                                                  ''))
                                                  .toList();

                                      if (staggeredViewImagesRowList.isEmpty) {
                                        if (_model.selectedCategory == 'all') {
                                          // No products at all — show onboarding empty state
                                          final title =
                                              FFLocalizations.of(context)
                                                  .getText('home_empty_title');
                                          final subtitle = FFLocalizations.of(
                                                  context)
                                              .getText('home_empty_subtitle');
                                          final btnLabel =
                                              FFLocalizations.of(context)
                                                  .getText('home_empty_add');
                                          return Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      32, 48, 32, 32),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 56,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                        .withOpacity(0.35),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                    title,
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMediumFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleMediumIsCustom,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    subtitle,
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 28),
                                                  AppButton(
                                                    label: btnLabel,
                                                    fullWidth: false,
                                                    onPressed: () {
                                                      context.pushNamed(
                                                          TakeorUploadPageWidget
                                                              .routeName);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 40.0),
                                            child: Text(
                                              FFLocalizations.of(context)
                                                  .getText('xtop_empty'),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                            ),
                                          ),
                                        );
                                      }

                                      return MasonryGridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                        itemCount:
                                            staggeredViewImagesRowList.length,
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          0,
                                          0,
                                        ),
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (context, staggeredViewIndex) {
                                          final staggeredViewImagesRow =
                                              staggeredViewImagesRowList[
                                                  staggeredViewIndex];
                                          return InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (Navigator.of(context)
                                                  .canPop()) {
                                                context.pop();
                                              }
                                              context.pushNamed(
                                                Itemcard2Widget.routeName,
                                                queryParameters: {
                                                  'imageid': serializeParam(
                                                    staggeredViewImagesRow.id,
                                                    ParamType.int,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            child: ImagedetailedMainWidget(
                                              key: Key(
                                                  'Keyoxp_${staggeredViewIndex}_of_${staggeredViewImagesRowList.length}'),
                                              imageUrl: valueOrDefault<String>(
                                                staggeredViewImagesRow.imageUrl,
                                                'https://demofree.sirv.com/nope-not-here.jpg',
                                              ),
                                              brand: valueOrDefault<String>(
                                                staggeredViewImagesRow.brand,
                                                'No brand info',
                                              ),
                                              name: valueOrDefault<String>(
                                                staggeredViewImagesRow
                                                    .productName,
                                                'No product name info',
                                              ),
                                              score: staggeredViewImagesRow
                                                  .saCompositeScore,
                                              stars: 0,
                                              tags: staggeredViewImagesRow
                                                  .saBestForTags,
                                              hasSpf: staggeredViewImagesRow
                                                  .saHasSpf,
                                              imageID:
                                                  staggeredViewImagesRow.id,
                                              avgPrice: _model
                                                  .priceMap[
                                                      '${(staggeredViewImagesRow.productName ?? '').toLowerCase().trim()}|${(staggeredViewImagesRow.brand ?? '').toLowerCase().trim()}']
                                                  ?.avgPrice,
                                              priceCurrencyCode: _model
                                                  .priceMap[
                                                      '${(staggeredViewImagesRow.productName ?? '').toLowerCase().trim()}|${(staggeredViewImagesRow.brand ?? '').toLowerCase().trim()}']
                                                  ?.priceCurrencyCode,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ), // ConstrainedBox
                      ), // SingleChildScrollView
                    ), // RawScrollbar
                  ), // RefreshIndicator
                );
              },
            ),
            if (!(isWeb
                ? MediaQuery.viewInsetsOf(context).bottom > 0
                : _isKeyboardVisible))
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.navbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NavbarWidget(
                    activePage: 2,
                    analysesused:
                        _model.usersanswer?.firstOrNull?.monthlyAnalysesUsed,
                    onScrollToTop: () {
                      if (_model.scrollController.hasClients) {
                        _model.scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Scan quota bar shown below the scan card on the home screen ──────────────

class _HomeQuotaBar extends StatelessWidget {
  const _HomeQuotaBar({
    required this.isPro,
    required this.scansUsed,
    required this.weekResetDate,
    required this.weekLimit,
  });

  final bool isPro;
  final int scansUsed;
  final DateTime? weekResetDate;
  final int weekLimit;

  String _resetLabel(BuildContext context) {
    if (weekResetDate == null) return '';
    final resetAt = weekResetDate!.add(const Duration(days: 7)).toLocal();
    final now = DateTime.now();
    final resetDay = DateTime(resetAt.year, resetAt.month, resetAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final days = (resetDay.difference(today).inHours / 24).round();
    if (days < 0) return '';
    final loc = FFLocalizations.of(context);
    if (days == 0) return loc.getText('home_resets_today');
    if (days == 1) return loc.getText('home_resets_tomorrow');
    return loc.getText('home_resets_days').replaceAll('{n}', '$days');
  }

  @override
  Widget build(BuildContext context) {
    if (isPro) {
      return Row(
        children: [
          Icon(Icons.all_inclusive, size: 14, color: Colors.black),
          const SizedBox(width: 6),
          Text(
            FFLocalizations.of(context).getText('home_pro_unlimited'),
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: Colors.black,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ],
      );
    }

    final remaining = (weekLimit - scansUsed).clamp(0, weekLimit);
    final progress = weekLimit > 0 ? scansUsed / weekLimit : 0.0;
    final isExhausted = remaining == 0;
    final resetLabel = _resetLabel(context);
    final barColor = isExhausted
        ? Colors.red.shade400
        : FlutterFlowTheme.of(context).primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FFLocalizations.of(context)
                  .getText('home_scans_left')
                  .replaceAll('{remaining}', '$remaining')
                  .replaceAll('{limit}', '$weekLimit'),
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                    color: isExhausted ? Colors.red.shade400 : Colors.black,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodySmallIsCustom,
                  ),
            ),
            if (resetLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                resetLabel,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                      color: Colors.black,
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodySmallIsCustom,
                    ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4.0,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}


