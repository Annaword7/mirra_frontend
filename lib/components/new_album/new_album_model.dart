import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'new_album_widget.dart' show NewAlbumWidget;
import 'package:flutter/material.dart';

class NewAlbumModel extends FlutterFlowModel<NewAlbumWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for Albumname widget.
  FocusNode? albumnameFocusNode;
  TextEditingController? albumnameTextController;
  String? Function(BuildContext, String?)? albumnameTextControllerValidator;
  String? _albumnameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        '5t47wlr7' /* Title is required. */,
      );
    }

    return null;
  }

  // Stores action output result for [Backend Call - Insert Row] action in Annual widget.
  AlbumRow? album;

  @override
  void initState(BuildContext context) {
    albumnameTextControllerValidator = _albumnameTextControllerValidator;
  }

  @override
  void dispose() {
    albumnameFocusNode?.dispose();
    albumnameTextController?.dispose();
  }
}
