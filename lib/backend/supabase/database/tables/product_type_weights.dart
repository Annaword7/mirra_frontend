import '../database.dart';

class ProductTypeWeightsTable extends SupabaseTable<ProductTypeWeightsRow> {
  @override
  String get tableName => 'product_type_weights';

  @override
  ProductTypeWeightsRow createRow(Map<String, dynamic> data) =>
      ProductTypeWeightsRow(data);
}

class ProductTypeWeightsRow extends SupabaseDataRow {
  ProductTypeWeightsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProductTypeWeightsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get productType => getField<String>('product_type')!;
  set productType(String value) => setField<String>('product_type', value);

  double get efficacyWeight => getField<double>('efficacy_weight')!;
  set efficacyWeight(double value) =>
      setField<double>('efficacy_weight', value);

  double get safetyWeight => getField<double>('safety_weight')!;
  set safetyWeight(double value) => setField<double>('safety_weight', value);

  double get stabilityWeight => getField<double>('stability_weight')!;
  set stabilityWeight(double value) =>
      setField<double>('stability_weight', value);

  double get uxWeight => getField<double>('ux_weight')!;
  set uxWeight(double value) => setField<double>('ux_weight', value);

  double get comedogenicityWeight => getField<double>('comedogenicity_weight')!;
  set comedogenicityWeight(double value) =>
      setField<double>('comedogenicity_weight', value);

  String? get displayNameEn => getField<String>('display_name_en');
  set displayNameEn(String? value) =>
      setField<String>('display_name_en', value);

  String? get displayNameRu => getField<String>('display_name_ru');
  set displayNameRu(String? value) =>
      setField<String>('display_name_ru', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
