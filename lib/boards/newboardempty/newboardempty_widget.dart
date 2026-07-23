import '/components/new_album/new_album_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/mirra_empty_state.dart';
import 'package:flutter/material.dart';
import 'newboardempty_model.dart';
export 'newboardempty_model.dart';

class NewboardemptyWidget extends StatefulWidget {
  const NewboardemptyWidget({super.key, this.onBoardCreated});

  final VoidCallback? onBoardCreated;

  @override
  State<NewboardemptyWidget> createState() => _NewboardemptyWidgetState();
}

class _NewboardemptyWidgetState extends State<NewboardemptyWidget> {
  late NewboardemptyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewboardemptyModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  void _openNewAlbum() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: NewAlbumWidget(),
        );
      },
    ).then((value) {
      safeSetState(() {});
      widget.onBoardCreated?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MirraEmptyState(
      icon: Icons.collections_bookmark_outlined,
      headline: FFLocalizations.of(context).getText(
        '95giorwg' /* Your collections */,
      ),
      body: FFLocalizations.of(context).getText(
        'd37etdgk' /* Save favourites, build routines, share your picks */,
      ),
      ctaLabel: FFLocalizations.of(context).getText(
        'o1bipgy8' /* Create collection */,
      ),
      ctaIcon: Icons.add,
      onCta: _openNewAlbum,
    );
  }
}
