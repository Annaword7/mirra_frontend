import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'toprated_widget.dart' show TopratedWidget;
import 'package:flutter/material.dart';

class TopratedModel extends FlutterFlowModel<TopratedWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Toprated widget.
  List<UsersRow>? userrow;
  // Stores action output result for [Backend Call - Query Rows] action in Toprated widget.
  List<UsersRow>? usersanswer2;
  // State field(s) for ListView widget.
  ScrollController? listViewController;
  // State field(s) for StaggeredView widget.
  ScrollController? staggeredViewController;
  // Model for navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    listViewController = ScrollController();
    staggeredViewController = ScrollController();
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    listViewController?.dispose();
    staggeredViewController?.dispose();
    navbarModel.dispose();
  }
}
