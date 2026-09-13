import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/backend/supabase/database/database.dart';
import 'package:mi_r_r_a_dev/components/product_card_v2/product_card_v2_widget.dart';
import 'package:mi_r_r_a_dev/design_system/components/settings_row.dart';
import 'package:mi_r_r_a_dev/flutter_flow/internationalization.dart';

/// Все блоки карточки продукта стоят на одном горизонтальном отступе 16.
/// Строка «Тип кожи» пришла из дизайн-системы со своей вёрсткой, поэтому её
/// ширина проверяется отдельно: она обязана совпадать с вердиктом и остальными.
const double _screenWidth = 390;
const double _gutter = 16;

Future<void> _pumpCard(WidgetTester tester, {String? skinType}) async {
  tester.view.physicalSize = const Size(_screenWidth * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final image = ImagesRow({
    'id': 1,
    'sa_composite_score': 71,
    'sa_quick_summary': 'Хорошая база, но отдушка ближе к началу состава.',
    'sa_ingredients_total': 30,
    'sa_ingredients_recognized': 22,
    'sa_confidence_level': 'medium',
    'sa_scoring_log': {
      'safety': {'score': 88},
      'efficacy': {'score': 62},
      'stability': {'score': 60},
      'comedogenicity': {'score': 75},
      'user_experience': {'score': 70},
    },
  });

  final compatibility = [
    ImageSkinCompatibilityRow({'skin_type': 'dry', 'compatibility_score': 64}),
    ImageSkinCompatibilityRow({'skin_type': 'oily', 'compatibility_score': 51}),
    ImageSkinCompatibilityRow({'skin_type': 'normal', 'compatibility_score': 68}),
  ];

  await tester.pumpWidget(MaterialApp(
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: const [
      FFLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: SingleChildScrollView(
        child: ProductCardV2Widget(
          image: image,
          skinCompatibility: compatibility,
          topIngredients: const [],
          ingredientIssues: const [],
          userSkinType: skinType,
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('строка «Тип кожи» шириной с остальные блоки', (tester) async {
    await _pumpCard(tester, skinType: 'dry');

    final row = tester.getRect(find.byType(SettingsRow));

    expect(row.left, _gutter,
        reason: 'левый край строки совпадает с остальными блоками');
    expect(row.right, _screenWidth - _gutter,
        reason: 'правый край тоже: блок не уже и не шире соседей');
    expect(row.width, _screenWidth - _gutter * 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('без профиля строка на месте и показывает «без учёта типа»',
      (tester) async {
    await _pumpCard(tester);

    expect(find.byType(SettingsRow), findsOneWidget);
    expect(tester.getRect(find.byType(SettingsRow)).width,
        _screenWidth - _gutter * 2);
    expect(tester.takeException(), isNull);
  });
}
