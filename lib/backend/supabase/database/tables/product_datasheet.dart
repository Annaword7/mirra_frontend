import '../database.dart';

class ProductDatasheetTable extends SupabaseTable<ProductDatasheetRow> {
  @override
  String get tableName => 'product_datasheet';

  @override
  ProductDatasheetRow createRow(Map<String, dynamic> data) =>
      ProductDatasheetRow(data);
}

class ProductDatasheetRow extends SupabaseDataRow {
  ProductDatasheetRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProductDatasheetTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get brand => getField<String>('brand');
  set brand(String? value) => setField<String>('brand', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  String? get country => getField<String>('country');
  set country(String? value) => setField<String>('country', value);

  String get ingredients => getField<String>('ingredients')!;
  set ingredients(String value) => setField<String>('ingredients', value);

  String? get afterUse => getField<String>('after_use');
  set afterUse(String? value) => setField<String>('after_use', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get inciEmbedding => getField<String>('inci_embedding');
  set inciEmbedding(String? value) => setField<String>('inci_embedding', value);
}
