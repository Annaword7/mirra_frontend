import '/auth/supabase_auth/auth_util.dart';
import '/backend/cosmetic_bag_service.dart';
import '/backend/supabase/database/database.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/profile_summary_card.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'bag_add_helpers.dart';
import 'cosmetic_bag_model.dart';

export 'cosmetic_bag_model.dart';

/// Persistent Косметичка: the user's product slots with a cached compatibility
/// score. Swapping products between slots is a Pro feature.
class CosmeticBagWidget extends StatefulWidget {
  const CosmeticBagWidget({super.key});

  static String routeName = 'CosmeticBag';
  static String routePath = '/cosmeticBag';

  @override
  State<CosmeticBagWidget> createState() => _CosmeticBagWidgetState();
}

class _CosmeticBagWidgetState extends State<CosmeticBagWidget> {
  late CosmeticBagModel _model;

  List<BagSlotsRow> _slots = [];
  Map<int, ImagesRow> _images = {};
  double? _cachedScore;
  UsersRow? _profileRow;
  bool _loading = true;

  /// How many of the 3 base placeholders (slot_index 0..2) are filled.
  int get _baseFilled => _slots
      .where((s) =>
          (s.slotIndex ?? kBagOnboardingSlots) < kBagOnboardingSlots &&
          s.imageId != null)
      .length;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CosmeticBagModel());
    _load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final slots = await CosmeticBagService.instance.ensureSlots();
    final ids = slots
        .map((s) => s.imageId)
        .where((id) => id != null)
        .cast<int>()
        .toList();
    var images = <int, ImagesRow>{};
    if (ids.isNotEmpty) {
      final rows = await ImagesTable().queryRows(
        queryFn: (q) => q.inFilterOrNull('id', ids),
      );
      images = {for (final r in rows) r.id: r};
    }
    final bag = await CosmeticBagTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid),
    );
    final user = await UsersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', currentUserUid),
    );
    if (!mounted) return;
    setState(() {
      _slots = slots;
      _images = images;
      _cachedScore = bag.isNotEmpty ? bag.first.lastCompatibilityScore : null;
      _profileRow = user.isNotEmpty ? user.first : null;
      _loading = false;
    });
  }

  Future<void> _onSlotTap(BagSlotsRow slot, bool isPro) async {
    HapticFeedback.lightImpact();
    final filled = slot.imageId != null;
    if (!filled) {
      await _addToSlot(slot);
      return;
    }
    if (!isPro) {
      context.pushNamed(PaywallpageWidget.routeName);
      return;
    }
    // Explicit replace / new scan / remove for a filled slot (Pro).
    final action = await showSlotActions(context);
    if (action == SlotAction.replace) {
      if (!mounted) return;
      final img = await pickUserProduct(context);
      if (img != null) {
        await CosmeticBagService.instance.assignSlot(slot.slotIndex!, img.id);
      }
    } else if (action == SlotAction.newScan) {
      FFAppState().pendingBagSlot = slot.slotIndex!;
      if (!mounted) return;
      await context.pushNamed(TakeorUploadPageWidget.routeName);
    } else if (action == SlotAction.remove) {
      await CosmeticBagService.instance.removeFromSlot(slot.slotIndex!);
    }
    if (mounted) _load();
  }

  /// "+" tile: create a new slot only once a product is actually chosen, so
  /// dismissing the popup leaves no empty cell behind.
  Future<void> _addNewSlot() async {
    HapticFeedback.lightImpact();
    final choice = await showAddChoice(context);
    if (choice == AddChoice.fromProducts) {
      if (!mounted) return;
      final img = await pickUserProduct(context);
      if (img == null) return; // cancelled → no slot created
      final idx = await CosmeticBagService.instance.addEmptySlot();
      if (idx != null) {
        await CosmeticBagService.instance.assignSlot(idx, img.id);
      }
    } else if (choice == AddChoice.newScan) {
      // The new slot is created on scan success (kNewBagSlotPending sentinel).
      FFAppState().pendingBagSlot = kNewBagSlotPending;
      if (!mounted) return;
      await context.pushNamed(TakeorUploadPageWidget.routeName);
    }
    if (mounted) _load();
  }

  Future<void> _addToSlot(BagSlotsRow slot) async {
    final choice = await showAddChoice(context);
    if (choice == AddChoice.fromProducts) {
      if (!mounted) return;
      final img = await pickUserProduct(context);
      if (img != null) {
        await CosmeticBagService.instance.assignSlot(slot.slotIndex!, img.id);
      }
    } else if (choice == AddChoice.newScan) {
      FFAppState().pendingBagSlot = slot.slotIndex!;
      if (!mounted) return;
      await context.pushNamed(TakeorUploadPageWidget.routeName);
    }
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isPro = context.watch<FFAppState>().isprouser;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          FFLocalizations.of(context).getText('cb_bag_title'),
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: Colors.black,
            letterSpacing: 0,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
      ),
      bottomNavigationBar: wrapWithModel(
        model: _model.navbarModel,
        updateCallback: () => safeSetState(() {}),
        child: const NavbarWidget(activePage: 3),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),
                  ProfileSummaryCard(profileRow: _profileRow),
                  _ScoreHeader(
                    score: _cachedScore,
                    onView: () async {
                      await context
                          .pushNamed(CompatibilityResultWidget.routeName);
                      if (mounted) _load();
                    },
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                    children: [
                      // Filled slots show the product; empty slots use the very
                      // same add tile as the trailing "+", so there is only one
                      // "add" look in the whole grid.
                      for (final slot in _slots)
                        if (slot.imageId != null)
                          _BagTile(
                            image: _images[slot.imageId],
                            proLock: !isPro,
                            onTap: () => _onSlotTap(slot, isPro),
                          )
                        else
                          _AddSlotTile(onTap: () => _onSlotTap(slot, isPro)),
                      // The trailing "+" appears only once all 3 base
                      // placeholders are filled (to extend beyond 3).
                      if (_baseFilled >= kBagOnboardingSlots)
                        _AddSlotTile(onTap: _addNewSlot),
                    ],
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.score, required this.onView});
  final double? score;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onView,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: glowCardDecoration(theme),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary.withValues(alpha: 0.12),
              ),
              child: Text(
                score != null ? score!.toStringAsFixed(1) : '—',
                style: theme.titleLarge.override(
                  fontFamily: theme.titleLargeFamily,
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                  useGoogleFonts: !theme.titleLargeIsCustom,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(context).getText('cb_compat_title'),
                    style: theme.bodyLarge.override(
                      fontFamily: theme.bodyLargeFamily,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodyLargeIsCustom,
                    ),
                  ),
                  Text(
                    FFLocalizations.of(context).getText('cb_open_analysis'),
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.primary,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _AddSlotTile extends StatelessWidget {
  const _AddSlotTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: theme.primary, size: 30),
            const SizedBox(height: 8),
            Text(
              FFLocalizations.of(context).getText('cb_slot_add'),
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.primary,
                letterSpacing: 0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BagTile extends StatelessWidget {
  const _BagTile({
    required this.image,
    required this.proLock,
    required this.onTap,
  });
  final ImagesRow? image;
  final bool proLock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const borderWidth = 1.5;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primary, width: borderWidth),
        ),
        // Inset the image by the border width and clip it to the inner radius
        // so the rounded corners line up exactly with the border.
        child: Padding(
          padding: const EdgeInsets.all(borderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16 - borderWidth),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if ((image?.imageUrl ?? '').isNotEmpty)
                  Image.network(image!.imageUrl, fit: BoxFit.cover)
                else
                  Container(color: Colors.white),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: theme.primary,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      image?.productName ?? image?.brand ?? '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: Colors.white,
                        letterSpacing: 0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                ),
                if (proLock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.lock_rounded,
                        color: Colors.white, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
