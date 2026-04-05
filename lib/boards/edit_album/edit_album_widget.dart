import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'edit_album_model.dart';
export 'edit_album_model.dart';

class EditAlbumWidget extends StatefulWidget {
  const EditAlbumWidget({
    super.key,
    required this.albumRef,
  });

  final String? albumRef;

  @override
  State<EditAlbumWidget> createState() => _EditAlbumWidgetState();
}

class _EditAlbumWidgetState extends State<EditAlbumWidget> {
  late EditAlbumModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditAlbumModel());
    _model.folderTitleFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _confirmDeleteAlbum() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          FFLocalizations.of(context).getText('fr6pjcbf_del_title' /* Delete board? */),
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: FlutterFlowTheme.of(context).headlineSmallFamily,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).headlineSmallIsCustom,
              ),
        ),
        content: Text(
          FFLocalizations.of(context).getText('fr6pjcbf_del_body' /* All products in this board will also be deleted. */),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              FFLocalizations.of(context).getText('ood20cri' /* Cancel */),
              style: TextStyle(
                  color: FlutterFlowTheme.of(context).secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AlbumTable().delete(
        matchingRows: (rows) => rows.eqOrNull('id', widget.albumRef),
      );
      context.safePop();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 100.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).info,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                child: Text(
                  FFLocalizations.of(context).getText('fr6pjcbf' /* Edit board details */),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: FlutterFlowTheme.of(context)
                            .headlineSmallFamily,
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !FlutterFlowTheme.of(context)
                            .headlineSmallIsCustom,
                      ),
                ),
              ),
              Form(
                key: _model.formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: FutureBuilder<List<AlbumRow>>(
                  future: AlbumTable().querySingleRow(
                    queryFn: (q) =>
                        q.eqOrNull('id', widget.albumRef),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      );
                    }
                    final columnAlbumRow = snapshot.data!.isNotEmpty
                        ? snapshot.data!.first
                        : null;

                    return Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 0.0),
                      child: TextFormField(
                        controller: _model.folderTitleTextController ??=
                            TextEditingController(
                          text: columnAlbumRow?.name,
                        ),
                        focusNode: _model.folderTitleFocusNode,
                        autofocus: false,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: FFLocalizations.of(context)
                              .getText('cfmx4p6n' /* Title */),
                          hintStyle: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).info,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context).info,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FlutterFlowTheme.of(context)
                                  .bodyMediumFamily,
                              color:
                                  FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                        cursorColor: FlutterFlowTheme.of(context).primary,
                        validator: _model
                            .folderTitleTextControllerValidator
                            .asValidator(context),
                        inputFormatters: [
                          if (!isAndroid && !isiOS)
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              return TextEditingValue(
                                selection: newValue.selection,
                                text: newValue.text.toCapitalization(
                                    TextCapitalization.words),
                              );
                            }),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10.0),

              // Save button — always visible
              FFButtonWidget(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  FocusScope.of(context).unfocus();
                  if (_model.formKey.currentState == null ||
                      !_model.formKey.currentState!.validate()) {
                    return;
                  }
                  await AlbumTable().update(
                    data: {'name': _model.folderTitleTextController.text},
                    matchingRows: (rows) =>
                        rows.eqOrNull('id', widget.albumRef),
                  );
                  Navigator.pop(context);
                },
                text: FFLocalizations.of(context)
                    .getText('ifhesf3b' /* Save Changes */),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 55.0,
                  padding: EdgeInsets.zero,
                  iconPadding: EdgeInsets.zero,
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle:
                      FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: FlutterFlowTheme.of(context)
                                .titleSmallFamily,
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleSmallIsCustom,
                          ),
                  elevation: 0.0,
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),

              // Delete button
              FFButtonWidget(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await _confirmDeleteAlbum();
                },
                text: FFLocalizations.of(context).getText('aqmuxxl3' /* Delete */),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 55.0,
                  padding: EdgeInsets.zero,
                  iconPadding: EdgeInsets.zero,
                  color: FlutterFlowTheme.of(context).tertiary,
                  textStyle:
                      FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: FlutterFlowTheme.of(context)
                                .titleSmallFamily,
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleSmallIsCustom,
                          ),
                  elevation: 0.0,
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ].divide(const SizedBox(height: 10.0)),
          ),
        ),
      ),
    );
  }
}
