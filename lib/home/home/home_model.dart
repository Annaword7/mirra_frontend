import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  Local state fields for this page.

  bool searchActive = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Home widget.
  List<UsersRow>? usersanswer;
  // Stores action output result for [Backend Call - Query Rows] action in Home widget.
  List<CountriesRow>? countrieshome;
  // Model for navbar component.
  late NavbarModel navbarModel;

  // Cached future for images — store so FutureBuilder doesn't re-fetch on every rebuild,
  // but can be explicitly refreshed by reassigning.
  Future<List<ImagesRow>>? imagesFuture;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();
  }
}
