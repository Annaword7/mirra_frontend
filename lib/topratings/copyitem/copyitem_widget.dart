import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'copyitem_model.dart';
export 'copyitem_model.dart';

/// Create a popup for item deleting confirmation
class CopyitemWidget extends StatefulWidget {
  const CopyitemWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<CopyitemWidget> createState() => _CopyitemWidgetState();
}

class _CopyitemWidgetState extends State<CopyitemWidget> {
  late CopyitemModel _model;
  bool _isLoading = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CopyitemModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          'yj35oi8u' /* Copy Item */,
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
                          'p2cdk61c' /* Are you sure you want to copy ... */,
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
                      AppButton(
                        label: FFLocalizations.of(context).getText(
                          '5gas3j6n' /* Cancel */,
                        ),
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.md,
                        fullWidth: false,
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                      AppButton(
                        label: FFLocalizations.of(context).getText(
                          'noj51h6l' /* Copy */,
                        ),
                        size: AppButtonSize.md,
                        fullWidth: false,
                        loading: _isLoading,
                        onPressed: () async {
                          safeSetState(() => _isLoading = true);
                          try {
                            _model.copiedimage =
                                await CopyproductNEWBCNDCall.call(
                              host: FFDevEnvironmentValues().backendhost,
                              sourceImageId: widget.imageid,
                              targetUserId: currentUserUid,
                              token: currentJwtToken,
                            );

                            final newId = CopyproductNEWBCNDCall.newimageid(
                              _model.copiedimage?.jsonBody ?? '',
                            );

                            debugPrint('[CopyProduct] response: ${_model.copiedimage?.jsonBody}');
                            debugPrint('[CopyProduct] new_image_id: $newId');

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            if (newId != null) {
                              context.pushNamed(
                                Itemcard2Widget.routeName,
                                queryParameters: {
                                  'imageid': serializeParam(newId, ParamType.int),
                                },
                              );
                            } else {
                              debugPrint('[CopyProduct] ERROR: new_image_id is null, cannot navigate');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to copy product. Please try again.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) safeSetState(() => _isLoading = false);
                          }
                        },
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
