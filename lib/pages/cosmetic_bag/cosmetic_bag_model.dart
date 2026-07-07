import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'cosmetic_bag_widget.dart' show CosmeticBagWidget;
import 'package:flutter/material.dart';

class CosmeticBagModel extends FlutterFlowModel<CosmeticBagWidget> {
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();
  }
}
