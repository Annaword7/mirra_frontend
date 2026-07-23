import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'markasspam_model.dart';
export 'markasspam_model.dart';

/// Create a popup for item deleting confirmation
class MarkasspamWidget extends StatefulWidget {
  const MarkasspamWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<MarkasspamWidget> createState() => _MarkasspamWidgetState();
}

class _MarkasspamWidgetState extends State<MarkasspamWidget> {
  late MarkasspamModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MarkasspamModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 12.0,
                  color: Color(0x33000000),
                  offset: Offset(
                    0.0,
                    4.0,
                  ),
                  spreadRadius: 0.0,
                )
              ],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'tost89il' /* Mark as spam */,
                        ),
                        textAlign: TextAlign.center,
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineSmallFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineSmallIsCustom,
                                ),
                      ),
                      Text(
                        FFLocalizations.of(context).getText(
                          '0whnywol' /* This product will be hidden fr... */,
                        ),
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: Colors.black,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(height: 12.0)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppButton(
                          label: FFLocalizations.of(context).getText(
                            'h4qorptg' /* Cancel */,
                          ),
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.md,
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: AppButton(
                          label: FFLocalizations.of(context).getText(
                            '899uf23u' /* Hide */,
                          ),
                          size: AppButtonSize.md,
                          onPressed: () async {
                            FFAppState().addToSpamlist(widget.imageid!);
                            await UsersTable().update(
                              data: {
                                'spam_images': FFAppState().spamlist,
                              },
                              matchingRows: (rows) =>
                                  rows.eqOrNull('id', currentUserUid),
                            );
                            if (context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                        ),
                      ),
                    ].divide(SizedBox(width: 12.0)),
                  ),
                ].divide(SizedBox(height: 20.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
