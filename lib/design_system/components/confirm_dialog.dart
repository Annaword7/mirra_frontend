import 'dart:async';
import 'dart:math' as math;

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
    this.surfaceColor,
  });

  final String title;
  final String? body;
  final String confirmLabel;

  /// When it returns a Future, the confirm button shows a spinner while it runs.
  final FutureOr<void> Function() onConfirm;

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

  /// Card surface. Defaults to white (`alternate`) — see [MirraDialogCard].
  final Color? surfaceColor;

  /// Наименьший читаемый кегль подписи в паре кнопок. Ниже — текст уже не
  /// столько «компактный», сколько мелкий, и пара уходит в колонку.
  static const double _minPairLabelSize = 13.0;

  /// Как показать пару кнопок: рядом (и с каким общим кеглем) или в колонку.
  ///
  /// Подписи бывают сильно разной длины: «Продолжить настройку» рядом с
  /// «Пропустить» не помещается в свою половину и обрезается многоточием.
  /// Ужимать только длинную нельзя — в паре получились бы два разных кегля,
  /// поэтому меряем обе и берём общий масштаб. Если и он не спасает (а в
  /// половине диалога на текст остаётся ~90pt), кнопки встают одна под другой
  /// во всю ширину: там подписи влезают целиком и уменьшать ничего не нужно.
  ({bool stack, double? fontSize}) _pairLayout(
      BuildContext context, FlutterFlowTheme theme, double rowWidth) {
    final style = theme.labelLarge.override(fontWeight: FontWeight.w600);
    final base = style.fontSize ?? 16.0;
    // Половина ряда минус зазор и горизонтальные поля lg-кнопки (24 с каждой).
    final available = (rowWidth - 12.0) / 2 - 48.0;
    if (available <= 0) return (stack: true, fontSize: null);

    var fontSize = base;
    for (final label in [cancelLabel!, confirmLabel]) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
      )..layout();
      if (painter.width > available) {
        fontSize = math.min(fontSize, base * available / painter.width);
      }
    }
    if (fontSize < _minPairLabelSize) return (stack: true, fontSize: null);
    return (stack: false, fontSize: fontSize >= base ? null : fontSize);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final card = Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor ?? theme.alternate,
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
                    LayoutBuilder(builder: (context, constraints) {
                      final layout =
                          _pairLayout(context, theme, constraints.maxWidth);

                      AppButton cancel({bool fullWidth = true}) => AppButton(
                            label: cancelLabel!,
                            variant: AppButtonVariant.secondary,
                            labelFontSize: layout.fontSize,
                            fullWidth: fullWidth,
                            onPressed:
                                onCancel ?? () => Navigator.pop(context),
                          );
                      AppButton confirm({bool fullWidth = true}) => AppButton(
                            label: confirmLabel,
                            variant: destructive
                                ? AppButtonVariant.destructive
                                : AppButtonVariant.primary,
                            loading: confirmLoading,
                            labelFontSize: layout.fontSize,
                            fullWidth: fullWidth,
                            onPressed: onConfirm,
                          );

                      // В колонке подтверждение сверху (Material: stacked —
                      // confirming action on top), отказ под ним.
                      if (layout.stack) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            confirm(),
                            const SizedBox(height: 8.0),
                            cancel(),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: cancel()),
                          const SizedBox(width: 12.0),
                          Expanded(child: confirm()),
                        ],
                      );
                    })
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
