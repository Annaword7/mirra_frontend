import '../database.dart';

class ProductPricesTable extends SupabaseTable<ProductPricesRow> {
  @override
  String get tableName => 'product_prices';

  @override
  ProductPricesRow createRow(Map<String, dynamic> data) =>
      ProductPricesRow(data);
}

class ProductPricesRow extends SupabaseDataRow {
  ProductPricesRow(super.data);

  @override
  SupabaseTable get table => ProductPricesTable();

  String get productNameKey => getField<String>('product_name_key')!;
  String get brandKey => getField<String>('brand_key')!;
  String get countryCode => getField<String>('country_code')!;
  double? get avgPrice => _parseNumeric(data['avg_price']);
  double? get priceMin => _parseNumeric(data['price_min']);
  double? get priceMax => _parseNumeric(data['price_max']);
  String get priceCurrencyCode => getField<String>('price_currency_code')!;
  DateTime? get priceSearchedAt => getField<DateTime>('price_searched_at');

  static double? _parseNumeric(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
