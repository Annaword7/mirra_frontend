/// Shared layout constants (Design Review Initiative 13).
///
/// The bottom nav bar height is the anchor other layouts should reference so
/// magic offsets stay coordinated (review B13). Note: the team rewrote the
/// navbar since the review (height is now 121, not the review's 108), so the
/// capture-screen offsets that hand-tune around it (takeor_upload's
/// `bottom: 320` illustration + `bottom: 100 + safeArea` action zone) should be
/// re-derived from this constant only after a navbar re-review + on-device check
/// — not blind — and are intentionally left untouched here.
library;

import 'package:flutter/widgets.dart';

/// Height of the bottom navigation bar (`navbar_widget`).
const double kNavBarHeight = 121.0;

/// С этой ширины окна раскладка планшетная. iPad mini в портрете — 744pt,
/// самый широкий iPhone — 440pt; окно Split View в треть iPad (≈320pt)
/// получает телефонную раскладку.
const double kTabletBreakpoint = 600.0;

/// Предел ширины контента на планшете для страниц-списков и форм (настройки,
/// карточка продукта, вход, шторки). Совпадает с `maxWidth: 600`, который
/// FlutterFlow уже проставил на части страниц; шире — строки настроек и
/// кнопки растягиваются во весь iPad.
const double kContentMaxWidth = 600.0;

/// Предел ширины центрированного диалога. Material 2 ширину диалога не
/// ограничивает, и на iPad длинный текст растягивал карточку почти во весь
/// экран. На телефоне предел не достигается: самый широкий iPhone минус
/// отступы диалога — 392pt.
const double kDialogMaxWidth = 420.0;

/// Число колонок сетки по ширине окна: на телефоне [phone], на планшете —
/// сколько плиток шириной около [tileWidth] помещается, но не больше шести.
///
/// Считаем от ширины окна, а не устройства: в Split View iPad сужается до
/// телефонной ширины и должен получить телефонную сетку.
int gridColumns(BuildContext context,
    {int phone = 2, double tileWidth = 180.0}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < kTabletBreakpoint) return phone;
  final fit = (width / tileWidth).floor();
  if (fit < phone) return phone;
  return fit > 6 ? 6 : fit;
}

/// Отношение ширины к высоте у рамок под фото продуктов (3:4).
///
/// Снимки продуктов — вертикальные: каталожные квадратные, пользовательские
/// доходят до 1:2 (скриншоты из галереи). В квадратной рамке первые обрезаются
/// по бокам, вторые превращаются в полоску; вертикальная рамка подходит обоим.
const double kThumbAspect = 3 / 4;
