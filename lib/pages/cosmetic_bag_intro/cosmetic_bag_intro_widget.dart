import '/backend/cosmetic_bag_service.dart';
import '/backend/supabase/database/database.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/cosmetic_bag/bag_add_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cosmetic_bag_intro_model.dart';

export 'cosmetic_bag_intro_model.dart';

/// Onboarding game-flow: 3 placeholders that prompt the user to scan 3 products
/// and then see how they work together. Also the shared slot-rendering surface
/// reused by the persistent Косметичка screen.
class CosmeticBagIntroWidget extends StatefulWidget {
  const CosmeticBagIntroWidget({super.key});

  static String routeName = 'CosmeticBagIntro';
  static String routePath = '/cosmeticBagIntro';

  static Map<String, dynamic> get _fadeExtra => <String, dynamic>{
        '__transition_info__': TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
        ),
      };

  /// Called at every scan-success point in the scan widget. During the
  /// onboarding game-flow it drops the scan into the next placeholder and
  /// routes to the intro (or the compatibility teaser once all 3 are filled),
  /// and returns true so the caller skips its normal item-card navigation.
  /// Returns false when onboarding is already done — caller navigates as usual.
  static Future<bool> handleScanSuccess(
    BuildContext context,
    int? imageId, {
    required bool mounted,
  }) async {
    if (imageId == null) return false;
    // Persistent-bag "new scan into this slot": fill the target slot (or create
    // a fresh slot for the "+" flow), then show the normal product card.
    final pending = FFAppState().pendingBagSlot;
    if (pending != -1) {
      FFAppState().pendingBagSlot = -1;
      if (pending == kNewBagSlotPending) {
        final idx = await CosmeticBagService.instance.addEmptySlot();
        if (idx != null) {
          await CosmeticBagService.instance.assignSlot(idx, imageId);
        }
      } else {
        await CosmeticBagService.instance.assignSlot(pending, imageId);
      }
      return false;
    }
    // Only intercept while a new user is actively inside the game-flow —
    // existing users (or anyone past onboarding) scan normally.
    if (!FFAppState().bagOnboardingActive || FFAppState().bagOnboardingDone) {
      return false;
    }
    final filled = await CosmeticBagService.instance.onScanCompleted(imageId);
    final done = filled >= kBagOnboardingSlots;
    if (done) {
      FFAppState().bagOnboardingDone = true;
      FFAppState().bagOnboardingActive = false;
    }
    final navCtx = mounted ? context : appNavigatorKey.currentContext;
    navCtx?.goNamed(
      done ? CompatibilityResultWidget.routeName : routeName,
      extra: _fadeExtra,
    );
    return true;
  }

  @override
  State<CosmeticBagIntroWidget> createState() => _CosmeticBagIntroWidgetState();
}

class _CosmeticBagIntroWidgetState extends State<CosmeticBagIntroWidget> {
  late CosmeticBagIntroModel _model;

  List<BagSlotsRow> _slots = [];
  Map<int, ImagesRow> _images = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CosmeticBagIntroModel());
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
    if (!mounted) return;
    setState(() {
      _slots = slots;
      _images = images;
      _loading = false;
    });
  }

  int get _filledCount => _slots
      .where((s) =>
          (s.slotIndex ?? kBagOnboardingSlots) < kBagOnboardingSlots &&
          s.imageId != null)
      .length;

  Future<void> _startScan() async {
    HapticFeedback.lightImpact();
    final choice = await showAddChoice(context);
    if (choice == AddChoice.fromProducts) {
      if (!mounted) return;
      final img = await pickUserProduct(context);
      if (img != null) await _addExisting(img.id);
    } else if (choice == AddChoice.newScan) {
      if (!mounted) return;
      await context.pushNamed(
        TakeorUploadPageWidget.routeName,
        extra: CosmeticBagIntroWidget._fadeExtra,
      );
      // Returning from the scan flow (or if the reroute lands us back here).
      if (mounted) _load();
    }
  }

  /// Fill the next placeholder from an existing product (no scan), mirroring
  /// the scan-success flow: advance to the teaser once all 3 are filled.
  Future<void> _addExisting(int imageId) async {
    final filled = await CosmeticBagService.instance.onScanCompleted(imageId);
    if (!mounted) return;
    if (filled >= kBagOnboardingSlots) {
      FFAppState().bagOnboardingDone = true;
      FFAppState().bagOnboardingActive = false;
      context.goNamed(CompatibilityResultWidget.routeName);
    } else {
      _load();
    }
  }

  void _seeTogether() {
    HapticFeedback.lightImpact();
    context.pushNamed(CompatibilityResultWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final filled = _filledCount;
    final allDone = filled >= kBagOnboardingSlots;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      FFLocalizations.of(context).getText('cb_intro_title'),
                      textAlign: TextAlign.center,
                      style: theme.displaySmall.override(
                        fontFamily: theme.displaySmallFamily,
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                        useGoogleFonts: !theme.displaySmallIsCustom,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      FFLocalizations.of(context).getText('cb_intro_subtitle'),
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontSize: 15,
                        letterSpacing: 0,
                        color: Colors.black54,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$filled/$kBagOnboardingSlots',
                      textAlign: TextAlign.center,
                      style: theme.titleMedium.override(
                        fontFamily: theme.titleMediumFamily,
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        useGoogleFonts: !theme.titleMediumIsCustom,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.separated(
                        itemCount: kBagOnboardingSlots,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final slot = _slots.firstWhere(
                            (s) => s.slotIndex == i,
                            orElse: () => BagSlotsRow({'slot_index': i}),
                          );
                          final img = slot.imageId != null
                              ? _images[slot.imageId]
                              : null;
                          return _SlotCard(index: i, image: img);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: allDone ? _seeTogether : _startScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          FFLocalizations.of(context).getText(
                            allDone ? 'cb_see_together_cta' : 'cb_scan_cta',
                          ),
                          style: theme.titleSmall.override(
                            fontFamily: theme.titleSmallFamily,
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            useGoogleFonts: !theme.titleSmallIsCustom,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.index, required this.image});

  final int index;
  final ImagesRow? image;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final filled = image != null;
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: filled ? theme.primary : const Color(0xFFE6E6E6),
          width: filled ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.white,
                child: filled && image!.imageUrl.isNotEmpty
                    ? Image.network(
                        image!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image_outlined, color: Colors.black54),
                      )
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.headlineSmall.override(
                            fontFamily: theme.headlineSmallFamily,
                            color: Colors.black54,
                            letterSpacing: 0,
                            useGoogleFonts: !theme.headlineSmallIsCustom,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                filled
                    ? (image!.productName ?? image!.brand ?? '—')
                    : FFLocalizations.of(context).getText('cb_slot_add'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyLarge.override(
                  fontFamily: theme.bodyLargeFamily,
                  color: filled ? Colors.black : Colors.black54,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
                  letterSpacing: 0,
                  useGoogleFonts: !theme.bodyLargeIsCustom,
                ),
              ),
            ),
            Icon(
              filled ? Icons.check_circle_rounded : Icons.add_circle_outline,
              color: filled ? theme.primary : Colors.black54,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
