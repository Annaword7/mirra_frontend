import 'dart:async';
import 'dart:convert';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_manager.dart';
import '/environment_values.dart';

/// Вызов бэкенда, который не удался: запрос не дошёл (status -1, исключение
/// транспорта) или пришёл не-2xx. В тексте и код, и само исключение, чтобы в
/// консоли была причина, а не голый «-1».
class ApiCallFailure implements Exception {
  ApiCallFailure(this.call, this.response);

  final String call;
  final ApiCallResponse response;

  /// Код для дашборда: TRANSPORT — ответа не было вовсе, иначе HTTP-статус.
  String get code =>
      response.statusCode < 0 ? 'TRANSPORT' : 'HTTP_${response.statusCode}';

  @override
  String toString() {
    final cause = response.exception;
    return '$call failed: ${response.statusCode}'
        '${cause == null ? '' : ' $cause'}';
  }
}

/// Ошибки экранов, о которых сервер сам не узнает: запрос до него не дошёл,
/// ответ был не-2xx или не разобрался. Уходят в POST /client-errors, ложатся
/// в analysis_events и поднимают алерт на дашборде.
///
/// Пока сети нет, отчёт отправить некуда, поэтому он ждёт в памяти и уходит
/// при следующем [report] или [flush] (экран зовёт его после удачного
/// запроса). Очередь ограничена: десять нажатий «Повторить» — десять строк,
/// больше двадцати хранить незачем.
class ClientErrorReporter {
  ClientErrorReporter._();
  static final instance = ClientErrorReporter._();

  static const _maxPending = 20;
  final List<Map<String, dynamic>> _pending = [];
  bool _flushing = false;

  Future<void> report(String stage, Object error) {
    final message = error.toString();
    _pending.add({
      'stage': stage,
      'error_code': error is ApiCallFailure ? error.code : 'CLIENT_EXCEPTION',
      'error_message':
          message.length > 500 ? message.substring(0, 500) : message,
      'metadata': {
        'app_env': FFDevEnvironmentValues.currentEnvironment,
        'occurred_at': DateTime.now().toUtc().toIso8601String(),
      },
    });
    if (_pending.length > _maxPending) _pending.removeAt(0);
    return flush();
  }

  /// Отправляет накопленное по одному. 2xx — записано, 4xx — не примут и
  /// позже, остальное (сеть, 5xx) оставляем до следующего раза.
  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      while (_pending.isNotEmpty) {
        final resp = await _send(_pending.first);
        if (resp.statusCode < 0 || resp.statusCode >= 500) return;
        _pending.removeAt(0);
      }
    } finally {
      _flushing = false;
    }
  }

  Future<ApiCallResponse> _send(Map<String, dynamic> body) =>
      ApiManager.instance.makeApiCall(
        callName: 'clientErrors',
        apiUrl:
            '${FFDevEnvironmentValues().backendhost}api/mirra/client-errors',
        callType: ApiCallType.POST,
        headers: {
          'Authorization': 'Bearer $currentJwtToken',
          'Content-Type': 'application/json',
        },
        params: {},
        body: json.encode(body),
        bodyType: BodyType.JSON,
        returnBody: true,
        cache: false,
      );
}
