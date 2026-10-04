// Профиль кожи для подбора балла: одно правило на карточку и на ленту.
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/backend/supabase/supabase.dart';
import 'package:mi_r_r_a_dev/components/product_card_v3/skin_profile.dart';

UsersRow _user(Map<String, dynamic> fields) => UsersRow({
      'id': 'u1',
      'skin_type': null,
      'skin_sensitivity': null,
      'acne_prone': null,
      'skin_goals': <String>[],
      'pregnancy_status': 'none',
      ...fields,
    });

void main() {
  tearDown(SkinProfile.forget);

  group('SkinProfile.fromUser', () {
    test('колонка acne_prone без акне в типе и целях не включает признак', () {
      // Настоящий профиль: сухая кожа, цели «поры, увлажнение, барьер»,
      // acne_prone = true от прежнего онбординга. Лента показывала по нему
      // балл для склонной к акне кожи, карточка — по типу.
      final p = SkinProfile.fromUser(_user({
        'skin_type': 'dry',
        'skin_sensitivity': true,
        'acne_prone': true,
        'skin_goals': ['pores', 'hydration', 'barrier'],
      }));
      expect(p.skinType, 'dry');
      expect(p.sensitive, isTrue);
      expect(p.acneProne, isFalse);
    });

    test('признак берётся из типа кожи и из цели', () {
      expect(SkinProfile.fromUser(_user({'skin_type': 'acne_prone'})).acneProne, isTrue);
      expect(
          SkinProfile.fromUser(_user({'skin_type': 'oily', 'skin_goals': ['acne']})).acneProne,
          isTrue);
      expect(SkinProfile.fromUser(_user({'skin_type': 'sensitive'})).sensitive, isTrue);
    });

    test('беременность читается из pregnancy_status', () {
      expect(SkinProfile.fromUser(_user({'pregnancy_status': 'pregnant_or_nursing'})).pregnant,
          isTrue);
      expect(SkinProfile.fromUser(_user({})).pregnant, isFalse);
    });

    test('пустой профиль ничего не затирает в памяти', () {
      SkinProfile.remember(_user({'skin_type': 'dry'}));
      SkinProfile.remember(null);
      expect(SkinProfile.remembered?.skinType, 'dry');
    });
  });

}
