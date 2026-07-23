import 'dart:convert';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_manager.dart';
import '/environment_values.dart';

/// Назначение ухода — клиент серверных команд контекста (M3, Architecture v1).
///
/// Все решения (составление, инварианты, каскады) живут на бэкенде;
/// этот класс только транспорт: команда → HTTP → ответ.
class CarePlanningService {
  CarePlanningService._();
  static final instance = CarePlanningService._();

  String get _host => FFDevEnvironmentValues().backendhost;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $currentJwtToken',
        'Content-Type': 'application/json',
      };

  Future<ApiCallResponse> _call(
    String name,
    String path,
    ApiCallType type, {
    Map<String, dynamic>? body,
  }) {
    return ApiManager.instance.makeApiCall(
      callName: name,
      apiUrl: '${_host}api/mirra/$path',
      callType: type,
      headers: _headers,
      params: {},
      body: body == null ? null : json.encode(body),
      bodyType: body == null ? null : BodyType.JSON,
      returnBody: true,
      cache: false,
    );
  }

  /// Команда СоставитьРежим.
  Future<ApiCallResponse> compose(List<int> imageIds) => _call(
        'careRegimenCompose',
        'care/regimen/compose',
        ApiCallType.POST,
        body: {'image_ids': imageIds},
      );

  /// Команда ПринятьРежим.
  Future<ApiCallResponse> accept(String regimenId) => _call(
        'careRegimenAccept',
        'care/regimen/$regimenId/accept',
        ApiCallType.POST,
        body: {},
      );

  /// Текущий режим (accepted, иначе последний proposed).
  Future<ApiCallResponse> current() =>
      _call('careRegimenCurrent', 'care/regimen/current', ApiCallType.GET);

  Future<ApiCallResponse> suspend(String prescriptionId) => _call(
        'carePrescriptionSuspend',
        'care/prescriptions/$prescriptionId/suspend',
        ApiCallType.POST,
        body: {},
      );

  Future<ApiCallResponse> resume(String prescriptionId) => _call(
        'carePrescriptionResume',
        'care/prescriptions/$prescriptionId/resume',
        ApiCallType.POST,
        body: {},
      );

  /// Команда УточнитьДирективу (частота ≤ cap класса — валидирует сервер).
  Future<ApiCallResponse> refineDirective(
          String prescriptionId, int daysPerWeek) =>
      _call(
        'carePrescriptionDirective',
        'care/prescriptions/$prescriptionId/directive',
        ApiCallType.PATCH,
        body: {'days_per_week': daysPerWeek},
      );
}
