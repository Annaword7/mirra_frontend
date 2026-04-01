import '../database.dart';

class UserSubscriptionInfoTable extends SupabaseTable<UserSubscriptionInfoRow> {
  @override
  String get tableName => 'user_subscription_info';

  @override
  UserSubscriptionInfoRow createRow(Map<String, dynamic> data) =>
      UserSubscriptionInfoRow(data);
}

class UserSubscriptionInfoRow extends SupabaseDataRow {
  UserSubscriptionInfoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserSubscriptionInfoTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get subscriptionPlan => getField<String>('subscription_plan');
  set subscriptionPlan(String? value) =>
      setField<String>('subscription_plan', value);

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

  int? get monthlyLimit => getField<int>('monthly_limit');
  set monthlyLimit(int? value) => setField<int>('monthly_limit', value);

  int? get remainingAnalyses => getField<int>('remaining_analyses');
  set remainingAnalyses(int? value) =>
      setField<int>('remaining_analyses', value);

  String? get subscriptionStatus => getField<String>('subscription_status');
  set subscriptionStatus(String? value) =>
      setField<String>('subscription_status', value);

  int? get daysUntilExpiry => getField<int>('days_until_expiry');
  set daysUntilExpiry(int? value) => setField<int>('days_until_expiry', value);
}
