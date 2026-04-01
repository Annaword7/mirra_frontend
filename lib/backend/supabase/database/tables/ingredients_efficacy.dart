import '../database.dart';

class IngredientsEfficacyTable extends SupabaseTable<IngredientsEfficacyRow> {
  @override
  String get tableName => 'ingredients_efficacy';

  @override
  IngredientsEfficacyRow createRow(Map<String, dynamic> data) =>
      IngredientsEfficacyRow(data);
}

class IngredientsEfficacyRow extends SupabaseDataRow {
  IngredientsEfficacyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientsEfficacyTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get inciName => getField<String>('inci_name')!;
  set inciName(String value) => setField<String>('inci_name', value);

  String get inciNameNormalized => getField<String>('inci_name_normalized')!;
  set inciNameNormalized(String value) =>
      setField<String>('inci_name_normalized', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String? get subcategory => getField<String>('subcategory');
  set subcategory(String? value) => setField<String>('subcategory', value);

  int get efficacyTier => getField<int>('efficacy_tier')!;
  set efficacyTier(int value) => setField<int>('efficacy_tier', value);

  int? get hydrationWeight => getField<int>('hydration_weight');
  set hydrationWeight(int? value) => setField<int>('hydration_weight', value);

  int? get brighteningWeight => getField<int>('brightening_weight');
  set brighteningWeight(int? value) =>
      setField<int>('brightening_weight', value);

  int? get antiAgingWeight => getField<int>('anti_aging_weight');
  set antiAgingWeight(int? value) => setField<int>('anti_aging_weight', value);

  int? get soothingWeight => getField<int>('soothing_weight');
  set soothingWeight(int? value) => setField<int>('soothing_weight', value);

  int? get acneControlWeight => getField<int>('acne_control_weight');
  set acneControlWeight(int? value) =>
      setField<int>('acne_control_weight', value);

  String get evidenceLevel => getField<String>('evidence_level')!;
  set evidenceLevel(String value) => setField<String>('evidence_level', value);

  double get evidenceMultiplier => getField<double>('evidence_multiplier')!;
  set evidenceMultiplier(double value) =>
      setField<double>('evidence_multiplier', value);

  double? get minEffectiveConcentration =>
      getField<double>('min_effective_concentration');
  set minEffectiveConcentration(double? value) =>
      setField<double>('min_effective_concentration', value);

  double? get maxEffectiveConcentration =>
      getField<double>('max_effective_concentration');
  set maxEffectiveConcentration(double? value) =>
      setField<double>('max_effective_concentration', value);

  double? get optimalConcentration => getField<double>('optimal_concentration');
  set optimalConcentration(double? value) =>
      setField<double>('optimal_concentration', value);

  bool? get effectiveAtLowConcentration =>
      getField<bool>('effective_at_low_concentration');
  set effectiveAtLowConcentration(bool? value) =>
      setField<bool>('effective_at_low_concentration', value);

  dynamic get scientificReferences =>
      getField<dynamic>('scientific_references');
  set scientificReferences(dynamic value) =>
      setField<dynamic>('scientific_references', value);

  String? get mechanismOfAction => getField<String>('mechanism_of_action');
  set mechanismOfAction(String? value) =>
      setField<String>('mechanism_of_action', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
