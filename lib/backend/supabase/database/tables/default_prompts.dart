import '../database.dart';

class DefaultPromptsTable extends SupabaseTable<DefaultPromptsRow> {
  @override
  String get tableName => 'default_prompts';

  @override
  DefaultPromptsRow createRow(Map<String, dynamic> data) =>
      DefaultPromptsRow(data);
}

class DefaultPromptsRow extends SupabaseDataRow {
  DefaultPromptsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DefaultPromptsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get prompt1 => getField<String>('prompt_1');
  set prompt1(String? value) => setField<String>('prompt_1', value);

  String? get lang => getField<String>('lang');
  set lang(String? value) => setField<String>('lang', value);

  String? get prompt2 => getField<String>('prompt_2');
  set prompt2(String? value) => setField<String>('prompt_2', value);
}
