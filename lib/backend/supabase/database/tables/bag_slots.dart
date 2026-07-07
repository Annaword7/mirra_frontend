import '../database.dart';

class BagSlotsTable extends SupabaseTable<BagSlotsRow> {
  @override
  String get tableName => 'bag_slots';

  @override
  BagSlotsRow createRow(Map<String, dynamic> data) => BagSlotsRow(data);
}

class BagSlotsRow extends SupabaseDataRow {
  BagSlotsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BagSlotsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get slotIndex => getField<int>('slot_index');
  set slotIndex(int? value) => setField<int>('slot_index', value);

  int? get imageId => getField<int>('image_id');
  set imageId(int? value) => setField<int>('image_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
