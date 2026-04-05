import '/backend/supabase/supabase.dart';
import '/boards/edit_album/edit_album_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item_card/imagedetailed_main/imagedetailed_main_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'imagesby_album_model.dart';
export 'imagesby_album_model.dart';

class ImagesbyAlbumWidget extends StatefulWidget {
  const ImagesbyAlbumWidget({
    super.key,
    this.albumid,
  });

  final String? albumid;

  static String routeName = 'imagesbyAlbum';
  static String routePath = '/imagesbyAlbum';

  @override
  State<ImagesbyAlbumWidget> createState() => _ImagesbyAlbumWidgetState();
}

class _ImagesbyAlbumWidgetState extends State<ImagesbyAlbumWidget> {
  late ImagesbyAlbumModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImagesbyAlbumModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlbumRow>>(
      future: AlbumTable().querySingleRow(
        queryFn: (q) => q.eqOrNull(
          'id',
          widget.albumid,
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
        List<AlbumRow> imagesbyAlbumAlbumRowList = snapshot.data!;

        final imagesbyAlbumAlbumRow = imagesbyAlbumAlbumRowList.isNotEmpty
            ? imagesbyAlbumAlbumRowList.first
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
              iconTheme: IconThemeData(
                  color: FlutterFlowTheme.of(context).primaryText),
              automaticallyImplyLeading: false,
              leading: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: FlutterFlowIconButton(
                  borderRadius: 20.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.arrow_back_outlined,
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    context.safePop();
                  },
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          imagesbyAlbumAlbumRow!.name!,
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleLargeFamily,
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                fontSize: 20.0,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleLargeIsCustom,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                    child: FlutterFlowIconButton(
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      icon: Icon(
                        Icons.edit,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          enableDrag: true,
                          isDismissible: true,
                          context: context,
                          builder: (context) {
                            return GestureDetector(
                              onTap: () => Navigator.pop(context),
                              behavior: HitTestBehavior.opaque,
                              child: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                },
                                behavior: HitTestBehavior.deferToChild,
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: EditAlbumWidget(
                                    albumRef: widget.albumid!,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                    ),
                  ),
                ),
              ],
              centerTitle: true,
              toolbarHeight: 80.0,
              elevation: 0.0,
            ),
            body: Align(
              alignment: AlignmentDirectional(0.0, -1.0),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 1.0,
                constraints: BoxConstraints(
                  maxWidth: 600.0,
                ),
                decoration: BoxDecoration(),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FutureBuilder<List<AlbumImagesRow>>(
                    future: AlbumImagesTable().queryRows(
                      queryFn: (q) => q.eqOrNull(
                        'album_id',
                        widget.albumid,
                      ),
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
                      List<AlbumImagesRow> staggeredViewAlbumImagesRowList =
                          snapshot.data!;

                      return MasonryGridView.builder(
                        gridDelegate:
                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        itemCount: staggeredViewAlbumImagesRowList.length,
                        itemBuilder: (context, staggeredViewIndex) {
                          final staggeredViewAlbumImagesRow =
                              staggeredViewAlbumImagesRowList[
                                  staggeredViewIndex];
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
                                    staggeredViewAlbumImagesRow.imageId,
                                    ParamType.int,
                                  ),
                                }.withoutNulls,
                              );
                            },
                            child: ImagedetailedMainWidget(
                              key: Key(
                                  'Keyk9r_${staggeredViewIndex}_of_${staggeredViewAlbumImagesRowList.length}'),
                              imageUrl: staggeredViewAlbumImagesRow.imageUrl,
                              brand: staggeredViewAlbumImagesRow.brand,
                              name: staggeredViewAlbumImagesRow.productName,
                              score: (staggeredViewAlbumImagesRow.saCompositeScore ?? staggeredViewAlbumImagesRow.score ?? 0.0).roundToDouble(),
                              imageID: staggeredViewAlbumImagesRow.imageId,
                              tags: staggeredViewAlbumImagesRow.saBestForTags,
                              stars: staggeredViewAlbumImagesRow.starsFromUser,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
