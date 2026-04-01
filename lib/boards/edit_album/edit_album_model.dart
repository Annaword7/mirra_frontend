import '/flutter_flow/flutter_flow_util.dart';
import 'edit_album_widget.dart' show EditAlbumWidget;
import 'package:flutter/material.dart';

class EditAlbumModel extends FlutterFlowModel<EditAlbumWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for folderTitle widget.
  FocusNode? folderTitleFocusNode;
  TextEditingController? folderTitleTextController;
  String? Function(BuildContext, String?)? folderTitleTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    folderTitleFocusNode?.dispose();
    folderTitleTextController?.dispose();
  }
}
