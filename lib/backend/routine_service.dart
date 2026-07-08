import '/flutter_flow/notification_service.dart';
import 'cosmetic_bag_service.dart';
import 'supabase/database/database.dart';

/// Routine reminders. Rows in `routine_events` are the source of truth. Instead
/// of one push per product, we schedule TWO daily digest reminders (one AM, one
/// PM) that deep-link to the routine calendar — rebuilt via [syncDigests].
class RoutineService {
  RoutineService._();
  static final instance = RoutineService._();

  // Fixed notification ids for the two daily digests (AM / PM).
  static const int _amBase = 990001;
  static const int _pmBase = 990002;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00';

  Future<List<RoutineEventsRow>> getEvents() async {
    final userId = _userId;
    if (userId == null) return [];
    return RoutineEventsTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user_id', userId).order('created_at', ascending: true),
    );
  }

  Future<void> addEvent({
    required int? imageId,
    required String title,
    required List<int> weekdays,
    required int hour,
    required int minute,
  }) async {
    final userId = _userId;
    if (userId == null || weekdays.isEmpty) return;
    await SupaFlow.client.from('routine_events').insert({
      'user_id': userId,
      'image_id': imageId,
      'title': title,
      'part_of_day': hour < 12 ? 'am' : 'pm',
      'weekdays': weekdays,
      'time_of_day': _fmt(hour, minute),
      'enabled': true,
    });
  }

  /// Turn an LLM routine (am/pm step lists) into routine_events for the bag's
  /// products. Matches each step's `product` to a scanned product; skips generic
  /// steps and products that already have an event for that part of day.
  Future<int> generateFromRoutine({
    required List<dynamic> am,
    required List<dynamic> pm,
    int amHour = 8,
    int amMinute = 0,
    int pmHour = 21,
    int pmMinute = 0,
  }) async {
    final userId = _userId;
    if (userId == null) return 0;

    final slots = await CosmeticBagService.instance.getSlots();
    final ids = slots.map((s) => s.imageId).whereType<int>().toList();
    if (ids.isEmpty) return 0;
    final rows = await ImagesTable().queryRows(
      queryFn: (q) => q.inFilterOrNull('id', ids),
    );
    final byName = <String, int>{};
    for (final r in rows) {
      final n = (r.productName ?? '').trim().toLowerCase();
      if (n.isNotEmpty) byName[n] = r.id;
    }

    final existing = await getEvents();
    final have = existing.map((e) => '${e.imageId}_${e.partOfDay}').toSet();
    var created = 0;

    Future<void> gen(List<dynamic> steps, String part, int h, int m) async {
      for (final step in steps) {
        if (step is! Map) continue;
        final name = (step['product'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        final imageId = byName[name.toLowerCase()];
        if (imageId == null) continue;
        final key = '${imageId}_$part';
        if (have.contains(key)) continue;
        have.add(key);
        await addEvent(
          imageId: imageId,
          title: name,
          weekdays: const [1, 2, 3, 4, 5, 6, 7],
          hour: h,
          minute: m,
        );
        created++;
      }
    }

    await gen(am, 'am', amHour, amMinute);
    await gen(pm, 'pm', pmHour, pmMinute);
    return created;
  }

  Future<void> deleteEvent(RoutineEventsRow row) async {
    if (row.id != null) {
      await SupaFlow.client.from('routine_events').delete().eq('id', row.id!);
    }
  }

  /// Set one reminder time for the whole part of day (am/pm) — every product in
  /// that part shares it. part_of_day is kept as-is (the section identity).
  Future<void> setPartTime(String part, int hour, int minute) async {
    final userId = _userId;
    if (userId == null) return;
    await SupaFlow.client
        .from('routine_events')
        .update({'time_of_day': _fmt(hour, minute)})
        .eq('user_id', userId)
        .eq('part_of_day', part);
  }

  /// Rebuild the two daily digest reminders from all enabled events — a single
  /// "check your routine" push per part of day, tapping opens the calendar.
  /// Call after any change and on calendar open.
  Future<void> syncDigests({
    required String amTitle,
    required String amBody,
    required String pmTitle,
    required String pmBody,
    int defaultAmHour = 8,
    int defaultPmHour = 21,
  }) async {
    await NotificationService.instance.cancelReminders(_amBase);
    await NotificationService.instance.cancelReminders(_pmBase);

    final events = (await getEvents())
        .where((e) => (e.enabled ?? false) && e.weekdays.isNotEmpty)
        .toList();

    await _scheduleDigest(
      events.where((e) => (e.partOfDay ?? 'am') == 'am').toList(),
      _amBase,
      defaultAmHour,
      amTitle,
      amBody,
    );
    await _scheduleDigest(
      events.where((e) => (e.partOfDay ?? 'am') == 'pm').toList(),
      _pmBase,
      defaultPmHour,
      pmTitle,
      pmBody,
    );
  }

  /// Schedule one weekly reminder per covered weekday, at the earliest product
  /// time of that part of day (so the nudge lands before the routine starts).
  Future<void> _scheduleDigest(
    List<RoutineEventsRow> events,
    int baseId,
    int defaultHour,
    String title,
    String body,
  ) async {
    if (events.isEmpty) return;
    final weekdays = <int>{};
    var minMinutes = defaultHour * 60;
    var haveTime = false;
    for (final e in events) {
      weekdays.addAll(e.weekdays);
      final parts = (e.timeOfDay ?? '').split(':');
      final h = int.tryParse(parts.isNotEmpty ? parts[0] : '');
      if (h != null) {
        final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
        final t = h * 60 + m;
        if (!haveTime || t < minMinutes) {
          minMinutes = t;
          haveTime = true;
        }
      }
    }
    if (weekdays.isEmpty) return;
    await NotificationService.instance.scheduleWeeklyReminders(
      baseId: baseId,
      weekdays: weekdays.toList()..sort(),
      hour: minMinutes ~/ 60,
      minute: minMinutes % 60,
      title: title,
      body: body,
      payload: 'routine',
    );
  }
}
