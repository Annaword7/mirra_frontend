import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/design_system/components/app_button.dart';
import 'package:mi_r_r_a_dev/design_system/components/confirm_dialog.dart';

/// Пара кнопок в ConfirmDialog: пока подписи влезают — они в ряд, а длинная
/// пара («Пропустить» / «Продолжить настройку») встаёт в колонку, вместо того
/// чтобы обрезать текст многоточием.
Future<void> _pumpDialog(
  WidgetTester tester, {
  required String confirmLabel,
  required String cancelLabel,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ConfirmDialog(
        title: 'Пропустить опрос?',
        body: 'Приложение работает и без профиля.',
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () {},
        onCancel: () {},
      ),
    ),
  ));
  await tester.pump();
}

Offset _centerOf(WidgetTester tester, String label) =>
    tester.getCenter(find.widgetWithText(AppButton, label));

void main() {
  testWidgets('длинная пара встаёт в колонку, а не режет текст',
      (tester) async {
    await _pumpDialog(
      tester,
      confirmLabel: 'Продолжить настройку',
      cancelLabel: 'Пропустить',
    );

    final confirm = _centerOf(tester, 'Продолжить настройку');
    final cancel = _centerOf(tester, 'Пропустить');

    expect(confirm.dx, closeTo(cancel.dx, 0.5),
        reason: 'в колонке обе кнопки во всю ширину, центры совпадают по x');
    expect(confirm.dy, lessThan(cancel.dy),
        reason: 'подтверждение сверху (Material: stacked — confirm on top)');
    expect(tester.takeException(), isNull);
  });

  testWidgets('короткая пара остаётся в ряд', (tester) async {
    await _pumpDialog(tester, confirmLabel: 'Да', cancelLabel: 'Отмена');

    final confirm = _centerOf(tester, 'Да');
    final cancel = _centerOf(tester, 'Отмена');

    expect(confirm.dy, closeTo(cancel.dy, 0.5),
        reason: 'в ряд обе кнопки на одной высоте');
    expect(cancel.dx, lessThan(confirm.dx),
        reason: 'отказ слева, подтверждение справа');
    expect(tester.takeException(), isNull);
  });
}
