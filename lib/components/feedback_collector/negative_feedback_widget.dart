import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/app_text_field.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class NegativeFeedbackWidget extends StatefulWidget {
  const NegativeFeedbackWidget({super.key});

  @override
  State<NegativeFeedbackWidget> createState() => _NegativeFeedbackWidgetState();
}

class _NegativeFeedbackWidgetState extends State<NegativeFeedbackWidget> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  late StreamSubscription<bool> _keyboardSubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    if (!isWeb) {
      _keyboardSubscription =
          KeyboardVisibilityController().onChange.listen((visible) {
        safeSetState(() => _isKeyboardVisible = visible);
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    if (!isWeb) _keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return MirraBottomSheet(
      // Белый лист и выравнивание по левому краю, как в остальных окнах:
      // раньше содержимое центрировалось, а тексты внутри шли от края.
      surfaceColor: Colors.white,
      addBottomInset: false,
      handleGap: 12.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FFLocalizations.of(context).getText('fc_neg_title'),
            style: theme.displayXS,
          ),
          const SizedBox(height: 6),
          Text(
            FFLocalizations.of(context).getText('fc_neg_subtitle'),
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              lineHeight: 1.25,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Оба поля — AppTextField: те же заливка, рамка и радиус, что
                // на остальных экранах. Раньше стили были расписаны вручную,
                // причём фокус подсвечивался цветом фона — рамка пропадала.
                AppTextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  hintText: FFLocalizations.of(context).getText('fc_neg_hint'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLines: 4,
                  minLines: 3,
                  maxLength: 1000,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  showCounter: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return FFLocalizations.of(context)
                          .getText('fc_neg_validator');
                    }
                    return null;
                  },
                ),
                AppTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  hintText: FFLocalizations.of(context).getText('fc_neg_email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
              ].divide(const SizedBox(height: 12.0)),
            ),
          ),
          if (!(isWeb
              ? MediaQuery.viewInsetsOf(context).bottom > 0
              : _isKeyboardVisible)) ...[
            const SizedBox(height: 24),
            AppButton(
              label: FFLocalizations.of(context).getText('fc_neg_submit'),
              onPressed: () async {
                HapticFeedback.lightImpact();
                if (_formKey.currentState == null ||
                    !_formKey.currentState!.validate()) {
                  return;
                }
                final email = _emailController.text.trim().isNotEmpty
                    ? _emailController.text.trim()
                    : currentUserEmail;
                await TelegrammessegeCall.call(
                  messega: _commentController.text,
                  email: email,
                );
                await FirebaseAnalytics.instance
                    .logEvent(name: 'feedback_submitted');
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }
}
