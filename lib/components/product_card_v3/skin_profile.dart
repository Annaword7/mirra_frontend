import '/backend/supabase/supabase.dart';
import '/domain/client_card/client_card_service.dart';

/// Профиль кожи для подбора балла: тип и два признака.
///
/// Одно правило на карточку и на ленту Главной. Раньше карточка выводила
/// признаки из типа кожи и целей, а лента читала колонку `acne_prone`, и
/// один и тот же продукт показывал в кружке ленты одно число, на карточке
/// другое.
///
/// Колонка `users.acne_prone` в расчёт не идёт: у 55 из 145 людей с
/// `acne_prone = true` ни тип кожи, ни цели про акне не говорят (сухая кожа,
/// цели «поры, увлажнение, барьер»), и лента показывала им балл для склонной
/// к акне кожи. Признак берётся только из типа `acne_prone` и цели `acne`,
/// как на карточке.
class SkinProfile {
  const SkinProfile({
    this.skinType,
    this.sensitive = false,
    this.acneProne = false,
    this.pregnant = false,
  });

  final String? skinType;
  final bool sensitive;
  final bool acneProne;

  /// Беременность или кормление: карточка красит этим флагом состав и
  /// показывает плашку с противопоказаниями.
  final bool pregnant;

  static const SkinProfile empty = SkinProfile();


  /// Профиль, прочитанный любым экраном в этом запуске. Карточка берёт его в
  /// `initState`, поэтому первый кадр уже с нужным типом кожи: раньше она
  /// успевала показать запасную «нормальную», пока свой запрос профиля стоял
  /// в очереди за строкой и косметичкой.
  static SkinProfile? _last;

  static SkinProfile? get remembered => _last;

  /// Запомнить профиль пользователя. Пустая строка профиля ничего не
  /// затирает: лучше прежний профиль, чем сброс к «нормальной».
  static SkinProfile remember(UsersRow? u) {
    final profile = SkinProfile.fromUser(u);
    if (u != null) _last = profile;
    return profile;
  }

  /// Забыть профиль: при выходе из аккаунта.
  static void forget() => _last = null;

  factory SkinProfile.fromUser(UsersRow? u) {
    if (u == null) return empty;
    return SkinProfile(
      skinType: u.skinType,
      sensitive: (u.skinSensitivity ?? false) || u.skinType == 'sensitive',
      acneProne: u.skinType == 'acne_prone' || u.skinGoals.contains('acne'),
      pregnant: u.pregnancyStatus == ClientCardService.pregnantOrNursing,
    );
  }
}

/// `sa_card.skin_scores` из строки `images`, прочитанный целиком или через
/// `skin_scores:sa_card->skin_scores` в select ленты. null, если карточки нет.
Map<String, int>? skinScoresOf(ImagesRow row) {
  dynamic raw = row.getField<dynamic>('skin_scores');
  if (raw == null) {
    final card = row.saCard;
    if (card is Map) raw = card['skin_scores'];
  }
  if (raw is! Map) return null;
  final scores = <String, int>{
    for (final e in raw.entries)
      if (e.value is num) '${e.key}': (e.value as num).round(),
  };
  return scores.isEmpty ? null : scores;
}
