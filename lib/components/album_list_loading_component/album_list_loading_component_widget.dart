import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/skeleton_grid.dart';
import 'package:flutter/material.dart';
import 'album_list_loading_component_model.dart';
export 'album_list_loading_component_model.dart';

class AlbumListLoadingComponentWidget extends StatefulWidget {
  const AlbumListLoadingComponentWidget({super.key});

  @override
  State<AlbumListLoadingComponentWidget> createState() =>
      _AlbumListLoadingComponentWidgetState();
}

class _AlbumListLoadingComponentWidgetState
    extends State<AlbumListLoadingComponentWidget> {
  late AlbumListLoadingComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlbumListLoadingComponentModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 8 album-cover cards in a 2-column grid; each card is a 2×2 skeleton mosaic.
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.0,
      ),
      itemCount: 8,
      itemBuilder: (context, i) => Container(
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
      ),
    );
  }
}
