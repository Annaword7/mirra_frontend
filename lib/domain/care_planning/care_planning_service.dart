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

  /// Команда СоставитьРежим. Без [imageIds] сервер берёт Косметичку.
  Future<ApiCallResponse> compose(List<int>? imageIds) => _call(
        'careRegimenCompose',
        'care/regimen/compose',
        ApiCallType.POST,
        body: {if (imageIds != null) 'image_ids': imageIds},
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

  Map<String, dynamic>? _currentRegimen;
  bool _currentFetched = false;

  /// Чей уход закэширован: после входа другим аккаунтом кэш обязан считаться
  /// пустым, иначе экраны покажут чужой режим.
  String _cacheUser = '';
  bool get _cacheValid => _cacheUser == currentUserUid;

  /// Режим уже загружен в этой сессии — значит показывать его можно сразу,
  /// без промежуточного «проверяем».
  bool get hasCurrentRegimen => _cacheValid && _currentFetched;

  /// Загруженный режим без обращения к сети (null, если ещё не загружали).
  Map<String, dynamic>? get cachedRegimen => _cacheValid ? _currentRegimen : null;

  /// Текущий режим с кэшем на сессию. Измениться он может только от команд
  /// (собрать/принять режим, уточнить директиву) и от правки состава
  /// Косметички — все они зовут [invalidateCare], поэтому перечитывать его на
  /// каждое открытие экрана незачем.
  Future<Map<String, dynamic>?> currentRegimen({bool refresh = false}) async {
    if (!_cacheValid) invalidateCare();
    if (_currentFetched && !refresh) return _currentRegimen;
    final resp = await current();
    if (resp.succeeded && resp.jsonBody is Map) {
      final map = (resp.jsonBody as Map).cast<String, dynamic>();
      _currentRegimen = (map['regimen'] as Map?)?.cast<String, dynamic>();
      _currentFetched = true;
      _cacheUser = currentUserUid;
    }
    return _currentRegimen;
  }

  Map<String, dynamic>? _timetable;
  bool _timetableFetched = false;

  /// Расписание уже загружено в этой сессии — Рутина может рисовать сразу.
  bool get hasTimetable => _cacheValid && _timetableFetched;

  /// Загруженное расписание без обращения к сети.
  Map<String, dynamic>? get cachedTimetable => _cacheValid ? _timetable : null;

  /// Раскладка по дням с кэшем на сессию. Это проекция режима, поэтому живёт
  /// и сбрасывается вместе с ним.
  Future<Map<String, dynamic>> timetableCached({bool refresh = false}) async {
    if (!_cacheValid) invalidateCare();
    final cached = _timetable;
    if (_timetableFetched && !refresh && cached != null) return cached;
    final resp = await timetable();
    if (!resp.succeeded) throw Exception('timetable ${resp.statusCode}');
    final map = (resp.jsonBody as Map).cast<String, dynamic>();
    _timetable = map;
    _timetableFetched = true;
    _cacheUser = currentUserUid;
    return map;
  }

  /// Сбрасывает всё, что зависит от состава режима: и сам режим, и его
  /// раскладку по дням.
  void invalidateCare() {
    _currentFetched = false;
    _currentRegimen = null;
    _timetableFetched = false;
    _timetable = null;
  }

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

  /// Команда УточнитьДирективу: конкретные дни (сужение директивы) или
  /// частота. Cap класса валидирует сервер.
  Future<ApiCallResponse> refineDirective(
    String prescriptionId, {
    int? daysPerWeek,
    List<int>? pinnedDays,
  }) =>
      _call(
        'carePrescriptionDirective',
        'care/prescriptions/$prescriptionId/directive',
        ApiCallType.PATCH,
        body: {
          if (daysPerWeek != null) 'days_per_week': daysPerWeek,
          if (pinnedDays != null) 'pinned_days': pinnedDays,
        },
      );

  /// Проекция календаря принятого режима (M4).
  Future<ApiCallResponse> timetable() =>
      _call('careTimetable', 'care/timetable', ApiCallType.GET);
}
