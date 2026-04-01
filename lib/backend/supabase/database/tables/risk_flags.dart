import '../database.dart';

class RiskFlagsTable extends SupabaseTable<RiskFlagsRow> {
  @override
  String get tableName => 'risk_flags';

  @override
  RiskFlagsRow createRow(Map<String, dynamic> data) => RiskFlagsRow(data);
}

class RiskFlagsRow extends SupabaseDataRow {
  RiskFlagsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RiskFlagsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
