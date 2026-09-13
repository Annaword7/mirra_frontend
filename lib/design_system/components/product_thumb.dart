import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '/design_system/foundations/image_thumb.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Миниатюра продукта: снимок поверх размытой заливки им же.
///
/// Фото продуктов приходят без общего формата: каталожные с INCIdecoder бывают
/// почти квадратными и вытянутыми до 1:2, а собственные снимки пользователей —
/// вообще чем угодно, вплоть до скриншота экрана телефона 9:19,5. Один режим
/// вписывания на всё это не натягивается, поэтому режим выбирается по форме
/// самого снимка:
///
///  * **источник выше рамки** (флакон, скриншот) — заполняем с обрезкой по
///    высоте. Сверху и снизу у таких кадров поля или интерфейс, а сам продукт
///    в середине: обрезка забирает пустое и показывает нужное крупно;
///  * **источник шире рамки или квадратный** — вписываем целиком. Обрезать
///    ширину нельзя, от этикетки останется середина без названия.
///
/// Пока размеры снимка неизвестны (первый кадр, пока картинка грузится),
/// вписываем целиком: это безопасный вариант, и подменять его на обрезку в уже
/// отрисованной сетке заметнее, чем наоборот.
///
/// Фон — то же фото, растянутое по рамке и размытое: контейнер заполнен всегда,
/// даже когда снимок вписан с полями.
class ProductThumb extends StatefulWidget {
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

  /// Воздух между фото и рамкой, когда снимок вписывается целиком.
  final double padding;

  /// Ширина распаковки фоновой заливки: её всё равно размывают, детали не
  /// нужны, а память в сетке из полусотни миниатюр — нужна.
  static const int backdropDecodeWidth = 48;

  @override
  State<ProductThumb> createState() => _ProductThumbState();
}

class _ProductThumbState extends State<ProductThumb> {
  ImageStream? _stream;
  ImageStreamListener? _listener;

  /// Ширина / высота исходного снимка. null — ещё не знаем.
  double? _sourceAspect;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveSourceAspect();
  }

  @override
  void didUpdateWidget(covariant ProductThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _sourceAspect = null;
      _resolveSourceAspect();
    }
  }

  void _resolveSourceAspect() {
    if (widget.url.isEmpty) return;
    _detach();
    // Слушаем ту же картинку, что и рисуем: второй загрузки не будет, кадр
    // придёт из того же кэша.
    final stream = thumbProvider(widget.url, width: widget.decodeWidth)
        .resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener((info, _) {
      final aspect = info.image.width / info.image.height;
      if (mounted && aspect != _sourceAspect) {
        setState(() => _sourceAspect = aspect);
      }
    }, onError: (_, __) {});
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  void _detach() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (widget.url.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
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
      borderRadius: BorderRadius.circular(widget.radius),
      child: LayoutBuilder(builder: (context, constraints) {
        final frameAspect = constraints.maxHeight > 0
            ? constraints.maxWidth / constraints.maxHeight
            : 1.0;
        final source = _sourceAspect;
        final cropsHeight = source != null && source < frameAspect;

        return Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Image(
                image: thumbProvider(widget.url,
                    width: ProductThumb.backdropDecodeWidth),
                fit: BoxFit.cover,
              ),
            ),
            // Вуаль поверх размытия: без неё тёмная упаковка даёт фон, на
            // котором теряется и сам снимок, и подпись под миниатюрой.
            ColoredBox(
              color: Colors.white.withValues(alpha: theme.opacity.o64),
            ),
            Padding(
              // Вписанному снимку нужен воздух от рамки, обрезанному — нет:
              // он и должен доходить до краёв.
              padding: EdgeInsets.all(cropsHeight ? 0 : widget.padding),
              child: Image(
                image: thumbProvider(widget.url, width: widget.decodeWidth),
                fit: cropsHeight ? BoxFit.cover : BoxFit.contain,
              ),
            ),
          ],
        );
      }),
    );
  }
}
