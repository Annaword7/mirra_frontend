import '../database.dart';

class IngredientQueueSummaryTable
    extends SupabaseTable<IngredientQueueSummaryRow> {
  @override
  String get tableName => 'ingredient_queue_summary';

  @override
  IngredientQueueSummaryRow createRow(Map<String, dynamic> data) =>
      IngredientQueueSummaryRow(data);
}

class IngredientQueueSummaryRow extends SupabaseDataRow {
  IngredientQueueSummaryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientQueueSummaryTable();

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  int? get count => getField<int>('count');
  set count(int? value) => setField<int>('count', value);

  String? get highPriorityIngredients =>
      getField<String>('high_priority_ingredients');
  set highPriorityIngredients(String? value) =>
      setField<String>('high_priority_ingredients', value);
}
