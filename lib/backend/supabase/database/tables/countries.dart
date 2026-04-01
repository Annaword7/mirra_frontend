import '../database.dart';

class CountriesTable extends SupabaseTable<CountriesRow> {
  @override
  String get tableName => 'countries';

  @override
  CountriesRow createRow(Map<String, dynamic> data) => CountriesRow(data);
}

class CountriesRow extends SupabaseDataRow {
  CountriesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CountriesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get nameEn => getField<String>('name_en')!;
  set nameEn(String value) => setField<String>('name_en', value);

  String get nameRu => getField<String>('name_ru')!;
  set nameRu(String value) => setField<String>('name_ru', value);

  String get nameEs => getField<String>('name_es')!;
  set nameEs(String value) => setField<String>('name_es', value);

  String? get flagEmoji => getField<String>('flag_emoji');
  set flagEmoji(String? value) => setField<String>('flag_emoji', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
