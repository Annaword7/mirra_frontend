import '../database.dart';

class FeedbackTable extends SupabaseTable<FeedbackRow> {
  @override
  String get tableName => 'feedback';

  @override
  FeedbackRow createRow(Map<String, dynamic> data) => FeedbackRow(data);
}

class FeedbackRow extends SupabaseDataRow {
  FeedbackRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FeedbackTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get imageId => getField<int>('image_id')!;
  set imageId(int value) => setField<int>('image_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  bool get vote => getField<bool>('vote')!;
  set vote(bool value) => setField<bool>('vote', value);

  bool? get previousValue => getField<bool>('previous_value');
  set previousValue(bool? value) => setField<bool>('previous_value', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get lastChangedAt => getField<DateTime>('last_changed_at')!;
  set lastChangedAt(DateTime value) =>
      setField<DateTime>('last_changed_at', value);
}
