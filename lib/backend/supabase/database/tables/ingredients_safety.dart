import '../database.dart';

class IngredientsSafetyTable extends SupabaseTable<IngredientsSafetyRow> {
  @override
  String get tableName => 'ingredients_safety';

  @override
  IngredientsSafetyRow createRow(Map<String, dynamic> data) =>
      IngredientsSafetyRow(data);
}

class IngredientsSafetyRow extends SupabaseDataRow {
  IngredientsSafetyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientsSafetyTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get inciName => getField<String>('inci_name')!;
  set inciName(String value) => setField<String>('inci_name', value);

  String get inciNameNormalized => getField<String>('inci_name_normalized')!;
  set inciNameNormalized(String value) =>
      setField<String>('inci_name_normalized', value);

  int get overallSafetyScore => getField<int>('overall_safety_score')!;
  set overallSafetyScore(int value) =>
      setField<int>('overall_safety_score', value);

  int? get ewgScore => getField<int>('ewg_score');
  set ewgScore(int? value) => setField<int>('ewg_score', value);

  String get irritationRisk => getField<String>('irritation_risk')!;
  set irritationRisk(String value) =>
      setField<String>('irritation_risk', value);

  String get sensitizationRisk => getField<String>('sensitization_risk')!;
  set sensitizationRisk(String value) =>
      setField<String>('sensitization_risk', value);

  String get photosensitivityRisk => getField<String>('photosensitivity_risk')!;
  set photosensitivityRisk(String value) =>
      setField<String>('photosensitivity_risk', value);

  bool? get isAllergen => getField<bool>('is_allergen');
  set isAllergen(bool? value) => setField<bool>('is_allergen', value);

  bool? get isFormaldehydeReleaser =>
      getField<bool>('is_formaldehyde_releaser');
  set isFormaldehydeReleaser(bool? value) =>
      setField<bool>('is_formaldehyde_releaser', value);

  bool? get isHarshSurfactant => getField<bool>('is_harsh_surfactant');
  set isHarshSurfactant(bool? value) =>
      setField<bool>('is_harsh_surfactant', value);

  bool? get isDryingAlcohol => getField<bool>('is_drying_alcohol');
  set isDryingAlcohol(bool? value) =>
      setField<bool>('is_drying_alcohol', value);

  bool? get isFragrance => getField<bool>('is_fragrance');
  set isFragrance(bool? value) => setField<bool>('is_fragrance', value);

  bool? get isEssentialOil => getField<bool>('is_essential_oil');
  set isEssentialOil(bool? value) => setField<bool>('is_essential_oil', value);

  bool? get euRestricted => getField<bool>('eu_restricted');
  set euRestricted(bool? value) => setField<bool>('eu_restricted', value);

  bool? get euBanned => getField<bool>('eu_banned');
  set euBanned(bool? value) => setField<bool>('eu_banned', value);

  double? get maxAllowedConcentration =>
      getField<double>('max_allowed_concentration');
  set maxAllowedConcentration(double? value) =>
      setField<double>('max_allowed_concentration', value);

  String? get safetyNotes => getField<String>('safety_notes');
  set safetyNotes(String? value) => setField<String>('safety_notes', value);

  String? get contraindications => getField<String>('contraindications');
  set contraindications(String? value) =>
      setField<String>('contraindications', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
