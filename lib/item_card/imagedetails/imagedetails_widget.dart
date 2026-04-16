import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/boards/albumslist/albumslist_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/new_album/new_album_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/item_card/deleteitem/deleteitem_widget.dart';
import '/item_card/imagedetailed/imagedetailed_widget.dart';
import '/item_card/ingridients/ingridients_widget.dart';
import '/item_card/markasspam/markasspam_widget.dart';
import '/item_card/parametrs/parametrs_widget.dart';
import '/item_card/personalnotes/personalnotes_widget.dart';
import '/item_card/ratingdetailed/ratingdetailed_widget.dart';
import '/item_card/sammary/sammary_widget.dart';
import '/item_card/yourrating/yourrating_widget.dart';
import '/topratings/copyitem/copyitem_widget.dart';
import '/topratings/hidenavailability/hidenavailability_widget.dart';
import '/topratings/makeprivate/makeprivate_widget.dart';
import '/topratings/makepubluc/makepubluc_widget.dart';
import 'dart:async';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:aligned_tooltip/aligned_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'imagedetails_model.dart';
export 'imagedetails_model.dart';

class ImagedetailsWidget extends StatefulWidget {
  const ImagedetailsWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  static String routeName = 'imagedetails';
  static String routePath = '/imagedetails';

  @override
  State<ImagedetailsWidget> createState() => _ImagedetailsWidgetState();
}

