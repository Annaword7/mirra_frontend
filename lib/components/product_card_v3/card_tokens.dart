import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Токены карточки v3 из хэндоффа (тема «white»).
///
/// Почти всё совпадает с FlutterFlowTheme; здесь только то, чего в теме нет
/// или что в ней другое: фон плашек, обводка секций и цвет иконок минусов.
/// Фон экрана белый, как `theme.alternate`; глобальный primaryBackground
/// не трогаем.
class CardTokens {
  static const Color surfaceMuted = Color(0xFFF6F4F1);
  static const Color cardEdge = Color(0xFFEDEAE6);
  static const Color minusIcon = Color(0xFFE5404B);

  static const double sectionRadius = 24;
  static const double sectionPadding = 20;
  static const double sectionGap = 12;
  static const double gutter = 16;
}

/// Текст карточки: Raleway из темы, ровные цифры, без межбуквенного интервала.
TextStyle cardText(
  FlutterFlowTheme theme, {
  double size = 15,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  bool lining = false,
  double letterSpacing = 0.0,
}) {
  final base = theme.bodyMedium.override(
    fontFamily: theme.bodyMediumFamily,
    fontSize: size,
    fontWeight: weight,
    color: color ?? theme.primaryText,
    letterSpacing: letterSpacing,
    useGoogleFonts: !theme.bodyMediumIsCustom,
  );
  return base.copyWith(
    height: height,
    fontFeatures: lining ? const [FontFeature.liningFigures()] : null,
  );
}

/// Секция-карточка: белая, радиус 24, обводка 1 px, внутренний отступ 20.
class CardSection extends StatelessWidget {
  const CardSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(CardTokens.sectionPadding),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.alternate,
        borderRadius: BorderRadius.circular(CardTokens.sectionRadius),
        border: Border.all(color: CardTokens.cardEdge),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Заголовок секции: 17 / 600.
class CardSectionTitle extends StatelessWidget {
  const CardSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final title = Text(text, style: cardText(theme, size: 17, weight: FontWeight.w600));
    if (trailing == null) return title;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Expanded(child: title), trailing!],
    );
  }
}
