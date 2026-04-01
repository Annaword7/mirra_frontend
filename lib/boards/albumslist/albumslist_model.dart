import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'albumslist_widget.dart' show AlbumslistWidget;
import 'package:flutter/material.dart';

class AlbumslistModel extends FlutterFlowModel<AlbumslistWidget> {
  ///  Local state fields for this component.

  List<String> albumsselected2 = [];
  void addToAlbumsselected2(String item) => albumsselected2.add(item);
  void removeFromAlbumsselected2(String item) => albumsselected2.remove(item);
  void removeAtIndexFromAlbumsselected2(int index) =>
      albumsselected2.removeAt(index);
  void insertAtIndexInAlbumsselected2(int index, String item) =>
      albumsselected2.insert(index, item);
  void updateAlbumsselected2AtIndex(int index, Function(String) updateFn) =>
      albumsselected2[index] = updateFn(albumsselected2[index]);

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Query Rows] action in albumslist widget.
  List<ImagesAlbumsConnectionRow>? albumsalreadyadded2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
