import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/components/feedback_collector/feedback_collector_widget.dart';
import 'package:mi_r_r_a_dev/design_system/components/constrained_content.dart';
import 'package:mi_r_r_a_dev/design_system/components/mirra_dialog_card.dart';
import 'package:mi_r_r_a_dev/design_system/foundations/layout.dart';
import 'package:mi_r_r_a_dev/flutter_flow/internationalization.dart';

/// Планшетная раскладка: число колонок по ширине окна и ограничение ширины
/// контента. Ширины — реальные: iPhone, iPad mini/Air/Pro в портрете и
/// альбоме, окно Split View.
void main() {
  Future<int> columnsAt(
    WidgetTester tester,
    double width, {
    int phone = 2,
    double tileWidth = 180,
  }) async {
    late int result;
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(size: Size(width, 1000)),
      child: Builder(builder: (context) {
        result = gridColumns(context, phone: phone, tileWidth: tileWidth);
        return const SizedBox();
      }),
    ));
    return result;
  }

  group('gridColumns', () {
    testWidgets('телефон и узкое окно Split View — телефонная сетка',
        (tester) async {
      expect(await columnsAt(tester, 320), 2); // треть iPad в Split View
      expect(await columnsAt(tester, 390), 2); // iPhone
      expect(await columnsAt(tester, 440), 2); // iPhone Pro Max
      expect(await columnsAt(tester, 599), 2);
    });

    testWidgets('iPad — по ширине, не больше шести', (tester) async {
      expect(await columnsAt(tester, 744), 4); // iPad mini, портрет
      expect(await columnsAt(tester, 820), 4); // iPad Air 11", портрет
      expect(await columnsAt(tester, 1024), 5); // iPad Pro 13", портрет
      expect(await columnsAt(tester, 1180), 6); // iPad Air 11", альбом
      expect(await columnsAt(tester, 1366), 6); // iPad Pro 13", альбом
    });

    testWidgets('phone и tileWidth задают базу (сетка косметички)',
        (tester) async {
      expect(await columnsAt(tester, 390, phone: 3, tileWidth: 130), 3);
      expect(await columnsAt(tester, 820, phone: 3, tileWidth: 130), 6);
    });
  });

  group('ConstrainedContent', () {
    const key = Key('content');

    Future<Rect> rectAt(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: ConstrainedContent(child: SizedBox.expand(key: key)),
      ));
      return tester.getRect(find.byKey(key));
    }

    testWidgets('на телефоне ширину не меняет', (tester) async {
      final rect = await rectAt(tester, const Size(390, 844));
      expect(rect.width, 390);
      expect(rect.left, 0);
    });

    testWidgets('на iPad в альбоме ограничивает и центрирует', (tester) async {
      final rect = await rectAt(tester, const Size(1180, 820));
      expect(rect.width, kContentMaxWidth);
      expect(rect.left, (1180 - kContentMaxWidth) / 2);
      expect(rect.top, 0);
      expect(rect.height, 820);
    });
  });

  group('диалоги на iPad', () {
    // Ширина карточки диалога — по обёртке с kDialogMaxWidth: так тест
    // заодно проверяет, что обёртка на месте.
    final card = find.byWidgetPredicate((w) =>
        w is ConstrainedBox && w.constraints.maxWidth == kDialogMaxWidth);

    Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
      tester.view.physicalSize = const Size(1180, 820);
      tester.view.devicePixelRatio = 1.0;
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
        home: Scaffold(body: dialog),
      ));
      await tester.pump();
    }

    testWidgets('«Нравится ли Mirra» не шире kDialogMaxWidth', (tester) async {
      await pumpDialog(tester, const FeedbackCollectorWidget());
      expect(card, findsOneWidget);
      expect(tester.getSize(card).width, lessThanOrEqualTo(kDialogMaxWidth));
    });

    testWidgets('MirraDialogCard с длинным текстом не шире kDialogMaxWidth',
        (tester) async {
      await pumpDialog(
        tester,
        MirraDialogCard(children: [Text('слово ' * 80)]),
      );
      expect(card, findsOneWidget);
      expect(tester.getSize(card).width, lessThanOrEqualTo(kDialogMaxWidth));
    });
  });
}
