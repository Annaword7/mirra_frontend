import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/item_card/imagedetailed_main/imagedetailed_main_widget.dart';
import 'dart:async';
import '/environment_values.dart';
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
  'serum':       ['serum'],
  'toner':       ['toner'],
  'moisturizer': ['moisturizer', 'treatment'],
  'mask':        ['mask'],
  'cleanser':    ['cleanser', 'exfoliant'],
  'sunscreen':   ['sunscreen'],
  'eye_cream':   ['eye_cream', 'eye_care'],
  'lip_balm':    ['balm', 'lip_balm'],
  'makeup': [
    'foundation', 'bb_cream', 'cc_cream', 'concealer', 'powder',
    'blush', 'mascara', 'eyeliner', 'lipstick', 'lip_gloss',
    'primer', 'highlighter', 'bronzer', 'eyeshadow',
  ],
};

// Localized chip labels for all category keys — independent of FlutterFlow keys.
const Map<String, Map<String, String>> _kCategoryLabels = {
  'all':         {'en': 'All',        'ru': 'Все',              'es': 'Todo'},
  'serum':       {'en': 'Serum',      'ru': 'Сыворотки',        'es': 'Sérum'},
  'toner':       {'en': 'Toner',      'ru': 'Тоники',           'es': 'Tónico'},
  'moisturizer': {'en': 'Moisturizer','ru': 'Кремы',            'es': 'Hidratante'},
  'mask':        {'en': 'Mask',       'ru': 'Маски',            'es': 'Mascarilla'},
  'cleanser':    {'en': 'Cleanser',   'ru': 'Очищение',         'es': 'Limpiador'},
  'sunscreen':   {'en': 'Sunscreen',  'ru': 'Санскрин',         'es': 'Protector solar'},
  'eye_cream':   {'en': 'Eye Care',   'ru': 'Уход за глазами',  'es': 'Contorno de ojos'},
  'lip_balm':    {'en': 'Lip & Balm', 'ru': 'Губы и бальзамы', 'es': 'Labios y bálsamos'},
  'makeup':      {'en': 'Makeup',     'ru': 'Макияж',           'es': 'Maquillaje'},
};

