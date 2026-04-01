import '../database.dart';

class ImageConclusionsTable extends SupabaseTable<ImageConclusionsRow> {
  @override
  String get tableName => 'image_conclusions';

  @override
  ImageConclusionsRow createRow(Map<String, dynamic> data) =>
      ImageConclusionsRow(data);
}

class ImageConclusionsRow extends SupabaseDataRow {
  ImageConclusionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ImageConclusionsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get imageId => getField<int>('image_id')!;
  set imageId(int value) => setField<int>('image_id', value);

  String get conclusionType => getField<String>('conclusion_type')!;
  set conclusionType(String value) =>
      setField<String>('conclusion_type', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  int? get sortOrder => getField<int>('sort_order');
  set sortOrder(int? value) => setField<int>('sort_order', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
