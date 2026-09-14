import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Устойчивая идентичность устройства для аналитики.
///
/// Supabase-uuid для этого не годится: он меняется при переустановке (сессия
/// лежит в SharedPreferences и стирается с приложением) и при входе через
/// Apple (создаётся новый аккаунт). Amplitude при этом двух разных `user_id`
/// не склеивает, поэтому стабильным должен быть сам `user_id`.
///
/// UUID генерируется один раз и хранится в Keychain — единственном месте,
/// которое переживает удаление приложения. `first_unlock` (а не
/// `*_this_device`) нужен, чтобы идентичность уезжала в зашифрованный бэкап и
/// переезжала на новый телефон: это тот же человек.
class DeviceIdentity {
  DeviceIdentity._();

  static const _key = 'mirra_analytics_identity';

  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Текущая идентичность; создаётся при первом обращении.
  static Future<String> get() async {
    final existing = await _storage.read(key: _key);
    if (existing != null && existing.isNotEmpty) return existing;
    return _mint();
  }

  /// Новая идентичность взамен старой. Единственный законный повод —
  /// удаление аккаунта: человек попросил забыть его, и пришивать следующего
  /// анонима к прежней истории нельзя.
  static Future<String> rotate() => _mint();

  static Future<String> _mint() async {
    final fresh = const Uuid().v4();
    await _storage.write(key: _key, value: fresh);
    debugPrint('DeviceIdentity: minted new identity');
    return fresh;
  }
}
