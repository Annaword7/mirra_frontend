import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
      _keyboardSubscription = KeyboardVisibilityController().onChange.listen((visible) {
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
    return Stack(
      children: [
        // Tap outside to dismiss
        Align(
          alignment: AlignmentDirectional(-1.0, 1.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              color: Colors.transparent,
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional(0.0, 1.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).alternate,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 100.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).info,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                    child: Text(
                      FFLocalizations.of(context).getText('fc_neg_title'),
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: FlutterFlowTheme.of(context).headlineSmallFamily,
                            fontSize: 26.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            useGoogleFonts: !FlutterFlowTheme.of(context).headlineSmallIsCustom,
                          ),
                    ),
                  ),
                  Text(
                    FFLocalizations.of(context).getText('fc_neg_subtitle'),
                    textAlign: TextAlign.start,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                          letterSpacing: 0.0,
                          lineHeight: 1.1,
                          useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Comment field (required)
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            autofocus: true,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            obscureText: false,
                            maxLines: 4,
                            minLines: 3,
                            maxLength: 1000,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            decoration: InputDecoration(
                              hintText: FFLocalizations.of(context).getText('fc_neg_hint'),
                              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                    letterSpacing: 0.0,
                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).info, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).primaryBackground, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).info,
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                ),
                            cursorColor: FlutterFlowTheme.of(context).primary,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return FFLocalizations.of(context).getText('fc_neg_validator');
                              }
                              return null;
                            },
                          ),
                        ),
                        // Email field (optional)
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: FFLocalizations.of(context).getText('fc_neg_email'),
                              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                    letterSpacing: 0.0,
                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).info, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).primaryBackground, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).info,
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                ),
                            cursorColor: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ].divide(const SizedBox(height: 12.0)),
                    ),
                  ),
                  if (!(isWeb
                      ? MediaQuery.viewInsetsOf(context).bottom > 0
                      : _isKeyboardVisible))
                    FFButtonWidget(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                          return;
                        }
                        final email = _emailController.text.trim().isNotEmpty
                            ? _emailController.text.trim()
                            : currentUserEmail;
                        await TelegrammessegeCall.call(
                          messega: _commentController.text,
                          email: email,
                        );
                        await FirebaseAnalytics.instance.logEvent(name: 'feedback_submitted');
                        if (context.mounted) Navigator.pop(context);
                      },
                      text: FFLocalizations.of(context).getText('fc_neg_submit'),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 55.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                              color: Colors.white,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                            ),
                        elevation: 0.0,
                        borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                ].divide(const SizedBox(height: 15.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
