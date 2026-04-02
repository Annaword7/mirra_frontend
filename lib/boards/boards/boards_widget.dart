import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/boards/newboardempty/newboardempty_widget.dart';
import '/components/album_list_loading_component/album_list_loading_component_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/new_album/new_album_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'boards_model.dart';
export 'boards_model.dart';

class BoardsWidget extends StatefulWidget {
  const BoardsWidget({super.key});

  static String routeName = 'Boards';
  static String routePath = '/boards';

  @override
  State<BoardsWidget> createState() => _BoardsWidgetState();
}

class _BoardsWidgetState extends State<BoardsWidget> {
  late BoardsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<ImagesAlbumsConnectionRow>> _connectionsFuture;
  late Future<List<AlbumRow>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BoardsModel());
    _connectionsFuture = ImagesAlbumsConnectionTable().queryRows(
      queryFn: (q) => q.eqOrNull('user', currentUserUid),
    );
    _albumsFuture = AlbumTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user', currentUserUid)
          .order('created_at'),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _refresh() {
    safeSetState(() {
      _connectionsFuture = ImagesAlbumsConnectionTable().queryRows(
        queryFn: (q) => q.eqOrNull('user', currentUserUid),
      );
      _albumsFuture = AlbumTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('user', currentUserUid)
            .order('created_at'),
      );
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImagesAlbumsConnectionRow>>(
      future: _connectionsFuture,
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
        List<ImagesAlbumsConnectionRow> boardsImagesAlbumsConnectionRowList =
            snapshot.data!;

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
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 64.0, 16.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              FFLocalizations.of(context).getText(
                                'g9plkvs3' /* Boards */,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleLargeFamily,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleLargeIsCustom,
                                  ),
                            ),
                            FFButtonWidget(
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
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: NewAlbumWidget(),
                                      ),
                                    );
                                  },
                                ).then((value) => _refresh());
                              },
                              text: FFLocalizations.of(context).getText(
                                'lkfbdixo' /* New board */,
                              ),
                              icon: Icon(
                                Icons.add,
                                size: 15.0,
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
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<AlbumRow>>(
                          future: _albumsFuture,
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return AlbumListLoadingComponentWidget();
                            }
                            List<AlbumRow> gridViewAlbumRowList =
                                snapshot.data!;

                            if (gridViewAlbumRowList.isEmpty) {
                              return NewboardemptyWidget(
                                onBoardCreated: _refresh,
                              );
                            }

                            return GridView.builder(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.0,
                                mainAxisSpacing: 12.0,
                                childAspectRatio: 0.87,
                              ),
                              primary: false,
                              scrollDirection: Axis.vertical,
                              itemCount: gridViewAlbumRowList.length,
                              itemBuilder: (context, gridViewIndex) {
                                final gridViewAlbumRow =
                                    gridViewAlbumRowList[gridViewIndex];
                                return _AlbumCard(album: gridViewAlbumRow);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.navbarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavbarWidget(
                      activePage: 3,
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

class _AlbumCard extends StatefulWidget {
  const _AlbumCard({required this.album});
  final AlbumRow album;

  @override
  State<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<_AlbumCard> {
  late Future<List<AlbumImagesRow>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = AlbumImagesTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('album_id', widget.album.id)
          .eqOrNull('owner_id', currentUserUid),
      limit: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            onTap: () => context.pushNamed(
              ImagesbyAlbumWidget.routeName,
              queryParameters: {
                'albumid': serializeParam(widget.album.id, ParamType.String),
              }.withoutNulls,
            ),
            child: FutureBuilder<List<AlbumImagesRow>>(
              future: _imagesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  );
                }
                return _AlbumPreview(images: snapshot.data!);
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          valueOrDefault<String>(widget.album.name, 'Untitled'),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
      ],
    );
  }
}

class _AlbumPreview extends StatelessWidget {
  const _AlbumPreview({required this.images});
  final List<AlbumImagesRow> images;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = (constraints.maxWidth - 9) / 2;
          final slots = List.generate(4, (i) => i);
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Row(
                  children: [
                    for (final i in [0, 1])
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == 0 ? 2.5 : 0,
                            bottom: 2.5,
                          ),
                          child: _cell(i),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    for (final i in [2, 3])
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == 2 ? 2.5 : 0,
                            top: 2.5,
                          ),
                          child: _cell(i),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cell(int index) {
    if (index >= images.length || images[index].imageUrl == null) {
      return const SizedBox.expand();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        images[index].imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
