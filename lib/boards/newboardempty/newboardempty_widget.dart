import '/components/new_album/new_album_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final primary = FlutterFlowTheme.of(context).primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withOpacity(0.06),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withOpacity(0.11),
                    ),
                  ),
                  Icon(
                    Icons.collections_bookmark_outlined,
                    size: 48,
                    color: primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              FFLocalizations.of(context).getText(
                '95giorwg' /* Your collections */,
              ),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily:
                        FlutterFlowTheme.of(context).headlineMediumFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              FFLocalizations.of(context).getText(
                'd37etdgk' /* Save favourites, build routines, share your picks */,
              ),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily:
                        FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: FFLocalizations.of(context).getText(
                'o1bipgy8' /* Create collection */,
              ),
              icon: Icons.add,
              onPressed: () async {
                await showModalBottomSheet(
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
