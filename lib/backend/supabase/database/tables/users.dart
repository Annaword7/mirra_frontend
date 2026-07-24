import '../database.dart';

class UsersTable extends SupabaseTable<UsersRow> {
  @override
  String get tableName => 'users';

  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

class UsersRow extends SupabaseDataRow {
  UsersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UsersTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  String? get profileImage => getField<String>('profile_image');
  set profileImage(String? value) => setField<String>('profile_image', value);

  String? get nickname => getField<String>('nickname');
  set nickname(String? value) => setField<String>('nickname', value);

  bool? get onboarded => getField<bool>('onboarded');
  set onboarded(bool? value) => setField<bool>('onboarded', value);

  String? get subscriptionPlan => getField<String>('subscription_plan');
  set subscriptionPlan(String? value) =>
      setField<String>('subscription_plan', value);

  String? get languageCode => getField<String>('language_code');
  set languageCode(String? value) => setField<String>('language_code', value);

  int? get countryId => getField<int>('country_id');
  set countryId(int? value) => setField<int>('country_id', value);

  int? get monthlyAnalysesUsed => getField<int>('monthly_analyses_used');
  set monthlyAnalysesUsed(int? value) =>
      setField<int>('monthly_analyses_used', value);

  DateTime? get subscriptionStartDate =>
      getField<DateTime>('subscription_start_date');
  set subscriptionStartDate(DateTime? value) =>
      setField<DateTime>('subscription_start_date', value);

  DateTime? get subscriptionEndDate =>
      getField<DateTime>('subscription_end_date');
  set subscriptionEndDate(DateTime? value) =>
      setField<DateTime>('subscription_end_date', value);

  DateTime? get lastResetDate => getField<DateTime>('last_reset_date');
  set lastResetDate(DateTime? value) =>
      setField<DateTime>('last_reset_date', value);

  List<int> get spamImages {
    final raw = data['spam_images'];
    if (raw == null) return [];
    return (raw as List)
        .map((v) => int.tryParse(v.toString()))
        .whereType<int>()
        .toList();
  }

  set spamImages(List<int>? value) => setListField<int>('spam_images', value);

  /// Skin profile from onboarding — the single source of truth for fit
  /// composition. Matrix taps on the card are ephemeral previews and never
  /// write here.
  String? get skinType => getField<String>('skin_type');
  set skinType(String? value) => setField<String>('skin_type', value);

  bool? get skinSensitivity => getField<bool>('skin_sensitivity');
  set skinSensitivity(bool? value) =>
      setField<bool>('skin_sensitivity', value);

  /// Goals: acne, pigmentation, barrier, anti_aging, hydration, pores
  List<String> get skinGoals => getListField<String>('skin_goals');
  set skinGoals(List<String>? value) =>
      setListField<String>('skin_goals', value);

  /// Acne-proneness — independent of skin_type (migration 20260613).
  bool? get acneProne => getField<bool>('acne_prone');
  set acneProne(bool? value) => setField<bool>('acne_prone', value);

  /// Optional onboarding answers (not in scoring yet; migration 20260613).
  String? get ageRange => getField<String>('age_range');
  set ageRange(String? value) => setField<String>('age_range', value);

  String? get budgetRange => getField<String>('budget_range');
  set budgetRange(String? value) => setField<String>('budget_range', value);

  List<String> get trustedBrands => getListField<String>('trusted_brands');
  set trustedBrands(List<String>? value) =>
      setListField<String>('trusted_brands', value);

  /// Карта клиента (M1): 'pregnant_or_nursing' | 'none' | 'undisclosed' | null.
  String? get pregnancyStatus => getField<String>('pregnancy_status');
  set pregnancyStatus(String? value) =>
      setField<String>('pregnancy_status', value);

  /// Карта клиента (M1): предпочтения (рамки приемлемости ухода), словарь.
  dynamic get carePreferences => getField<dynamic>('care_preferences');
  set carePreferences(dynamic value) =>
      setField<dynamic>('care_preferences', value);
}
