import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item_card/imagedetailed/imagedetailed_widget.dart';
import '/item_card/ingridients/ingridients_widget.dart';
import '/item_card/parametrs/parametrs_widget.dart';
import '/item_card/personalnotes/personalnotes_widget.dart';
import '/item_card/ratingdetailed/ratingdetailed_widget.dart';
import '/item_card/sammary/sammary_widget.dart';
import '/item_card/yourrating/yourrating_widget.dart';
import '/index.dart';
import 'imagedetails_widget.dart' show ImagedetailsWidget;
import 'package:flutter/material.dart';

class ImagedetailsModel extends FlutterFlowModel<ImagedetailsWidget> {
  ///  Local state fields for this page.

  String? imageStyle = '';

  String imageSize = '1024x1024';

  List<String> albumsselected2 = [];
  void addToAlbumsselected2(String item) => albumsselected2.add(item);
  void removeFromAlbumsselected2(String item) => albumsselected2.remove(item);
  void removeAtIndexFromAlbumsselected2(int index) =>
      albumsselected2.removeAt(index);
  void insertAtIndexInAlbumsselected2(int index, String item) =>
      albumsselected2.insert(index, item);
  void updateAlbumsselected2AtIndex(int index, Function(String) updateFn) =>
      albumsselected2[index] = updateFn(albumsselected2[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in imagedetails widget.
  List<ImagesAlbumsConnectionRow>? albumsalreadyadded2;
  // Model for imagedetailed component.
  late ImagedetailedModel imagedetailedModel;
  // Model for ratingdetailed component.
  late RatingdetailedModel ratingdetailedModel;
  // Model for ingridients component.
  late IngridientsModel ingridientsModel;
  // Model for yourrating component.
  late YourratingModel yourratingModel;
  // Model for personalnotes component.
  late PersonalnotesModel personalnotesModel;
  // Model for sammary component.
  late SammaryModel sammaryModel;
  // Model for Parametrs component.
  late ParametrsModel parametrsModel;
  // Model for navbar component.
  late NavbarModel navbarModel;
  // Stores action output result for [Backend Call - Query Rows] action in IconButton widget.
  List<AlbumRow>? albums;

  @override
  void initState(BuildContext context) {
    imagedetailedModel = createModel(context, () => ImagedetailedModel());
    ratingdetailedModel = createModel(context, () => RatingdetailedModel());
    ingridientsModel = createModel(context, () => IngridientsModel());
    yourratingModel = createModel(context, () => YourratingModel());
    personalnotesModel = createModel(context, () => PersonalnotesModel());
    sammaryModel = createModel(context, () => SammaryModel());
    parametrsModel = createModel(context, () => ParametrsModel());
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    imagedetailedModel.dispose();
    ratingdetailedModel.dispose();
    ingridientsModel.dispose();
    yourratingModel.dispose();
    personalnotesModel.dispose();
    sammaryModel.dispose();
    parametrsModel.dispose();
    navbarModel.dispose();
  }
}
