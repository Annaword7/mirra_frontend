import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';
import 'imagecart_model.dart';
export 'imagecart_model.dart';

class ImagecartWidget extends StatefulWidget {
  const ImagecartWidget({
    super.key,
    required this.imageUrl,
    double? score,
    required this.brand,
    required this.name,
    this.tags,
    this.stars,
  }) : this.score = score ?? 0.0;

  final String? imageUrl;
  final double score;
  final String? brand;
  final String? name;
  final List<String>? tags;
  final int? stars;

  @override
  State<ImagecartWidget> createState() => _ImagecartWidgetState();
}

class _ImagecartWidgetState extends State<ImagecartWidget> {
  late ImagecartModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImagecartModel());

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
                alignment: AlignmentDirectional(-1.0, 1.0),
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
                          widget.imageUrl!,
                        ),
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(-1.0, 1.0),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: valueOrDefault<Color>(
                            () {
                              if (widget.score >= 7.0) {
                                return FlutterFlowTheme.of(context).success;
                              } else if ((widget.score < 7.0) &&
                                  (widget.score >= 3.0)) {
                                return Color(0xFFFA8B4B);
                              } else {
                                return FlutterFlowTheme.of(context).error;
                              }
                            }(),
                            FlutterFlowTheme.of(context).primary,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: valueOrDefault<Color>(
                              () {
                                if (widget.score >= 7.0) {
                                  return FlutterFlowTheme.of(context).success;
                                } else if ((widget.score < 7.0) &&
                                    (widget.score >= 3.0)) {
                                  return Color(0xFFFA8B4B);
                                } else {
                                  return FlutterFlowTheme.of(context).error;
                                }
                              }(),
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            '⭐️ ${valueOrDefault<String>(
                              widget.score.toString(),
                              '0',
                            )}/10',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context).alternate,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
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
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 10.0, 0.0, 0.0),
              child: Text(
                valueOrDefault<String>(
                  widget.name,
                  'Product name',
                ),
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).headlineMediumFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                    ),
              ),
            ),
          ),
          if (widget.tags!.length > 0)
            Flexible(
              child: Builder(
                builder: (context) {
                  final tagsfromlist = widget.tags?.toList() ?? [];

                  return Wrap(
                    spacing: 0.0,
                    runSpacing: 0.0,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.horizontal,
                    runAlignment: WrapAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    clipBehavior: Clip.none,
                    children:
                        List.generate(tagsfromlist.length, (tagsfromlistIndex) {
                      final tagsfromlistItem = tagsfromlist[tagsfromlistIndex];
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text(
                              FFLocalizations.of(context).getText(
                                'zbl2b3bx' /* Hello World */,
                              ),
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
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          Container(
            decoration: BoxDecoration(),
            child: Visibility(
              visible: widget.stars! > 0,
              child: Text(
                () {
                  if (widget.stars == 1) {
                    return '⭐';
                  } else if (widget.stars == 2) {
                    return '⭐⭐';
                  } else if (widget.stars == 3) {
                    return '⭐⭐⭐';
                  } else if (widget.stars == 4) {
                    return '⭐⭐⭐⭐';
                  } else if (widget.stars == 5) {
                    return '⭐⭐⭐⭐⭐';
                  } else {
                    return ' ';
                  }
                }(),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ),
        ].addToEnd(SizedBox(height: 30.0)),
      ),
    );
  }
}
