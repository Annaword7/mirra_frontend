import '../database.dart';

class ProgressStepsTable extends SupabaseTable<ProgressStepsRow> {
  @override
  String get tableName => 'progress_steps';

  @override
  ProgressStepsRow createRow(Map<String, dynamic> data) =>
      ProgressStepsRow(data);
}

class ProgressStepsRow extends SupabaseDataRow {
  ProgressStepsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProgressStepsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get stepKey => getField<String>('step_key')!;
  set stepKey(String value) => setField<String>('step_key', value);

  int get stepNumber => getField<int>('step_number')!;
  set stepNumber(int value) => setField<int>('step_number', value);

  String get languageCode => getField<String>('language_code')!;
  set languageCode(String value) => setField<String>('language_code', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);
}
