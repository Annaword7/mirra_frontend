import '../database.dart';

class RoutineEventsTable extends SupabaseTable<RoutineEventsRow> {
  @override
  String get tableName => 'routine_events';

  @override
  RoutineEventsRow createRow(Map<String, dynamic> data) =>
      RoutineEventsRow(data);
}

class RoutineEventsRow extends SupabaseDataRow {
  RoutineEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RoutineEventsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get imageId => getField<int>('image_id');
  set imageId(int? value) => setField<int>('image_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get partOfDay => getField<String>('part_of_day');
  set partOfDay(String? value) => setField<String>('part_of_day', value);

  List<int> get weekdays => getListField<int>('weekdays');
  set weekdays(List<int>? value) => setListField<int>('weekdays', value);

  String? get timeOfDay => getField<String>('time_of_day');
  set timeOfDay(String? value) => setField<String>('time_of_day', value);

  bool? get enabled => getField<bool>('enabled');
  set enabled(bool? value) => setField<bool>('enabled', value);

  int? get localNotificationId => getField<int>('local_notification_id');
  set localNotificationId(int? value) =>
      setField<int>('local_notification_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
