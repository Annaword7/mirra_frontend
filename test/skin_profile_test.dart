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
    test('признаки читаются из тумблеров анкеты', () {
      final p = SkinProfile.fromUser(_user({
        'skin_type': 'dry',
        'skin_sensitivity': true,
        'acne_prone': true,
        'skin_goals': ['pores', 'hydration', 'barrier'],
      }));
      expect(p.skinType, 'dry');
      expect(p.sensitive, isTrue);
      expect(p.acneProne, isTrue);
    });

    test('признак берётся и из типа кожи, а цель ухода признаком не считается', () {
      expect(SkinProfile.fromUser(_user({'skin_type': 'acne_prone'})).acneProne, isTrue);
      expect(SkinProfile.fromUser(_user({'skin_type': 'sensitive'})).sensitive, isTrue);
      // «Хочу убрать акне» это задача, а не свойство кожи.
      expect(
          SkinProfile.fromUser(_user({'skin_type': 'oily', 'skin_goals': ['acne']})).acneProne,
          isFalse);
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

  group('fitScoreFor: тумблеры перекрывают основной тип', () {
    const scores = {
      'dry': 70,
      'normal': 75,
      'combination': 65,
      'oily': 60,
      'sensitive': 50,
      'acne_prone': 30,
    };

    int? score({String? type = 'dry', bool sensitive = false, bool acne = false}) =>
        fitScoreFor(scores, skinType: type, sensitive: sensitive, acneProne: acne);

    test('без тумблеров — балл основного типа', () {
      expect(score(), 70);
      expect(score(type: 'oily'), 60);
    });

    test('один тумблер — его балл, даже если он выше балла типа', () {
      expect(score(sensitive: true), 50);
      expect(score(acne: true), 30);
      expect(
          fitScoreFor({'oily': 40, 'sensitive': 80},
              skinType: 'oily', sensitive: true, acneProne: false),
          80);
    });

    test('оба тумблера — меньший из двух', () {
      expect(score(sensitive: true, acne: true), 30);
      expect(
          fitScoreFor({'dry': 10, 'sensitive': 80, 'acne_prone': 90},
              skinType: 'dry', sensitive: true, acneProne: true),
          80);
    });

    test('нет типа — читается как нормальная кожа', () {
      expect(score(type: null), 75);
      expect(score(type: 'unknown'), 75);
    });

    test('балла признака нет в разборе — берётся тип', () {
      expect(fitScoreFor({'dry': 70}, skinType: 'dry', sensitive: true, acneProne: true), 70);
      expect(fitScoreFor(const {}, skinType: 'dry', sensitive: false, acneProne: false), isNull);
    });
  });
}
