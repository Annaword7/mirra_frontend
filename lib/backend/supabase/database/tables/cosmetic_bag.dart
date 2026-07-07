import '../database.dart';

class CosmeticBagTable extends SupabaseTable<CosmeticBagRow> {
  @override
  String get tableName => 'cosmetic_bag';

  @override
  CosmeticBagRow createRow(Map<String, dynamic> data) => CosmeticBagRow(data);
}

class CosmeticBagRow extends SupabaseDataRow {
  CosmeticBagRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CosmeticBagTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  double? get lastCompatibilityScore =>
      getField<double>('last_compatibility_score');
  set lastCompatibilityScore(double? value) =>
      setField<double>('last_compatibility_score', value);

  dynamic get lastResult => getField<dynamic>('last_result');
  set lastResult(dynamic value) => setField<dynamic>('last_result', value);

  DateTime? get lastAnalyzedAt => getField<DateTime>('last_analyzed_at');
  set lastAnalyzedAt(DateTime? value) =>
      setField<DateTime>('last_analyzed_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
