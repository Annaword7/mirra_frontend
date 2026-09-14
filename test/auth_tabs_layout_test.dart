import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/design_system/components/app_button.dart';
import 'package:mi_r_r_a_dev/design_system/components/app_text_field.dart';
import 'package:mi_r_r_a_dev/flutter_flow/internationalization.dart';
import 'package:mi_r_r_a_dev/pages/log_in_page/log_in_page_widget.dart';

/// Вкладки «Вход» и «Создать аккаунт» обязаны совпадать по разметке: при
/// переключении поля и кнопка не должны прыгать по вертикали, а соглашение об
/// использовании закреплено внизу и не двигается вовсе.
Future<void> _pumpLogIn(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(
    locale: Locale('ru'),
    supportedLocales: [Locale('ru')],
    localizationsDelegates: [
      FFLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: LogInPageWidget(),
  ));
  await tester.pumpAndSettle();
}

/// Верхние края почты, пароля, основной кнопки и подписи под ними.
List<double> _rowTops(WidgetTester tester) => [
      tester.getTopLeft(find.byType(AppTextField).at(0)).dy,
      tester.getTopLeft(find.byType(AppTextField).at(1)).dy,
      tester.getTopLeft(find.byType(AppButton)).dy,
      tester.getTopLeft(find.text('Условия использования')).dy,
    ];

void main() {
  testWidgets('поля и кнопки стоят на одних и тех же местах на обеих вкладках',
      (tester) async {
    await _pumpLogIn(tester);

    expect(find.text('С возвращением'), findsOneWidget);
    final loginTops = _rowTops(tester);

    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();

    expect(find.text('Создать аккаунт'), findsWidgets);
    expect(_rowTops(tester), loginTops);
  });

  testWidgets('форму снизу ничем не перекрывает', (tester) async {
    await _pumpLogIn(tester);

    // Карусель лежала в Stack поверх формы и налезала на её нижнюю часть.
    // Теперь под формой только закреплённое соглашение, и они не пересекаются.
    final formBottom = tester.getBottomLeft(find.byType(AppButton)).dy;
    final footerTop = tester.getTopLeft(find.text('Условия использования')).dy;
    expect(formBottom, lessThan(footerTop));
  });
}
