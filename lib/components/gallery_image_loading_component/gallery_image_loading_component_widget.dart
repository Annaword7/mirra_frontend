import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/skeleton_grid.dart';
import 'package:flutter/material.dart';
import 'gallery_image_loading_component_model.dart';
export 'gallery_image_loading_component_model.dart';

class GalleryImageLoadingComponentWidget extends StatefulWidget {
  const GalleryImageLoadingComponentWidget({super.key});

  @override
  State<GalleryImageLoadingComponentWidget> createState() =>
      _GalleryImageLoadingComponentWidgetState();
}

class _GalleryImageLoadingComponentWidgetState
    extends State<GalleryImageLoadingComponentWidget> {
  late GalleryImageLoadingComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GalleryImageLoadingComponentModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SkeletonGrid(
      count: 4,
      columns: 2,
      spacing: 8.0,
      aspectRatio: 1.0,
      tileRadius: 16.0,
    );
  }
}
