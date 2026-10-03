// Дымовой тест экрана карточки: строка с готовой карточкой лежит в кэше,
// сеть недоступна (локальный адрес без сервера). Экран обязан нарисовать
// ProductCardV3Widget, а не крутить лоадер.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mi_r_r_a_dev/app_state.dart';
import 'package:mi_r_r_a_dev/backend/supabase/supabase.dart';
import 'package:mi_r_r_a_dev/components/product_card_v3/product_card_v3_widget.dart';
import 'package:mi_r_r_a_dev/design_system/components/screen_loader.dart';
import 'package:mi_r_r_a_dev/domain/images/images_row_cache.dart';
import 'package:mi_r_r_a_dev/flutter_flow/internationalization.dart';
import 'package:mi_r_r_a_dev/itemcard2/itemcard2_widget.dart';

final Map<String, dynamic> _card = {
  'version': 3,
  'language_code': 'ru',
  'product_type': 'moisturizer',
  'usage': 'day',
  'rinse_off': false,
  'routine': {'morning': [3], 'evening': []},
  'description': 'Крем с глицерином.',
  'how_to_use': 'Утром после сыворотки.',
  'skin_scores': {'dry': 70, 'oily': 60, 'normal': 75, 'combination': 65, 'sensitive': 50, 'acne_prone': 55},
  'functions': [{'key': 'hydration', 'score': 80, 'evidence': ['Glycerin']}],
  'drawbacks': [],
  'spf': null,
  'pregnancy': {'safe': true, 'classes': [], 'ingredients': []},
  'line': {'position': 3, 'basis': 'marker'},
  'ingredients': [
    {'position': 1, 'name': 'Aqua', 'kind': 'plain', 'reason': 'inactive', 'zone': 'above_1pct'},
    {'position': 2, 'name': 'Glycerin', 'kind': 'good', 'reason': 'working_dose', 'zone': 'above_1pct',
     'status': 'working', 'tip': 'Увлажнитель.'},
    {'position': 3, 'name': 'Phenoxyethanol', 'kind': 'plain', 'reason': 'inactive', 'zone': 'below_1pct'},
  ],
};

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'http://127.0.0.1:1', anonKey: 'test-anon-key');
    await FFAppState().initializePersistedState();
  });

  testWidgets('карточка из кэша рисуется, лоадер не висит', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    ImagesRowCache.put(ImagesRow({
      'id': 777,
      'user': 'someone',
      'brand': 'Aurelle',
      'product_name': 'Hydra Balance Day Cream',
      'image_url': null,
      'catalog_image_url': null,
      'created_at': '2026-10-01T10:00:00Z',
      'hided': false,
      'sa_composite_score': 72.0,
      'sa_card': _card,
      'product_type': 'moisturizer',
    }));

    await tester.pumpWidget(ChangeNotifierProvider<FFAppState>.value(
      value: FFAppState(),
      child: MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru')],
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Itemcard2Widget(imageid: 777),
      ),
    ));

    // Сеть в тесте не отвечает вовсе: карточка из кэша обязана появиться
    // за первые кадры, не дожидаясь обновления строки.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      final err = tester.takeException();
      if (err != null) debugPrint('exception after pump $i: $err');
    }
    debugPrint('DIAG loaders: ${find.byType(ScreenLoader).evaluate().length}, '
        'cards: ${find.byType(ProductCardV3Widget).evaluate().length}, '
        'appbar: ${find.byType(AppBar).evaluate().length}, '
        'brand text: ${find.text('Aurelle').evaluate().length}, '
        'pending text: ${find.text('Разбор ещё идёт').evaluate().length}, '
        'texts: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().take(8).toList()}');

    expect(find.byType(ProductCardV3Widget), findsOneWidget);
    expect(find.byType(ScreenLoader), findsNothing);
    // Висящие запросы строки и профиля должны отвалиться по таймауту, не
    // оставив таймеров.
    await tester.pump(const Duration(seconds: 30));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
