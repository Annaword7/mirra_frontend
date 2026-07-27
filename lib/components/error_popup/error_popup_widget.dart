import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/app_button.dart';
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
            fontFamily: theme.headlineSmallFamily,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(
            fontFamily: theme.bodyMediumFamily,
            color: theme.secondaryText,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodyMediumIsCustom,
          ),
        ),
      ],
    );
  }
}

class ErrorPopupWidget extends StatelessWidget {
  const ErrorPopupWidget({super.key, required this.type});

  final ErrorPopupType type;

  static Future<void> show(BuildContext context, ErrorPopupType type) =>
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (ctx) => ErrorPopupWidget(type: type),
      );

  static Future<IngredientInputResult?> showIngredientInput(
          BuildContext context) =>
      showDialog<IngredientInputResult?>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (ctx) => const _IngredientsInputDialog(),
      );

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
    final cfg = _config(context);

    return MirraDialogCard(
      icon: cfg.icon,
      iconColor: cfg.iconColor,
      children: [
        _DialogTitleBody(title: cfg.title, body: cfg.body),
        const SizedBox(height: 24.0),
        AppButton(
          label: FFLocalizations.of(context).getText('err_ok_btn'),
          onPressed: () => Navigator.pop(context),
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

class _IngredientsInputDialog extends StatefulWidget {
  const _IngredientsInputDialog();

  @override
  State<_IngredientsInputDialog> createState() =>
      _IngredientsInputDialogState();
}

class _IngredientsInputDialogState extends State<_IngredientsInputDialog> {
  final _controller = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final loc = FFLocalizations.of(context);
    final hasText = _controller.text.trim().isNotEmpty;

    return MirraDialogCard(
      icon: Icons.science_rounded,
      iconColor: const Color(0xFF7B1FA2),
      children: [
        _DialogTitleBody(
          title: loc.getText('err_ingredients_not_found_title'),
          body: loc.getText('err_ingredients_not_found_body'),
        ),
        const SizedBox(height: 16.0),
        AppButton(
          label: loc.getText('err_photograph_ingredients'),
          icon: Icons.photo_camera_rounded,
          onPressed: () => Navigator.pop(
            context,
            const IngredientInputResult(IngredientInputAction.photo),
          ),
        ),
        const SizedBox(height: 4.0),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    loc.getText('err_enter_ingredients_manually'),
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: theme.primary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.primary,
                  size: 20.0,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8.0),
          TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Water, Glycerin, Niacinamide...',
              hintStyle: TextStyle(color: theme.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: theme.alternate),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: theme.alternate),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: theme.primary),
              ),
              contentPadding: const EdgeInsets.all(12.0),
            ),
          ),
        ],
        const SizedBox(height: 20.0),
        if (hasText && _expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: AppButton(
              label: loc.getText('err_analyze_btn'),
              onPressed: () => Navigator.pop(
                context,
                IngredientInputResult(
                  IngredientInputAction.manualText,
                  _controller.text.trim(),
                ),
              ),
            ),
          ),
        AppButton(
          label: hasText && _expanded
              ? loc.getText('err_close_btn')
              : loc.getText('err_ok_btn'),
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.pop(context, null),
        ),
      ],
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
          onPressed: () => Navigator.pop(context, IngredientInputAction.photo),
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
