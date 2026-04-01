import '../database.dart';

class IngredientSynonymsTable extends SupabaseTable<IngredientSynonymsRow> {
  @override
  String get tableName => 'ingredient_synonyms';

  @override
  IngredientSynonymsRow createRow(Map<String, dynamic> data) =>
      IngredientSynonymsRow(data);
}

class IngredientSynonymsRow extends SupabaseDataRow {
  IngredientSynonymsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientSynonymsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get ingredientId => getField<int>('ingredient_id')!;
  set ingredientId(int value) => setField<int>('ingredient_id', value);

  String get synonym => getField<String>('synonym')!;
  set synonym(String value) => setField<String>('synonym', value);

  String get normalizedSynonym => getField<String>('normalized_synonym')!;
  set normalizedSynonym(String value) =>
      setField<String>('normalized_synonym', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
