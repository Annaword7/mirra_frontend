import '/auth/supabase_auth/auth_util.dart';
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

  late Future<List<AlbumRow>> _albumFuture;
  late Future<List<ImagesRow>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImagesbyAlbumModel());
    _albumFuture = AlbumTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', widget.albumid),
    );
    _imagesFuture = _loadImages();
  }

  Future<List<ImagesRow>> _loadImages() async {
    final connections = await ImagesAlbumsConnectionTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('album_id', widget.albumid)
          .eqOrNull('user', currentUserUid),
    );
    if (connections.isEmpty) return [];
    final ids = connections
        .map((c) => c.imageId)
        .whereType<int>()
        .toList();
    if (ids.isEmpty) return [];
    return ImagesTable().queryRows(
      queryFn: (q) => q.inFilter('id', ids),
    );
  }

  void _refresh() {
    safeSetState(() {
      _imagesFuture = _loadImages();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlbumRow>>(
      future: _albumFuture,
      builder: (context, albumSnapshot) {
        if (!albumSnapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
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
        final album = albumSnapshot.data?.firstOrNull;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                  color: FlutterFlowTheme.of(context).primaryText),
              automaticallyImplyLeading: false,
              leading: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: FlutterFlowIconButton(
                  borderRadius: 24.0,
                  buttonSize: 48.0,
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
                          album?.name ?? '',
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
                      borderRadius: 24.0,
                      borderWidth: 1.0,
                      buttonSize: 48.0,
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
                        ).then((_) => _refresh());
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
                  child: FutureBuilder<List<ImagesRow>>(
                    future: _imagesFuture,
                    builder: (context, snapshot) {
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
                      final images = snapshot.data!;

                      if (images.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                FFLocalizations.of(context).getText(
                                  'iba_empty',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      return MasonryGridView.builder(
                        gridDelegate:
                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final row = images[index];
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
                                    row.id,
                                    ParamType.int,
                                  ),
                                }.withoutNulls,
                              );
                            },
                            child: ImagedetailedMainWidget(
                              key: Key(
                                  'Keyk9r_${index}_of_${images.length}'),
                              imageUrl: row.imageUrl,
                              brand: row.brand,
                              name: row.productName,
                              score: (row.saCompositeScore ?? 0.0)
                                  .roundToDouble(),
                              imageID: row.id,
                              tags: row.saBestForTags,
                              hasSpf: row.saHasSpf,
                              stars: row.starsFromUser,
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
