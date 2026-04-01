import '../database.dart';

class ImageSkinCompatibilityTable
    extends SupabaseTable<ImageSkinCompatibilityRow> {
  @override
  String get tableName => 'image_skin_compatibility';

  @override
  ImageSkinCompatibilityRow createRow(Map<String, dynamic> data) =>
      ImageSkinCompatibilityRow(data);
}

class ImageSkinCompatibilityRow extends SupabaseDataRow {
  ImageSkinCompatibilityRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ImageSkinCompatibilityTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get imageId => getField<int>('image_id')!;
  set imageId(int value) => setField<int>('image_id', value);

  String get skinType => getField<String>('skin_type')!;
  set skinType(String value) => setField<String>('skin_type', value);

  int get compatibilityScore => getField<int>('compatibility_score')!;
  set compatibilityScore(int value) =>
      setField<int>('compatibility_score', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get label => getField<String>('label');
  set label(String? value) => setField<String>('label', value);
}
