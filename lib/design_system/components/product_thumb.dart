import 'package:flutter/material.dart';

import '/design_system/foundations/image_thumb.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Миниатюра продукта для тесных сеток (Косметичка, выбор «Из моих продуктов»).
///
/// Фото вписывается целиком (`contain`) на белом фоне с небольшим внутренним
/// отступом. Раньше тут стоял `cover`, и в узком слоте от вытянутого флакона
/// оставался средний обрезок — по нему продукт не узнать. Каталожные снимки
/// сняты на белом, поэтому вписанное фото не выглядит «письмом в конверте», а
/// собственный скан пользователя хотя бы остаётся целиком.
///
/// Крупные плитки (лента) обрезкой не страдают — там фото высотой 300, и `cover`
/// там уместен: см. [ProductTile].
class ProductThumb extends StatelessWidget {
  const ProductThumb({
    super.key,
    required this.url,
    required this.decodeWidth,
    this.radius = 12,
    this.padding = 6,
  });

  /// Ссылка на фото; пустая строка — заплатка вместо картинки.
  final String url;

  /// Предел распаковки в пикселях: в сетках миниатюры мелкие, и полный размер
  /// снимка держать в памяти незачем (лента однажды уже падала на этом).
  final int decodeWidth;

  final double radius;

  /// Воздух между фото и рамкой, чтобы флакон не упирался в край.
  final double padding;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: double.infinity,
        color: url.isEmpty ? theme.surfaceMuted : Colors.white,
        padding: EdgeInsets.all(url.isEmpty ? 0 : padding),
        child: url.isEmpty
            ? Center(
                child: Icon(Icons.spa_outlined,
                    color: theme.textDisabled, size: theme.size.iconMd),
              )
            : Image(
                image: thumbProvider(url, width: decodeWidth),
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
