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
                    child: _ScoreBadge(score: widget.score),
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
                          '~ ${_formatCardPrice(widget.avgPrice!, widget.priceCurrencyCode)}',
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

String _formatCardPrice(double price, String? code) {
  const symbols = {
    'ARS': 'AR\$', 'CAD': 'CA\$', 'CLP': 'CL\$', 'CNY': '¥',
    'COP': 'CO\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
    'KRW': '₩', 'MXN': 'MX\$', 'PEN': 'S/', 'RUB': '₽', 'USD': '\$',
  };
  final sym = symbols[code] ?? code ?? '';
  return '$sym${price.round()}';
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final double? score;

  Color get _color {
    final s = score!;
    if (s >= 75) return const Color(0xFF1B5E20);
    if (s >= 65) return const Color(0xFF43A047);
    if (s >= 55) return const Color(0xFFC0CA33);
    if (s >= 45) return const Color(0xFFFFB300);
    if (s >= 35) return const Color(0xFFFF7043);
    return const Color(0xFFD32F2F);
  }

  String get _grade {
    final s = score!;
    if (s >= 75) return 'A';
    if (s >= 65) return 'B';
    if (s >= 55) return 'C';
    if (s >= 45) return 'D';
    if (s >= 35) return 'E';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    if (score == null) {
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
            Icon(Icons.science_outlined, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              '···',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }
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
            percent: (score! / 100.0).clamp(0.0, 1.0),
            backgroundColor: _color.withOpacity(0.15),
            progressColor: _color,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            center: Text(
              _grade,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
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
                '${score!.toStringAsFixed(0)}/100',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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
