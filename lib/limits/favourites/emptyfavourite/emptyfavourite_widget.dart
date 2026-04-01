import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'emptyfavourite_model.dart';
export 'emptyfavourite_model.dart';

class EmptyfavouriteWidget extends StatefulWidget {
  const EmptyfavouriteWidget({super.key});

  @override
  State<EmptyfavouriteWidget> createState() => _EmptyfavouriteWidgetState();
}

class _EmptyfavouriteWidgetState extends State<EmptyfavouriteWidget> {
  late EmptyfavouriteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyfavouriteModel());

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
      decoration: BoxDecoration(),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          FFLocalizations.of(context).getText(
            'f9tt3hzn' /* Your favorite products will ap... */,
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: FlutterFlowTheme.of(context).primary,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
      ),
    );
  }
}
