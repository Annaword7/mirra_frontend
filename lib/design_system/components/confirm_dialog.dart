import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/mirra_dialog_card.dart';

/// The single confirm dialog (Design Review Initiative 8): a centered card with
/// an optional icon badge, title, body, and action buttons. With [cancelLabel]
/// it's a **side-by-side** Cancel / Confirm pair (Cancel first, so a destructive
/// action isn't the most prominent — review deleteitem #3); without it, a single
/// centered confirm button. Unifies the confirm modals (deleteitem, markasspam)
/// and the visibility sheets (makepublic / makeprivate / hidenavailability /
/// copyitem). Shown inside `showModalBottomSheet(backgroundColor: transparent,
/// ...)`; it self-centers.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel,
    this.onCancel,
    this.body,
    this.destructive = false,
    this.confirmLoading = false,
    this.icon,
    this.iconColor,
    this.onBackgroundTap,
  });

  final String title;
  final String? body;
  final String confirmLabel;
  final VoidCallback onConfirm;

  /// When null, only the confirm button is shown (centered).
  final String? cancelLabel;

  /// Defaults to popping the sheet.
  final VoidCallback? onCancel;

  /// Shows a spinner on the confirm button.
  final bool confirmLoading;

  /// Confirm button is `destructive` when true, else `primary`.
  final bool destructive;

  /// Optional icon badge above the title.
  final IconData? icon;
  final Color? iconColor;

  /// When set, tapping the scrim (outside the card) runs this (tap-to-dismiss).
  final VoidCallback? onBackgroundTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final card = Align(
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
                  if (cancelLabel != null)
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: cancelLabel!,
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
                            loading: confirmLoading,
                            onPressed: onConfirm,
                          ),
                        ),
                      ],
                    )
                  else
                    AppButton(
                      label: confirmLabel,
                      variant: destructive
                          ? AppButtonVariant.destructive
                          : AppButtonVariant.primary,
                      loading: confirmLoading,
                      fullWidth: false,
                      onPressed: onConfirm,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

    if (onBackgroundTap == null) {
      return Container(color: Colors.transparent, child: card);
    }
    return GestureDetector(
      onTap: onBackgroundTap,
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(onTap: () {}, child: card),
    );
  }
}
