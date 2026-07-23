import 'dart:async';

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Canonical Mirra button (Design Review Initiative 2 — Button system).
///
/// One pill-shaped button family replacing the ~10 heights / 12 radii and the
/// mix of FFButtonWidget / ElevatedButton / hand-rolled Ink pills. All colours,
/// sizes and the (full/pill) radius come from design tokens.
///
/// Variants: [primary] (fill `primary`, `onPrimary` text), [secondary] (fill
/// `surfaceMuted`, `primaryText`), [outline] (1px `border`), [text] (ghost,
/// `primary` text), [destructive] (fill `error`).
///
/// Sizes: [sm] 36 · [md] 44 · [lg] 52 (the `FFSizing.button*` tokens).
///
/// If [onPressed] returns a Future, a loading spinner shows while it runs
/// (like `FFButtonWidget.showLoadingIndicator`); pass [loading] to drive it
/// from external state instead.
enum AppButtonVariant { primary, secondary, outline, text, destructive }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.icon,
    this.trailingIcon,
    this.fullWidth = true,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final FutureOr<void> Function()? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trailing icon (e.g. a forward arrow on a CTA).
  final IconData? trailingIcon;
  final bool fullWidth;

  /// External loading state. Independent of the auto-spinner for async onPressed.
  final bool loading;
  final bool enabled;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _busy = false;

  double get _height {
    final s = FlutterFlowTheme.of(context).size;
    switch (widget.size) {
      case AppButtonSize.sm:
        return s.buttonSm;
      case AppButtonSize.md:
        return s.buttonMd;
      case AppButtonSize.lg:
        return s.buttonLg;
    }
  }

  double get _paddingX {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 16.0;
      case AppButtonSize.md:
        return 20.0;
      case AppButtonSize.lg:
        return 24.0;
    }
  }

  Future<void> _handleTap() async {
    final cb = widget.onPressed;
    if (cb == null) return;
    final result = cb();
    if (result is Future) {
      setState(() => _busy = true);
      try {
        await result;
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final showSpinner = widget.loading || _busy;
    final disabled =
        !widget.enabled || widget.onPressed == null || showSpinner;

    // Variant colours.
    late final Color bg;
    late final Color fg;
    BorderSide side = BorderSide.none;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = theme.primary;
        fg = theme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        bg = theme.surfaceMuted;
        fg = theme.primaryText;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = theme.primaryText;
        side = BorderSide(color: theme.border, width: 1.0);
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = theme.primary;
        break;
      case AppButtonVariant.destructive:
        bg = theme.error;
        fg = theme.onPrimary;
        break;
    }

    final labelStyle = (widget.size == AppButtonSize.sm
            ? theme.labelMedium
            : theme.labelLarge)
        .override(color: fg, fontWeight: FontWeight.w600);

    Widget content;
    if (showSpinner) {
      content = SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(strokeWidth: 2.0, color: fg),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20.0, color: fg),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: 8.0),
            Icon(widget.trailingIcon, size: 20.0, color: fg),
          ],
        ],
      );
    }

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        height: _height,
        child: Material(
          color: bg,
          shape: StadiumBorder(side: side),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: disabled ? null : _handleTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _paddingX),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
