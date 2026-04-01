import '../database.dart';

class IngredientRiskMapTable extends SupabaseTable<IngredientRiskMapRow> {
  @override
  String get tableName => 'ingredient_risk_map';

  @override
  IngredientRiskMapRow createRow(Map<String, dynamic> data) =>
      IngredientRiskMapRow(data);
}

class IngredientRiskMapRow extends SupabaseDataRow {
  IngredientRiskMapRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientRiskMapTable();

  int get ingredientId => getField<int>('ingredient_id')!;
  set ingredientId(int value) => setField<int>('ingredient_id', value);

  int get riskFlagId => getField<int>('risk_flag_id')!;
  set riskFlagId(int value) => setField<int>('risk_flag_id', value);

  int get severity => getField<int>('severity')!;
  set severity(int value) => setField<int>('severity', value);

  String get evidenceLevel => getField<String>('evidence_level')!;
  set evidenceLevel(String value) => setField<String>('evidence_level', value);

  String? get conditions => getField<String>('conditions');
  set conditions(String? value) => setField<String>('conditions', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
