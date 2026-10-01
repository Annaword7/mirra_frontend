import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/backend/supabase/database/database.dart';
import 'package:mi_r_r_a_dev/components/product_card_v2/product_card_v2_widget.dart';
import 'package:mi_r_r_a_dev/flutter_flow/internationalization.dart';

/// Блок «Ответ» открывает карточку: метка для вашей кожи, абзац, кольцо.
/// Он стоит на том же горизонтальном отступе 16, что и остальные блоки.
/// Без профиля вместо метки чипы «какая у вас кожа?», абзац общий.
const double _screenWidth = 390;
const double _gutter = 16;

Future<void> _pumpCard(WidgetTester tester,
    {String? skinType, bool sensitive = false}) async {
  tester.view.physicalSize = const Size(_screenWidth * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final image = ImagesRow({
    'id': 1,
    'sa_composite_score': 71,
    'sa_quick_summary': 'Хорошая база, но отдушка ближе к началу состава.',
    'sa_plain_verdict': {
      'general': [
        'Крем с глицерином и ниацинамидом.',
        'База на силиконах, один консервант.',
        'Увлажнение формула держит.',
        'Единственная претензия: отдушка ниже линии 1 %.',
      ],
      'by_skin_type': {
        'dry': 'Для сухой кожи претензий нет.',
        'sensitive': 'Для чувствительной кожи минус: отдушка.',
      },
    },
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
    ImageSkinCompatibilityRow(
        {'skin_type': 'sensitive', 'compatibility_score': 33}),
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
          userIsSensitive: sensitive,
        ),
      ),
    ),
  ));
  await tester.pump();
}

Finder get _answer => find.byKey(const Key('cardv2_answer'));

void main() {
  testWidgets('блок «Ответ» шириной с остальные блоки', (tester) async {
    await _pumpCard(tester, skinType: 'dry');

    final rect = tester.getRect(_answer);
    expect(rect.left, _gutter,
        reason: 'левый край ответа совпадает с остальными блоками');
    expect(rect.right, _screenWidth - _gutter,
        reason: 'правый край тоже: блок не уже и не шире соседей');
    expect(tester.takeException(), isNull);
  });

  testWidgets('с профилем: метка по типу и четвёртое предложение для кожи',
      (tester) async {
    await _pumpCard(tester, skinType: 'dry');

    // 64 для сухой кожи: 60 и выше — «подходит».
    expect(find.text('подходит'), findsOneWidget);
    expect(find.textContaining('Для вашей кожи'), findsOneWidget);
    expect(find.textContaining('Для сухой кожи претензий нет.'), findsOneWidget);
    expect(find.textContaining('Единственная претензия'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('чувствительность важнее типа: худший балл и свой абзац',
      (tester) async {
    await _pumpCard(tester, skinType: 'dry', sensitive: true);

    // min(64, 33) = 33: ниже 40 — «не подходит».
    expect(find.text('не подходит'), findsOneWidget);
    expect(find.textContaining('минус: отдушка'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('без профиля: общий абзац и чипы «какая у вас кожа?»',
      (tester) async {
    await _pumpCard(tester);

    expect(find.text('Какая у вас кожа?'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(4));
    expect(find.textContaining('Для вашей кожи'), findsNothing);
    expect(find.textContaining('Единственная претензия'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
