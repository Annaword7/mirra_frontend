import '/flutter_flow/flutter_flow_util.dart';
import 'leave_review_widget.dart' show LeaveReviewWidget;
import 'package:flutter/material.dart';

class LeaveReviewModel extends FlutterFlowModel<LeaveReviewWidget> {
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
