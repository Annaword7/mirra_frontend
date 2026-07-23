import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Canonical Mirra text field (Design Review Initiative 1 — Inputs).
///
/// Filled style with a **visible focus ring**, one consistent fill/border/radius,
/// and an optional password-visibility toggle in a ≥44px tap target. All colours
/// and the radius come from the design tokens in [FlutterFlowTheme]; no raw hex.
///
/// Spec: fill `surfaceMuted`, resting border 1px `border`, focus border 1.5px
/// `primary`, error border 1.5px `error`, radius 16, hint `secondaryText`.
///
/// Field *behaviour* (controller, validator, keyboard type, actions, autofill …)
/// is passed straight through so call-sites keep their existing logic — only the
/// decoration is standardised.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autovalidateMode,
    this.autofillHints,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onTap,
  });

  /// Password variant: obscured text with a visibility toggle.
  factory AppTextField.password({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? hintText,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
    AutovalidateMode? autovalidateMode,
    Iterable<String>? autofillHints,
    bool enabled = true,
    bool autofocus = false,
  }) =>
      AppTextField(
        key: key,
        controller: controller,
        focusNode: focusNode,
        hintText: hintText,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: textInputAction,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        autovalidateMode: autovalidateMode,
        autofillHints: autofillHints,
        enabled: enabled,
        autofocus: autofocus,
        obscureText: true,
        showObscureToggle: true,
      );

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final bool obscureText;
  final bool showObscureToggle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radii.r16),
          borderSide: BorderSide(color: color, width: width),
        );

    Widget? suffix = widget.suffixIcon;
    if (widget.showObscureToggle) {
      suffix = IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        splashRadius: 22,
        icon: Icon(
          _obscured
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          size: 20,
          color: theme.textTertiary,
        ),
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      autovalidateMode: widget.autovalidateMode,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      obscureText: _obscured,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      onTap: widget.onTap,
      cursorColor: theme.primary,
      style: theme.bodyMedium.override(color: theme.primaryText),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: theme.bodyMedium.override(color: theme.secondaryText),
        filled: true,
        fillColor: theme.surfaceMuted,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        prefixIcon: widget.prefixIcon,
        suffixIcon: suffix,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
        enabledBorder: outline(theme.border, 1.0),
        focusedBorder: outline(theme.primary, 1.5),
        disabledBorder: outline(theme.border, 1.0),
        errorBorder: outline(theme.error, 1.5),
        focusedErrorBorder: outline(theme.error, 1.5),
        border: outline(theme.border, 1.0),
        errorStyle: theme.bodySmall.override(color: theme.error),
      ),
    );
  }
}
