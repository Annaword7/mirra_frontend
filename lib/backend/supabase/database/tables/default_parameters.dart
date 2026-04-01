import '../database.dart';

class DefaultParametersTable extends SupabaseTable<DefaultParametersRow> {
  @override
  String get tableName => 'default_parameters';

  @override
  DefaultParametersRow createRow(Map<String, dynamic> data) =>
      DefaultParametersRow(data);
}

class DefaultParametersRow extends SupabaseDataRow {
  DefaultParametersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DefaultParametersTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get defaultParameterName =>
      getField<String>('default_parameter_name');
  set defaultParameterName(String? value) =>
      setField<String>('default_parameter_name', value);

  String? get lang => getField<String>('lang');
  set lang(String? value) => setField<String>('lang', value);
}
