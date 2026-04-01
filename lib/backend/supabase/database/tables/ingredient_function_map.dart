import '../database.dart';

class IngredientFunctionMapTable
    extends SupabaseTable<IngredientFunctionMapRow> {
  @override
  String get tableName => 'ingredient_function_map';

  @override
  IngredientFunctionMapRow createRow(Map<String, dynamic> data) =>
      IngredientFunctionMapRow(data);
}

class IngredientFunctionMapRow extends SupabaseDataRow {
  IngredientFunctionMapRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientFunctionMapTable();

  int get ingredientId => getField<int>('ingredient_id')!;
  set ingredientId(int value) => setField<int>('ingredient_id', value);

  int get functionId => getField<int>('function_id')!;
  set functionId(int value) => setField<int>('function_id', value);

  int get weight => getField<int>('weight')!;
  set weight(int value) => setField<int>('weight', value);

  String get evidenceLevel => getField<String>('evidence_level')!;
  set evidenceLevel(String value) => setField<String>('evidence_level', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
