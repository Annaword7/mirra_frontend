import '../database.dart';

class AlbumImagesTable extends SupabaseTable<AlbumImagesRow> {
  @override
  String get tableName => 'album_images';

  @override
  AlbumImagesRow createRow(Map<String, dynamic> data) => AlbumImagesRow(data);
}

class AlbumImagesRow extends SupabaseDataRow {
  AlbumImagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlbumImagesTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get albumId => getField<String>('album_id');
  set albumId(String? value) => setField<String>('album_id', value);

  String? get ownerId => getField<String>('owner_id');
  set ownerId(String? value) => setField<String>('owner_id', value);

  int? get imageId => getField<int>('image_id');
  set imageId(int? value) => setField<int>('image_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get imageUser => getField<String>('image_user');
  set imageUser(String? value) => setField<String>('image_user', value);

  String? get productName => getField<String>('product_name');
  set productName(String? value) => setField<String>('product_name', value);

  String? get brand => getField<String>('brand');
  set brand(String? value) => setField<String>('brand', value);

  String? get rating => getField<String>('rating');
  set rating(String? value) => setField<String>('rating', value);

  double? get score => getField<double>('score');
  set score(double? value) => setField<double>('score', value);

  String? get pros => getField<String>('pros');
  set pros(String? value) => setField<String>('pros', value);

  String? get cons => getField<String>('cons');
  set cons(String? value) => setField<String>('cons', value);

  String? get warnings => getField<String>('warnings');
  set warnings(String? value) => setField<String>('warnings', value);

  String? get summary => getField<String>('summary');
  set summary(String? value) => setField<String>('summary', value);

  String? get skinTypeRecommendation =>
      getField<String>('skin_type_recommendation');
  set skinTypeRecommendation(String? value) =>
      setField<String>('skin_type_recommendation', value);
}
