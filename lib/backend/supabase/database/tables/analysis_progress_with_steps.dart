import '../database.dart';

class AnalysisProgressWithStepsTable
    extends SupabaseTable<AnalysisProgressWithStepsRow> {
  @override
  String get tableName => 'analysis_progress_with_steps';

  @override
  AnalysisProgressWithStepsRow createRow(Map<String, dynamic> data) =>
      AnalysisProgressWithStepsRow(data);
}

class AnalysisProgressWithStepsRow extends SupabaseDataRow {
  AnalysisProgressWithStepsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AnalysisProgressWithStepsTable();

  String? get analysisId => getField<String>('analysis_id');
  set analysisId(String? value) => setField<String>('analysis_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get imageId => getField<int>('image_id');
  set imageId(int? value) => setField<int>('image_id', value);

  int? get currentStep => getField<int>('current_step');
  set currentStep(int? value) => setField<int>('current_step', value);

  int? get totalSteps => getField<int>('total_steps');
  set totalSteps(int? value) => setField<int>('total_steps', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  int? get progressPercentage => getField<int>('progress_percentage');
  set progressPercentage(int? value) =>
      setField<int>('progress_percentage', value);

  String? get errorMessage => getField<String>('error_message');
  set errorMessage(String? value) => setField<String>('error_message', value);

  String? get errorCode => getField<String>('error_code');
  set errorCode(String? value) => setField<String>('error_code', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);

  String? get languageCode => getField<String>('language_code');
  set languageCode(String? value) => setField<String>('language_code', value);

  String? get stepTitle => getField<String>('step_title');
  set stepTitle(String? value) => setField<String>('step_title', value);

  String? get stepDescription => getField<String>('step_description');
  set stepDescription(String? value) =>
      setField<String>('step_description', value);
}
