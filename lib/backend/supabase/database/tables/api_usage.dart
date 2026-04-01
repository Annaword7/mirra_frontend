import '../database.dart';

class ApiUsageTable extends SupabaseTable<ApiUsageRow> {
  @override
  String get tableName => 'api_usage';

  @override
  ApiUsageRow createRow(Map<String, dynamic> data) => ApiUsageRow(data);
}

class ApiUsageRow extends SupabaseDataRow {
  ApiUsageRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ApiUsageTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get endpoint => getField<String>('endpoint')!;
  set endpoint(String value) => setField<String>('endpoint', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
