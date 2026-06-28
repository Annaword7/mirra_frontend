import '/flutter_flow/flutter_flow_util.dart';
import 'onboarding_quiz_widget.dart' show OnboardingQuizWidget;
import 'package:flutter/material.dart';

class OnboardingQuizModel extends FlutterFlowModel<OnboardingQuizWidget> {
  // Optional block — favorite brands free-text input.
  FocusNode? brandsFocusNode;
  TextEditingController? brandsTextController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    brandsFocusNode?.dispose();
    brandsTextController?.dispose();
  }
}
