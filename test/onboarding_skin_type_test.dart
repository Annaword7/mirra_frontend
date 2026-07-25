import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/pages/onboarding_quiz/skin_type_resolver.dart';

void main() {
  group('resolveSkinType — decision tree (spec §2 step 1b)', () {
    test('shine all over → oily (wins over tightness)', () {
      expect(
        resolveSkinType(
          shine: ShineLevel.all,
          tight: TightLevel.strong, // contradictory, but rule 1 wins
          pores: PoreLevel.none,
        ),
        'oily',
      );
    });

    test('wide pores → oily', () {
      expect(
        resolveSkinType(
          shine: ShineLevel.none,
          tight: TightLevel.no,
          pores: PoreLevel.wide,
        ),
        'oily',
      );
    });

    test('t-zone shine → combination', () {
      expect(
        resolveSkinType(
          shine: ShineLevel.tzone,
          tight: TightLevel.no,
          pores: PoreLevel.none,
        ),
        'combination',
      );
    });

    test('t-zone shine + strong tightness → combination (oily T, dry cheeks)',
        () {
      expect(
        resolveSkinType(
          shine: ShineLevel.tzone,
          tight: TightLevel.strong,
          pores: PoreLevel.none,
        ),
        'combination',
      );
    });

    test('t-zone pores → combination', () {
      expect(
        resolveSkinType(
          shine: ShineLevel.none,
          tight: TightLevel.no,
          pores: PoreLevel.tzone,
        ),
        'combination',
      );
    });

    test('strong tightness, no shine/pores → dry', () {
      expect(
        resolveSkinType(
          shine: ShineLevel.none,
          tight: TightLevel.strong,
          pores: PoreLevel.none,
        ),
        'dry',
      );
    });

    test('some tightness, no shine/pores → dry', () {
      expect(
        resolveSkinType(
          shine: ShineLevel.none,
          tight: TightLevel.some,
          pores: PoreLevel.none,
        ),
        'dry',
      );
    });

    test('fully neutral → normal', () {
      expect(
        resolveSkinType(
          shine: ShineLevel.none,
          tight: TightLevel.no,
          pores: PoreLevel.none,
        ),
        'normal',
      );
    });

    test('all 27 combinations resolve to a valid base type', () {
      const valid = {'dry', 'oily', 'combination', 'normal'};
      for (final shine in ShineLevel.values) {
        for (final tight in TightLevel.values) {
          for (final pores in PoreLevel.values) {
            final result =
                resolveSkinType(shine: shine, tight: tight, pores: pores);
            expect(valid.contains(result), isTrue,
                reason: 'shine=$shine tight=$tight pores=$pores → $result');
          }
        }
      }
    });
  });
}
