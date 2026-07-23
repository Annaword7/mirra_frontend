import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/skeleton_grid.dart';
import 'package:flutter/material.dart';
import 'gallery_loading_component_model.dart';
export 'gallery_loading_component_model.dart';

class GalleryLoadingComponentWidget extends StatefulWidget {
  const GalleryLoadingComponentWidget({super.key});

  @override
  State<GalleryLoadingComponentWidget> createState() =>
      _GalleryLoadingComponentWidgetState();
}

class _GalleryLoadingComponentWidgetState
    extends State<GalleryLoadingComponentWidget> {
  late GalleryLoadingComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GalleryLoadingComponentModel());
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
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: SkeletonGrid(
          count: 4,
          columns: 2,
          spacing: 8.0,
          aspectRatio: 1.0,
          tileRadius: 8.0,
        ),
      ),
    );
  }
}
