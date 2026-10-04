// Кэш строк `images` для экрана карточки.
//
// База в тесте недоступна, поэтому любое чтение отказывает: это и нужно.
// Главное свойство — чтение всегда ЗАВЕРШАЕТСЯ. Пока `whenComplete` снимал
// запись из очереди стрелкой (`() => _inflight.remove(id)`), колбэк отдавал
// тот же самый future, whenComplete ждал его, и цепочка ждала саму себя:
// экран карточки крутил лоадер без конца всюду, где строки ещё не было в
// кэше — из Top Rated, из поиска и сразу после скана.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mi_r_r_a_dev/backend/supabase/supabase.dart';
import 'package:mi_r_r_a_dev/domain/images/images_row_cache.dart';

Future<List<ImagesRow>> _read(int id, {bool refresh = false}) =>
    ImagesRowCache.rowFuture(id, refresh: refresh).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw StateError('чтение строки $id не завершилось'),
    );

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'http://127.0.0.1:1', anonKey: 'test-anon-key');
  });

  test('чтение завершается, когда база отказала', () async {
    expect(await _read(901), isEmpty);
  });

  test('после отказа id не остаётся в очереди: второе чтение тоже завершается',
      () async {
    expect(await _read(902), isEmpty);
    expect(await _read(902), isEmpty);
  });

  test('подписка на уже идущее чтение завершается вместе с ним', () async {
    final first = ImagesRowCache.rowFuture(903);
    final second = ImagesRowCache.rowFuture(903);
    final results = await Future.wait([first, second]).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw StateError('подписка не завершилась'),
    );
    expect(results, hasLength(2));
  });

  test('строка из кэша отдаётся без запроса', () async {
    final row = ImagesRow({'id': 904, 'user': 'u', 'created_at': '2026-10-04T00:00:00Z'});
    ImagesRowCache.put(row);
    expect(ImagesRowCache.get(904)?.id, 904);
    expect((await _read(904)).single.id, 904);
    // refresh обходит кэш и всё равно завершается.
    expect(await _read(904, refresh: true), isEmpty);
    ImagesRowCache.remove(904);
    expect(ImagesRowCache.get(904), isNull);
  });

  test('подогрев не роняет ошибку наружу', () async {
    ImagesRowCache.prefetch(905);
    ImagesRowCache.prefetchMany([906, 907]);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(ImagesRowCache.get(905), isNull);
  });
}
