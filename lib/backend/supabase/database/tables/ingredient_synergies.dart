import '../database.dart';

class IngredientSynergiesTable extends SupabaseTable<IngredientSynergiesRow> {
  @override
  String get tableName => 'ingredient_synergies';

  @override
  IngredientSynergiesRow createRow(Map<String, dynamic> data) =>
      IngredientSynergiesRow(data);
}

class IngredientSynergiesRow extends SupabaseDataRow {
  IngredientSynergiesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientSynergiesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get ingredientA => getField<String>('ingredient_a')!;
  set ingredientA(String value) => setField<String>('ingredient_a', value);

  String get ingredientANormalized =>
      getField<String>('ingredient_a_normalized')!;
  set ingredientANormalized(String value) =>
      setField<String>('ingredient_a_normalized', value);

  String get ingredientB => getField<String>('ingredient_b')!;
  set ingredientB(String value) => setField<String>('ingredient_b', value);

  String get ingredientBNormalized =>
      getField<String>('ingredient_b_normalized')!;
  set ingredientBNormalized(String value) =>
      setField<String>('ingredient_b_normalized', value);

  String get synergyType => getField<String>('synergy_type')!;
  set synergyType(String value) => setField<String>('synergy_type', value);

  double get synergyStrength => getField<double>('synergy_strength')!;
  set synergyStrength(double value) =>
      setField<double>('synergy_strength', value);

  bool? get affectsEfficacy => getField<bool>('affects_efficacy');
  set affectsEfficacy(bool? value) => setField<bool>('affects_efficacy', value);

  bool? get affectsStability => getField<bool>('affects_stability');
  set affectsStability(bool? value) =>
      setField<bool>('affects_stability', value);

  bool? get affectsSafety => getField<bool>('affects_safety');
  set affectsSafety(bool? value) => setField<bool>('affects_safety', value);

  String? get mechanism => getField<String>('mechanism');
  set mechanism(String? value) => setField<String>('mechanism', value);

  String? get scientificReference => getField<String>('scientific_reference');
  set scientificReference(String? value) =>
      setField<String>('scientific_reference', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
