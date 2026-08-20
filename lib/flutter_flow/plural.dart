import 'package:flutter/widgets.dart';

import 'internationalization.dart';

/// Множественные формы существительных.
///
/// В русском их три (1 замечание / 3 замечания / 5 замечаний), в большинстве
/// европейских языков — две, в турецком и восточноазиатских — одна. Строки
/// хранятся в kTranslationsMap как `<key>_one`, `<key>_few`, `<key>_many`;
/// языкам с двумя формами достаточно `_one` и `_many`.

/// Форма для [n] в языке [lang]: 'one' | 'few' | 'many'.
String pluralForm(String lang, int n) {
  final abs = n.abs();
  switch (lang) {
    case 'ru':
      final mod10 = abs % 10;
      final mod100 = abs % 100;
      if (mod10 == 1 && mod100 != 11) return 'one';
      if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
      return 'many';
    case 'tr':
    case 'ja':
    case 'ko':
    case 'zh':
      // Счётной формы нет — существительное не меняется.
      return 'many';
    case 'fr':
      return abs <= 1 ? 'one' : 'many';
    default:
      return abs == 1 ? 'one' : 'many';
  }
}

/// Локализованная строка с числом: подбирает форму по [n] и подставляет `{n}`.
/// Если форм для ключа ещё нет, откатывается на сам ключ — строка остаётся
/// осмысленной, просто без согласования.
String pluralText(BuildContext context, String key, int n) {
  final loc = FFLocalizations.of(context);
  final form = pluralForm(loc.languageCode, n);
  var text = loc.getText('${key}_$form');
  if (text.isEmpty && form != 'many') text = loc.getText('${key}_many');
  if (text.isEmpty) text = loc.getText(key);
  return text.replaceAll('{n}', '$n');
}
