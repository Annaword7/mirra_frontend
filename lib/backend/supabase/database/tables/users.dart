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

  List<int> get spamImages => getListField<int>('spam_images');
  set spamImages(List<int>? value) => setListField<int>('spam_images', value);
}
