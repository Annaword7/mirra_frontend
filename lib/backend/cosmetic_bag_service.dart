import '/app_state.dart';
import 'supabase/database/database.dart';

/// Number of placeholder slots shown in the onboarding game-flow.
const int kBagOnboardingSlots = 3;

/// pendingBagSlot sentinel: "create a brand-new slot for the next scan"
/// (used by the "+" add tile so no empty slot is created until a scan lands).
const int kNewBagSlotPending = -2;

/// Owns the "Косметичка" slots: the 3 onboarding placeholders plus any extra
/// slots the persistent screen adds. Slot logic lives here so the scan widget
/// only needs a single call on scan success.
class CosmeticBagService {
  CosmeticBagService._();
  static final instance = CosmeticBagService._();

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  /// Ensure the 3 onboarding placeholder rows (slot_index 0..2) exist, then
  /// return every slot for the current user ordered by slot_index.
  Future<List<BagSlotsRow>> ensureSlots() async {
    final userId = _userId;
    if (userId == null) return [];

    final existing = await getSlots();
    final present = existing.map((s) => s.slotIndex).toSet();
    final missing = [
      for (var i = 0; i < kBagOnboardingSlots; i++)
        if (!present.contains(i)) i
    ];
    if (missing.isNotEmpty) {
      await SupaFlow.client.from('bag_slots').insert([
        for (final i in missing) {'user_id': userId, 'slot_index': i}
      ]);
      return getSlots();
    }
    return existing;
  }

  Future<List<BagSlotsRow>> getSlots() async {
    final userId = _userId;
    if (userId == null) return [];
    return BagSlotsTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId).order(
            'slot_index',
            ascending: true,
          ),
    );
  }

  /// How many of the first [kBagOnboardingSlots] placeholders are filled.
  Future<int> filledOnboardingCount() async {
    final slots = await getSlots();
    return slots
        .where((s) =>
            (s.slotIndex ?? -1) < kBagOnboardingSlots && s.imageId != null)
        .length;
  }

  /// Add a new empty slot after the current last one. Returns its slot_index.
  Future<int?> addEmptySlot() async {
    final userId = _userId;
    if (userId == null) return null;
    final slots = await getSlots();
    final nextIndex = slots.isEmpty
        ? 0
        : slots.map((s) => s.slotIndex ?? 0).fold(0, (a, b) => a > b ? a : b) +
            1;
    await SupaFlow.client
        .from('bag_slots')
        .insert({'user_id': userId, 'slot_index': nextIndex});
    return nextIndex;
  }

  /// Assign [imageId] to a specific slot (used by the Pro swap UI).
  Future<void> assignSlot(int slotIndex, int? imageId) async {
    final userId = _userId;
    if (userId == null) return;
    await SupaFlow.client
        .from('bag_slots')
        .update({'image_id': imageId})
        .eq('user_id', userId)
        .eq('slot_index', slotIndex);
  }

  /// Remove a product from a slot. Extra slots (beyond the 3 onboarding ones)
  /// are deleted entirely; the 3 placeholders are just cleared.
  Future<void> removeFromSlot(int slotIndex) async {
    final userId = _userId;
    if (userId == null) return;
    if (slotIndex >= kBagOnboardingSlots) {
      await SupaFlow.client
          .from('bag_slots')
          .delete()
          .eq('user_id', userId)
          .eq('slot_index', slotIndex);
    } else {
      await assignSlot(slotIndex, null);
    }
  }

  /// Record a completed scan during the onboarding game-flow: drop [imageId]
  /// into the next empty placeholder and sync the progress counter. No-op once
  /// onboarding is done. Returns the number of filled placeholders (0..3).
  Future<int> onScanCompleted(int imageId) async {
    if (FFAppState().bagOnboardingDone) return kBagOnboardingSlots;
    final slots = await ensureSlots();
    // Idempotent: if this image is already in a slot, don't add it twice.
    final alreadyIn = slots.any((s) => s.imageId == imageId);
    if (!alreadyIn) {
      BagSlotsRow? empty;
      for (final s in slots) {
        if ((s.slotIndex ?? kBagOnboardingSlots) < kBagOnboardingSlots &&
            s.imageId == null) {
          empty = s;
          break;
        }
      }
      if (empty != null) {
        await assignSlot(empty.slotIndex!, imageId);
      }
    }
    final filled = await filledOnboardingCount();
    FFAppState().bagScanCount = filled;
    return filled;
  }
}
