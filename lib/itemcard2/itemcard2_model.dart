import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item_card/ingridients/ingridients_widget.dart';
import '/index.dart';
import 'itemcard2_widget.dart' show Itemcard2Widget;
import 'package:flutter/material.dart';

class Itemcard2Model extends FlutterFlowModel<Itemcard2Widget> {
  ///  Local state fields for this page.

  bool loading = true;

  int? overallscore;

  bool optiondropdownopen = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in itemcard2 widget.
  List<ImagesRow>? imageraw;
  // Stores action output result for [Backend Call - Query Rows] action in itemcard2 widget.
  List<ImageSkinCompatibilityRow>? skinCompabilityRaw;
  // Stores action output result for [Backend Call - Query Rows] action in itemcard2 widget.
  List<ImageTopIngredientsRow>? topIngredientsRaw;
  // Stores action output result for [Backend Call - Query Rows] action in itemcard2 widget.
  List<ImageIngredientIssuesRow>? ingredientIssuesRaw;
  // Model for ingridients component.
  late IngridientsModel ingridientsModel;
  // Stores action output result for [Backend Call - API (feedback NEW BCND)] action in Container widget.
  ApiCallResponse? apiResult6oo;
  // Stores action output result for [Backend Call - API (feedback NEW BCND)] action in Container widget.
  ApiCallResponse? apiResult6oo8;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - Query Rows] action in Row widget.
  List<AlbumRow>? albums;

  @override
  void initState(BuildContext context) {
    ingridientsModel = createModel(context, () => IngridientsModel());
  }

  @override
  void dispose() {
    ingridientsModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
