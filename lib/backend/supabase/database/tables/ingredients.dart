import '../database.dart';

class IngredientsTable extends SupabaseTable<IngredientsRow> {
  @override
  String get tableName => 'ingredients';

  @override
  IngredientsRow createRow(Map<String, dynamic> data) => IngredientsRow(data);
}

class IngredientsRow extends SupabaseDataRow {
  IngredientsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get inciName => getField<String>('inci_name')!;
  set inciName(String value) => setField<String>('inci_name', value);

  String? get rating => getField<String>('rating');
  set rating(String? value) => setField<String>('rating', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String? get embedding => getField<String>('embedding');
  set embedding(String? value) => setField<String>('embedding', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get normalizedInciName => getField<String>('normalized_inci_name')!;
  set normalizedInciName(String value) =>
      setField<String>('normalized_inci_name', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
