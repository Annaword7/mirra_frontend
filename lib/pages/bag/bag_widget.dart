import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/database/database.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/profile_summary_card.dart';
import '/design_system/components/app_button.dart';
import '/domain/cosmetic_bag/cosmetic_bag_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/paywall/paywallpage/paywallpage_widget.dart';
import '/pages/care_review/care_review_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// «Косметичка» (M3c, контекст «Понимание продукта», Architecture v1).
///
/// Курируемый набор «чем я реально пользуюсь»: 3 бесплатных слота
/// (4-й — Pro), добавление из своих сканов, CTA на разбор и сборку режима.
/// Сама логика режима — на сервере; экран только владеет набором.
class BagWidget extends StatefulWidget {
  const BagWidget({super.key});

  static String routeName = 'Bag';
  static String routePath = '/bag';

  @override
  State<BagWidget> createState() => _BagWidgetState();
}

class _BagWidgetState extends State<BagWidget> {
  bool _loading = true;
  List<BagItemsRow> _items = [];
  Map<int, ImagesRow> _images = {};
  UsersRow? _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  Future<void> _load() async {
    try {
      final items = await CosmeticBagService.instance.items();
      final ids = items.map((i) => i.imageId).whereType<int>().toList();
      var images = <int, ImagesRow>{};
      if (ids.isNotEmpty) {
        final rows = await ImagesTable().queryRows(
          queryFn: (q) => q.inFilterOrNull('id', ids),
        );
        images = {for (final r in rows) r.id: r};
      }
      UsersRow? profile;
      if (currentUserUid.isNotEmpty) {
        final rows = await UsersTable().queryRows(
          queryFn: (q) => q.eqOrNull('id', currentUserUid),
        );
        profile = rows.isEmpty ? null : rows.first;
      }
      if (!mounted) return;
      setState(() {
        _items = items;
        _images = images;
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      debugPrint('bag load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _slotCount {
    // Free: ровно 3 слота. Pro: все продукты + 1 пустой «добавить».
    if (!FFAppState().isprouser) return kFreeBagSlots;
    return _items.length + 1;
  }

  Future<void> _addFlow() async {
    HapticFeedback.lightImpact();
    // Пейволл: 4-й продукт — Pro (коммерческое правило).
    if (!FFAppState().isprouser && _items.length >= kFreeBagSlots) {
      context.pushNamed(PaywallpageWidget.routeName);
      return;
    }
    final inBag = _items.map((i) => i.imageId).whereType<int>().toSet();
    final scans = await ImagesTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user', currentUserUid)
          .not('sa_analyzed_at', 'is', null)
          .order('id', ascending: false),
      limit: 50,
    );
    final candidates =
        scans.where((s) => !inBag.contains(s.id)).toList();
    if (!mounted) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickScanSheet(
        candidates: candidates,
        title: _t('cb_add_from_products'),
        emptyText: _t('cb_bag_empty'),
      ),
    );
    if (picked == null) return;
    await CosmeticBagService.instance.add(picked);
    _load();
  }

  Future<void> _remove(int imageId) async {
    HapticFeedback.lightImpact();
    await CosmeticBagService.instance.remove(imageId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final filled = _items.length;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _t('cb_bag_title'),
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: Colors.black,
            letterSpacing: 0,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
      ),
      bottomNavigationBar: const NavbarWidget(activePage: 3),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              children: [
                // «Твой профиль»: саммари онбординга, тап → квиз (изменить).
                ProfileSummaryCard(profileRow: _profile),
                Text(
                  _t('bag_subtitle'),
                  style: const TextStyle(color: Colors.black54, fontSize: 13.5),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                  children: [
                    for (var i = 0; i < _slotCount; i++)
                      i < filled
                          ? _FilledSlot(
                              image: _images[_items[i].imageId],
                              onRemove: () => _remove(_items[i].imageId!),
                            )
                          : _EmptySlot(
                              primary: theme.primary,
                              locked: !FFAppState().isprouser &&
                                  i >= kFreeBagSlots,
                              onTap: _addFlow,
                            ),
                  ],
                ),
                const SizedBox(height: 24),
                if (filled >= 2)
                  AppButton(
                    label: _t('bag_cta'),
                    onPressed: () async {
                      await context.pushNamed(CareReviewWidget.routeName);
                      if (mounted) _load();
                    },
                  )
                else
                  Text(
                    _t('bag_need_more'),
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
              ],
            ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  const _FilledSlot({required this.image, required this.onRemove});
  final ImagesRow? image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                children: [
                  Expanded(
                    child: (image != null && image!.imageUrl.isNotEmpty)
                        ? Image.network(image!.imageUrl,
                            width: double.infinity, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFF2F2F2),
                            child: const Center(
                              child: Icon(Icons.spa_outlined,
                                  color: Colors.black38),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      image?.productName ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x22000000), blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({
    required this.primary,
    required this.locked,
    required this.onTap,
  });
  final Color primary;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
          ),
        ),
        child: Center(
          child: Icon(
            locked ? Icons.lock_outline_rounded : Icons.add_rounded,
            color: locked ? Colors.black26 : primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _PickScanSheet extends StatelessWidget {
  const _PickScanSheet({
    required this.candidates,
    required this.title,
    required this.emptyText,
  });
  final List<ImagesRow> candidates;
  final String title;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
            ),
            const SizedBox(height: 12),
            if (candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(emptyText,
                    style: const TextStyle(color: Colors.black54)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    for (final img in candidates)
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(img.id),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: img.imageUrl.isNotEmpty
                              ? Image.network(img.imageUrl,
                                  fit: BoxFit.cover)
                              : Container(color: const Color(0xFFF2F2F2)),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
