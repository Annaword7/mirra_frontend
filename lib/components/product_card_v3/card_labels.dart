import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Словари карточки v3: ключ бэкенда → ключ локализации и иконка Material.
///
/// Ключи функций, минусов, причин подсветки и типов продукта приходят из
/// `sa_card` и `mirra/product_types.py`; строки для них живут в
/// kTranslationsMap под префиксами `card_function_`, `card_drawback_`,
/// `card_reason_`, `ptype_`. Неизвестный ключ показывается как есть, чтобы
/// новый enum на бэкенде не ломал карточку.

/// Функция «что делает» → иконка.
const Map<String, IconData> kFunctionIcons = {
  'hydration': LucideIcons.droplet,
  'barrier': LucideIcons.layers,
  'anti_age': LucideIcons.sparkles,
  'brightening': LucideIcons.sun,
  'pores': LucideIcons.circleDotDashed,
  'acne': LucideIcons.bandage,
  'soothing': LucideIcons.leaf,
  'exfoliation': LucideIcons.grip,
  'mattifying': LucideIcons.haze,
  'uv_protection': LucideIcons.shield,
  'cleansing': LucideIcons.soapDispenserDroplet,
};

/// Минус → иконка.
const Map<String, IconData> kDrawbackIcons = {
  'drying': LucideIcons.dropletOff,
  'comedogenic': LucideIcons.circleDot,
  'irritating': LucideIcons.flame,
  'photosensitizing': LucideIcons.sunDim,
  'controversial': LucideIcons.octagonAlert,
};

/// Шаги рутины: индексы 0–4 как в `routine.morning` / `routine.evening`.
const List<String> kMorningStepKeys = [
  'card_step_cleanse',
  'card_step_tone',
  'card_step_actives',
  'card_step_moisturize',
  'card_step_spf',
];
const List<String> kEveningStepKeys = [
  'card_step_makeup_remove',
  'card_step_cleanse',
  'card_step_tone',
  'card_step_actives',
  'card_step_night_care',
];

/// Типы кожи в выпадающем списке: четыре типа из онбординга и два признака.
const List<String> kSkinTypes = ['dry', 'normal', 'combination', 'oily'];
const List<String> kSkinFlags = ['sensitive', 'acne_prone'];

/// Балл продукта для профиля кожи: худший из балла типа и включённых признаков.
/// Признак, который человеку не выставлен, в расчёт не идёт.
///
/// Общий на карточку и на ленту Главной: считали в двух местах по-разному, и
/// один и тот же продукт показывал в кружке одно число, а на карточке другое.
/// [scores] — `sa_card.skin_scores` или строки `image_skin_compatibility`: это
/// одни и те же баллы из `skin_type_suitability`.
///
/// null — баллов нет вовсе (старый снимок): показывать тогда нечего, и зовущий
/// сам решает, чем это заменить.
int? skinFitScore(
  Map<String, int> scores, {
  required String? skinType,
  required bool sensitive,
  required bool acneProne,
}) {
  // Тип вне списка (пусто у того, кто пропустил анкету) читаем как «нормальная»:
  // так же поступает карточка, когда профиля нет.
  final type = kSkinTypes.contains(skinType) ? skinType! : 'normal';
  final parts = <int>[
    if (scores[type] != null) scores[type]!,
    if (sensitive && scores['sensitive'] != null) scores['sensitive']!,
    if (acneProne && scores['acne_prone'] != null) scores['acne_prone']!,
  ];
  if (parts.isEmpty) return null;
  return parts.reduce(min);
}

/// Пороги метки под кольцом: 75 и выше «хорошо подходит», 50–74
/// «подходит с оговорками», ниже 50 «не лучший выбор».
String fitKey(int score) {
  if (score >= 75) return 'card_fit_good';
  if (score >= 50) return 'card_fit_caveat';
  return 'card_fit_bad';
}

/// Цвет кольца и балла: success / warning / error по тем же порогам.
Color fitColor(int score, {required Color success, required Color warning, required Color error}) {
  if (score >= 75) return success;
  if (score >= 50) return warning;
  return error;
}

String functionLabelKey(String key) => 'card_function_$key';
String drawbackLabelKey(String key) => 'card_drawback_$key';
String reasonLabelKey(String reason) => 'card_reason_$reason';
String productTypeLabelKey(String type) => 'ptype_$type';
String kindLabelKey(String kind) => 'card_kind_$kind';
