import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

enum ErrorPopupType { productNotFound, ingredientsNotFound, subscriptionSync, unsupported, generic }

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

  static Future<String?> showIngredientInput(BuildContext context) =>
      showDialog<String?>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (ctx) => const _IngredientsInputDialog(),
      );

  _PopupConfig _config(BuildContext context) {
    final loc = FFLocalizations.of(context);
    switch (type) {
      case ErrorPopupType.productNotFound:
        return _PopupConfig(
          icon: Icons.search_off_rounded,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFE65100),
          title: loc.getText('err_product_not_found_title'),
          body: loc.getText('err_product_not_found_body'),
        );
      case ErrorPopupType.ingredientsNotFound:
        return _PopupConfig(
          icon: Icons.science_rounded,
          iconBg: const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF7B1FA2),
          title: loc.getText('err_ingredients_not_found_title'),
          body: loc.getText('err_ingredients_not_found_body'),
        );
      case ErrorPopupType.subscriptionSync:
        return _PopupConfig(
          icon: Icons.sync_rounded,
          iconBg: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1565C0),
          title: loc.getText('err_sub_sync_title'),
          body: loc.getText('err_sub_sync_body'),
        );
      case ErrorPopupType.unsupported:
        return _PopupConfig(
          icon: Icons.block_rounded,
          iconBg: const Color(0xFFFFFDE7),
          iconColor: const Color(0xFFF9A825),
          title: loc.getText('nnsq0kj5'),
          body: loc.getText('48je50c9'),
        );
      case ErrorPopupType.generic:
        return _PopupConfig(
          icon: Icons.error_outline_rounded,
          iconBg: const Color(0xFFFFEEEE),
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: cfg.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(cfg.icon, color: cfg.iconColor, size: 28.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                cfg.title,
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
                cfg.body,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: Text(
                    FFLocalizations.of(context).getText('err_ok_btn'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupConfig {
  const _PopupConfig({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconBg;
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
              Container(
                width: 56.0,
                height: 56.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.science_rounded,
                  color: Color(0xFF7B1FA2),
                  size: 28.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                loc.getText('err_ingredients_not_found_title'),
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
                loc.getText('err_ingredients_not_found_body'),
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
              const SizedBox(height: 12.0),
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, _controller.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: const Text(
                        'Анализировать',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasText && _expanded ? theme.alternate : theme.primary,
                    foregroundColor: hasText && _expanded
                        ? theme.primaryText
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: Text(
                    hasText && _expanded
                        ? 'Закрыть'
                        : loc.getText('err_ok_btn'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
