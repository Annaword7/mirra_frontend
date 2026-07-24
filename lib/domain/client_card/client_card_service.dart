import '/app_state.dart';
import '/backend/supabase/database/database.dart';

/// Карта клиента — контекст «Карта клиента» (M1, Architecture v1).
///
/// Канонический носитель карты — строка `users` текущего пользователя:
/// анамнез (skin_type, skin_sensitivity, acne_prone, pregnancy_status,
/// age_range), цели (skin_goals) и предпочтения (care_preferences).
///
/// Команды тонкие: инвариантов у самой карты нет (RLS ограничивает доступ),
/// каскады — например, приостановка ретиноидных назначений при беременности
/// (инвариант 3) — принадлежат Режиму ухода (M3) и срабатывают там.
///
/// Анонимный ввод (до логина) буферится в FFAppState (ob*-поля) и флашится
/// в users после аутентификации — существующий механизм HomeWidget.
class ClientCardService {
  ClientCardService._();
  static final instance = ClientCardService._();

  // pregnancy_status (см. migrations/20260723_client_card.sql).
  static const pregnantOrNursing = 'pregnant_or_nursing';
  static const pregnancyNone = 'none';
  static const pregnancyUndisclosed = 'undisclosed';

  String get _userId => Supabase.instance.client.auth.currentUser?.id ?? '';

  /// Карта текущего пользователя, или null (аноним без строки / не найдена).
  Future<UsersRow?> getCard() async {
    if (_userId.isEmpty) return null;
    final rows = await UsersTable().queryRows(
      queryFn: (q) => q.eqOrNull('id', _userId),
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Команда ОбновитьАнамнез: частичное обновление — null-параметры не трогаются.
  Future<void> updateAnamnesis({
    String? skinType,
    bool? sensitive,
    bool? acneProne,
    String? pregnancyStatus,
    String? ageRange,
  }) async {
    final patch = <String, dynamic>{
      if (skinType != null) 'skin_type': skinType,
      if (sensitive != null) 'skin_sensitivity': sensitive,
      if (acneProne != null) 'acne_prone': acneProne,
      if (pregnancyStatus != null) 'pregnancy_status': pregnancyStatus,
      if (ageRange != null) 'age_range': ageRange,
    };
    if (patch.isEmpty) return;
    if (_userId.isEmpty) {
      // Аноним: буфер до логина (флашится в HomeWidget).
      final app = FFAppState();
      if (skinType != null) app.obSkinType = skinType;
      if (sensitive != null) app.obSensitive = sensitive;
      if (acneProne != null) app.obAcneProne = acneProne;
      if (pregnancyStatus != null) app.obPregnancy = pregnancyStatus;
      if (ageRange != null) app.obAgeRange = ageRange;
      app.obPendingFlush = true;
      return;
    }
    await UsersTable().update(
      data: patch,
      matchingRows: (rows) => rows.eqOrNull('id', _userId),
    );
  }

  /// Команда ИзменитьЦель: полный список целей (порядок = приоритет).
  Future<void> updateGoals(List<String> goals) async {
    if (_userId.isEmpty) {
      FFAppState()
        ..obGoals = List<String>.from(goals)
        ..obPendingFlush = true;
      return;
    }
    await UsersTable().update(
      data: {'skin_goals': goals},
      matchingRows: (rows) => rows.eqOrNull('id', _userId),
    );
  }

  /// Команда ЗаявитьПредпочтение: merge в care_preferences
  /// (например {'max_steps': 3} или {'fragrance_free': true});
  /// значение null удаляет предпочтение.
  Future<void> setPreferences(Map<String, dynamic> changes) async {
    if (_userId.isEmpty || changes.isEmpty) return;
    final card = await getCard();
    final current = Map<String, dynamic>.from(
        (card?.carePreferences as Map?)?.cast<String, dynamic>() ?? {});
    changes.forEach((k, v) => v == null ? current.remove(k) : current[k] = v);
    await UsersTable().update(
      data: {'care_preferences': current},
      matchingRows: (rows) => rows.eqOrNull('id', _userId),
    );
  }
}
