import '../database.dart';

class UnsortedImagesTable extends SupabaseTable<UnsortedImagesRow> {
  @override
  String get tableName => 'unsorted_images';

  @override
  UnsortedImagesRow createRow(Map<String, dynamic> data) =>
      UnsortedImagesRow(data);
}

class UnsortedImagesRow extends SupabaseDataRow {
  UnsortedImagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UnsortedImagesTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get user => getField<String>('user');
  set user(String? value) => setField<String>('user', value);

  String? get productName => getField<String>('product_name');
  set productName(String? value) => setField<String>('product_name', value);
}
