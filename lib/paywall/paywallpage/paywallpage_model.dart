import '/backend/api_requests/api_calls.dart';
import '/components/premium_features_list/premium_features_list_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'paywallpage_widget.dart' show PaywallpageWidget;
import 'package:flutter/material.dart';

class PaywallpageModel extends FlutterFlowModel<PaywallpageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for premiumFeaturesList component.
  late PremiumFeaturesListModel premiumFeaturesListModel;
  // Stores action output result for [Custom Action - rcEnsureLogin] action in Button widget.
  String? rCUserID;
  // Stores action output result for [Custom Action - rcPurchasePackage] action in Button widget.
  dynamic rCPayment;
  // Stores action output result for [Custom Action - rcRefreshEntitlement] action in Button widget.
  bool? rcRefreshEntitlement;
  // Stores action output result for [Backend Call - API (Telegrammessege)] action in Button widget.
  ApiCallResponse? subscriptionmonth;
  // Stores action output result for [Custom Action - rcEnsureLogin] action in Annual widget.
  String? rCUserID2;
  // Stores action output result for [Custom Action - rcPurchasePackage] action in Annual widget.
  dynamic rCPayment2;
  // Stores action output result for [Custom Action - rcRefreshEntitlement] action in Annual widget.
  bool? rcRefreshEntitlement2;
  // Stores action output result for [Backend Call - API (Telegrammessege)] action in Annual widget.
  ApiCallResponse? yearsubscription;
  // Stores action output result for [Custom Action - rcEnsureLogin] action in Text widget.
  String? rCUserID3;

  @override
  void initState(BuildContext context) {
    premiumFeaturesListModel =
        createModel(context, () => PremiumFeaturesListModel());
  }

  @override
  void dispose() {
    premiumFeaturesListModel.dispose();
  }
}
