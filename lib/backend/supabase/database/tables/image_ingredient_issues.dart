import '../database.dart';

class ImageIngredientIssuesTable
    extends SupabaseTable<ImageIngredientIssuesRow> {
  @override
  String get tableName => 'image_ingredient_issues';

  @override
  ImageIngredientIssuesRow createRow(Map<String, dynamic> data) =>
      ImageIngredientIssuesRow(data);
}

class ImageIngredientIssuesRow extends SupabaseDataRow {
  ImageIngredientIssuesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ImageIngredientIssuesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get imageId => getField<int>('image_id')!;
  set imageId(int value) => setField<int>('image_id', value);

  String get ingredientName => getField<String>('ingredient_name')!;
  set ingredientName(String value) =>
      setField<String>('ingredient_name', value);

  String get issueType => getField<String>('issue_type')!;
  set issueType(String value) => setField<String>('issue_type', value);

  String get severity => getField<String>('severity')!;
  set severity(String value) => setField<String>('severity', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
