import 'dart:async';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/analytics_service.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/analysis_loading/analysis_loading_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/components/out_of_generations/out_of_generations_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/limits/limit_out/limit_out_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'takeor_upload_page_model.dart';
export 'takeor_upload_page_model.dart';

class TakeorUploadPageWidget extends StatefulWidget {
  const TakeorUploadPageWidget({super.key});

  static String routeName = 'TakeorUploadPage';
  static String routePath = '/takeorUploadPage';

  @override
  State<TakeorUploadPageWidget> createState() => _TakeorUploadPageWidgetState();
}

class _TakeorUploadPageWidgetState extends State<TakeorUploadPageWidget>
    with TickerProviderStateMixin {
  late TakeorUploadPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hintExpanded = false;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TakeorUploadPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.useranalyspage = await UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          currentUserUid,
        ),
      );
      _model.countriesRaw = await CountriesTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          _model.useranalyspage?.firstOrNull?.countryId,
        ),
      );
    });

    animationsMap.addAll({
      'iconOnPageLoadAnimation': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 1200.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _loadHintState();
  }

  Future<void> _loadHintState() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hint_upload_seen') ?? false;
    if (!seen) {
      await prefs.setBool('hint_upload_seen', true);
      if (mounted) setState(() => _hintExpanded = true);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildCameraButton(BuildContext context) {
    return FFButtonWidget(
      onPressed: () async {
        var _shouldSetState = false;
        _model.checkifallowedCamera =
            await SubscriptioncheckNEWBCNDCall.call(
          host: FFDevEnvironmentValues().backendhost,
          userId: currentUserUid,
        );

        _shouldSetState = true;
        if (SubscriptioncheckNEWBCNDCall.allowed(
          (_model.checkifallowedCamera?.jsonBody ?? ''),
        )!) {
          final selectedMedia = await selectMedia(
            storageFolderPath: 'users_images',
            multiImage: false,
          );
          if (selectedMedia != null &&
              selectedMedia.every((m) =>
                  validateFileFormat(m.storagePath, context))) {
            safeSetState(() =>
                _model.isDataUploading_uploadImageSupabaseCamera = true);
            var selectedUploadedFiles = <FFUploadedFile>[];

            var downloadUrls = <String>[];
            try {
              selectedUploadedFiles = selectedMedia
                  .map((m) => FFUploadedFile(
                        name: m.storagePath.split('/').last,
                        bytes: m.bytes,
                        height: m.dimensions?.height,
                        width: m.dimensions?.width,
                        blurHash: m.blurHash,
                        originalFilename: m.originalFilename,
                      ))
                  .toList();

              downloadUrls = await uploadSupabaseStorageFiles(
                bucketName: 'images',
                selectedFiles: selectedMedia,
              );
            } finally {
              _model.isDataUploading_uploadImageSupabaseCamera = false;
            }
            if (selectedUploadedFiles.length == selectedMedia.length &&
                downloadUrls.length == selectedMedia.length) {
              safeSetState(() {
                _model.uploadedLocalFile_uploadImageSupabaseCamera =
                    selectedUploadedFiles.first;
                _model.uploadedFileUrl_uploadImageSupabaseCamera =
                    downloadUrls.first;
              });
            } else {
              safeSetState(() {});
              return;
            }
          } else {
            // User cancelled picker or invalid format — don't proceed
            if (_shouldSetState) safeSetState(() {});
            return;
          }

          unawaited(AnalyticsService.instance.trackAnalysisStarted(source: 'camera'));
          FFAppState().analysisloading = true;
          FFAppState().extractedProductName = '';
          FFAppState().extractedBrand = '';
          safeSetState(() {});
          if (_model.uploadedFileUrl_uploadImageSupabaseCamera != '') {
            FFAppState().uploadedimageurl =
                _model.uploadedFileUrl_uploadImageSupabaseCamera;
            FFAppState().uploudedimagepath =
                _model.uploadedFileUrl_uploadImageSupabaseCamera;
            FFAppState().Producanalysstate = 1;
            safeSetState(() {});
            _model.extractedproductcamera =
                await ExtractproductinfoNEWBCNDCopyCall.call(
              host: FFDevEnvironmentValues().backendhost,
              imageUrl: _model.uploadedFileUrl_uploadImageSupabaseCamera,
              userId: currentUserUid,
              languageCode: FFLocalizations.of(context).languageCode,
              country: FFAppState().countrycode,
            );

            _shouldSetState = true;
            if ((_model.extractedproductcamera?.succeeded ?? true)) {
              FFAppState().Producanalysstate = 2;
              FFAppState().extractedProductName =
                  ExtractproductinfoNEWBCNDCopyCall.name(
                        (_model.extractedproductcamera?.jsonBody ?? ''),
                      ) ??
                      '';
              FFAppState().extractedBrand =
                  ExtractproductinfoNEWBCNDCopyCall.brand(
                        (_model.extractedproductcamera?.jsonBody ?? ''),
                      ) ??
                      '';
              safeSetState(() {});
              _model.analyseImageProductNameCamera =
                  await SearchingredientsNEWBCNDCall.call(
                host: FFDevEnvironmentValues().backendhost,
                imageId: ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                  (_model.extractedproductcamera?.jsonBody ?? ''),
                )?.toString(),
                productName: ExtractproductinfoNEWBCNDCopyCall.name(
                  (_model.extractedproductcamera?.jsonBody ?? ''),
                ),
                brand: ExtractproductinfoNEWBCNDCopyCall.brand(
                  (_model.extractedproductcamera?.jsonBody ?? ''),
                ),
                country: _model.countriesRaw
                    ?.where((e) =>
                        e.id ==
                        _model.useranalyspage?.firstOrNull?.countryId)
                    .toList()
                    .firstOrNull
                    ?.code,
              );

              _shouldSetState = true;
            } else {
              await TelegrammessegeCall.call(
                messega:
                    '${_model.uploadedFileUrl_uploadImageSupabaseCamera}на этапе extract product info, camera',
                email: 'from mobile app',
                form: 'tech message',
              );

              await showDialog(
                context: context,
                builder: (alertDialogContext) {
                  return AlertDialog(
                    title: Text('Error!'),
                    content: Text('Product not found, data error'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext),
                        child: Text('Ok'),
                      ),
                    ],
                  );
                },
              );
              FFAppState().uploadedimageurl = '';
              FFAppState().analysisloading = false;
              safeSetState(() {});
              await ImagesTable().delete(
                matchingRows: (rows) => rows.eqOrNull(
                  'id',
                  ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                    (_model.extractedproductcamera?.jsonBody ?? ''),
                  ),
                ),
              );
              if (_shouldSetState) safeSetState(() {});
              return;
            }

            if ((_model.analyseImageProductNameCamera?.statusCode ??
                    200) ==
                200) {
              FFAppState().Producanalysstate = 3;
              safeSetState(() {});
              _model.scientificanalysresultgalary =
                  await ScientificanalysisNEWBCNDCall.call(
                host: FFDevEnvironmentValues().backendhost,
                imageId: ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                  (_model.extractedproductcamera?.jsonBody ?? ''),
                )?.toString(),
                userId: currentUserUid,
                languageCode: ExtractproductinfoNEWBCNDCopyCall.langcode(
                  (_model.extractedproductcamera?.jsonBody ?? ''),
                ),
              );

              _shouldSetState = true;
              if ((_model.scientificanalysresultgalary?.succeeded ??
                  true)) {
                context.pushNamed(
                  Itemcard2Widget.routeName,
                  queryParameters: {
                    'imageid': serializeParam(
                      ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                        (_model.extractedproductcamera?.jsonBody ?? ''),
                      ),
                      ParamType.int,
                    ),
                  }.withoutNulls,
                );

                FFAppState().uploadedimageurl = '';
                FFAppState().analysisloading = false;
                FFAppState().Producanalysstate = 0;
                safeSetState(() {});
              } else {
                final _cameraScientificStatusCode =
                    _model.scientificanalysresultgalary?.statusCode ?? 0;
                if (_cameraScientificStatusCode == 422) {
                  await showDialog(
                    context: context,
                    builder: (alertDialogContext) {
                      return AlertDialog(
                        title: Text(FFLocalizations.of(context)
                            .getText('nnsq0kj5')),
                        content: Text(FFLocalizations.of(context)
                            .getText('48je50c9')),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(alertDialogContext),
                            child: Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  await TelegrammessegeCall.call(
                    messega:
                        '${_model.uploadedFileUrl_uploadImageSupabaseCamera} на этапе scientific research, camera',
                    email: 'from mobile app',
                    form: 'tech message',
                  );

                  await showDialog(
                    context: context,
                    builder: (alertDialogContext) {
                      return AlertDialog(
                        title: Text('Error!'),
                        content: Text('Product not found, data error'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(alertDialogContext),
                            child: Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                }
                FFAppState().uploadedimageurl = '';
                FFAppState().analysisloading = false;
                FFAppState().Producanalysstate = 0;
                safeSetState(() {});
                await ImagesTable().delete(
                  matchingRows: (rows) => rows.eqOrNull(
                    'id',
                    ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                      (_model.extractedproductcamera?.jsonBody ?? ''),
                    ),
                  ),
                );
                if (_shouldSetState) safeSetState(() {});
                return;
              }
            } else {
              if ((_model.analyseImageProductNameCamera?.statusCode ??
                      200) ==
                  400) {
                await showDialog(
                  context: context,
                  builder: (alertDialogContext) {
                    return AlertDialog(
                      title: Text('Error!'),
                      content: Text('Product not found, data error'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(alertDialogContext),
                          child: Text('Ok'),
                        ),
                      ],
                    );
                  },
                );
                await ImagesTable().delete(
                  matchingRows: (rows) => rows.eqOrNull(
                    'id',
                    ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                      (_model.extractedproductcamera?.jsonBody ?? ''),
                    ),
                  ),
                );
                FFAppState().uploadedimageurl = '';
                FFAppState().analysisloading = false;
                FFAppState().Producanalysstate = 0;
                safeSetState(() {});
              } else {
                if ((_model.analyseImageProductNameCamera?.statusCode ??
                        200) ==
                    429) {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    context: context,
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: LimitOutWidget(
                            limit: SearchingredientsNEWBCNDCall.limit(
                              (_model.analyseImageProductNameCamera
                                      ?.jsonBody ??
                                  ''),
                            )!,
                            date: SearchingredientsNEWBCNDCall.resettime(
                              (_model.analyseImageProductNameCamera
                                      ?.jsonBody ??
                                  ''),
                            )!,
                            isPro: FFAppState().isprouser,
                          ),
                        ),
                      );
                    },
                  ).then((value) => safeSetState(() {}));

                  await ImagesTable().delete(
                    matchingRows: (rows) => rows.eqOrNull(
                      'id',
                      ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                        (_model.extractedproductcamera?.jsonBody ?? ''),
                      ),
                    ),
                  );
                  FFAppState().uploadedimageurl = '';
                  FFAppState().analysisloading = false;
                  FFAppState().Producanalysstate = 0;
                  safeSetState(() {});
                } else {
                  if ((_model.analyseImageProductNameCamera?.statusCode ??
                          200) ==
                      500) {
                    context.pushNamed(HomeWidget.routeName);

                    await ImagesTable().delete(
                      matchingRows: (rows) => rows.eqOrNull(
                        'id',
                        ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                          (_model.extractedproductcamera?.jsonBody ?? ''),
                        ),
                      ),
                    );
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          title: Text(SearchingredientsNEWBCNDCall.error(
                            (_model.analyseImageProductNameCamera
                                    ?.jsonBody ??
                                ''),
                          )!),
                          content:
                              Text(SearchingredientsNEWBCNDCall.details(
                            (_model.analyseImageProductNameCamera
                                    ?.jsonBody ??
                                ''),
                          )!),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext),
                              child: Text('Ok'),
                            ),
                          ],
                        );
                      },
                    );
                    safeSetState(() {});
                    FFAppState().uploadedimageurl = '';
                    FFAppState().analysisloading = false;
                    FFAppState().Producanalysstate = 0;
                    safeSetState(() {});
                  } else {
                    await TelegrammessegeCall.call(
                      messega:
                          '${_model.uploadedFileUrl_uploadImageSupabaseCamera} на этапе поиска ингредиентов, с камеры',
                      email: 'from mobile app',
                      form: 'tech message',
                    );

                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          title: Text('Error!'),
                          content: Text('Product not found, data error'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext),
                              child: Text('Ok'),
                            ),
                          ],
                        );
                      },
                    );
                    FFAppState().uploadedimageurl = '';
                    FFAppState().analysisloading = false;
                    FFAppState().Producanalysstate = 0;
                    safeSetState(() {});
                    await ImagesTable().delete(
                      matchingRows: (rows) => rows.eqOrNull(
                        'id',
                        ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                          (_model.extractedproductcamera?.jsonBody ?? ''),
                        ),
                      ),
                    );
                    if (_shouldSetState) safeSetState(() {});
                    return;
                  }
                }
              }
            }
          } else {
            FFAppState().analysisloading = false;
            safeSetState(() {});
            if (_shouldSetState) safeSetState(() {});
            return;
          }
        } else {
          await showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            enableDrag: false,
            context: context,
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Padding(
                  padding: MediaQuery.viewInsetsOf(context),
                  child: OutOfGenerationsWidget(),
                ),
              );
            },
          ).then((value) => safeSetState(() {}));

          FFAppState().uploadedimageurl = '';
          FFAppState().analysisloading = false;
          safeSetState(() {});
        }

        if (_shouldSetState) safeSetState(() {});
      },
      text: FFLocalizations.of(context).getText(
        'xirptk6c' /* Take a photo */,
      ),
      icon: Icon(
        Icons.camera_alt,
        size: 28.0,
      ),
      options: FFButtonOptions(
        width: double.infinity,
        height: 65.0,
        padding: EdgeInsets.all(8.0),
        iconPadding:
            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        iconColor: Colors.white,
        color: Color(0xD25C85D9),
        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily:
                  FlutterFlowTheme.of(context).titleMediumFamily,
              color: Colors.white,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              useGoogleFonts:
                  !FlutterFlowTheme.of(context).titleMediumIsCustom,
            ),
        elevation: 0.4,
        borderSide: BorderSide(
          color: Color(0xD15C85D9),
        ),
        borderRadius: BorderRadius.circular(36.0),
      ),
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
    return FFButtonWidget(
      onPressed: () async {
        var _shouldSetState = false;
        // Galary
        _model.checkifallowedGalarry =
            await SubscriptioncheckNEWBCNDCall.call(
          host: FFDevEnvironmentValues().backendhost,
          userId: currentUserUid,
        );

        _shouldSetState = true;
        if ((_model.checkifallowedGalarry?.succeeded ?? true)) {
          final selectedMedia = await selectMedia(
            storageFolderPath: 'users_images',
            mediaSource: MediaSource.photoGallery,
            multiImage: false,
          );
          if (selectedMedia != null &&
              selectedMedia.every((m) =>
                  validateFileFormat(m.storagePath, context))) {
            safeSetState(() =>
                _model.isDataUploading_uploadImageSupabaseGallary = true);
            var selectedUploadedFiles = <FFUploadedFile>[];

            var downloadUrls = <String>[];
            try {
              selectedUploadedFiles = selectedMedia
                  .map((m) => FFUploadedFile(
                        name: m.storagePath.split('/').last,
                        bytes: m.bytes,
                        height: m.dimensions?.height,
                        width: m.dimensions?.width,
                        blurHash: m.blurHash,
                        originalFilename: m.originalFilename,
                      ))
                  .toList();

              downloadUrls = await uploadSupabaseStorageFiles(
                bucketName: 'images',
                selectedFiles: selectedMedia,
              );
            } finally {
              _model.isDataUploading_uploadImageSupabaseGallary = false;
            }
            if (selectedUploadedFiles.length == selectedMedia.length &&
                downloadUrls.length == selectedMedia.length) {
              safeSetState(() {
                _model.uploadedLocalFile_uploadImageSupabaseGallary =
                    selectedUploadedFiles.first;
                _model.uploadedFileUrl_uploadImageSupabaseGallary =
                    downloadUrls.first;
              });
            } else {
              safeSetState(() {});
              return;
            }
          } else {
            // User cancelled picker or invalid format — don't proceed
            if (_shouldSetState) safeSetState(() {});
            return;
          }

          unawaited(AnalyticsService.instance.trackAnalysisStarted(source: 'gallery'));
          FFAppState().analysisloading = true;
          FFAppState().extractedProductName = '';
          FFAppState().extractedBrand = '';
          safeSetState(() {});
          if (_model.uploadedFileUrl_uploadImageSupabaseGallary != '') {
            FFAppState().uploadedimageurl =
                _model.uploadedFileUrl_uploadImageSupabaseGallary;
            FFAppState().uploudedimagepath =
                _model.uploadedFileUrl_uploadImageSupabaseGallary;
            FFAppState().Producanalysstate = 1;
            safeSetState(() {});
            _model.extractedproductGalary =
                await ExtractproductinfoNEWBCNDCopyCall.call(
              host: FFDevEnvironmentValues().backendhost,
              imageUrl: FFAppState().uploadedimageurl,
              userId: currentUserUid,
              languageCode: FFLocalizations.of(context).languageCode,
              country: FFAppState().countrycode,
            );

            _shouldSetState = true;
            if ((_model.extractedproductGalary?.succeeded ?? true)) {
              FFAppState().Producanalysstate = 2;
              FFAppState().extractedProductName =
                  ExtractproductinfoNEWBCNDCopyCall.name(
                        (_model.extractedproductGalary?.jsonBody ?? ''),
                      ) ??
                      '';
              FFAppState().extractedBrand =
                  ExtractproductinfoNEWBCNDCopyCall.brand(
                        (_model.extractedproductGalary?.jsonBody ?? ''),
                      ) ??
                      '';
              safeSetState(() {});
              _model.analyseImageProductName =
                  await SearchingredientsNEWBCNDCall.call(
                host: FFDevEnvironmentValues().backendhost,
                imageId: ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                  (_model.extractedproductGalary?.jsonBody ?? ''),
                )?.toString(),
                productName: ExtractproductinfoNEWBCNDCopyCall.name(
                  (_model.extractedproductGalary?.jsonBody ?? ''),
                ),
                brand: ExtractproductinfoNEWBCNDCopyCall.brand(
                  (_model.extractedproductGalary?.jsonBody ?? ''),
                ),
                country: _model.countriesRaw
                    ?.where((e) =>
                        e.id ==
                        _model.useranalyspage?.firstOrNull?.countryId)
                    .toList()
                    .firstOrNull
                    ?.code,
              );

              _shouldSetState = true;
            } else {
              await TelegrammessegeCall.call(
                messega:
                    '${_model.uploadedFileUrl_uploadImageSupabaseGallary}на этапе extract product info галерея',
                email: 'from mobile app Extract Product Name Step',
                form: 'tech message',
              );

              await showDialog(
                context: context,
                builder: (alertDialogContext) {
                  return AlertDialog(
                    title: Text('Error!'),
                    content: Text('Product not found, data error - 3'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext),
                        child: Text('Ok'),
                      ),
                    ],
                  );
                },
              );
              FFAppState().uploadedimageurl = '';
              FFAppState().analysisloading = false;
              FFAppState().Producanalysstate = 0;
              safeSetState(() {});
              await ImagesTable().delete(
                matchingRows: (rows) => rows.eqOrNull(
                  'id',
                  ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                    (_model.extractedproductGalary?.jsonBody ?? ''),
                  ),
                ),
              );
              if (_shouldSetState) safeSetState(() {});
              return;
            }

            if ((_model.analyseImageProductName?.statusCode ?? 200) ==
                200) {
              FFAppState().Producanalysstate = 3;
              safeSetState(() {});
              _model.scientificanalysresultcamara =
                  await ScientificanalysisNEWBCNDCall.call(
                host: FFDevEnvironmentValues().backendhost,
                imageId: ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                  (_model.extractedproductGalary?.jsonBody ?? ''),
                )?.toString(),
                userId: currentUserUid,
                languageCode: ExtractproductinfoNEWBCNDCopyCall.langcode(
                  (_model.extractedproductGalary?.jsonBody ?? ''),
                ),
              );

              _shouldSetState = true;
              if ((_model.scientificanalysresultgalary?.succeeded ??
                  true)) {
                context.pushNamed(
                  Itemcard2Widget.routeName,
                  queryParameters: {
                    'imageid': serializeParam(
                      ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                        (_model.extractedproductGalary?.jsonBody ?? ''),
                      ),
                      ParamType.int,
                    ),
                  }.withoutNulls,
                );

                FFAppState().uploadedimageurl = '';
                FFAppState().analysisloading = false;
                safeSetState(() {});
              } else {
                final _galleryScientificStatusCode =
                    _model.scientificanalysresultcamara?.statusCode ?? 0;
                if (_galleryScientificStatusCode == 422) {
                  await showDialog(
                    context: context,
                    builder: (alertDialogContext) {
                      return AlertDialog(
                        title: Text(FFLocalizations.of(context)
                            .getText('nnsq0kj5')),
                        content: Text(FFLocalizations.of(context)
                            .getText('48je50c9')),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(alertDialogContext),
                            child: Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  await TelegrammessegeCall.call(
                    messega:
                        '${_model.uploadedFileUrl_uploadImageSupabaseCamera} на этапе scientific research, gallary',
                    email: 'from mobile app',
                    form: 'tech message',
                  );

                  await showDialog(
                    context: context,
                    builder: (alertDialogContext) {
                      return AlertDialog(
                        title: Text('Error!'),
                        content: Text('Product not found, data error'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(alertDialogContext),
                            child: Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                }
                FFAppState().uploadedimageurl = '';
                FFAppState().analysisloading = false;
                FFAppState().Producanalysstate = 0;
                safeSetState(() {});
                await ImagesTable().delete(
                  matchingRows: (rows) => rows.eqOrNull(
                    'id',
                    ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                      (_model.extractedproductGalary?.jsonBody ?? ''),
                    ),
                  ),
                );
                if (_shouldSetState) safeSetState(() {});
                return;
              }
            } else {
              if ((_model.analyseImageProductName?.statusCode ?? 200) ==
                  400) {
                await showDialog(
                  context: context,
                  builder: (alertDialogContext) {
                    return AlertDialog(
                      title: Text('Error!'),
                      content: Text('Product not found, data error'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(alertDialogContext),
                          child: Text('Ok'),
                        ),
                      ],
                    );
                  },
                );
                FFAppState().uploadedimageurl = '';
                FFAppState().analysisloading = false;
                FFAppState().Producanalysstate = 0;
                safeSetState(() {});
                await ImagesTable().delete(
                  matchingRows: (rows) => rows.eqOrNull(
                    'id',
                    ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                      (_model.extractedproductGalary?.jsonBody ?? ''),
                    ),
                  ),
                );
              } else {
                if ((_model.analyseImageProductName?.statusCode ?? 200) ==
                    429) {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    context: context,
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: LimitOutWidget(
                            limit: SearchingredientsNEWBCNDCall.limit(
                              (_model.analyseImageProductName?.jsonBody ??
                                  ''),
                            )!,
                            date: SearchingredientsNEWBCNDCall.resettime(
                              (_model.analyseImageProductName?.jsonBody ??
                                  ''),
                            )!,
                            isPro: FFAppState().isprouser,
                          ),
                        ),
                      );
                    },
                  ).then((value) => safeSetState(() {}));

                  FFAppState().uploadedimageurl = '';
                  FFAppState().analysisloading = false;
                  FFAppState().Producanalysstate = 0;
                  safeSetState(() {});
                  await ImagesTable().delete(
                    matchingRows: (rows) => rows.eqOrNull(
                      'id',
                      ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                        (_model.extractedproductGalary?.jsonBody ?? ''),
                      ),
                    ),
                  );
                } else {
                  if ((_model.analyseImageProductName?.statusCode ??
                          200) ==
                      500) {
                    context.pushNamed(HomeWidget.routeName);

                    await ImagesTable().delete(
                      matchingRows: (rows) => rows.eqOrNull(
                        'id',
                        ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                          (_model.extractedproductGalary?.jsonBody ?? ''),
                        ),
                      ),
                    );
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          title: Text(SearchingredientsNEWBCNDCall.error(
                            (_model.analyseImageProductName?.jsonBody ??
                                ''),
                          )!),
                          content:
                              Text(SearchingredientsNEWBCNDCall.details(
                            (_model.analyseImageProductName?.jsonBody ??
                                ''),
                          )!),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext),
                              child: Text('Ok'),
                            ),
                          ],
                        );
                      },
                    );
                    FFAppState().uploadedimageurl = '';
                    FFAppState().analysisloading = false;
                    FFAppState().Producanalysstate = 0;
                    safeSetState(() {});
                    safeSetState(() {});
                  } else {
                    await TelegrammessegeCall.call(
                      messega:
                          '${_model.uploadedFileUrl_uploadImageSupabaseGallary} на этапе анализа, из галереи',
                      email: 'from mobile app',
                      form: 'tech message',
                    );

                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          title: Text('Error!'),
                          content: Text('Product not found, data error'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext),
                              child: Text('Ok'),
                            ),
                          ],
                        );
                      },
                    );
                    FFAppState().uploadedimageurl = '';
                    FFAppState().analysisloading = false;
                    FFAppState().Producanalysstate = 0;
                    safeSetState(() {});
                    await ImagesTable().delete(
                      matchingRows: (rows) => rows.eqOrNull(
                        'id',
                        ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                          (_model.extractedproductGalary?.jsonBody ?? ''),
                        ),
                      ),
                    );
                    if (_shouldSetState) safeSetState(() {});
                    return;
                  }
                }
              }
            }
          } else {
            FFAppState().analysisloading = false;
            safeSetState(() {});
            if (_shouldSetState) safeSetState(() {});
            return;
          }
        } else {
          await showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            enableDrag: false,
            context: context,
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Padding(
                  padding: MediaQuery.viewInsetsOf(context),
                  child: OutOfGenerationsWidget(),
                ),
              );
            },
          ).then((value) => safeSetState(() {}));

          FFAppState().uploadedimageurl = '';
          FFAppState().analysisloading = false;
          safeSetState(() {});
        }

        if (_shouldSetState) safeSetState(() {});
      },
      text: FFLocalizations.of(context).getText(
        'pznd0mgm' /* Choose from gallery */,
      ),
      icon: Icon(
        Icons.photo_library,
        size: 28.0,
      ),
      options: FFButtonOptions(
        width: double.infinity,
        height: 65.0,
        padding: EdgeInsets.all(8.0),
        iconPadding:
            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        iconColor: Colors.white,
        color: Color(0xD25C85D9),
        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily:
                  FlutterFlowTheme.of(context).titleMediumFamily,
              color: Colors.white,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              useGoogleFonts:
                  !FlutterFlowTheme.of(context).titleMediumIsCustom,
            ),
        elevation: 0.4,
        borderSide: BorderSide(
          color: Color(0xD15C85D9),
        ),
        borderRadius: BorderRadius.circular(36.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).alternate,
        body: Stack(
          children: [
            // ── Illustration (top content area) ──
            if (!FFAppState().analysisloading)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 56,
                    bottom: 320,
                  ),
                  child: const _UploadIllustration(),
                ),
              ),

            // ── Bottom action zone (thumb reach) ──
            if (!FFAppState().analysisloading)
              Positioned(
                left: 16,
                right: 16,
                bottom: 100.0 + MediaQuery.of(context).padding.bottom,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HintCard(
                      expanded: _hintExpanded,
                      onToggle: () =>
                          setState(() => _hintExpanded = !_hintExpanded),
                    ),
                    const SizedBox(height: 12),
                    _buildCameraButton(context),
                    const SizedBox(height: 12),
                    _buildGalleryButton(context),
                  ],
                ),
              ),

            // ── Full-screen loading overlay ──
            if (FFAppState().analysisloading)
              const Positioned.fill(child: AnalysisLoadingWidget()),

            // ── Navbar ──
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.navbarModel,
                updateCallback: () => safeSetState(() {}),
                child: NavbarWidget(
                  activePage: 5,
                  analysesused: FFAppState().analysesused,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Illustration widget
// ─────────────────────────────────────────────

class _UploadIllustration extends StatelessWidget {
  const _UploadIllustration();

  @override
  Widget build(BuildContext context) {
    final primary = FlutterFlowTheme.of(context).primary;
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.06),
              ),
            ),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.11),
              ),
            ),
            Icon(Icons.camera_alt_rounded, size: 58, color: primary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Collapsible hint card
// ─────────────────────────────────────────────

class _HintCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _HintCard({required this.expanded, required this.onToggle});

  Widget _tip(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_sharp, color: Color(0xFFFBBF23), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  fontSize: 14,
                  letterSpacing: 0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      alignment: Alignment.bottomCenter,
      child: Material(
        color: const Color(0xFFFFF9EB),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(expanded ? 16.0 : 12.0),
            child: expanded ? _buildExpanded(context) : _buildCollapsed(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFFBBF23),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            FontAwesomeIcons.solidLightbulb,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            FFLocalizations.of(context).getText('c793vezr' /* Photo tips */),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
        const Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Color(0xFFFBBF23),
        ),
      ],
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBF23),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                FontAwesomeIcons.solidLightbulb,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                FFLocalizations.of(context).getText('c793vezr' /* Photo tips */),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodyMediumFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFFBBF23),
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _tip(
          context,
          FFLocalizations.of(context)
              .getText('byujsu2p' /* Make sure the brand name and p... */),
        ),
        const SizedBox(height: 8),
        _tip(
          context,
          FFLocalizations.of(context)
              .getText('dcho9j17' /* Use good lighting for bettera... */),
        ),
        const SizedBox(height: 8),
        _tip(
          context,
          FFLocalizations.of(context)
              .getText('be3z130n' /* Keep text in focus and readabl... */),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/image_(6).jpg',
            height: MediaQuery.of(context).size.height * 0.25,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
