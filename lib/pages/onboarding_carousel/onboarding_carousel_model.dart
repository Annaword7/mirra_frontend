import '/flutter_flow/flutter_flow_util.dart';
import 'onboarding_carousel_widget.dart' show OnboardingCarouselWidget;
import 'package:flutter/material.dart';

class OnboardingCarouselModel
    extends FlutterFlowModel<OnboardingCarouselWidget> {
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    pageViewController?.dispose();
  }
}
