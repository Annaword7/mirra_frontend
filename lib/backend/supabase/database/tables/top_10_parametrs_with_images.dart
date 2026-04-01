import '../database.dart';

class Top10ParametrsWithImagesTable
    extends SupabaseTable<Top10ParametrsWithImagesRow> {
  @override
  String get tableName => 'top_10_parametrs_with_images';

  @override
  Top10ParametrsWithImagesRow createRow(Map<String, dynamic> data) =>
      Top10ParametrsWithImagesRow(data);
}

class Top10ParametrsWithImagesRow extends SupabaseDataRow {
  Top10ParametrsWithImagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => Top10ParametrsWithImagesTable();

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
