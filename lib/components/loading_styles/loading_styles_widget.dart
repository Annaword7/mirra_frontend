import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'loading_styles_model.dart';
export 'loading_styles_model.dart';

class LoadingStylesWidget extends StatefulWidget {
  const LoadingStylesWidget({super.key});

  @override
  State<LoadingStylesWidget> createState() => _LoadingStylesWidgetState();
}

class _LoadingStylesWidgetState extends State<LoadingStylesWidget> {
  late LoadingStylesModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingStylesModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  // Loop-reverse fade pulse, staggered per card.
  Widget _pulse(Widget child, int i) => child
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .fade(
        begin: 0.0,
        end: 1.0,
        delay: (i * 120).ms,
        duration: 600.ms,
        curve: Curves.easeInOut,
      );

  // One style-card skeleton: image tile + label pill.
  Widget _styleCard(FlutterFlowTheme theme, int i) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
        child: Container(
          width: 110.0,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: theme.alternate),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _pulse(
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: theme.alternate,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                  ),
                  i,
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 6.0),
                  child: _pulse(
                    Container(
                      width: 100.0,
                      height: 18.0,
                      decoration: BoxDecoration(
                        color: theme.alternate,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                    i,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: List.generate(4, (i) => _styleCard(theme, i))
            .divide(const SizedBox(width: 12.0))
            .addToStart(const SizedBox(width: 16.0))
            .addToEnd(const SizedBox(width: 16.0)),
      ),
    );
  }
}
