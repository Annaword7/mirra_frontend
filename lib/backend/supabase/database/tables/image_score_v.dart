import '../database.dart';

class ImageScoreVTable extends SupabaseTable<ImageScoreVRow> {
  @override
  String get tableName => 'image_score_v';

  @override
  ImageScoreVRow createRow(Map<String, dynamic> data) => ImageScoreVRow(data);
}

class ImageScoreVRow extends SupabaseDataRow {
  ImageScoreVRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ImageScoreVTable();

  int? get imageId => getField<int>('image_id');
  set imageId(int? value) => setField<int>('image_id', value);

  String? get ingredients => getField<String>('ingredients');
  set ingredients(String? value) => setField<String>('ingredients', value);

  int? get parsedCount => getField<int>('parsed_count');
  set parsedCount(int? value) => setField<int>('parsed_count', value);

  int? get matchedCount => getField<int>('matched_count');
  set matchedCount(int? value) => setField<int>('matched_count', value);

  int? get unmatchedCount => getField<int>('unmatched_count');
  set unmatchedCount(int? value) => setField<int>('unmatched_count', value);

  double? get coveragePct => getField<double>('coverage_pct');
  set coveragePct(double? value) => setField<double>('coverage_pct', value);

  bool? get claimHydration => getField<bool>('claim_hydration');
  set claimHydration(bool? value) => setField<bool>('claim_hydration', value);

  bool? get claimSoftening => getField<bool>('claim_softening');
  set claimSoftening(bool? value) => setField<bool>('claim_softening', value);

  bool? get claimOcclusiveProtection =>
      getField<bool>('claim_occlusive_protection');
  set claimOcclusiveProtection(bool? value) =>
      setField<bool>('claim_occlusive_protection', value);

  bool? get claimTextureSmoothing => getField<bool>('claim_texture_smoothing');
  set claimTextureSmoothing(bool? value) =>
      setField<bool>('claim_texture_smoothing', value);

  bool? get claimGelTexture => getField<bool>('claim_gel_texture');
  set claimGelTexture(bool? value) =>
      setField<bool>('claim_gel_texture', value);

  bool? get claimEmulsionBase => getField<bool>('claim_emulsion_base');
  set claimEmulsionBase(bool? value) =>
      setField<bool>('claim_emulsion_base', value);

  bool? get claimFilmSmoothing => getField<bool>('claim_film_smoothing');
  set claimFilmSmoothing(bool? value) =>
      setField<bool>('claim_film_smoothing', value);

  bool? get claimBarrierSupport => getField<bool>('claim_barrier_support');
  set claimBarrierSupport(bool? value) =>
      setField<bool>('claim_barrier_support', value);

  bool? get claimSoothing => getField<bool>('claim_soothing');
  set claimSoothing(bool? value) => setField<bool>('claim_soothing', value);

  bool? get claimAntioxidantSupport =>
      getField<bool>('claim_antioxidant_support');
  set claimAntioxidantSupport(bool? value) =>
      setField<bool>('claim_antioxidant_support', value);

  bool? get claimBrighteningEvenTone =>
      getField<bool>('claim_brightening_even_tone');
  set claimBrighteningEvenTone(bool? value) =>
      setField<bool>('claim_brightening_even_tone', value);

  bool? get claimExfoliation => getField<bool>('claim_exfoliation');
  set claimExfoliation(bool? value) =>
      setField<bool>('claim_exfoliation', value);

  bool? get warnFragranceAllergen => getField<bool>('warn_fragrance_allergen');
  set warnFragranceAllergen(bool? value) =>
      setField<bool>('warn_fragrance_allergen', value);

  bool? get warnEyeAreaCaution => getField<bool>('warn_eye_area_caution');
  set warnEyeAreaCaution(bool? value) =>
      setField<bool>('warn_eye_area_caution', value);

  bool? get warnDrySkinUnfriendly => getField<bool>('warn_dry_skin_unfriendly');
  set warnDrySkinUnfriendly(bool? value) =>
      setField<bool>('warn_dry_skin_unfriendly', value);

  int? get score100 => getField<int>('score_100');
  set score100(int? value) => setField<int>('score_100', value);

  double? get score10 => getField<double>('score_10');
  set score10(double? value) => setField<double>('score_10', value);

  int? get scoreComponentsComfort => getField<int>('score_components_comfort');
  set scoreComponentsComfort(int? value) =>
      setField<int>('score_components_comfort', value);

  int? get scoreComponentsBarrier => getField<int>('score_components_barrier');
  set scoreComponentsBarrier(int? value) =>
      setField<int>('score_components_barrier', value);

  int? get scoreComponentsActives => getField<int>('score_components_actives');
  set scoreComponentsActives(int? value) =>
      setField<int>('score_components_actives', value);

  int? get scoreComponentsTexture => getField<int>('score_components_texture');
  set scoreComponentsTexture(int? value) =>
      setField<int>('score_components_texture', value);

  int? get scoreComponentsPenalties =>
      getField<int>('score_components_penalties');
  set scoreComponentsPenalties(int? value) =>
      setField<int>('score_components_penalties', value);

  int? get nLowCoverage => getField<int>('n_low_coverage');
  set nLowCoverage(int? value) => setField<int>('n_low_coverage', value);
}
