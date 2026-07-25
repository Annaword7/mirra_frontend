import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// A circular tinted icon badge for [MirraDialogCard] (Design Review Initiative
/// 6): a 56×56 circle filled with a light tint of [color], with the icon in
/// full [color]. Replaces the per-dialog hand-rolled badge (e.g. error_popup's
/// `#F3E5F5` behind `#7B1FA2`).
class MirraDialogIcon extends StatelessWidget {
  const MirraDialogIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 56.0,
    this.iconSize = 28.0,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

/// The single centered dialog shell (Design Review Initiative 6): a transparent
/// [Dialog] wrapping a rounded (r20) surface with a soft shadow and standard
/// padding, with an optional [MirraDialogIcon] at the top. Replaces the
/// hand-rolled `Dialog`/`Container` shells (error_popup's 3 cards, the takeor
/// info dialog).
class MirraDialogCard extends StatelessWidget {
  const MirraDialogCard({
    super.key,
    required this.children,
    this.icon,
    this.iconColor,
    this.insetPadding = const EdgeInsets.all(24.0),
    this.padding = const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.surfaceColor,
  });

  /// Body of the dialog, below the optional icon (title / body / actions).
  final List<Widget> children;

  /// When set, a [MirraDialogIcon] is rendered at the top (with a 16px gap).
  final IconData? icon;
  final Color? iconColor;

  final EdgeInsets insetPadding;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: insetPadding,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor ?? theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24.0,
              color: Color(0x1A000000),
              offset: Offset(0.0, 8.0),
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              if (icon != null) ...[
                MirraDialogIcon(icon: icon!, color: iconColor ?? theme.primary),
                const SizedBox(height: 16.0),
              ],
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
