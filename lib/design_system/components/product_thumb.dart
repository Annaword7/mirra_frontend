import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '/design_system/foundations/image_thumb.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Миниатюра продукта: снимок во всю ширину рамки поверх размытой заливки им же.
///
/// Фото приходят без общего формата: каталожные с INCIdecoder бывают почти
/// квадратными и вытянутыми до 1:2, собственные снимки пользователей — чем
/// угодно, вплоть до скриншота экрана телефона 9:19,5. Отсюда правило: снимок
/// всегда показывается во всю ширину и центруется, а по высоте либо обрезается
/// (если он выше рамки), либо оставляет поля сверху и снизу (если ниже).
///
/// Это [BoxFit.fitWidth]. Ни `cover`, ни `contain` так не умеют: первый режет
/// ширину у всего, что шире рамки, и от этикетки остаётся середина без
/// названия; второй ужимает вытянутые кадры в узкую полоску.
///
/// Поля закрывает фон — то же фото, растянутое и размытое, — поэтому рамка
/// выглядит заполненной при любой форме исходника.
class ProductThumb extends StatelessWidget {
  const ProductThumb({
    super.key,
    required this.url,
    required this.decodeWidth,
    this.radius = 12,
  });

  /// Ссылка на фото; пустая строка — заплатка вместо картинки.
  final String url;

  /// Предел распаковки в пикселях: в сетках миниатюры мелкие, и полный размер
  /// снимка держать в памяти незачем (лента однажды уже падала на этом).
  final int decodeWidth;

  final double radius;

  /// Ширина распаковки фоновой заливки: её всё равно размывают, детали не
  /// нужны, а память в сетке из полусотни миниатюр — нужна.
  static const int backdropDecodeWidth = 48;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (url.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: double.infinity,
          color: theme.surfaceMuted,
          child: Center(
            child: Icon(Icons.spa_outlined,
                color: theme.textDisabled, size: theme.size.iconMd),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Image(
              image: thumbProvider(url, width: backdropDecodeWidth),
              fit: BoxFit.cover,
            ),
          ),
          // Вуаль поверх размытия: без неё тёмная упаковка даёт фон, на котором
          // теряется и сам снимок, и подпись под миниатюрой.
          ColoredBox(color: Colors.white.withValues(alpha: theme.opacity.o64)),
          Image(
            image: thumbProvider(url, width: decodeWidth),
            fit: BoxFit.fitWidth,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}
