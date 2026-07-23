import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/skeleton_grid.dart';
import 'package:flutter/material.dart';
import 'loading_recent_model.dart';
export 'loading_recent_model.dart';

class LoadingRecentWidget extends StatefulWidget {
  const LoadingRecentWidget({super.key});

  @override
  State<LoadingRecentWidget> createState() => _LoadingRecentWidgetState();
}

class _LoadingRecentWidgetState extends State<LoadingRecentWidget> {
  late LoadingRecentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingRecentModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonGrid(
      count: 6,
      columns: 3,
      spacing: 10.0,
      aspectRatio: 1.0,
      tileRadius: 8.0,
      tileColor: FlutterFlowTheme.of(context).secondaryBackground,
    );
  }
}
