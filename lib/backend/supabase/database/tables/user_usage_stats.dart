import '../database.dart';

class UserUsageStatsTable extends SupabaseTable<UserUsageStatsRow> {
  @override
  String get tableName => 'user_usage_stats';

  @override
  UserUsageStatsRow createRow(Map<String, dynamic> data) =>
      UserUsageStatsRow(data);
}

class UserUsageStatsRow extends SupabaseDataRow {
  UserUsageStatsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UserUsageStatsTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get hourlyCount => getField<int>('hourly_count');
  set hourlyCount(int? value) => setField<int>('hourly_count', value);

  int? get dailyCount => getField<int>('daily_count');
  set dailyCount(int? value) => setField<int>('daily_count', value);

  int? get monthlyCount => getField<int>('monthly_count');
  set monthlyCount(int? value) => setField<int>('monthly_count', value);

  int? get totalCount => getField<int>('total_count');
  set totalCount(int? value) => setField<int>('total_count', value);
}
