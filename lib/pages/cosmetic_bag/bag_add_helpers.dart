import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/database/database.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// How the user wants to fill a bag slot.
enum AddChoice { fromProducts, newScan }

/// Action on a filled slot.
enum SlotAction { replace, newScan, remove }

class _BagOption<T> {
  const _BagOption(this.icon, this.labelKey, this.value, {this.danger = false});
  final IconData icon;
  final String labelKey;
  final T value;
  final bool danger;
}

/// Shared bottom-sheet used by both the "+" (empty slot) and filled-slot menus
/// so they look identical: drag handle, white, one row per option.
Future<T?> _bagOptionsSheet<T>(
    BuildContext context, List<_BagOption<T>> options) {
  final theme = FlutterFlowTheme.of(context);
  const danger = Color(0xFFD9534F);
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in options)
              ListTile(
                leading:
                    Icon(o.icon, color: o.danger ? danger : theme.primary),
                title: Text(
                  FFLocalizations.of(context).getText(o.labelKey),
                  style: TextStyle(color: o.danger ? danger : Colors.black),
                ),
                onTap: () => Navigator.of(ctx).pop(o.value),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

/// Popup for an empty slot / the "+" tile: add from existing products or scan.
Future<AddChoice?> showAddChoice(BuildContext context) => _bagOptionsSheet(
      context,
      const [
        _BagOption(Icons.grid_view_rounded, 'cb_add_from_products',
            AddChoice.fromProducts),
        _BagOption(
            Icons.camera_alt_rounded, 'cb_add_new_scan', AddChoice.newScan),
      ],
    );

/// Popup for a filled slot: replace, scan new, or remove — same look as above.
Future<SlotAction?> showSlotActions(BuildContext context) => _bagOptionsSheet(
      context,
      const [
        _BagOption(
            Icons.swap_horiz_rounded, 'cb_slot_replace', SlotAction.replace),
        _BagOption(
            Icons.camera_alt_rounded, 'cb_slot_newscan', SlotAction.newScan),
        _BagOption(Icons.delete_outline, 'cb_slot_remove', SlotAction.remove,
            danger: true),
      ],
    );

/// Present the user's scanned products and return the chosen one (or null).
Future<ImagesRow?> pickUserProduct(BuildContext context) async {
  final scans = await ImagesTable().queryRows(
    queryFn: (q) =>
        q.eqOrNull('user', currentUserUid).order('id', ascending: false),
    limit: 50,
  );
  if (!context.mounted) return null;
  final theme = FlutterFlowTheme.of(context);
  return showModalBottomSheet<ImagesRow>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      FFLocalizations.of(context).getText('cb_swap_pick'),
                      style: theme.titleMedium.override(
                        fontFamily: theme.titleMediumFamily,
                        color: Colors.black,
                        letterSpacing: 0,
                        useGoogleFonts: !theme.titleMediumIsCustom,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: scans.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final img = scans[i];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: img.imageUrl.isNotEmpty
                            ? Image.network(img.imageUrl,
                                width: 44, height: 44, fit: BoxFit.cover)
                            : Container(
                                width: 44,
                                height: 44,
                                color: Colors.white),
                      ),
                      title: Text(
                        img.productName ?? img.brand ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black),
                      ),
                      onTap: () => Navigator.of(ctx).pop(img),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
