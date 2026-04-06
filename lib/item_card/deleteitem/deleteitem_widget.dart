import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'deleteitem_model.dart';
export 'deleteitem_model.dart';

/// Create a popup for item deleting confirmation
class DeleteitemWidget extends StatefulWidget {
  const DeleteitemWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  @override
  State<DeleteitemWidget> createState() => _DeleteitemWidgetState();
}

class _DeleteitemWidgetState extends State<DeleteitemWidget> {
  late DeleteitemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeleteitemModel());
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
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24.0,
                  color: Color(0x1A000000),
                  offset: Offset(0.0, 8.0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trash icon
                  Container(
                    width: 52.0,
                    height: 52.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFD32F2F),
                      size: 26.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Title
                  Text(
                    FFLocalizations.of(context).getText('ww2bynjy'),
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).headlineSmallFamily,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .headlineSmallIsCustom,
                        ),
                  ),
                  const SizedBox(height: 8.0),

                  // Subtitle
                  Text(
                    FFLocalizations.of(context).getText('ejy0zcsp'),
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .bodyMediumIsCustom,
                        ),
                  ),
                  const SizedBox(height: 24.0),

                  // Delete button (primary destructive)
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ImagesTable().delete(
                          matchingRows: (rows) => rows.eqOrNull(
                            'id',
                            widget.imageid,
                          ),
                        );
                        if (context.mounted) {
                          context.go(HomeWidget.routePath);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: Text(
                        FFLocalizations.of(context).getText('y814btsy'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Cancel button (ghost)
                  SizedBox(
                    width: double.infinity,
                    height: 44.0,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            FlutterFlowTheme.of(context).secondaryText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: Text(
                        FFLocalizations.of(context).getText('ood20cri'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
