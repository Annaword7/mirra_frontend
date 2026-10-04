// Мягкий перенос (U+00AD) в подписях шагов рутины и функций: слово длиннее
// колонки ломается в заданном месте с дефисом, а не по последней букве
// («Увлажнени» / «е»). В тестовом шрифте каждая буква шириной в размер
// кегля, поэтому ширину колонки можно задать числом букв.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

TextPainter _paint(String text, {required double glyphs}) {
  final p = TextPainter(
    text: TextSpan(text: text, style: const TextStyle(fontSize: 10)),
    textDirection: TextDirection.ltr,
    maxLines: 2,
  )..layout(maxWidth: 10 * glyphs);
  return p;
}

void main() {
  test('без мягкого переноса слово рвётся по букве', () {
    final p = _paint('Тонизирование', glyphs: 10);
    final firstLine = p.getLineBoundary(const TextPosition(offset: 0));
    expect(p.computeLineMetrics().length, 2);
    expect(firstLine.end, 10); // «Тонизирова» | «ние»
  });

  test('мягкий перенос ломает слово в заданном месте', () {
    final p = _paint('Тонизи­рование', glyphs: 10);
    final firstLine = p.getLineBoundary(const TextPosition(offset: 0));
    expect(p.computeLineMetrics().length, 2);
    // Первая строка кончается на мягком переносе: «Тонизи-».
    expect(firstLine.end, 7);
  });

  test('когда слово влезает, мягкий перенос невидим', () {
    final p = _paint('Увлаж­нение', glyphs: 12);
    expect(p.computeLineMetrics().length, 1);
    // Ширина как у слова без переноса: символ ничего не занимает.
    expect(p.width, _paint('Увлажнение', glyphs: 12).width);
  });
}
