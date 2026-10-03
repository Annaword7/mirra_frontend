import '/backend/supabase/supabase.dart';

/// Профиль кожи для подбора балла: тип и два признака.
///
/// Одно правило на карточку и на ленту Главной. Раньше карточка выводила
/// признаки из типа кожи и целей, а лента читала колонку `acne_prone`, и
/// один и тот же продукт показывал в кружке ленты одно число, на карточке
/// другое.
class SkinProfile {
  const SkinProfile({this.skinType, this.sensitive = false, this.acneProne = false});

  final String? skinType;
  final bool sensitive;
  final bool acneProne;

  static const SkinProfile empty = SkinProfile();

  factory SkinProfile.fromUser(UsersRow? u) {
    if (u == null) return empty;
    return SkinProfile(
      skinType: u.skinType,
      sensitive: (u.skinSensitivity ?? false) || u.skinType == 'sensitive',
      acneProne: u.skinType == 'acne_prone' ||
          (u.acneProne ?? false) ||
          u.skinGoals.contains('acne'),
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
