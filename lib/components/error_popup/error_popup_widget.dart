import 'dart:async';

import 'package:flutter/material.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/app_text_field.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/design_system/components/mirra_dialog_card.dart';
import '/flutter_flow/flutter_flow_util.dart';

enum ErrorPopupType {
  productNotFound,
  ingredientsNotFound,
  subscriptionSync,
  unsupported,
  generic
}

enum IngredientInputAction { cancelled, manualText, photo }

class IngredientInputResult {
  const IngredientInputResult(this.action, [this.text]);

  final IngredientInputAction action;
  final String? text;
}

/// Shared title + body pair for the error/choice dialogs below.
class _DialogTitleBody extends StatelessWidget {
  const _DialogTitleBody({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.headlineSmall.override(
            color: theme.primaryText,
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.0,
            lineHeight: 1.25,
          ),
        ),
        SizedBox(height: theme.space.s8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(
            color: theme.secondaryText,
            letterSpacing: 0.0,
            lineHeight: 1.4,
          ),
        ),
      ],
    );
  }
}

class ErrorPopupWidget extends StatelessWidget {
  const ErrorPopupWidget({super.key, required this.type});

  final ErrorPopupType type;

  /// Every analysis failure surfaces through this dialog and nowhere else, so
  /// this is the one place that can report the whole failure taxonomy without
  /// instrumenting ~25 error branches across the two (mirrored) scan chains.
  /// One event with `reason` = [type] name; no per-type events on top of it.
  static Future<void> show(BuildContext context, ErrorPopupType type) {
    unawaited(AnalyticsService.instance.trackAnalysisFailed(reason: type.name));
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => ErrorPopupWidget(type: type),
    );
  }

  /// Лист, а не центрированный диалог: здесь вводят состав, то есть поднимается
  /// клавиатура. В диалоге она перекрывала кнопку «Анализировать» (та ещё и
  /// появлялась только после ввода, ниже поля), свернуть клавиатуру было нечем,
  /// а тап по затемнению закрывал окно вместе с уже вставленным составом — и
  /// скан после этого удалялся. Лист поднимается над клавиатурой, содержимое
  /// скроллится, закрыть можно только явной кнопкой.
  static Future<IngredientInputResult?> showIngredientInput(
      BuildContext context) {
    // Клавиатура предыдущего шага остаётся поднятой и открывает лист уже
    // наполовину перекрытым — гасим её перед показом.
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<IngredientInputResult?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => const _IngredientsInputSheet(),
    );
  }

  static Future<IngredientInputAction?> showLowConfidenceChoice(
          BuildContext context) =>
      showDialog<IngredientInputAction?>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (ctx) => const _LowConfidenceChoiceDialog(),
      );

  _PopupConfig _config(BuildContext context) {
    final loc = FFLocalizations.of(context);
    switch (type) {
      case ErrorPopupType.productNotFound:
        return _PopupConfig(
          icon: Icons.search_off_rounded,
          iconColor: const Color(0xFFE65100),
          title: loc.getText('err_product_not_found_title'),
          body: loc.getText('err_product_not_found_body'),
        );
      case ErrorPopupType.ingredientsNotFound:
        return _PopupConfig(
          icon: Icons.science_rounded,
          iconColor: const Color(0xFF7B1FA2),
          title: loc.getText('err_ingredients_not_found_title'),
          body: loc.getText('err_ingredients_not_found_body'),
        );
      case ErrorPopupType.subscriptionSync:
        return _PopupConfig(
          icon: Icons.sync_rounded,
          iconColor: const Color(0xFF1565C0),
          title: loc.getText('err_sub_sync_title'),
          body: loc.getText('err_sub_sync_body'),
        );
      case ErrorPopupType.unsupported:
        return _PopupConfig(
          icon: Icons.block_rounded,
          iconColor: const Color(0xFFF9A825),
          title: loc.getText('nnsq0kj5'),
          body: loc.getText('48je50c9'),
        );
      case ErrorPopupType.generic:
        return _PopupConfig(
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFD32F2F),
          title: loc.getText('err_generic_title'),
          body: loc.getText('err_generic_body'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final cfg = _config(context);

    return MirraDialogCard(
      icon: cfg.icon,
      iconColor: cfg.iconColor,
      children: [
        _DialogTitleBody(title: cfg.title, body: cfg.body),
        SizedBox(height: theme.space.s24),
        AppButton(
          label: FFLocalizations.of(context).getText('err_ok_btn'),
          onPressed: () {
            if (type == ErrorPopupType.productNotFound) {
              unawaited(
                  AnalyticsService.instance.trackScanProductNotRecognizedOk());
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _PopupConfig {
  const _PopupConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
}

/// «Состав не найден» — единственный экран приложения, который просит что-то
/// напечатать, и цена ошибки тут высокая: если закрыть его без состава, скан
/// удаляется вместе с продуктом.
///
/// Поле показано сразу, без раскрывашки: вставить состав — ровно то, зачем сюда
/// попадают, и прятать это за строкой-аккордеоном не за чем. Кнопка
/// «Анализировать» стоит под полем всегда (пока пусто — неактивная), так что
/// видно, чем закончится ввод.
class _IngredientsInputSheet extends StatefulWidget {
  const _IngredientsInputSheet();

  @override
  State<_IngredientsInputSheet> createState() => _IngredientsInputSheetState();
}

class _IngredientsInputSheetState extends State<_IngredientsInputSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Запятая — разделитель INCI, но из буфера часто прилетает список с
    // переносами строк или точкой с запятой; считаем по всем трём.
    final count =
        text.split(RegExp(r'[,;\n]')).where((p) => p.trim().isNotEmpty).length;
    unawaited(AnalyticsService.instance.trackScanIngredientsManually(
      length: text.length,
      ingredientsCount: count,
    ));
    Navigator.pop(
      context,
      IngredientInputResult(IngredientInputAction.manualText, text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final loc = FFLocalizations.of(context);
    final hasText = _controller.text.trim().isNotEmpty;

    return MirraBottomSheet(
      surfaceColor: theme.alternate,
      child: ConstrainedBox(
        // Считаем от высоты БЕЗ клавиатуры: она съедает до половины экрана, и
        // потолок от полной высоты сделал бы лист выше, чем остаётся места.
        // Что не влезло — прокручивается, а не ломается.
        constraints: BoxConstraints(
          maxHeight: (MediaQuery.sizeOf(context).height -
                  MediaQuery.viewInsetsOf(context).bottom) *
              0.78,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: MirraDialogIcon(
                  icon: Icons.science_rounded,
                  color: Color(0xFF7B1FA2),
                ),
              ),
              SizedBox(height: theme.space.s16),
              _DialogTitleBody(
                title: loc.getText('err_ingredients_not_found_title'),
                body: loc.getText('err_ingredients_not_found_body'),
              ),
              SizedBox(height: theme.space.s24),
              // Кнопка «Сфотографировать состав» временно снята: путь через
              // распознавание панели с фото ведёт себя непредсказуемо. Ветка
              // IngredientInputAction.photo и её обработка на экране сканера
              // оставлены нетронутыми — вернуть кнопку значит вернуть этот
              // блок, ничего больше.
              Text(
                loc.getText('err_enter_ingredients_manually'),
                style: theme.titleSmall.override(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
              SizedBox(height: theme.space.s8),
              AppTextField(
                controller: _controller,
                hintText: 'Water, Glycerin, Niacinamide…',
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: theme.space.s12),
              AppButton(
                label: loc.getText('err_analyze_btn'),
                onPressed: hasText ? _submit : null,
              ),
              SizedBox(height: theme.space.s4),
              AppButton(
                label: loc.getText('err_close_btn'),
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.pop(context, null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LowConfidenceChoiceDialog extends StatelessWidget {
  const _LowConfidenceChoiceDialog();

  @override
  Widget build(BuildContext context) {
    final loc = FFLocalizations.of(context);

    return MirraDialogCard(
      icon: Icons.fact_check_rounded,
      iconColor: const Color(0xFFE65100),
      children: [
        _DialogTitleBody(
          title: loc.getText('ing_low_confidence_title'),
          body: loc.getText('ing_low_confidence_body'),
        ),
        const SizedBox(height: 24.0),
        AppButton(
          label: loc.getText('err_photograph_ingredients'),
          icon: Icons.photo_camera_rounded,
          onPressed: () {
            unawaited(AnalyticsService.instance.trackScanPhotoIngredients());
            Navigator.pop(context, IngredientInputAction.photo);
          },
        ),
        const SizedBox(height: 8.0),
        AppButton(
          label: loc.getText('ing_continue_anyway'),
          variant: AppButtonVariant.secondary,
          onPressed: () =>
              Navigator.pop(context, IngredientInputAction.cancelled),
        ),
      ],
    );
  }
}
