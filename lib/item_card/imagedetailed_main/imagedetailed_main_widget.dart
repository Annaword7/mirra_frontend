import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'imagedetailed_main_model.dart';
export 'imagedetailed_main_model.dart';

class ImagedetailedMainWidget extends StatefulWidget {
  const ImagedetailedMainWidget({
    super.key,
    String? imageUrl,
    String? brand,
    String? name,
    double? score,
    this.tags,
    required this.imageID,
    this.stars,
    this.avgPrice,
    this.priceCurrencyCode,
    this.hasSpf = false,
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
  final int? stars;
  final double? avgPrice;
  final String? priceCurrencyCode;
  final bool hasSpf;

  @override
  State<ImagedetailedMainWidget> createState() =>
      _ImagedetailedMainWidgetState();
}

Color _scoreColor(double score) {
  if (score >= 75) return const Color(0xFF1B5E20);
  if (score >= 65) return const Color(0xFF43A047);
  if (score >= 55) return const Color(0xFFC0CA33);
  if (score >= 45) return const Color(0xFFFFB300);
  if (score >= 35) return const Color(0xFFFF7043);
  return const Color(0xFFD32F2F);
}

class _ImagedetailedMainWidgetState extends State<ImagedetailedMainWidget> {
  late ImagedetailedMainModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImagedetailedMainModel());

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
            blurRadius: 8.0,
            color: Color(0x33000000),
            offset: Offset(0.0, 2.0),
          ),
          BoxShadow(
            blurRadius: 16.0,
            color: _scoreColor(widget.score ?? 0).withOpacity(0.07),
            offset: Offset(0.0, 4.0),
          ),
        ],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          16.0,
        ),
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(),
              child: Stack(
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
                  // Bottom gradient overlay for depth
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      child: Container(
                        height: 90,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0x40000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 0.0),
                    child: _ScoreBadge(score: widget.score),
                  ),
                  if (widget.hasSpf)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              color: Color(0x44000000),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny_rounded, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'SPF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            fontWeight: FontWeight.bold,
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
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
            child: Container(
              decoration: BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if ((widget.stars ?? 0) >= 1)
                    Icon(
                      Icons.star_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                  if ((widget.stars ?? 0) >= 2)
                    Icon(
                      Icons.star_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                  if ((widget.stars ?? 0) >= 3)
                    Icon(
                      Icons.star_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                  if ((widget.stars ?? 0) >= 4)
                    Icon(
                      Icons.star_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                  if ((widget.stars ?? 0) >= 5)
                    Icon(
                      Icons.star_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                ],
              ),
            ),
          ),
        ].divide(SizedBox(height: 8.0)),
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
            ),
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
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }
    final sColor = _scoreColor(score!);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            blurRadius: 8,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
          BoxShadow(
            blurRadius: 10,
            color: sColor.withOpacity(0.35),
            offset: const Offset(0, 2),
          ),
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
            backgroundColor: sColor.withOpacity(0.15),
            progressColor: sColor,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            center: Text(
              _grade,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: sColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${score!.toStringAsFixed(0)}/100',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: sColor,
            ),
          ),
        ],
      ),
    );
  }
}
