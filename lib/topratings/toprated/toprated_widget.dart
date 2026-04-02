import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'toprated_model.dart';
export 'toprated_model.dart';

class TopratedWidget extends StatefulWidget {
  const TopratedWidget({super.key});

  static String routeName = 'Toprated';
  static String routePath = '/Toprated';

  @override
  State<TopratedWidget> createState() => _TopratedWidgetState();
}

class _TopratedWidgetState extends State<TopratedWidget> {
  late TopratedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TopratedModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.userrow = await UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          currentUserUid,
        ),
      );
      final profileImg = _model.userrow?.firstOrNull?.profileImage;
      if (profileImg != null && profileImg.isNotEmpty) {
        FFAppState().userProfilePicture = profileImg;
      }
      safeSetState(() {});
      await _model.listViewController?.animateTo(
        0,
        duration: Duration(milliseconds: 100),
        curve: Curves.ease,
      );
      _model.usersanswer2 = await UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          currentUserUid,
        ),
      );
      if (_model.usersanswer2!.length <= 0) {
        context.pushNamed(LogInPageWidget.routeName);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return FutureBuilder<List<ImagesRow>>(
      future: ImagesTable().queryRows(
        queryFn: (q) => q
            .neqOrNull(
              'user',
              currentUserUid,
            )
            .gteOrNull(
              'sa_composite_score',
              70.0,
            )
            .eqOrNull(
              'language_code',
              FFLocalizations.of(context).languageCode,
            )
            .order('score'),
        limit: 50,
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<ImagesRow> topratedImagesRowList = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: PopScope(
            canPop: false,
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: Stack(
                alignment: AlignmentDirectional(0.0, -1.0),
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 64.0, 16.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          0.0,
                          0,
                          0,
                        ),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Text(
                                FFLocalizations.of(context).getText(
                                  's0iman0p' /* Explore */,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleLargeFamily,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleLargeIsCustom,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 12.0, 16.0, 0.0),
                              child: Text(
                                FFLocalizations.of(context).getText(
                                  'lhz5s19w' /* Top-rated by the community */,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleLargeFamily,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleLargeIsCustom,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final images = topratedImagesRowList
                                    .map((e) => e)
                                    .toList();

                                return MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  itemCount: images.length,
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    0,
                                  ),
                                  shrinkWrap: true,
                                  itemBuilder: (context, imagesIndex) {
                                    final imagesItem = images[imagesIndex];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          Itemcard2Widget.routeName,
                                          queryParameters: {
                                            'imageid': serializeParam(
                                              imagesItem.id,
                                              ParamType.int,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child: ImagedetailedTopRaitedWidget(
                                        key: Key(
                                            'Keyytw_${imagesIndex}_of_${images.length}'),
                                        imageUrl: imagesItem.imageUrl,
                                        brand: imagesItem.brand,
                                        name: imagesItem.productName,
                                        score: imagesItem.saCompositeScore,
                                        imageID: imagesItem.id,
                                        tags: imagesItem.saBestForTags,
                                      ),
                                    );
                                  },
                                  controller: _model.staggeredViewController,
                                );
                              },
                            ),
                          ),
                        ],
                        controller: _model.listViewController,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: wrapWithModel(
                      model: _model.navbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: NavbarWidget(
                        activePage: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
