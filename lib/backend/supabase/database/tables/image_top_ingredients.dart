import '../database.dart';

class ImageTopIngredientsTable extends SupabaseTable<ImageTopIngredientsRow> {
  @override
  String get tableName => 'image_top_ingredients';

  @override
  ImageTopIngredientsRow createRow(Map<String, dynamic> data) =>
      ImageTopIngredientsRow(data);
}

class ImageTopIngredientsRow extends SupabaseDataRow {
  ImageTopIngredientsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ImageTopIngredientsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get imageId => getField<int>('image_id')!;
  set imageId(int value) => setField<int>('image_id', value);

  String get ingredientName => getField<String>('ingredient_name')!;
  set ingredientName(String value) =>
      setField<String>('ingredient_name', value);

  int? get inciPosition => getField<int>('inci_position');
  set inciPosition(int? value) => setField<int>('inci_position', value);

  double? get efficacyContribution => getField<double>('efficacy_contribution');
  set efficacyContribution(double? value) =>
      setField<double>('efficacy_contribution', value);

  String? get concentrationEstimate =>
      getField<String>('concentration_estimate');
  set concentrationEstimate(String? value) =>
      setField<String>('concentration_estimate', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  int? get sortOrder => getField<int>('sort_order');
  set sortOrder(int? value) => setField<int>('sort_order', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);
}
