import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'log_in_page_widget.dart' show LogInPageWidget;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class LogInPageModel extends FlutterFlowModel<LogInPageWidget> {
  ///  State fields for stateful widgets in this page.

  // ── Login tab ────────────────────────────────────────────────────────────
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  // ── Register tab ─────────────────────────────────────────────────────────
  final formKeyRegister = GlobalKey<FormState>();

  FocusNode? emailRegisterFocusNode;
  TextEditingController? emailRegisterTextController;
  String? Function(BuildContext, String?)? emailRegisterTextControllerValidator;
  String? _emailRegisterValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText('yktrgba2' /* Enter valid email */);
    }
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  FocusNode? passwordRegisterFocusNode;
  TextEditingController? passwordRegisterTextController;
  late bool passwordRegisterVisibility;
  String? Function(BuildContext, String?)? passwordRegisterTextControllerValidator;
  String? _passwordRegisterValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText('pw6ghio3' /* Enter valid password */);
    }
    if (val.length < 5) {
      return FFLocalizations.of(context).getText('eeqs1ag8' /* The password must be at least ... */);
    }
    return null;
  }

  // ── Carousel (shared) ────────────────────────────────────────────────────
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 1;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    passwordRegisterVisibility = false;
    emailRegisterTextControllerValidator = _emailRegisterValidator;
    passwordRegisterTextControllerValidator = _passwordRegisterValidator;
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    emailRegisterFocusNode?.dispose();
    emailRegisterTextController?.dispose();
    passwordRegisterFocusNode?.dispose();
    passwordRegisterTextController?.dispose();
  }
}
