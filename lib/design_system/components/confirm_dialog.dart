import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/mirra_dialog_card.dart';

/// The single confirm dialog (Design Review Initiative 8): a centered card with
/// an optional icon badge, title, body, and a **side-by-side** Cancel / Confirm
/// pair (Cancel first, so a destructive action isn't the most prominent — review
/// deleteitem #3). Unifies the two incompatible confirm modals (deleteitem
/// stacked-destructive + markasspam side-by-side). Shown inside
/// `showModalBottomSheet(backgroundColor: transparent, ...)`; it self-centers.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    required this.cancelLabel,
    this.onCancel,
    this.body,
    this.destructive = false,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String? body;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String cancelLabel;

  /// Defaults to popping the sheet.
  final VoidCallback? onCancel;

  /// Confirm button is `destructive` when true, else `primary`.
  final bool destructive;

  /// Optional icon badge above the title.
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
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
              padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    MirraDialogIcon(
                      icon: icon!,
                      color: iconColor ?? theme.primary,
                      size: 52.0,
                      iconSize: 26.0,
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.headlineSmall.override(
                      fontFamily: theme.headlineSmallFamily,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.headlineSmallIsCustom,
                    ),
                  ),
                  if (body != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      body!,
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: cancelLabel,
                          variant: AppButtonVariant.secondary,
                          onPressed: onCancel ?? () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: AppButton(
                          label: confirmLabel,
                          variant: destructive
                              ? AppButtonVariant.destructive
                              : AppButtonVariant.primary,
                          onPressed: onConfirm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
