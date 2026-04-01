import '../database.dart';

class ParametersTable extends SupabaseTable<ParametersRow> {
  @override
  String get tableName => 'parameters';

  @override
  ParametersRow createRow(Map<String, dynamic> data) => ParametersRow(data);
}

class ParametersRow extends SupabaseDataRow {
  ParametersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ParametersTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get value => getField<String>('value');
  set value(String? value) => setField<String>('value', value);

  int? get imageId => getField<int>('image_id');
  set imageId(int? value) => setField<int>('image_id', value);

  String? get user => getField<String>('user');
  set user(String? value) => setField<String>('user', value);

  int? get parameterNumber => getField<int>('parameter_number');
  set parameterNumber(int? value) => setField<int>('parameter_number', value);

  double? get score => getField<double>('score');
  set score(double? value) => setField<double>('score', value);
}
