import '/flutter_flow/notification_service.dart';
import 'cosmetic_bag_service.dart';
import 'supabase/database/database.dart';

/// CRUD + local scheduling for routine reminders. Rows in `routine_events` are
/// the source of truth; device-local notifications are (re)built from them.
class RoutineService {
  RoutineService._();
  static final instance = RoutineService._();

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

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
    required String reminderBody,
  }) async {
    final userId = _userId;
    if (userId == null || weekdays.isEmpty) return;
    final baseId = DateTime.now().millisecondsSinceEpoch % 1000000;
    final time =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    await SupaFlow.client.from('routine_events').insert({
      'user_id': userId,
      'image_id': imageId,
      'title': title,
      'part_of_day': hour < 12 ? 'am' : 'pm',
      'weekdays': weekdays,
      'time_of_day': time,
      'enabled': true,
      'local_notification_id': baseId,
    });
    await NotificationService.instance.scheduleWeeklyReminders(
      baseId: baseId,
      weekdays: weekdays,
      hour: hour,
      minute: minute,
      title: title,
      body: reminderBody,
    );
  }

  /// Turn an LLM routine (am/pm step lists) into scheduled reminders for the
  /// bag's products. Matches each step's `product` name to a scanned product,
  /// skips generic steps and products that already have an event for that
  /// part of day. Returns how many reminders were created.
  Future<int> generateFromRoutine({
    required List<dynamic> am,
    required List<dynamic> pm,
    required String reminderBody,
    int amHour = 8,
    int amMinute = 0,
    int pmHour = 21,
    int pmMinute = 0,
  }) async {
    final userId = _userId;
    if (userId == null) return 0;

    // Map product name -> image id from the current bag.
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
          reminderBody: reminderBody,
        );
        created++;
      }
    }

    await gen(am, 'am', amHour, amMinute);
    await gen(pm, 'pm', pmHour, pmMinute);
    return created;
  }

  /// Change an event's time (and AM/PM), then reschedule its reminders.
  Future<void> updateEventTime(
    RoutineEventsRow row,
    int hour,
    int minute,
    String reminderBody,
  ) async {
    if (row.id == null) return;
    final time =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    await SupaFlow.client.from('routine_events').update({
      'time_of_day': time,
      'part_of_day': hour < 12 ? 'am' : 'pm',
    }).eq('id', row.id!);
    final baseId = row.localNotificationId;
    if (baseId != null) {
      await NotificationService.instance.cancelReminders(baseId);
      if (row.enabled ?? true) {
        await NotificationService.instance.scheduleWeeklyReminders(
          baseId: baseId,
          weekdays: row.weekdays,
          hour: hour,
          minute: minute,
          title: row.title ?? '',
          body: reminderBody,
        );
      }
    }
  }

  Future<void> deleteEvent(RoutineEventsRow row) async {
    final baseId = row.localNotificationId;
    if (baseId != null) {
      await NotificationService.instance.cancelReminders(baseId);
    }
    if (row.id != null) {
      await SupaFlow.client.from('routine_events').delete().eq('id', row.id!);
    }
  }

  /// Cancel and re-schedule every enabled event. Call on launch — local
  /// notifications do not survive reinstall / OS clears.
  Future<void> reconcile(String reminderBody) async {
    final events = await getEvents();
    for (final e in events) {
      final baseId = e.localNotificationId;
      if (baseId == null) continue;
      await NotificationService.instance.cancelReminders(baseId);
      if ((e.enabled ?? false) && e.weekdays.isNotEmpty) {
        final parts = (e.timeOfDay ?? '00:00:00').split(':');
        final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        await NotificationService.instance.scheduleWeeklyReminders(
          baseId: baseId,
          weekdays: e.weekdays,
          hour: hour,
          minute: minute,
          title: e.title ?? '',
          body: reminderBody,
        );
      }
    }
  }
}
