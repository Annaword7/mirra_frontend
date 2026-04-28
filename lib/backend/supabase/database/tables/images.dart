import '../database.dart';

class ImagesTable extends SupabaseTable<ImagesRow> {
  @override
  String get tableName => 'images';

  @override
  ImagesRow createRow(Map<String, dynamic> data) => ImagesRow(data);
}

class ImagesRow extends SupabaseDataRow {
  ImagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ImagesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get imageUrl => getField<String>('image_url')!;
  set imageUrl(String value) => setField<String>('image_url', value);

  String? get user => getField<String>('user');
  set user(String? value) => setField<String>('user', value);

  String? get productName => getField<String>('product_name');
  set productName(String? value) => setField<String>('product_name', value);

  bool? get favourite => getField<bool>('favourite');
  set favourite(bool? value) => setField<bool>('favourite', value);

  String? get languageCode => getField<String>('language_code');
  set languageCode(String? value) => setField<String>('language_code', value);

  String? get brand => getField<String>('brand');
  set brand(String? value) => setField<String>('brand', value);

  String? get personalNotes => getField<String>('personal_notes');
  set personalNotes(String? value) => setField<String>('personal_notes', value);

  String? get ingredients => getField<String>('ingredients');
  set ingredients(String? value) => setField<String>('ingredients', value);

  bool? get hided => getField<bool>('hided');
  set hided(bool? value) => setField<bool>('hided', value);

  double? get saCompositeScore => getField<double>('sa_composite_score');
  set saCompositeScore(double? value) =>
      setField<double>('sa_composite_score', value);

  double? get saLegacyScore => getField<double>('sa_legacy_score');
  set saLegacyScore(double? value) =>
      setField<double>('sa_legacy_score', value);

  double? get saEfficacyScore => getField<double>('sa_efficacy_score');
  set saEfficacyScore(double? value) =>
      setField<double>('sa_efficacy_score', value);

  double? get saSafetyScore => getField<double>('sa_safety_score');
  set saSafetyScore(double? value) =>
      setField<double>('sa_safety_score', value);

  double? get saStabilityScore => getField<double>('sa_stability_score');
  set saStabilityScore(double? value) =>
      setField<double>('sa_stability_score', value);

  double? get saUxScore => getField<double>('sa_ux_score');
  set saUxScore(double? value) => setField<double>('sa_ux_score', value);

  double? get saComedogenicityScore =>
      getField<double>('sa_comedogenicity_score');
  set saComedogenicityScore(double? value) =>
      setField<double>('sa_comedogenicity_score', value);

  String? get saQuickSummary => getField<String>('sa_quick_summary');
  set saQuickSummary(String? value) =>
      setField<String>('sa_quick_summary', value);

  String? get saExpertAnalysis => getField<String>('sa_expert_analysis');
  set saExpertAnalysis(String? value) =>
      setField<String>('sa_expert_analysis', value);

  List<String> get saBestForTags => getListField<String>('sa_best_for_tags');
  set saBestForTags(List<String>? value) =>
      setListField<String>('sa_best_for_tags', value);

  int? get saIngredientsTotal => getField<int>('sa_ingredients_total');
  set saIngredientsTotal(int? value) =>
      setField<int>('sa_ingredients_total', value);

  int? get saIngredientsRecognized =>
      getField<int>('sa_ingredients_recognized');
  set saIngredientsRecognized(int? value) =>
      setField<int>('sa_ingredients_recognized', value);

  int? get saIngredientsInDatabase =>
      getField<int>('sa_ingredients_in_database');
  set saIngredientsInDatabase(int? value) =>
      setField<int>('sa_ingredients_in_database', value);

  DateTime? get saAnalyzedAt => getField<DateTime>('sa_analyzed_at');
  set saAnalyzedAt(DateTime? value) =>
      setField<DateTime>('sa_analyzed_at', value);

  String? get saRatingText => getField<String>('sa_rating_text');
  set saRatingText(String? value) => setField<String>('sa_rating_text', value);

  String? get saHowToUse => getField<String>('sa_how_to_use');
  set saHowToUse(String? value) => setField<String>('sa_how_to_use', value);

  String? get ingredientsNormalized =>
      getField<String>('ingredients_normalized');
  set ingredientsNormalized(String? value) =>
      setField<String>('ingredients_normalized', value);

  String? get saLanguageCode => getField<String>('sa_language_code');
  set saLanguageCode(String? value) =>
      setField<String>('sa_language_code', value);

  dynamic get saScoringLog => getField<dynamic>('sa_scoring_log');
  set saScoringLog(dynamic value) =>
      setField<dynamic>('sa_scoring_log', value);

  String? get productCategory => getField<String>('product_category');
  set productCategory(String? value) =>
      setField<String>('product_category', value);

  String? get productType => getField<String>('product_type');
  set productType(String? value) => setField<String>('product_type', value);

  // Legacy aliases — columns removed from DB, mapped to nearest equivalents.
  double? get score => saCompositeScore;
  String? get summary => saQuickSummary;
  List<String> get skinTypeTags => saBestForTags;
  int? get starsFromUser => null;
  String? get rating => null;
  String? get pros => null;
  String? get cons => null;
  String? get warnings => null;
  String? get skinTypeRecommendation => null;
  dynamic get detailedAnalysis => null;
  dynamic get scientificAnalysis => null;
}
