import 'dart:convert';
import 'package:flutter/services.dart';

class FFDevEnvironmentValues {
  static const String _appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'prod');
  static const String currentEnvironment =
      _appEnv == 'dev' ? 'Development' : 'Production';
  static const String environmentValuesPath = _appEnv == 'dev'
      ? 'assets/environment_values/environment.dev.json'
      : 'assets/environment_values/environment.json';

  static final FFDevEnvironmentValues _instance =
      FFDevEnvironmentValues._internal();

  factory FFDevEnvironmentValues() {
    return _instance;
  }

  FFDevEnvironmentValues._internal();

  Future<void> initialize() async {
    try {
      final String response =
          await rootBundle.loadString(environmentValuesPath);
      final data = await json.decode(response);
      _backendhost = data['backendhost'];
    } catch (e) {
      print('Error loading environment values: $e');
    }
  }

  String _backendhost = '';
  String get backendhost => _backendhost;
}
