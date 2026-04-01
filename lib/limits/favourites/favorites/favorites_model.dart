import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'favorites_widget.dart' show FavoritesWidget;
import 'package:flutter/material.dart';

class FavoritesModel extends FlutterFlowModel<FavoritesWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Favorites widget.
  List<UsersRow>? userrow;
  // Model for navbar component.
  late NavbarModel navbarModel1;
  // Model for navbar component.
  late NavbarModel navbarModel2;

  @override
  void initState(BuildContext context) {
    navbarModel1 = createModel(context, () => NavbarModel());
    navbarModel2 = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel1.dispose();
    navbarModel2.dispose();
  }
}
