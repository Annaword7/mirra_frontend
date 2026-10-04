import 'dart:math' show min;

import '/backend/supabase/supabase.dart';
import '/domain/client_card/client_card_service.dart';
import 'card_labels.dart' show kSkinTypes;

/// Профиль кожи для подбора балла: тип и два признака.
///
/// Одно правило на карточку и на ленту Главной: считали в двух местах по
/// разному, и один и тот же продукт показывал в кружке ленты одно число, а
/// на карточке другое.
///
/// Признаки это два тумблера из анкеты: `users.skin_sensitivity` и
/// `users.acne_prone`, их пишет онбординг. Цели ухода в признаки не идут:
/// «хочу убрать акне» это задача, а не свойство кожи.
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
      acneProne: (u.acneProne ?? false) || u.skinType == 'acne_prone',
      pregnant: u.pregnancyStatus == ClientCardService.pregnantOrNursing,
    );
  }
}

/// Балл продукта для профиля кожи: включённые тумблеры перекрывают основной
/// тип. Включён один признак, показываем его балл; включены оба, меньший из
/// двух; ни одного, балл основного типа.
///
/// Общий на карточку и на кружок в ленте Главной.
///
/// [scores] это `sa_card.skin_scores`. null, если нужного балла в нём нет
/// (старый разбор): зовущий сам решает, чем это заменить.
int? fitScoreFor(
  Map<String, int> scores, {
  required String? skinType,
  required bool sensitive,
  required bool acneProne,
}) {
  final flags = <int>[
    if (sensitive && scores['sensitive'] != null) scores['sensitive']!,
    if (acneProne && scores['acne_prone'] != null) scores['acne_prone']!,
  ];
  if (flags.isNotEmpty) return flags.reduce(min);
  // Тип вне списка (пусто у того, кто пропустил анкету) читаем как
  // «нормальная»: так же поступает карточка, когда профиля нет.
  final type = kSkinTypes.contains(skinType) ? skinType! : 'normal';
  return scores[type];
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
