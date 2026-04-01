import '../database.dart';

class ImagesAlbumsConnectionTable
    extends SupabaseTable<ImagesAlbumsConnectionRow> {
  @override
  String get tableName => 'images_albums_connection';

  @override
  ImagesAlbumsConnectionRow createRow(Map<String, dynamic> data) =>
      ImagesAlbumsConnectionRow(data);
}

class ImagesAlbumsConnectionRow extends SupabaseDataRow {
  ImagesAlbumsConnectionRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ImagesAlbumsConnectionTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get albumId => getField<String>('album_id');
  set albumId(String? value) => setField<String>('album_id', value);

  int? get imageId => getField<int>('image_id');
  set imageId(int? value) => setField<int>('image_id', value);

  String? get user => getField<String>('user');
  set user(String? value) => setField<String>('user', value);
}
