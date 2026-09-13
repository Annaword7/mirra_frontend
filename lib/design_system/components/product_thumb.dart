import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '/design_system/foundations/image_thumb.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Миниатюра продукта: снимок целиком поверх размытой заливки им же.
///
/// Каталожные фото приходят с INCIdecoder как есть, без приведения к общему
/// формату: попадаются и почти квадратные кадры, и вытянутые бутылочные вплоть
/// до 1:2. Ни один режим вписывания в одиночку с таким разбросом не работает:
/// `cover` режет квадратные до неузнаваемого фрагмента, `contain` превращает
/// вытянутые в узкую полоску посреди пустой рамки.
///
/// Поэтому два слоя. Фоном — то же фото, растянутое по рамке и размытое: оно
/// заполняет контейнер и подхватывает цвет упаковки. Сверху — снимок целиком,
/// без обрезки. Каталожные кадры сняты на белом, поэтому чаще всего фон выходит
/// светлым и приём незаметен; заметен он там, где фон цветной, и там как раз
/// выглядит уместно.
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

  /// Ширина распаковки фоновой заливки: её всё равно размывают, детали не
  /// нужны, а память в сетке из полусотни миниатюр — нужна.
  static const int _backdropDecodeWidth = 48;

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
              image: thumbProvider(url, width: _backdropDecodeWidth),
              fit: BoxFit.cover,
            ),
          ),
          // Вуаль поверх размытия: без неё тёмная упаковка даёт фон, на котором
          // сам снимок теряется, а подпись под миниатюрой перестаёт читаться.
          ColoredBox(
            color: Colors.white.withValues(alpha: theme.opacity.o64),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Image(
              image: thumbProvider(url, width: decodeWidth),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
