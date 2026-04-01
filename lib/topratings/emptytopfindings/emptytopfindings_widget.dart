import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'emptytopfindings_model.dart';
export 'emptytopfindings_model.dart';

class EmptytopfindingsWidget extends StatefulWidget {
  const EmptytopfindingsWidget({super.key});

  @override
  State<EmptytopfindingsWidget> createState() => _EmptytopfindingsWidgetState();
}

class _EmptytopfindingsWidgetState extends State<EmptytopfindingsWidget> {
  late EmptytopfindingsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptytopfindingsModel());

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
            'dupyww6s' /* Here you’ll see products with ... */,
          ),
          textAlign: TextAlign.center,
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
