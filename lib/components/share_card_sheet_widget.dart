import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'share_card_sheet_model.dart';
export 'share_card_sheet_model.dart';

class ShareCardSheetWidget extends StatefulWidget {
  const ShareCardSheetWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<ShareCardSheetWidget> createState() => _ShareCardSheetWidgetState();
}

class _ShareCardSheetWidgetState extends State<ShareCardSheetWidget> {
  late ShareCardSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ShareCardSheetModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

        final containerImagesRow = containerImagesRowList.isNotEmpty
            ? containerImagesRowList.first
            : null;

        return Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).alternate,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 0.0, 0.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'a1bpjvs8' /* Выберите формат карточки проду... */,
                      ),
                      textAlign: TextAlign.start,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          _model.isStory = true;
                          safeSetState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: valueOrDefault<Color>(
                              _model.isStory
                                  ? Color(0xFF1A1A1D)
                                  : Color(0xFFAFAFB0),
                              Color(0xFF1A1A1D),
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: valueOrDefault<Color>(
                                _model.isStory
                                    ? Color(0xFF1A1A1D)
                                    : Color(0xFFAFAFB0),
                                Color(0xFF1A1A1D),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 8.0, 16.0, 8.0),
                            child: Text(
                              FFLocalizations.of(context).getText(
                                'himmmtup' /* Сториз */,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          _model.isStory = false;
                          safeSetState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: valueOrDefault<Color>(
                              _model.isStory
                                  ? Color(0xFFAFAFB0)
                                  : Color(0xFF1A1A1D),
                              Color(0xFFAFAFB0),
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: valueOrDefault<Color>(
                                _model.isStory
                                    ? Color(0xFFAFAFB0)
                                    : Color(0xFF1A1A1D),
                                Color(0xFFAFAFB0),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 8.0, 16.0, 8.0),
                            child: Text(
                              FFLocalizations.of(context).getText(
                                'k2ruyzeg' /* Квадрат */,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ].divide(SizedBox(width: 10.0)),
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: MediaQuery.sizeOf(context).height * 1.0,
                  child: custom_widgets.ShareCardWidget(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    productName: valueOrDefault<String>(
                      containerImagesRow?.productName,
                      'None',
                    ),
                    brandName: valueOrDefault<String>(
                      containerImagesRow?.brand,
                      'No Brand',
                    ),
                    imageUrl: valueOrDefault<String>(
                      containerImagesRow?.imageUrl,
                      'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
                    ),
                    score: valueOrDefault<double>(
                      containerImagesRow?.saCompositeScore,
                      0.00,
                    ),
                    safetyScore: valueOrDefault<double>(
                      containerImagesRow?.saSafetyScore,
                      0.00,
                    ),
                    efficacyScore: valueOrDefault<double>(
                      containerImagesRow?.saEfficacyScore,
                      0.00,
                    ),
                    isStory: _model.isStory,
                    tags: containerImagesRow!.skinTypeTags,
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
