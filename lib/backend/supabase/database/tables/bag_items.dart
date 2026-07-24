import '../database.dart';

class BagItemsTable extends SupabaseTable<BagItemsRow> {
  @override
  String get tableName => 'bag_items';

  @override
  BagItemsRow createRow(Map<String, dynamic> data) => BagItemsRow(data);
}

class BagItemsRow extends SupabaseDataRow {
  BagItemsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BagItemsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get imageId => getField<int>('image_id');
  set imageId(int? value) => setField<int>('image_id', value);

  DateTime? get addedAt => getField<DateTime>('added_at');
  set addedAt(DateTime? value) => setField<DateTime>('added_at', value);
}
