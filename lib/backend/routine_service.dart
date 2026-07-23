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
    String? partOfDay,
    int? sortOrder,
  }) async {
    final userId = _userId;
    if (userId == null || weekdays.isEmpty) return;
    await SupaFlow.client.from('routine_events').insert({
      'user_id': userId,
      'image_id': imageId,
      'title': title,
      'part_of_day': partOfDay ?? (hour < 12 ? 'am' : 'pm'),
      'weekdays': weekdays,
      'time_of_day': _fmt(hour, minute),
      'enabled': true,
      'sort_order': sortOrder,
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
    final nameById = <int, String>{};
    for (final r in rows) {
      final n = (r.productName ?? '').trim();
      if (n.isNotEmpty) byName[n.toLowerCase()] = r.id;
      nameById[r.id] = n;
    }

    final existing = await getEvents();

    // Keep the user's section times: earliest existing time per part of day.
    (int, int) partTime(String part, int defH, int defM) {
      var best = -1;
      for (final e in existing.where((e) => (e.partOfDay ?? 'am') == part)) {
        final p = (e.timeOfDay ?? '').split(':');
        final h = int.tryParse(p.isNotEmpty ? p[0] : '');
        if (h == null) continue;
        final m = int.tryParse(p.length > 1 ? p[1] : '') ?? 0;
        final t = h * 60 + m;
        if (best < 0 || t < best) best = t;
      }
      return best < 0 ? (defH, defM) : (best ~/ 60, best % 60);
    }

    // Desired schedule: key `imageId_part` -> step data.
    final desired =
        <String, ({int imageId, String title, List<int> weekdays, int? sortOrder, String part})>{};
    void collect(List<dynamic> steps, String part) {
      for (final step in steps) {
        if (step is! Map) continue;
        final name = (step['product'] ?? '').toString().trim();
        // Prefer the scheduler's explicit image id; fall back to name match.
        // Either way the product must still be in the bag (nameById keys).
        final rawId = step['image_id'];
        final imageId = (rawId is int && nameById.containsKey(rawId))
            ? rawId
            : (name.isEmpty ? null : byName[name.toLowerCase()]);
        if (imageId == null) continue;
        final title = name.isNotEmpty ? name : (nameById[imageId] ?? '');
        if (title.isEmpty) continue;
        // Weekly schedule from the deterministic scheduler; older cached
        // results have no `days` -> every day.
        final days = (step['days'] is List)
            ? (step['days'] as List)
                .map((d) => int.tryParse(d.toString()))
                .whereType<int>()
                .where((d) => d >= 1 && d <= 7)
                .toSet()
                .toList()
            : <int>[];
        desired['${imageId}_$part'] = (
          imageId: imageId,
          title: title,
          weekdays:
              days.isEmpty ? const [1, 2, 3, 4, 5, 6, 7] : (days..sort()),
          sortOrder: int.tryParse((step['step'] ?? '').toString()),
          part: part,
        );
      }
    }

    collect(am, 'am');
    collect(pm, 'pm');

    // Reconcile. Scheduler-created events (sort_order set) are owned by the
    // schedule: update them in place, delete the ones no longer scheduled
    // (e.g. a retinoid that used to sit in the AM section). Manual events
    // (sort_order null) are never touched.
    var changes = 0;
    final manualKeys = <String>{};
    for (final e in existing) {
      final key = '${e.imageId}_${e.partOfDay}';
      if (e.sortOrder == null) {
        manualKeys.add(key);
        continue;
      }
      if (e.id == null) continue;
      final want = desired.remove(key);
      if (want == null) {
        await deleteEvent(e);
        changes++;
      } else {
        await SupaFlow.client.from('routine_events').update({
          'title': want.title,
          'weekdays': want.weekdays,
          'sort_order': want.sortOrder,
        }).eq('id', e.id!);
        changes++;
      }
    }
    for (final want in desired.values) {
      // A manual event already covers this product+part — leave it alone.
      if (manualKeys.contains('${want.imageId}_${want.part}')) continue;
      final (h, m) = want.part == 'am'
          ? partTime('am', amHour, amMinute)
          : partTime('pm', pmHour, pmMinute);
      await addEvent(
        imageId: want.imageId,
        title: want.title,
        weekdays: want.weekdays,
        hour: h,
        minute: m,
        partOfDay: want.part,
        sortOrder: want.sortOrder,
      );
      changes++;
    }
    return changes;
  }

  /// Update the weekdays a product is applied on. Time stays per part of day
  /// (the section chip), reminders stay the two shared AM/PM digests.
  Future<void> updateEventDays(RoutineEventsRow row, List<int> weekdays) async {
    if (row.id == null || weekdays.isEmpty) return;
    await SupaFlow.client
        .from('routine_events')
        .update({'weekdays': weekdays}).eq('id', row.id!);
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

  /// Turn the shared AM/PM digest push on/off for a part of day (bulk update
  /// on its events; syncDigests skips disabled ones).
  Future<void> setPartEnabled(String part, bool enabled) async {
    final userId = _userId;
    if (userId == null) return;
    await SupaFlow.client
        .from('routine_events')
        .update({'enabled': enabled})
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
