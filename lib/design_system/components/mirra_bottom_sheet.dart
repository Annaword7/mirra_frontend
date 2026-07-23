import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/mirra_drag_handle.dart';

/// The single bottom-sheet scaffold (Design Review Initiative 6): a top-rounded
/// (r24) surface with a canonical [MirraDragHandle] and standard padding, adding
/// the keyboard inset to its bottom pad. Replaces the two divergent sheet shells
/// (white / 40×4 handle vs `alternate` / 100×5 handle) and the per-sheet
/// radius/handle/padding drift.
///
/// Shown inside `showModalBottomSheet(isScrollControlled: true,
/// backgroundColor: Colors.transparent, ...)`. Provide the sheet body as [child];
/// the handle + chrome are supplied here.
class MirraBottomSheet extends StatelessWidget {
  const MirraBottomSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
    this.surfaceColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.showHandle = true,
    this.handleGap = 20.0,
    this.addBottomInset = true,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Sheet surface. Defaults to `secondaryBackground`.
  final Color? surfaceColor;

  final CrossAxisAlignment crossAxisAlignment;
  final bool showHandle;

  /// Gap between the handle and [child].
  final double handleGap;

  /// When true, adds `MediaQuery.viewInsets.bottom` to the bottom padding so the
  /// content clears the keyboard (for sheets that don't already wrap themselves
  /// in a view-insets padding at the call site).
  final bool addBottomInset;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final inset =
        addBottomInset ? MediaQuery.of(context).viewInsets.bottom : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor ?? theme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: padding.copyWith(bottom: padding.bottom + inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (showHandle) ...[
            const Center(child: MirraDragHandle()),
            SizedBox(height: handleGap),
          ],
          child,
        ],
      ),
    );
  }
}
