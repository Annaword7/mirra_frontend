import '../database.dart';

class IngredientIncompatibilitiesTable
    extends SupabaseTable<IngredientIncompatibilitiesRow> {
  @override
  String get tableName => 'ingredient_incompatibilities';

  @override
  IngredientIncompatibilitiesRow createRow(Map<String, dynamic> data) =>
      IngredientIncompatibilitiesRow(data);
}

class IngredientIncompatibilitiesRow extends SupabaseDataRow {
  IngredientIncompatibilitiesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientIncompatibilitiesTable();

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

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  double get penaltyMultiplier => getField<double>('penalty_multiplier')!;
  set penaltyMultiplier(double value) =>
      setField<double>('penalty_multiplier', value);

  String get incompatibilityType => getField<String>('incompatibility_type')!;
  set incompatibilityType(String value) =>
      setField<String>('incompatibility_type', value);

  bool? get affectsEfficacy => getField<bool>('affects_efficacy');
  set affectsEfficacy(bool? value) => setField<bool>('affects_efficacy', value);

  bool? get affectsStability => getField<bool>('affects_stability');
  set affectsStability(bool? value) =>
      setField<bool>('affects_stability', value);

  bool? get affectsSafety => getField<bool>('affects_safety');
  set affectsSafety(bool? value) => setField<bool>('affects_safety', value);

  bool? get canBeMitigated => getField<bool>('can_be_mitigated');
  set canBeMitigated(bool? value) => setField<bool>('can_be_mitigated', value);

  String? get mitigationNotes => getField<String>('mitigation_notes');
  set mitigationNotes(String? value) =>
      setField<String>('mitigation_notes', value);

  String? get mechanism => getField<String>('mechanism');
  set mechanism(String? value) => setField<String>('mechanism', value);

  String? get warningMessage => getField<String>('warning_message');
  set warningMessage(String? value) =>
      setField<String>('warning_message', value);

  String? get scientificReference => getField<String>('scientific_reference');
  set scientificReference(String? value) =>
      setField<String>('scientific_reference', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
