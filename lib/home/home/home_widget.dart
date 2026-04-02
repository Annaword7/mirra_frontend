import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/item_card/imagedetailed_main/imagedetailed_main_widget.dart';
import 'dart:async';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late HomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
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
              future: ImagesTable().queryRows(
                queryFn: (q) => q
                    .eqOrNull(
                      'user',
                      currentUserUid,
                    )
                    .order('created_at'),
              ),
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
                      safeSetState(() {});
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    18.0, 16.0, 18.0, 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'cs6ibthq' /* AI Cosmetic Analysis */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLargeFamily,
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLargeIsCustom,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              '5tol65io' /* Instantly analyze ingredients ... */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: Colors.white
                                                      .withOpacity(0.85),
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
                                    GestureDetector(
                                      onTap: () async {
                                        context.pushNamed(
                                          TakeorUploadPageWidget.routeName,
                                          extra: <String, dynamic>{
                                            '__transition_info__':
                                                TransitionInfo(
                                              hasTransition: true,
                                              transitionType:
                                                  PageTransitionType.fade,
                                              duration:
                                                  Duration(milliseconds: 0),
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
                                          FFLocalizations.of(context).getText(
                                            'sgp5e6y4' /* Start Analysis */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
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
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 10.0, 16.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(),
                              child: FutureBuilder<List<ImagesRow>>(
                                future: ImagesTable().queryRows(
                                  queryFn: (q) => q
                                      .eqOrNull(
                                        'user',
                                        currentUserUid,
                                      )
                                      .order('created_at'),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
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
                                  List<ImagesRow> staggeredViewImagesRowList =
                                      snapshot.data!;

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
                                          stars: valueOrDefault<int>(
                                            staggeredViewImagesRow
                                                .starsFromUser,
                                            0,
                                          ),
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
                    ),
                  ),
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
