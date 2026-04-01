import '../database.dart';

class IngredientsComedogenicityTable
    extends SupabaseTable<IngredientsComedogenicityRow> {
  @override
  String get tableName => 'ingredients_comedogenicity';

  @override
  IngredientsComedogenicityRow createRow(Map<String, dynamic> data) =>
      IngredientsComedogenicityRow(data);
}

class IngredientsComedogenicityRow extends SupabaseDataRow {
  IngredientsComedogenicityRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientsComedogenicityTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get inciName => getField<String>('inci_name')!;
  set inciName(String value) => setField<String>('inci_name', value);

  String get inciNameNormalized => getField<String>('inci_name_normalized')!;
  set inciNameNormalized(String value) =>
      setField<String>('inci_name_normalized', value);

  int get fultonRating => getField<int>('fulton_rating')!;
  set fultonRating(int value) => setField<int>('fulton_rating', value);

  String? get ratingConfidence => getField<String>('rating_confidence');
  set ratingConfidence(String? value) =>
      setField<String>('rating_confidence', value);

  bool? get canClogPores => getField<bool>('can_clog_pores');
  set canClogPores(bool? value) => setField<bool>('can_clog_pores', value);

  bool? get acneSafe => getField<bool>('acne_safe');
  set acneSafe(bool? value) => setField<bool>('acne_safe', value);

  bool? get fungalAcneSafe => getField<bool>('fungal_acne_safe');
  set fungalAcneSafe(bool? value) => setField<bool>('fungal_acne_safe', value);

  bool? get concentrationDependent => getField<bool>('concentration_dependent');
  set concentrationDependent(bool? value) =>
      setField<bool>('concentration_dependent', value);

  int? get safeBelowPosition => getField<int>('safe_below_position');
  set safeBelowPosition(int? value) =>
      setField<int>('safe_below_position', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
