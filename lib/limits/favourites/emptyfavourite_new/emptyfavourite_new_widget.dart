import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'emptyfavourite_new_model.dart';
export 'emptyfavourite_new_model.dart';

class EmptyfavouriteNewWidget extends StatefulWidget {
  const EmptyfavouriteNewWidget({super.key});

  @override
  State<EmptyfavouriteNewWidget> createState() =>
      _EmptyfavouriteNewWidgetState();
}

class _EmptyfavouriteNewWidgetState extends State<EmptyfavouriteNewWidget> {
  late EmptyfavouriteNewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyfavouriteNewModel());

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
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: 350.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                color: FlutterFlowTheme.of(context).alternate,
                size: 30.0,
              ),
            ),
            Text(
              FFLocalizations.of(context).getText(
                'vstpx0tw' /* No favourites yet */,
              ),
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                    fontSize: 24.0,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleLargeIsCustom,
                  ),
            ),
            FFButtonWidget(
              onPressed: () async {
                context.pushNamed(TakeorUploadPageWidget.routeName);
              },
              text: FFLocalizations.of(context).getText(
                'bea7pc3c' /* Scan a product */,
              ),
              icon: Icon(
                Icons.camera_alt,
                size: 26.0,
              ),
              options: FFButtonOptions(
                height: 60.0,
                padding: EdgeInsets.all(15.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                iconColor: FlutterFlowTheme.of(context).alternate,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                      color: FlutterFlowTheme.of(context).alternate,
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleSmallIsCustom,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(28.0),
              ),
            ),
          ].divide(SizedBox(height: 15.0)),
        ),
      ),
    );
  }
}
