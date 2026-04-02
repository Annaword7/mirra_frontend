import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 0.0),
                    child: _ScoreBadge(score: widget.score),
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

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final double score;

  Color get _color {
    if (score >= 75) return const Color(0xFF1B5E20);
    if (score >= 65) return const Color(0xFF43A047);
    if (score >= 55) return const Color(0xFFC0CA33);
    if (score >= 45) return const Color(0xFFFFB300);
    if (score >= 35) return const Color(0xFFFF7043);
    return const Color(0xFFD32F2F);
  }

  String get _grade {
    if (score >= 75) return 'A';
    if (score >= 65) return 'B';
    if (score >= 55) return 'C';
    if (score >= 45) return 'D';
    if (score >= 35) return 'E';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 20.0,
            lineWidth: 3.5,
            percent: (score / 100.0).clamp(0.0, 1.0),
            backgroundColor: _color.withOpacity(0.15),
            progressColor: _color,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            center: Text(
              _grade,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.toStringAsFixed(0)}/100',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
