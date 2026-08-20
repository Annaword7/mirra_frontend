import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/flutter_flow/plural.dart';

void main() {
  group('русский: три формы', () {
    test('единственное число', () {
      for (final n in [1, 21, 101, 1001]) {
        expect(pluralForm('ru', n), 'one', reason: '$n');
      }
    });

    test('2–4', () {
      for (final n in [2, 3, 4, 22, 34, 103]) {
        expect(pluralForm('ru', n), 'few', reason: '$n');
      }
    });

    test('5 и больше, ноль, подростковые исключения', () {
      for (final n in [0, 5, 11, 12, 13, 14, 19, 25, 111, 112]) {
        expect(pluralForm('ru', n), 'many', reason: '$n');
      }
    });
  });

  test('английский и другие двухформенные: только 1 — единственное', () {
    for (final lang in ['en', 'de', 'es', 'it', 'pt']) {
      expect(pluralForm(lang, 1), 'one', reason: lang);
      expect(pluralForm(lang, 0), 'many', reason: lang);
      expect(pluralForm(lang, 2), 'many', reason: lang);
      expect(pluralForm(lang, 21), 'many', reason: lang);
    }
  });

  test('французский: ноль тоже единственное', () {
    expect(pluralForm('fr', 0), 'one');
    expect(pluralForm('fr', 1), 'one');
    expect(pluralForm('fr', 2), 'many');
  });

  test('языки без счётной формы', () {
    for (final lang in ['tr', 'ja', 'ko', 'zh']) {
      expect(pluralForm(lang, 1), 'many', reason: lang);
      expect(pluralForm(lang, 5), 'many', reason: lang);
    }
  });
}
