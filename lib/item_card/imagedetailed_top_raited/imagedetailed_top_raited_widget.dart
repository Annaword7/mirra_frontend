import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/foundations/format_price.dart';
import '/design_system/components/score_badge.dart';
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
    this.avgPrice,
    this.priceCurrencyCode,
  })  : this.imageUrl = imageUrl ??
            'https://static.vecteezy.com/system/resources/thumbnails/022/014/063/small/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg',
        this.brand = brand ?? 'no brand',
        this.name = name ?? 'no name',
        this.score = score;

  final String imageUrl;
  final String brand;
  final String name;
  final double? score;
  final List<String>? tags;
  final int? imageID;
  final double? avgPrice;
  final String? priceCurrencyCode;

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
                        // Cap decode resolution: grid tiles otherwise decode
                        // each photo at full source size and OOM-kill the app.
                        image: ResizeImage(
                          NetworkImage(
                            widget.imageUrl,
                          ),
                          width: 720,
                        ),
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 300.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 0.0),
                    child: ScoreBadge(score: widget.score),
                  ),
                  if (widget.avgPrice != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              color: Color(0x44000000),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        child: Text(
                          '~ ${formatPrice(widget.avgPrice!, widget.priceCurrencyCode)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                            letterSpacing: 0.2,
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
        ].divide(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 8.0)),
      ),
    );
  }
}