// Ordered list of chip category keys (display order).
const List<String> _kHomeFilterChips = [
  'all', 'serum', 'toner', 'moisturizer', 'mask',
  'cleanser', 'sunscreen', 'eye_cream', 'lip_balm', 'makeup',
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

  late final AnimationController _pulseCtrl;

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

  void _onRouteChanged() {
    if (!mounted) return;
    final location =
        _goRouter?.routeInformationProvider.value.uri.path ?? '';
    if (_lastLocation != HomeWidget.routePath &&
        location == HomeWidget.routePath) {
      _refreshImages();
    }
    _lastLocation = location;
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
      _refreshImages();
      _model.usersanswer = await UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          currentUserUid,
        ),
      );
      if (_model.usersanswer!.length > 0) {
        _model.countrieshome = await CountriesTable().queryRows(
          queryFn: (q) => q.eqOrNull(
            'id',
            _model.usersanswer?.firstOrNull?.countryId,
          ),
        );
        FFAppState().isprouser =
            _model.usersanswer?.firstOrNull?.subscriptionPlan == 'premium'
                ? true
                : false;
        // Fallback: verify with RevenueCat in case database update failed
        // (e.g. after a successful purchase where the backend call timed out)
        if (!FFAppState().isprouser) {
          final isEntitled =
              await revenue_cat.isEntitled('EntitlementMirra') ?? false;
          if (isEntitled) {
            FFAppState().isprouser = true;
          }
        }
        FFAppState().countrycode = _model.countrieshome!.firstOrNull!.nameEn;
        FFAppState().spamlist =
            _model.usersanswer!.firstOrNull!.spamImages.toList().cast<int>();
        FFAppState().analysesused =
            _model.usersanswer!.firstOrNull!.monthlyAnalysesUsed!;
        safeSetState(() {});
      } else {
        context.pushNamed(LogInPageWidget.routeName);
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

    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<List<ImagesRow>> _fetchImages() => ImagesTable().queryRows(
        columns: 'id,image_url,product_name,brand,sa_composite_score,sa_best_for_tags,created_at,product_type',
        queryFn: (q) => q
            .eqOrNull('user', currentUserUid)
            .order('created_at', ascending: false),
      );

  void _refreshImages() {
    safeSetState(() {
      _model.imagesFuture = _fetchImages();
    });
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
    final labels = _kCategoryLabels[catKey] ?? {};
    return labels[langCode] ?? labels['en'] ?? catKey;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pulseCtrl.dispose();
    _goRouter?.routerDelegate.removeListener(_onRouteChanged);
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            FutureBuilder<List<ImagesRow>>(
              future: _model.imagesFuture,
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
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
                List<ImagesRow> containerImagesRowList = snapshot.data!;

                return Container(
                  constraints: BoxConstraints(
                    maxWidth: 600.0,
                  ),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primaryBackground,
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
                      thumbColor: FlutterFlowTheme.of(context).primary.withOpacity(0.55),
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
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            context.pushNamed(
                                                ProfileWidget.routeName);
                                          },
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            children: [
                                              Container(
                                                width: 44.0,
                                                height: 44.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                      ProfileWidget.routeName);
                                                },
                                                child: Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: Image.network(
                                                        valueOrDefault<String>(
                                                          _model
                                                              .usersanswer
                                                              ?.firstOrNull
                                                              ?.profileImage,
                                                          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png?20150327203541',
                                                        ),
                                                      ).image,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!FFAppState().isprouser)
                                          FFButtonWidget(
                                            onPressed: () async {
                                              context.pushNamed(
                                                  PaywallpageWidget.routeName);
                                            },
                                            text: FFLocalizations.of(context)
                                                .getText(
                                              'fjrdil62' /* Update to PRO */,
                                            ),
                                            icon: FaIcon(
                                              FontAwesomeIcons.crown,
                                              size: 15.0,
                                            ),
                                            options: FFButtonOptions(
                                              height: 35.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      18.0, 8.0, 17.0, 7.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 0.0,
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                          ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                    if (FFDevEnvironmentValues.currentEnvironment == 'Development')
                                      GestureDetector(
                                        onTap: _toggleAutoScroll,
                                        child: Container(
                                          width: 45.0,
                                          height: 45.0,
                                          decoration: BoxDecoration(
                                            color: _model.autoScrollActive
                                                ? const Color(0xFFFF9800)
                                                : FlutterFlowTheme.of(context).secondaryBackground,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFFF9800),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Icon(
                                            _model.autoScrollActive
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            color: _model.autoScrollActive
                                                ? Colors.white
                                                : const Color(0xFFFF9800),
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      width: 45.0,
                                      height: 45.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                              FavoritesWidget.routeName);
                                        },
                                        child: Icon(
                                          Icons.favorite_sharp,
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 16.0)),
                                ),
                              ),
                            ),
                          ),
                          if (_model.usersanswer != null &&
                              (_model.usersanswer)!.isNotEmpty)
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 20.0, 20.0, 0.0),
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          'pmne5rlo' /* Hello,  */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.raleway(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 28.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        valueOrDefault<String>(
                                          _model.usersanswer?.firstOrNull
                                              ?.firstName,
                                          'user',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.raleway(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 28.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 18.0, 20.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).primary,
                                    Color(0xFFA7B6CC),
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(21.0),
                              ),
                              child: Stack(
                                children: [
                                  // Glow circle: top-right
                                  Positioned(
                                    top: -40,
                                    right: -40,
                                    child: IgnorePointer(
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Glow circle: bottom-left
                                  Positioned(
                                    bottom: -40,
                                    left: -40,
                                    child: IgnorePointer(
                                      child: Container(
                                        width: 160,
                                        height: 160,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0x0FFFFFFF),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Content
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        18.0, 16.0, 18.0, 16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'cs6ibthq' /* AI Cosmetic Analysis */,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
                                                          color: Colors.white,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  '5tol65io' /* Instantly analyze ingredients ... */,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.85),
                                                          fontSize: 13.0,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        AnimatedBuilder(
                                          animation: _pulseCtrl,
                                          builder: (ctx, child) =>
                                              Transform.scale(
                                            scale: 1.0 +
                                                _pulseCtrl.value * 0.025,
                                            child: child,
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              context.pushNamed(
                                                TakeorUploadPageWidget
                                                    .routeName,
                                                extra: <String, dynamic>{
                                                  '__transition_info__':
                                                      TransitionInfo(
                                                    hasTransition: true,
                                                    transitionType:
                                                        PageTransitionType.fade,
                                                    duration: Duration(
                                                        milliseconds: 0),
                                                  ),
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'sgp5e6y4' /* Start Analysis */,
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmallFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmallIsCustom,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 21.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: _availableChips(containerImagesRowList)
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
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Text(
                                                _chipLabel(catKey, FFLocalizations.of(context).languageCode),
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
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
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
                                      })
                                      .toList(),
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(),
                              child: FutureBuilder<List<ImagesRow>>(
                                future: _model.imagesFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
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
                                  final allRows = snapshot.data!;
                                  final List<ImagesRow>
                                      staggeredViewImagesRowList =
                                      _model.selectedCategory == 'all'
                                          ? allRows
                                          : allRows
                                              .where((r) => (_kHomeCategoryTypes[
                                                          _model
                                                              .selectedCategory] ??
                                                      [])
                                                  .contains(
                                                      r.productType ?? ''))
                                              .toList();

                                  if (staggeredViewImagesRowList.isEmpty) {
                                    if (_model.selectedCategory == 'all') {
                                      // No products at all — show onboarding empty state
                                      final lang = FFLocalizations.of(context).languageCode;
                                      final title = lang == 'ru'
                                          ? 'Здесь появятся ваши продукты'
                                          : lang == 'es'
                                              ? 'Tus productos aparecerán aquí'
                                              : 'Your products will appear here';
                                      final subtitle = lang == 'ru'
                                          ? 'Сфотографируйте косметику или добавьте скриншот из галереи'
                                          : lang == 'es'
                                              ? 'Fotografía un cosmético o añade una captura de pantalla'
                                              : 'Photograph a product or add a screenshot from your gallery';
                                      final btnLabel = lang == 'ru'
                                          ? 'Добавить продукт'
                                          : lang == 'es'
                                              ? 'Añadir producto'
                                              : 'Add a product';
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                size: 56,
                                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.35),
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                title,
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                                      fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w600,
                                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                    ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                subtitle,
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                    ),
                                              ),
                                              const SizedBox(height: 28),
                                              FFButtonWidget(
                                                onPressed: () => context.pushNamed(TakeorUploadPageWidget.routeName),
                                                text: btnLabel,
                                                options: FFButtonOptions(
                                                  height: 50,
                                                  padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 28, 0),
                                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                      ),
                                                  elevation: 0.0,
                                                  borderRadius: BorderRadius.circular(50.0),
                                                ),
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
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                    itemBuilder: (context, staggeredViewIndex) {
                                      final staggeredViewImagesRow =
                                          staggeredViewImagesRowList[
                                              staggeredViewIndex];
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          if (Navigator.of(context).canPop()) {
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
                                            staggeredViewImagesRow.productName,
                                            'No product name info',
                                          ),
                                          score: valueOrDefault<double>(
                                            ((valueOrDefault<double>(
                                                          staggeredViewImagesRow
                                                              .saCompositeScore,
                                                          0.0,
                                                        ) ??
                                                        0)
                                                    .round())
                                                .toDouble(),
                                            0.0,
                                          ),
                                          stars: 0,
                                          tags: staggeredViewImagesRow
                                              .saBestForTags,
                                          imageID: staggeredViewImagesRow.id,
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
                    ),  // ConstrainedBox
                  ),  // SingleChildScrollView
                ),  // RawScrollbar
              ),  // RefreshIndicator
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
