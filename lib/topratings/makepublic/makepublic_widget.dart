import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import 'package:flutter/material.dart';
import 'makepublic_model.dart';
export 'makepublic_model.dart';

class MakepublicWidget extends StatefulWidget {
  const MakepublicWidget({super.key});

  @override
  State<MakepublicWidget> createState() => _MakepublicWidgetState();
}

class _MakepublicWidgetState extends State<MakepublicWidget> {
  late MakepublicModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MakepublicModel());
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
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12.0,
                  color: Color(0x33000000),
                  offset: Offset(0.0, 4.0),
                  spreadRadius: 0.0,
                )
              ],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText('553khwzz'),
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                              fontFamily: FlutterFlowTheme.of(context).headlineSmallFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context).headlineSmallIsCustom,
                            ),
                      ),
                      Text(
                        FFLocalizations.of(context).getText('g7bez9em'),
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                            ),
                      ),
                    ].divide(const SizedBox(height: 12.0)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        label: FFLocalizations.of(context).getText('dv0imp11'),
                        size: AppButtonSize.md,
                        fullWidth: false,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ].divide(const SizedBox(width: 12.0)),
                  ),
                ].divide(const SizedBox(height: 20.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
