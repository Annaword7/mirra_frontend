import '../database.dart';

class AlbumTable extends SupabaseTable<AlbumRow> {
  @override
  String get tableName => 'album';

  @override
  AlbumRow createRow(Map<String, dynamic> data) => AlbumRow(data);
}

class AlbumRow extends SupabaseDataRow {
  AlbumRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AlbumTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get user => getField<String>('user');
  set user(String? value) => setField<String>('user', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get cover => getField<String>('cover');
  set cover(String? value) => setField<String>('cover', value);
}
