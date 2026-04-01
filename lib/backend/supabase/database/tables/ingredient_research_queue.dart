import '../database.dart';

class IngredientResearchQueueTable
    extends SupabaseTable<IngredientResearchQueueRow> {
  @override
  String get tableName => 'ingredient_research_queue';

  @override
  IngredientResearchQueueRow createRow(Map<String, dynamic> data) =>
      IngredientResearchQueueRow(data);
}

class IngredientResearchQueueRow extends SupabaseDataRow {
  IngredientResearchQueueRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IngredientResearchQueueTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get inciName => getField<String>('inci_name')!;
  set inciName(String value) => setField<String>('inci_name', value);

  String get normalizedName => getField<String>('normalized_name')!;
  set normalizedName(String value) =>
      setField<String>('normalized_name', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int get priority => getField<int>('priority')!;
  set priority(int value) => setField<int>('priority', value);

  int get requestCount => getField<int>('request_count')!;
  set requestCount(int value) => setField<int>('request_count', value);

  int? get firstSeenImageId => getField<int>('first_seen_image_id');
  set firstSeenImageId(int? value) =>
      setField<int>('first_seen_image_id', value);

  String? get firstSeenProduct => getField<String>('first_seen_product');
  set firstSeenProduct(String? value) =>
      setField<String>('first_seen_product', value);

  String? get firstSeenBrand => getField<String>('first_seen_brand');
  set firstSeenBrand(String? value) =>
      setField<String>('first_seen_brand', value);

  dynamic get researchResult => getField<dynamic>('research_result');
  set researchResult(dynamic value) =>
      setField<dynamic>('research_result', value);

  String? get researchModel => getField<String>('research_model');
  set researchModel(String? value) => setField<String>('research_model', value);

  int? get researchTokensUsed => getField<int>('research_tokens_used');
  set researchTokensUsed(int? value) =>
      setField<int>('research_tokens_used', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  int get retryCount => getField<int>('retry_count')!;
  set retryCount(int value) => setField<int>('retry_count', value);

  int get maxRetries => getField<int>('max_retries')!;
  set maxRetries(int value) => setField<int>('max_retries', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  DateTime? get researchStartedAt => getField<DateTime>('research_started_at');
  set researchStartedAt(DateTime? value) =>
      setField<DateTime>('research_started_at', value);

  DateTime? get researchCompletedAt =>
      getField<DateTime>('research_completed_at');
  set researchCompletedAt(DateTime? value) =>
      setField<DateTime>('research_completed_at', value);
}
