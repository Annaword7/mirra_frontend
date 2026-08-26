import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/foundations/image_thumb.dart';
import '/design_system/foundations/score_status.dart';
import '/design_system/foundations/format_price.dart';
import '/design_system/components/score_badge.dart';

/// Visual style of a [ProductTile] (Design Review Initiative 7).
enum ProductTileVariant {
  /// The hero grid tile (ex-`imagedetailed_main`): score-tinted glow shadow,
  /// bottom image gradient, glowing [ScoreBadge], stars row.
  main,

  /// The lighter list tile (ex-`imagedetailed_top_raited`): flat shadow, plain
  /// badge, no stars.
  plain,
}

/// The single product card used across home / search / toprated /
/// imagesby_album (Design Review Initiative 7). Merges the two byte-similar
/// tiles `imagedetailed_main` + `imagedetailed_top_raited` (image block, score
/// badge, SPF/price chips, brand + name, stars) into one component with a
/// [ProductTileVariant].
class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    String? imageUrl,
    String? brand,
    String? name,
    this.score,
    this.stars,
    this.avgPrice,
    this.priceCurrencyCode,
    this.hasSpf = false,
    this.variant = ProductTileVariant.main,
  })  : imageUrl = imageUrl ??
            'https://static.vecteezy.com/system/resources/thumbnails/022/014/063/small/missing-picture-page-for-website-design-or-mobile-app-design-no-image-available-icon-vector.jpg',
        brand = brand ?? 'no brand',
        name = name ?? 'no name';

  final String imageUrl;
  final String brand;
  final String name;
  final double? score;

  /// 0–5; the stars row renders in the [ProductTileVariant.main] variant only.
  final int? stars;

  final double? avgPrice;
  final String? priceCurrencyCode;
  final bool hasSpf;
  final ProductTileVariant variant;

  // Chip colors kept from the original tiles (named, not tokenized — the
  // color-token track is paused): SPF badge blue and price-chip text.
  static const Color _spfBlue = Color(0xFF1565C0);
  static const Color _priceText = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isMain = variant == ProductTileVariant.main;

    return Container(
      decoration: BoxDecoration(
        color: theme.alternate,
        boxShadow: [
          BoxShadow(
            blurRadius: isMain ? 8.0 : 4.0,
            color: const Color(0x33000000),
            offset: const Offset(0.0, 2.0),
          ),
          if (isMain)
            BoxShadow(
              blurRadius: 16.0,
              color: semanticScoreColor(score ?? 0).withValues(alpha: 0.07),
              offset: const Offset(0.0, 4.0),
            ),
        ],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: isMain ? 16.0 : 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
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
                        // Уменьшенная версия с сервера (см. image_thumb): в
                        // ленту незачем тянуть исходные снимки на мегабайты.
                        // Предел на распаковку теперь внутри thumbProvider.
                        image: thumbProvider(imageUrl, width: 720),
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 300.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isMain)
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
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 0.0),
                    child: ScoreBadge(score: score, glow: isMain),
                  ),
                  if (hasSpf)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _spfBlue.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              color: Color(0x44000000),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny_rounded,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'SPF',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (avgPrice != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              color: Color(0x44000000),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        child: Text(
                          '~ ${formatPrice(avgPrice!, priceCurrencyCode)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _priceText,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-1.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 0.0, 0.0),
                child: Text(
                  brand,
                  textAlign: TextAlign.start,
                  style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.primary,
                        letterSpacing: 1.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-1.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                child: Text(
                  name,
                  textAlign: TextAlign.start,
                  style: theme.headlineMedium.override(
                        fontFamily: theme.headlineMediumFamily,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.headlineMediumIsCustom,
                      ),
                ),
              ),
            ),
            if (isMain)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                child: Semantics(
                  label: '${stars ?? 0}/5',
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      for (var i = 1; i <= 5; i++)
                        if ((stars ?? 0) >= i)
                          Icon(
                            Icons.star_rounded,
                            color: theme.primary,
                            size: 26.0,
                          ),
                    ],
                  ),
                ),
              ),
          ].divide(const SizedBox(height: 8.0)),
        ),
      ),
    );
  }
}
