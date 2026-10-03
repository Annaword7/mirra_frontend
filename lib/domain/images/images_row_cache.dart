import '/backend/supabase/supabase.dart';

/// Строки `images` для экрана карточки, прочитанные заранее.
///
/// Лента грузит строки без `sa_card` (он тяжёлый), поэтому карточка ходит в
/// базу сама. Между открытием экрана и ответом Supabase на долю секунды
/// показывалась заглушка «разбор ещё идёт», хотя разбор давно готов. Кэш
/// убирает эту паузу двумя путями: лента в фоне подгружает полные строки
/// первых плиток, а тап по плитке стартует запрос строки параллельно с
/// переходом. Экран карточки берёт строку отсюда и перечитывает её после
/// доразбора.
class ImagesRowCache {
  ImagesRowCache._();

  static const int _limit = 400;
  static const int _chunk = 20;
  static final Map<int, ImagesRow> _rows = <int, ImagesRow>{};
  static final Map<int, Future<List<ImagesRow>>> _inflight =
      <int, Future<List<ImagesRow>>>{};

  static void put(ImagesRow row) {
    final id = row.id;
    // Последний положенный считается свежим: удаляем и кладём в конец.
    _rows.remove(id);
    _rows[id] = row;
    if (_rows.length > _limit) {
      _rows.remove(_rows.keys.first);
    }
  }

  static void putAll(Iterable<ImagesRow> rows) {
    for (final row in rows) {
      put(row);
    }
  }

  static ImagesRow? get(int? id) => id == null ? null : _rows[id];

  static void remove(int? id) {
    if (id != null) _rows.remove(id);
  }

  /// Строка по id: из кэша, из уже идущего запроса или новым запросом.
  /// [refresh] перечитывает из базы, минуя кэш (после доразбора).
  static Future<List<ImagesRow>> rowFuture(int? id, {bool refresh = false}) {
    if (id == null) return Future.value(const <ImagesRow>[]);
    if (!refresh) {
      final cached = _rows[id];
      if (cached != null) return Future.value([cached]);
      final running = _inflight[id];
      if (running != null) return running;
    }
    final future = ImagesTable()
        .querySingleRow(queryFn: (q) => q.eqOrNull('id', id))
        .then((rows) {
      putAll(rows);
      return rows;
    }).whenComplete(() => _inflight.remove(id));
    _inflight[id] = future;
    return future;
  }

  /// Стартовать чтение строки, не дожидаясь результата (по тапу на плитку).
  static void prefetch(int? id) {
    if (id == null || _rows.containsKey(id) || _inflight.containsKey(id)) return;
    rowFuture(id).catchError((_) => const <ImagesRow>[]);
  }

  /// Подгрузить в фоне строки первых плиток ленты одним запросом на пачку.
  /// Повторный вызов с теми же id ничего не делает.
  static void prefetchMany(Iterable<int> ids) {
    final missing = ids
        .where((id) => !_rows.containsKey(id) && !_inflight.containsKey(id))
        .toList();
    for (var i = 0; i < missing.length; i += _chunk) {
      final batch = missing.sublist(i, (i + _chunk).clamp(0, missing.length));
      final future = ImagesTable()
          .queryRows(queryFn: (q) => q.inFilterOrNull('id', batch))
          .then((rows) {
        putAll(rows);
        return rows;
      }).whenComplete(() {
        for (final id in batch) {
          _inflight.remove(id);
        }
      });
      for (final id in batch) {
        _inflight[id] = future.then(
            (rows) => rows.where((r) => r.id == id).toList(growable: false));
      }
      future.catchError((_) => const <ImagesRow>[]);
    }
  }
}
