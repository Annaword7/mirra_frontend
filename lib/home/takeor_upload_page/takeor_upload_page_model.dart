import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'takeor_upload_page_widget.dart' show TakeorUploadPageWidget;
import 'package:flutter/material.dart';

class TakeorUploadPageModel extends FlutterFlowModel<TakeorUploadPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in TakeorUploadPage widget.
  List<UsersRow>? useranalyspage;
  // Stores action output result for [Backend Call - Query Rows] action in TakeorUploadPage widget.
  List<CountriesRow>? countriesRaw;
  // Stores action output result for [Backend Call - API (subscriptioncheck  NEW BCND)] action in Button widget.
  ApiCallResponse? checkifallowedCamera;
  bool isDataUploading_uploadImageSupabaseCamera = false;
  FFUploadedFile uploadedLocalFile_uploadImageSupabaseCamera =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadImageSupabaseCamera = '';

  // Stores action output result for [Backend Call - API (extractproductinfo NEW BCND Copy)] action in Button widget.
  ApiCallResponse? extractedproductcamera;
  // Stores action output result for [Backend Call - API (searchingredients NEW BCND)] action in Button widget.
  ApiCallResponse? analyseImageProductNameCamera;
  // Stores action output result for [Backend Call - API (scientificanalysis NEW BCND)] action in Button widget.
  ApiCallResponse? scientificanalysresultgalary;
  // Stores action output result for [Backend Call - API (subscriptioncheck  NEW BCND)] action in Button widget.
  ApiCallResponse? checkifallowedGalarry;
  bool isDataUploading_uploadImageSupabaseGallary = false;
  FFUploadedFile uploadedLocalFile_uploadImageSupabaseGallary =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadImageSupabaseGallary = '';

  // Stores action output result for [Backend Call - API (extractproductinfo NEW BCND Copy)] action in Button widget.
  ApiCallResponse? extractedproductGalary;
  // Stores action output result for [Backend Call - API (searchingredients NEW BCND)] action in Button widget.
  ApiCallResponse? analyseImageProductName;
  // Stores action output result for [Backend Call - API (scientificanalysis NEW BCND)] action in Button widget.
  ApiCallResponse? scientificanalysresultcamara;
  // Model for navbar component.
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
