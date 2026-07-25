import '../database.dart';

class AppConfigTable extends SupabaseTable<AppConfigRow> {
  @override
  String get tableName => 'app_config';

  @override
  AppConfigRow createRow(Map<String, dynamic> data) => AppConfigRow(data);
}

class AppConfigRow extends SupabaseDataRow {
  AppConfigRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AppConfigTable();

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  int? get intValue => getField<int>('int_value');
  set intValue(int? value) => setField<int>('int_value', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
