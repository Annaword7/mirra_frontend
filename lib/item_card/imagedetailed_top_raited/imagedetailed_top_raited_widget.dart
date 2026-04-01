import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';
import 'imagedetailed_top_raited_model.dart';
export 'imagedetailed_top_raited_model.dart';

class ImagedetailedTopRaitedWidget extends StatefulWidget {
  const ImagedetailedTopRaitedWidget({
    super.key,
    String? imageUrl,
    String? brand,
    String? name,
    double? score,
    this.tags,
    required this.imageID,
  })  : this.imageUrl = imageUrl ??
            'https://static.vecteezy.com/system/resources/thumbnails/022/014/063/small/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg',
        this.brand = brand ?? 'no brand',
        this.name = name ?? 'no name',
        this.score = score ?? 0.0;

  final String imageUrl;
  final String brand;
  final String name;
  final double score;
  final List<String>? tags;
  final int? imageID;

  @override
  State<ImagedetailedTopRaitedWidget> createState() =>
      _ImagedetailedTopRaitedWidgetState();
}

class _ImagedetailedTopRaitedWidgetState
    extends State<ImagedetailedTopRaitedWidget> {
  late ImagedetailedTopRaitedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImagedetailedTopRaitedModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(),
              child: Stack(
                alignment: AlignmentDirectional(-1.0, -1.0),
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: OctoImage(
                        placeholderBuilder: (_) => SizedBox.expand(
                          child: Image(
                            image:
                                BlurHashImage('L6PZfSi_.AyE_3t7t7R**0o#DgR4'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        image: NetworkImage(
                          widget.imageUrl,
                        ),
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 300.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 8.0),
                    child: Container(
                      width: 70.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: valueOrDefault<Color>(
                          () {
                            if (widget.score >= 75.0) {
                              return Color(0xFF1B5E20);
                            } else if ((widget.score < 75.0) &&
                                (widget.score >= 65.0)) {
                              return Color(0xFF43A047);
                            } else if ((widget.score < 65.0) &&
                                (widget.score >= 55.0)) {
                              return Color(0xFFC0CA33);
                            } else if ((widget.score < 55.0) &&
                                (widget.score >= 45.0)) {
                              return Color(0xFFFFB300);
                            } else if ((widget.score < 45.0) &&
                                (widget.score >= 35.0)) {
                              return Color(0xFFFF7043);
                            } else if ((widget.score < 35.0) &&
                                (widget.score >= 25.0)) {
                              return Colors.red;
                            } else {
                              return Color(0xFFD32F2F);
                            }
                          }(),
                          FlutterFlowTheme.of(context).secondaryText,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4.0,
                            color: Color(0x33000000),
                            offset: Offset(
                              0.0,
                              2.0,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: valueOrDefault<Color>(
                            () {
                              if (widget.score >= 75.0) {
                                return Color(0xFF1B5E20);
                              } else if ((widget.score < 75.0) &&
                                  (widget.score >= 65.0)) {
                                return Color(0xFF43A047);
                              } else if ((widget.score < 65.0) &&
                                  (widget.score >= 55.0)) {
                                return Color(0xFFC0CA33);
                              } else if ((widget.score < 55.0) &&
                                  (widget.score >= 45.0)) {
                                return Color(0xFFFFB300);
                              } else if ((widget.score < 45.0) &&
                                  (widget.score >= 35.0)) {
                                return Color(0xFFFF7043);
                              } else if ((widget.score < 35.0) &&
                                  (widget.score >= 25.0)) {
                                return Colors.red;
                              } else {
                                return Color(0xFFD32F2F);
                              }
                            }(),
                            FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          '${valueOrDefault<String>(
                            widget.score.toString(),
                            '-',
                          )}/10',
                          '-',
                        ),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 0.0, 0.0),
              child: Text(
                valueOrDefault<String>(
                  widget.brand,
                  'brand name',
                ),
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).primary,
                      letterSpacing: 1.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
              child: Text(
                valueOrDefault<String>(
                  widget.name,
                  'Product name',
                ),
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).headlineMediumFamily,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                    ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              decoration: BoxDecoration(),
              child: Visibility(
                visible: widget.tags != null && (widget.tags)!.isNotEmpty,
                child: Builder(
                  builder: (context) {
                    final tagsfromlist = widget.tags?.toList() ?? [];

                    return Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      direction: Axis.horizontal,
                      runAlignment: WrapAlignment.start,
                      verticalDirection: VerticalDirection.down,
                      clipBehavior: Clip.none,
                      children: List.generate(tagsfromlist.length,
                          (tagsfromlistIndex) {
                        final tagsfromlistItem =
                            tagsfromlist[tagsfromlistIndex];
                        return Container(
                          height: 35.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondary,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                17.0, 12.0, 18.0, 8.0),
                            child: Text(
                              tagsfromlistItem,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    fontSize: 10.0,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
        ].divide(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 8.0)),
      ),
    );
  }
}
