import 'dart:async';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_text_field.dart';
import '/design_system/components/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_album_model.dart';
export 'new_album_model.dart';

class NewAlbumWidget extends StatefulWidget {
  const NewAlbumWidget({super.key});

  @override
  State<NewAlbumWidget> createState() => _NewAlbumWidgetState();
}

class _NewAlbumWidgetState extends State<NewAlbumWidget> {
  late NewAlbumModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewAlbumModel());

    _model.albumnameTextController ??= TextEditingController();
    _model.albumnameFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).info,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                child: Text(
                  FFLocalizations.of(context).getText(
                    '3k3xtikh' /* Create new board */,
                  ),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).headlineSmallFamily,
                        fontSize: 26.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).headlineSmallIsCustom,
                      ),
                ),
              ),
              Text(
                FFLocalizations.of(context).getText(
                  'l4d5m49x' /* Add board details below */,
                ),
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      letterSpacing: 0.0,
                      lineHeight: 1.1,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
              Form(
                key: _model.formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: double.infinity,
                      child: AppTextField(
                        controller: _model.albumnameTextController,
                        focusNode: _model.albumnameFocusNode,
                        autofocus: true,
                        hintText: FFLocalizations.of(context).getText(
                          'azcd4b5c' /* New board name */,
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: _model.albumnameTextControllerValidator
                            .asValidator(context),
                        inputFormatters: [
                          if (!isAndroid && !isiOS)
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              return TextEditingValue(
                                selection: newValue.selection,
                                text: newValue.text
                                    .toCapitalization(TextCapitalization.words),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                label: FFLocalizations.of(context).getText(
                  'h68noqox' /* Create */,
                ),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  if (_model.formKey.currentState == null ||
                      !_model.formKey.currentState!.validate()) {
                    return;
                  }
                  _model.album = await AlbumTable().insert({
                    'name': _model.albumnameTextController.text,
                    'user': currentUserUid,
                    'cover':
                        'https://st2.depositphotos.com/2197626/7780/v/950/depositphotos_77803968-stock-illustration-blank-hardcover-album-template.jpg',
                  });
                  unawaited(AnalyticsService.instance.trackBoardCreated());
                  Navigator.pop(context);

                  safeSetState(() {});
                },
              ),
              AppButton(
                label: FFLocalizations.of(context).getText(
                  'sw4zsxbk' /* Cancel */,
                ),
                variant: AppButtonVariant.secondary,
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ].divide(SizedBox(height: 12.0)),
          ),
        ),
      ),
    );
  }
}
