import 'package:flutter/material.dart';

/// Словари карточки v3: ключ бэкенда → ключ локализации и иконка Material.
///
/// Ключи функций, минусов, причин подсветки и типов продукта приходят из
/// `sa_card` и `mirra/product_types.py`; строки для них живут в
/// kTranslationsMap под префиксами `card_function_`, `card_drawback_`,
/// `card_reason_`, `ptype_`. Неизвестный ключ показывается как есть, чтобы
/// новый enum на бэкенде не ломал карточку.

/// Функция «что делает» → иконка.
const Map<String, IconData> kFunctionIcons = {
  'hydration': Icons.water_drop_outlined,
  'barrier': Icons.layers_outlined,
  'anti_age': Icons.auto_awesome_outlined,
  'brightening': Icons.wb_sunny_outlined,
  'pores': Icons.blur_circular_outlined,
  'acne': Icons.healing_outlined,
  'soothing': Icons.eco_outlined,
  'exfoliation': Icons.grain,
  'mattifying': Icons.blur_on,
  'uv_protection': Icons.shield_outlined,
  'cleansing': Icons.soap_outlined,
};

/// Минус → иконка.
const Map<String, IconData> kDrawbackIcons = {
  'drying': Icons.format_color_reset_outlined,
  'comedogenic': Icons.lens,
  'irritating': Icons.local_fire_department_outlined,
  'photosensitizing': Icons.brightness_low_outlined,
  'controversial': Icons.report_outlined,
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
