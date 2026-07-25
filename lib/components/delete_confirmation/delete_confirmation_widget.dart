import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'delete_confirmation_model.dart';
export 'delete_confirmation_model.dart';

class DeleteConfirmationWidget extends StatefulWidget {
  const DeleteConfirmationWidget({super.key});

  @override
  State<DeleteConfirmationWidget> createState() =>
      _DeleteConfirmationWidgetState();
}

class _DeleteConfirmationWidgetState extends State<DeleteConfirmationWidget> {
  late DeleteConfirmationModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeleteConfirmationModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MirraBottomSheet(
      crossAxisAlignment: CrossAxisAlignment.center,
      addBottomInset: false,
      handleGap: 0.0,
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                child: Text(
                  FFLocalizations.of(context).getText(
                    '4latue44' /* Are you sure you want to delet... */,
                  ),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).displayXS,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                child: Text(
                  FFLocalizations.of(context).getText(
                    '9fm4u5g5' /* Any products you’ve added will... */,
                  ),
                  textAlign: TextAlign.start,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        letterSpacing: 0.0,
                        lineHeight: 1.1,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                child: AppButton(
                  label: FFLocalizations.of(context).getText(
                    'qh4oraql' /* Delete account */,
                  ),
                  variant: AppButtonVariant.destructive,
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    _model.deleteuseranswer = await DeleteUserNEWBCNDCall.call(
                      host: FFDevEnvironmentValues().backendhost,
                      userId: currentUserUid,
                      token: currentJwtToken,
                    );

                    if ((_model.deleteuseranswer?.succeeded ?? true)) {
                      FFAppState().isprouser = false;
                      FFAppState().analysesused = 0;
                      FFAppState().weekResetDate = null;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('hint_upload_seen');
                      await prefs.remove('pro_preview_used');
                      await revenue_cat.login(null);
                      GoRouter.of(context).prepareAuthEvent();
                      await authManager.signOut();
                      GoRouter.of(context).clearRedirectLocation();

                      context.pushNamedAuth(
                          NewblankWidget.routeName, context.mounted);
                    } else {
                      await showDialog(
                        context: context,
                        builder: (alertDialogContext) {
                          return AlertDialog(
                            title: Text('ups!'),
                            content: Text('something went wrong!'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(alertDialogContext),
                                child: Text('Ok'),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    safeSetState(() {});
                  },
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: AppButton(
                  label: FFLocalizations.of(context).getText(
                    '9lehmzbk' /* Cancel */,
                  ),
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
    );
  }
}
