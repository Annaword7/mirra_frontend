import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/components/product_card_v3/card_composition.dart';
import 'package:mi_r_r_a_dev/components/product_card_v3/card_data.dart';
import 'package:mi_r_r_a_dev/components/product_card_v3/product_card_v3_widget.dart';
import 'package:mi_r_r_a_dev/flutter_flow/internationalization.dart';

/// Карточка v3 по макету: читает один объект sa_card и ничего не пересчитывает,
/// кроме окраски при беременности и счётчиков состава.
final Map<String, dynamic> _sampleCard = {
  'version': 3,
  'language_code': 'ru',
  'product_type': 'moisturizer',
  'usage': 'day',
  'rinse_off': false,
  'routine': {'morning': [3, 4], 'evening': []},
  'description': 'Лёгкий крем с ниацинамидом и скваланом.',
  'how_to_use': 'Утром после сыворотки распределите горошину крема по лицу.',
  'skin_scores': {'dry': 57, 'normal': 78, 'combination': 72, 'oily': 64, 'sensitive': 38, 'acne_prone': 61},
  'functions': [
    {'key': 'hydration', 'score': 88, 'evidence': ['Glycerin']},
    {'key': 'uv_protection', 'score': 70, 'evidence': ['Ethylhexyl Methoxycinnamate']},
  ],
  'drawbacks': [
    {'key': 'drying', 'for': ['dry', 'sensitive'], 'ingredients': ['Alcohol Denat.']},
  ],
  'spf': {
    'filter_type': 'chemical', 'uvb': true, 'uva': false, 'broad_spectrum': false,
    'filters': [{'name': 'Ethylhexyl Methoxycinnamate', 'type': 'chemical', 'spectrum': ['UVB']}],
  },
  'pregnancy': {'safe': false, 'classes': ['retinoid'], 'ingredients': ['Retinyl Palmitate']},
  'line': {'position': 5, 'basis': 'marker'},
  'ingredients': [
    {'position': 1, 'name': 'Aqua', 'kind': 'plain', 'reason': 'inactive', 'zone': 'above_1pct'},
    {'position': 2, 'name': 'Glycerin', 'kind': 'good', 'reason': 'working_dose', 'zone': 'above_1pct',
     'status': 'working', 'mec': 2.0, 'tip': 'Увлажнитель в рабочей дозе.'},
    {'position': 3, 'name': 'Alcohol Denat.', 'kind': 'bad', 'reason': 'drying_alcohol_top',
     'zone': 'above_1pct', 'for': ['dry', 'sensitive'], 'tip': 'Сушит так высоко в составе.'},
    {'position': 4, 'name': 'Ethylhexyl Methoxycinnamate', 'kind': 'plain', 'reason': 'uv_filter',
     'zone': 'above_1pct', 'tip': 'Химический фильтр UVB.'},
    {'position': 5, 'name': 'Phenoxyethanol', 'kind': 'warn', 'reason': 'ewg_concern',
     'zone': 'below_1pct', 'for': ['all'], 'tip': 'Консервант.'},
    {'position': 6, 'name': 'Retinyl Palmitate', 'kind': 'plain', 'reason': 'decorative_active',
     'zone': 'below_1pct', 'status': 'decorative', 'pregnancy_class': 'retinoid', 'tip': 'Ради этикетки.'},
  ],
};

Future<void> _pump(WidgetTester tester, {String? skinType, bool sensitive = false, bool pregnant = false}) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
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
        child: ProductCardV3Widget(
          card: ProductCard.parse(_sampleCard)!,
          brand: 'Aurelle',
          productName: 'Hydra Balance Day Cream',
          profileSkinType: skinType,
          profileSensitive: sensitive,
          pregnant: pregnant,
          inBag: false,
          onToggleBag: () async {},
          onScanMore: () {},
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  test('parse: версия ниже третьей и мусор не читаются', () {
    expect(ProductCard.parse(null), isNull);
    expect(ProductCard.parse({'version': 2}), isNull);
    final card = ProductCard.parse(_sampleCard)!;
    expect(card.ingredients.length, 6);
    expect(card.spf!.uva, isFalse);
    expect(card.routineMorning, [3, 4]);
    expect(card.ingredients[5].kindFor(pregnant: true), 'bad');
    expect(card.ingredients[5].kindFor(pregnant: false), 'plain');
  });

  testWidgets('шапка, тип кожи из профиля и метка по порогу', (tester) async {
    await _pump(tester, skinType: 'dry');
    expect(find.text('AURELLE'), findsOneWidget);
    expect(find.text('Hydra Balance Day Cream'), findsOneWidget);
    // 57 для сухой: 50–74 «подходит с оговорками».
    expect(find.text('57'), findsOneWidget);
    expect(find.text('подходит с оговорками'), findsOneWidget);
    expect(find.text('Что делает'), findsOneWidget);
    // «Увлажнение» есть и в сетке функций, и в шагах рутины; UV уникальна.
    expect(find.text('Защита от UV'), findsOneWidget);
    expect(find.text('Сушит'), findsOneWidget);
    expect(find.text('Защита от солнца'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('признак чувствительности берёт худший балл', (tester) async {
    await _pump(tester, skinType: 'normal', sensitive: true);
    // min(normal 78, sensitive 38) = 38: «не лучший выбор».
    expect(find.text('38'), findsOneWidget);
    expect(find.text('не лучший выбор'), findsOneWidget);
  });

  testWidgets('беременность: плашка и перекраска в счётчиках', (tester) async {
    await _pump(tester, skinType: 'dry');
    expect(find.text('Не рекомендуется при беременности и ГВ'), findsNothing);
    // Без профиля беременности: 1 полезный, 1 вредный, 1 внимание.
    final composition = find.byType(CardComposition);
    expect(find.descendant(of: composition, matching: find.text('1')), findsNWidgets(3));

    await _pump(tester, skinType: 'dry', pregnant: true);
    expect(find.text('Не рекомендуется при беременности и ГВ'), findsOneWidget);
    expect(find.text('Retinyl Palmitate'), findsOneWidget);
    // Ретинил пальмитат стал вредным: вредных двое.
    expect(find.descendant(of: find.byType(CardComposition), matching: find.text('2')), findsOneWidget);
  });

  testWidgets('состав раскрывается и показывает подсказку по тапу', (tester) async {
    await _pump(tester, skinType: 'dry');
    expect(find.text('Glycerin'), findsNothing);
    await tester.tap(find.text('Раскрыть полный состав'));
    await tester.pump();
    expect(find.text('Glycerin'), findsOneWidget);
    expect(find.text('МЕНЬШЕ 1% · стабилизаторы, консерванты'), findsOneWidget);
    await tester.tap(find.text('Glycerin'));
    await tester.pump();
    expect(find.text('Увлажнитель в рабочей дозе.'), findsOneWidget);
    expect(find.text('Полезный'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