class _ImagedetailsWidgetState extends State<ImagedetailsWidget> {
  late ImagedetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImagedetailsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await action_blocks.se(context);
      safeSetState(() {});
      _model.albumsalreadyadded2 =
          await ImagesAlbumsConnectionTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'image_id',
          widget.imageid,
        ),
      );
      _model.albumsselected2 = functions
          .albumidsToList(_model.albumsalreadyadded2?.toList())!
          .toList()
          .cast<String>();
      safeSetState(() {});
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

    return FutureBuilder<List<ImagesRow>>(
      future: ImagesTable().querySingleRow(
        queryFn: (q) => q.eqOrNull(
          'id',
          widget.imageid,
        ),
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
        List<ImagesRow> imagedetailsImagesRowList = snapshot.data!;

        final imagedetailsImagesRow = imagedetailsImagesRowList.isNotEmpty
            ? imagedetailsImagesRowList.first
            : null;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: false,
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () async {
                  context.pushNamed(HomeWidget.routeName);
                },
              ),
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (imagedetailsImagesRow!.hided! &&
                        (imagedetailsImagesRow.user == currentUserUid))
                      FlutterFlowIconButton(
                        borderRadius: 30.0,
                        borderWidth: 1.0,
                        buttonSize: 60.0,
                        icon: FaIcon(
                          FontAwesomeIcons.eyeSlash,
                          color: FlutterFlowTheme.of(context).info,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await ImagesTable().update(
                            data: {
                              'hided': false,
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'id',
                              widget.imageid,
                            ),
                          );
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: MakepublucWidget(
                                    imageid: 0,
                                  ),
                                ),
                              );
                            },
                          ).then((value) => safeSetState(() {}));

                          safeSetState(() {});
                        },
                      ),
                    if (!imagedetailsImagesRow.hided! &&
                        (imagedetailsImagesRow.user == currentUserUid))
                      FlutterFlowIconButton(
                        borderRadius: 30.0,
                        borderWidth: 1.0,
                        buttonSize: 60.0,
                        icon: FaIcon(
                          FontAwesomeIcons.eye,
                          color: FlutterFlowTheme.of(context).info,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          if (FFAppState().isprouser) {
                            await ImagesTable().update(
                              data: {
                                'hided': true,
                              },
                              matchingRows: (rows) => rows.eqOrNull(
                                'id',
                                widget.imageid,
                              ),
                            );
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: MakeprivateWidget(
                                      imageid: 0,
                                    ),
                                  ),
                                );
                              },
                            ).then((value) => safeSetState(() {}));

                            safeSetState(() {});
                          } else {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: HidenavailabilityWidget(
                                      imageid: 0,
                                    ),
                                  ),
                                );
                              },
                            ).then((value) => safeSetState(() {}));
                          }
                        },
                      ),
                    if (!imagedetailsImagesRow.favourite! &&
                        (imagedetailsImagesRow.user == currentUserUid))
                      FlutterFlowIconButton(
                        borderRadius: 30.0,
                        borderWidth: 1.0,
                        buttonSize: 60.0,
                        icon: Icon(
                          Icons.favorite_border,
                          color: FlutterFlowTheme.of(context).info,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await ImagesTable().update(
                            data: {
                              'favourite': true,
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'id',
                              widget.imageid,
                            ),
                          );
                          safeSetState(() {});
                        },
                      ),
                    if (imagedetailsImagesRow.favourite! &&
                        (imagedetailsImagesRow.user == currentUserUid))
                      FlutterFlowIconButton(
                        borderRadius: 30.0,
                        borderWidth: 1.0,
                        buttonSize: 60.0,
                        icon: Icon(
                          Icons.favorite_sharp,
                          color: FlutterFlowTheme.of(context).error,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await ImagesTable().update(
                            data: {
                              'favourite': false,
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'id',
                              widget.imageid,
                            ),
                          );
                          safeSetState(() {});
                        },
                      ),
                    if (imagedetailsImagesRow.user == currentUserUid)
                      FlutterFlowIconButton(
                        borderRadius: 30.0,
                        borderWidth: 1.0,
                        buttonSize: 60.0,
                        icon: Icon(
                          Icons.add_box_rounded,
                          color: FlutterFlowTheme.of(context).info,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          _model.albums = await AlbumTable().queryRows(
                            queryFn: (q) => q.eqOrNull(
                              'user',
                              currentUserUid,
                            ),
                          );
                          if (_model.albums?.length == 0) {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: NewAlbumWidget(),
                                  ),
                                );
                              },
                            ).then((value) => safeSetState(() {}));
                          } else {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: AlbumslistWidget(
                                      imageID: widget.imageid!,
                                      albums: _model.albums ?? [],
                                    ),
                                  ),
                                );
                              },
                            ).then((value) => safeSetState(() {}));
                          }

                          safeSetState(() {});
                        },
                      ),
                    if (imagedetailsImagesRow.user == currentUserUid)
                      FlutterFlowIconButton(
                        borderRadius: 30.0,
                        borderWidth: 1.0,
                        buttonSize: 60.0,
                        icon: Icon(
                          Icons.delete_forever,
                          color: FlutterFlowTheme.of(context).info,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: DeleteitemWidget(
                                    imageid: widget.imageid!,
                                  ),
                                ),
                              );
                            },
                          ).then((value) => safeSetState(() {}));
                        },
                      ),
                    if (imagedetailsImagesRow.user != currentUserUid)
                      FlutterFlowIconButton(
                        borderRadius: 30.0,
                        borderWidth: 1.0,
                        buttonSize: 60.0,
                        icon: Icon(
                          Icons.copy_all,
                          color: FlutterFlowTheme.of(context).info,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: CopyitemWidget(
                                    imageid: widget.imageid!,
                                  ),
                                ),
                              );
                            },
                          ).then((value) => safeSetState(() {}));
                        },
                      ),
                    AlignedTooltip(
                      content: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'fpabsgw2' /* Mark as spam */,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyLargeFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyLargeIsCustom,
                              ),
                        ),
                      ),
                      offset: 4.0,
                      preferredDirection: AxisDirection.down,
                      borderRadius: BorderRadius.circular(8.0),
                      backgroundColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      elevation: 4.0,
                      tailBaseWidth: 24.0,
                      tailLength: 12.0,
                      waitDuration: Duration(milliseconds: 100),
                      showDuration: Duration(milliseconds: 1500),
                      triggerMode: TooltipTriggerMode.tap,
                      child: Visibility(
                        visible: imagedetailsImagesRow.user != currentUserUid,
                        child: FlutterFlowIconButton(
                          borderRadius: 30.0,
                          borderWidth: 1.0,
                          buttonSize: 60.0,
                          icon: Icon(
                            Icons.block,
                            color: FlutterFlowTheme.of(context).info,
                            size: 30.0,
                          ),
                          onPressed: () async {
                            final confirmed =
                                await showModalBottomSheet<bool>(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: MarkasspamWidget(
                                      imageid: widget.imageid!,
                                    ),
                                  ),
                                );
                              },
                            );
                            if (confirmed == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    FFLocalizations.of(context).getText(
                                      'spam_hidden_toast',
                                    ),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              );
                              context.safePop();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              centerTitle: false,
              elevation: 2.0,
            ),
            body: Stack(
              alignment: AlignmentDirectional(0.0, 1.0),
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 600.0,
                    ),
                    decoration: BoxDecoration(),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 16.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed(
                                    ShareproductWidget.routeName,
                                    queryParameters: {
                                      'imageid': serializeParam(
                                        widget.imageid,
                                        ParamType.int,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                                text: FFLocalizations.of(context).getText(
                                  'qrwru10w' /* Print */,
                                ),
                                options: FFButtonOptions(
                                  height: 40.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: wrapWithModel(
                              model: _model.imagedetailedModel,
                              updateCallback: () => safeSetState(() {}),
                              child: ImagedetailedWidget(
                                imageUrl: imagedetailsImagesRow.imageUrl,
                                brand: imagedetailsImagesRow.brand,
                                name: imagedetailsImagesRow.productName,
                                score: imagedetailsImagesRow.score,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: wrapWithModel(
                              model: _model.ratingdetailedModel,
                              updateCallback: () => safeSetState(() {}),
                              child: RatingdetailedWidget(
                                score: imagedetailsImagesRow.score,
                                tags: imagedetailsImagesRow.skinTypeTags,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: wrapWithModel(
                              model: _model.ingridientsModel,
                              updateCallback: () => safeSetState(() {}),
                              child: IngridientsWidget(
                                ingridients: imagedetailsImagesRow.ingredients,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: wrapWithModel(
                              model: _model.yourratingModel,
                              updateCallback: () => safeSetState(() {}),
                              child: YourratingWidget(
                                stars: imagedetailsImagesRow.starsFromUser,
                                imageid: imagedetailsImagesRow.id,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: wrapWithModel(
                              model: _model.personalnotesModel,
                              updateCallback: () => safeSetState(() {}),
                              child: PersonalnotesWidget(
                                personalnotes:
                                    imagedetailsImagesRow.personalNotes,
                                imageid: imagedetailsImagesRow.id,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: wrapWithModel(
                              model: _model.sammaryModel,
                              updateCallback: () => safeSetState(() {}),
                              child: SammaryWidget(
                                sammary: imagedetailsImagesRow.summary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: wrapWithModel(
                              model: _model.parametrsModel,
                              updateCallback: () => safeSetState(() {}),
                              child: ParametrsWidget(
                                imageID: widget.imageid!,
                              ),
                            ),
                          ),
                        ]
                            .divide(SizedBox(height: 12.0))
                            .addToStart(SizedBox(height: 24.0))
                            .addToEnd(SizedBox(height: 140.0)),
                      ),
                    ),
                  ),
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
                        activePage:
                            imagedetailsImagesRow.user == currentUserUid
                                ? 2
                                : 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
