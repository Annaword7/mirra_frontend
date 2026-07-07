import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'routine_calendar_widget.dart' show RoutineCalendarWidget;
import 'package:flutter/material.dart';

class RoutineCalendarModel extends FlutterFlowModel<RoutineCalendarWidget> {
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
