import 'dart:async';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'albumslist_model.dart';
export 'albumslist_model.dart';

class AlbumslistWidget extends StatefulWidget {
  const AlbumslistWidget({
    super.key,
    required this.imageID,
    required this.albums,
  });

  final int? imageID;
  final List<AlbumRow> albums;

  @override
  State<AlbumslistWidget> createState() => _AlbumslistWidgetState();
}

class _AlbumslistWidgetState extends State<AlbumslistWidget> {
  late AlbumslistModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlbumslistModel());

    // Load already-added albums to pre-select them
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.albumsalreadyadded2 =
          await ImagesAlbumsConnectionTable().queryRows(
        queryFn: (q) => q.eqOrNull('image_id', widget.imageID),
      );
      _model.albumsselected2 = functions
          .albumidsToList(_model.albumsalreadyadded2?.toList())!
          .toList()
          .cast<String>();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MirraBottomSheet(
      crossAxisAlignment: CrossAxisAlignment.center,
      addBottomInset: false,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                FFLocalizations.of(context).getText('2swgqgrb'),
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            // Album list (pre-fetched, no FutureBuilder)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.albums.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final album = widget.albums[index];
                  final selected =
                      _model.albumsselected2.contains(album.id);
                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      selected
                          ? _model.removeFromAlbumsselected2(album.id)
                          : _model.addToAlbumsselected2(album.id);
                      safeSetState(() {});
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      height: 52.0,
                      decoration: BoxDecoration(
                        color:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: selected
                              ? FlutterFlowTheme.of(context).primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                valueOrDefault<String>(album.name, 'Untitled'),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: selected
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context).secondaryText,
                              size: 22.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Apply button
            AppButton(
              label: FFLocalizations.of(context).getText('n2ylozbe'),
              onPressed: () async {
                await LinkitemtoalbumsCall.call(
                  token: currentJwtToken,
                  imageId: widget.imageID,
                  albumIdsList: _model.albumsselected2,
                );
                unawaited(AnalyticsService.instance
                    .trackProductAddedToBoard(imageId: widget.imageID ?? 0));
                HapticFeedback.vibrate();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
    );
  }
}
