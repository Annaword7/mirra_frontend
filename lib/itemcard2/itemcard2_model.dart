import '/backend/supabase/database/tables/product_prices.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item_card/ingridients/ingridients_widget.dart';
import '/index.dart';
import 'itemcard2_widget.dart' show Itemcard2Widget;
import 'package:flutter/material.dart';

class Itemcard2Model extends FlutterFlowModel<Itemcard2Widget> {
  ///  Local state fields for this page.

  bool loading = true;

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
  // Stores action output result for [Backend Call - Query Rows] action in Row widget.
  List<AlbumRow>? albums;
  // Price data from product_prices table for this product × user's country.
  ProductPricesRow? priceRow;
  // Skin type from the user's onboarding profile (null = cold start).
  // Default viewing context for the fit card; matrix taps never write it back.
  String? userSkinType;
  // Sensitivity / acne flags from onboarding — let the card surface warnings
  // addressed to 'sensitive' / 'acne_prone' regardless of the selected row.
  bool userIsSensitive = false;
  bool userIsAcneProne = false;

  @override
  void initState(BuildContext context) {
    ingridientsModel = createModel(context, () => IngridientsModel());
  }

  @override
  void dispose() {
    ingridientsModel.dispose();
  }
}
