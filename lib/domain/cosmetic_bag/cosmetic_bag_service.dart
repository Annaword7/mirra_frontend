import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/database/database.dart';
import '/domain/care_planning/care_planning_service.dart';

/// Косметичка — курируемый набор «чем я реально пользуюсь»
/// (контекст «Понимание продукта», Architecture v1).
///
/// Бесплатная версия ограничена [kFreeBagSlots] продуктами — это
/// коммерческое правило приложения (пейволл), не доменный инвариант.
const int kFreeBagSlots = 3;

class CosmeticBagService {
  CosmeticBagService._();
  static final instance = CosmeticBagService._();

  Future<List<BagItemsRow>> items() async {
    if (currentUserUid.isEmpty) return [];
    return BagItemsTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user_id', currentUserUid).order('added_at', ascending: true),
    );
  }

  /// Правка состава — единственное, что делает собранный режим устаревшим,
  /// поэтому кэш разбора сбрасывается здесь: любой экран, добавляющий продукт,
  /// получает это бесплатно.
  Future<void> add(int imageId) async {
    if (currentUserUid.isEmpty) return;
    await BagItemsTable().insert({
      'user_id': currentUserUid,
      'image_id': imageId,
    });
    CarePlanningService.instance.invalidateCare();
  }

  Future<void> remove(int imageId) async {
    if (currentUserUid.isEmpty) return;
    await BagItemsTable().delete(
      matchingRows: (q) =>
          q.eqOrNull('user_id', currentUserUid).eqOrNull('image_id', imageId),
    );
    CarePlanningService.instance.invalidateCare();
  }
}
