import 'dart:async';
import 'dart:math' as math;
import '/app_state.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/analytics_service.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/analysis_loading/analysis_loading_widget.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/design_system/components/app_button.dart';
import '/flutter_flow/upload_data.dart';
import '/limits/limit_out/limit_out_widget.dart';
import '/components/error_popup/error_popup_widget.dart';
import '/components/guest_prefs_sheet/guest_prefs_sheet_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
      FFAppState().analysisloading = false;
      FFAppState().Producanalysstate = 0;
      FFAppState().uploadedimageurl = '';
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

  Future<void> _showPendingResearchDialog(BuildContext context) async {
    String t(String key) => FFLocalizations.of(context).getText('tu_$key');
    final theme = FlutterFlowTheme.of(context);
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                blurRadius: 24.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 8.0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Color(0xFF1565C0),
                    size: 28.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  t('title'),
                  textAlign: TextAlign.center,
                  style: theme.headlineSmall.override(
                    fontFamily: theme.headlineSmallFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.headlineSmallIsCustom,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  t('body'),
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
                const SizedBox(height: 24.0),
                AppButton(
                  label: t('button'),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gallery analysis chain. Reads _model.uploadedFileUrl_uploadImageSupabaseGallary
  /// which must be set before calling this method.
  Future<void> _runGalleryAnalysisFromModel(BuildContext context) async {
    unawaited(
        AnalyticsService.instance.trackAnalysisStarted(source: 'gallery'));
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
      debugPrint('[gallery] → extract-product-info '
          'host=${FFDevEnvironmentValues().backendhost}');
      _model.extractedproductGalary =
          await ExtractproductinfoNEWBCNDCopyCall.call(
        host: FFDevEnvironmentValues().backendhost,
        imageUrl: FFAppState().uploadedimageurl,
        userId: currentUserUid,
        languageCode: FFLocalizations.of(context).languageCode,
        country: FFAppState().countrycode,
        token: currentJwtToken,
      );
      debugPrint('[gallery] extract-product-info: '
          'status=${_model.extractedproductGalary?.statusCode} '
          'succeeded=${_model.extractedproductGalary?.succeeded} '
          'body=${_model.extractedproductGalary?.jsonBody}');

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
                  e.id == _model.useranalyspage?.firstOrNull?.countryId)
              .toList()
              .firstOrNull
              ?.code,
          token: currentJwtToken,
        );
        debugPrint('[gallery] search-ingredients: '
            'status=${_model.analyseImageProductName?.statusCode} '
            'succeeded=${_model.analyseImageProductName?.succeeded}');
      } else {
        // Gallery: extract-product-info failed.
        debugPrint('[gallery] extract-product-info FAILED → '
            'status=${_model.extractedproductGalary?.statusCode}');
        // Check for quota exhaustion before showing a generic error.
        if ((_model.extractedproductGalary?.statusCode ?? 0) == 429) {
          if (context.read<FFAppState>().isprouser) {
            await ErrorPopupWidget.show(context, ErrorPopupType.subscriptionSync);
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
                    child: LimitOutWidget(
                      limit: ExtractproductinfoNEWBCNDCopyCall.quotaUsed(
                                (_model.extractedproductGalary?.jsonBody ?? ''),
                              ) ??
                          FFAppState().freeScanLimit,
                      date: ExtractproductinfoNEWBCNDCopyCall.resetTime(
                                (_model.extractedproductGalary?.jsonBody ?? ''),
                              ) ??
                          '',
                      isPro: false,
                    ),
                  ),
                );
              },
            ).then((value) => safeSetState(() {}));
          }
          // No image was created (quota check ran before image creation).
        } else {
          await TelegrammessegeCall.call(
            messega:
                '${_model.uploadedFileUrl_uploadImageSupabaseGallary} на этапе extract product info галерея. status=${_model.extractedproductGalary?.statusCode} body=${_model.extractedproductGalary?.jsonBody} tokenEmpty=${currentJwtToken.isEmpty}',
            email: 'from mobile app Extract Product Name Step',
            form: 'tech message',
          );
          await ErrorPopupWidget.show(context, ErrorPopupType.productNotFound);
          final _gallImgId = ExtractproductinfoNEWBCNDCopyCall.iamgeID(
            (_model.extractedproductGalary?.jsonBody ?? ''),
          );
          if (_gallImgId != null) {
            await ImagesTable().delete(
              matchingRows: (rows) => rows.eqOrNull('id', _gallImgId),
            );
          }
        }
        FFAppState().uploadedimageurl = '';
        FFAppState().analysisloading = false;
        FFAppState().Producanalysstate = 0;
        safeSetState(() {});
        return;
      }

      if ((_model.analyseImageProductName?.statusCode ?? 0) == 200) {
        await _maybeOfferIngredientsPhoto(
          searchJsonBody: _model.analyseImageProductName?.jsonBody ?? '',
          imageId: ExtractproductinfoNEWBCNDCopyCall.iamgeID(
            (_model.extractedproductGalary?.jsonBody ?? ''),
          ),
        );
        FFAppState().Producanalysstate = 3;
        safeSetState(() {});
        debugPrint('[gallery] → scientific-analysis');
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
          token: currentJwtToken,
        );
        debugPrint('[gallery] scientific-analysis: '
            'status=${_model.scientificanalysresultcamara?.statusCode} '
            'succeeded=${_model.scientificanalysresultcamara?.succeeded}');

        if ((_model.scientificanalysresultcamara?.succeeded ?? true)) {
          if ((_model.scientificanalysresultcamara?.statusCode ?? 200) == 202) {
            await _showPendingResearchDialog(context);
            unawaited(ResearchAndAnalyzeCall.call(
              host: FFDevEnvironmentValues().backendhost,
              imageId: ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                (_model.extractedproductGalary?.jsonBody ?? ''),
              ),
              languageCode: FFLocalizations.of(context).languageCode,
              token: currentJwtToken,
            ));
          }
          final _completedImageId = ExtractproductinfoNEWBCNDCopyCall.iamgeID(
            (_model.extractedproductGalary?.jsonBody ?? ''),
          );
          if (_completedImageId != null) {
            unawaited(AnalyticsService.instance.trackAnalysisCompleted(
              imageId: _completedImageId,
              score: ScientificanalysisNEWBCNDCall.compositescore(
                (_model.scientificanalysresultcamara?.jsonBody ?? ''),
              ),
              productType: ScientificanalysisNEWBCNDCall.producttype(
                (_model.scientificanalysresultcamara?.jsonBody ?? ''),
              ),
            ));
          }
          FFAppState().feedbackPendingScan = true;
          if (!mounted) {
            FFAppState().uploadedimageurl = '';
            FFAppState().analysisloading = false;
            FFAppState().Producanalysstate = 0;
            final navCtx = appNavigatorKey.currentContext;
            if (navCtx != null) {
              navCtx.pushNamed(
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
            }
            return;
          }
          await context.pushNamed(
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
          FFAppState().Producanalysstate = 0;
          safeSetState(() {});
        } else {
          final statusCode =
              _model.scientificanalysresultcamara?.statusCode ?? 0;
          if (statusCode == 422) {
            await ErrorPopupWidget.show(context, ErrorPopupType.unsupported);
          } else {
            await TelegrammessegeCall.call(
              messega:
                  '${_model.uploadedFileUrl_uploadImageSupabaseCamera} на этапе scientific research, gallary',
              email: 'from mobile app',
              form: 'tech message',
            );
            await ErrorPopupWidget.show(context, ErrorPopupType.productNotFound);
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
          return;
        }
      } else {
        if ((_model.analyseImageProductName?.statusCode ?? 200) == 400) {
          await ErrorPopupWidget.show(context, ErrorPopupType.productNotFound);
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
        } else if ((_model.analyseImageProductName?.statusCode ?? 200) ==
            429) {
          if (context.read<FFAppState>().isprouser) {
            await ErrorPopupWidget.show(context, ErrorPopupType.subscriptionSync);
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
                    child: LimitOutWidget(
                      limit: SearchingredientsNEWBCNDCall.limit(
                        (_model.analyseImageProductName?.jsonBody ?? ''),
                      )!,
                      date: SearchingredientsNEWBCNDCall.resettime(
                        (_model.analyseImageProductName?.jsonBody ?? ''),
                      )!,
                      isPro: false,
                    ),
                  ),
                );
              },
            ).then((value) => safeSetState(() {}));
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
        } else if ((_model.analyseImageProductName?.statusCode ?? 200) ==
            500) {
          FirebaseCrashlytics.instance.log(
            'Backend 500 on gallery analysis: body=${_model.analyseImageProductName?.jsonBody}',
          );
          context.pushNamed(HomeWidget.routeName);
          await ImagesTable().delete(
            matchingRows: (rows) => rows.eqOrNull(
              'id',
              ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                (_model.extractedproductGalary?.jsonBody ?? ''),
              ),
            ),
          );
          await ErrorPopupWidget.show(context, ErrorPopupType.generic);
          FFAppState().uploadedimageurl = '';
          FFAppState().analysisloading = false;
          FFAppState().Producanalysstate = 0;
          safeSetState(() {});
        } else if ((_model.analyseImageProductName?.statusCode ?? 200) ==
            422) {
          await ErrorPopupWidget.show(context, ErrorPopupType.unsupported);
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
        } else if ((_model.analyseImageProductName?.statusCode ?? 200) ==
            404) {
          final _gallImgId = ExtractproductinfoNEWBCNDCopyCall.iamgeID(
            (_model.extractedproductGalary?.jsonBody ?? ''),
          );
          if (_gallImgId != null) {
            await _handleIngredientsNotFound(
              imageId: _gallImgId,
              languageCode: ExtractproductinfoNEWBCNDCopyCall.langcode(
                (_model.extractedproductGalary?.jsonBody ?? ''),
              ),
            );
          } else {
            FFAppState().uploadedimageurl = '';
            FFAppState().analysisloading = false;
            FFAppState().Producanalysstate = 0;
            safeSetState(() {});
          }
        } else {
          await TelegrammessegeCall.call(
            messega:
                '${_model.uploadedFileUrl_uploadImageSupabaseGallary} на этапе анализа, из галереи',
            email: 'from mobile app',
            form: 'tech message',
          );
          await ErrorPopupWidget.show(context, ErrorPopupType.productNotFound);
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
        }
      }
    } else {
      FFAppState().analysisloading = false;
      safeSetState(() {});
    }
  }

  // ── Country check ────────────────────────────────────────────────────────

  /// Shows [GuestPrefsSheet] if the current user has no country set, then
  /// reloads user/country data so the subsequent scan uses the correct country.
  Future<void> _ensureCountrySet() async {
    // Reaching here without a session (anon sign-in normally happens on the
    // guest-entry screen) would send "" to a uuid column (Postgres 22P02).
    // Sign in anonymously first so the query is valid and the country sheet
    // can persist; bail out safely if that still didn't yield a uid.
    if (currentUserUid.isEmpty) {
      await authManager.signInAnonymously(context);
      if (!mounted || currentUserUid.isEmpty) return;
    }
    _model.useranalyspage ??= await UsersTable().queryRows(
      queryFn: (q) => q.eqOrNull('id', currentUserUid),
    );
    if (_model.useranalyspage?.firstOrNull?.countryId != null) return;

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) => Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: const GuestPrefsSheet(),
      ),
    );

    // Reload so the API calls pick up the newly chosen country.
    _model.useranalyspage = await UsersTable().queryRows(
      queryFn: (q) => q.eqOrNull('id', currentUserUid),
    );
    _model.countriesRaw = await CountriesTable().queryRows(
      queryFn: (q) => q.eqOrNull(
        'id',
        _model.useranalyspage?.firstOrNull?.countryId,
      ),
    );
    final countryRow = _model.countriesRaw?.firstOrNull;
    if (countryRow != null) {
      FFAppState().countrycode = countryRow.nameEn;
      FFAppState().countrycodeiso = countryRow.code;
    }
  }

  /// Photograph the product's ingredient panel, upload it to Supabase Storage
  /// and let the backend OCR it (POST /product/<id>/ingredients-photo).
  /// Returns true when the backend saved an ingredient list from the photo.
  Future<bool> _captureAndSubmitIngredientsPhoto(int imageId) async {
    List<SelectedFile>? selectedMedia;
    try {
      selectedMedia = await selectMedia(
        storageFolderPath: 'users_images',
        multiImage: false,
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          fatal: false, reason: 'selectMedia (ingredients photo) failed');
      return false;
    }
    if (selectedMedia == null ||
        !selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      return false;
    }

    var downloadUrls = <String>[];
    try {
      downloadUrls = await uploadSupabaseStorageFiles(
        bucketName: 'images',
        selectedFiles: selectedMedia,
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          fatal: false, reason: 'Supabase upload failed (ingredients photo)');
      return false;
    }
    if (downloadUrls.isEmpty) {
      return false;
    }

    final ocrResult = await SubmitIngredientsPhotoCall.call(
      imageId: imageId,
      photoUrl: downloadUrls.first,
      token: currentJwtToken,
    );
    debugPrint('[ingredients-photo] status=${ocrResult.statusCode} '
        'succeeded=${ocrResult.succeeded}');
    return ocrResult.succeeded;
  }

  /// Called after a search-ingredients 200: when the saved list is
  /// low-confidence, offer to photograph the ingredient panel for a precise
  /// analysis. Always proceeds to analysis afterwards — the low list is
  /// already saved server-side, the OCR result replaces it when it succeeds.
  Future<void> _maybeOfferIngredientsPhoto({
    required dynamic searchJsonBody,
    required int? imageId,
  }) async {
    if (imageId == null) return;
    final status =
        SearchingredientsNEWBCNDCall.ingredientsStatus(searchJsonBody);
    if (status != 'low') return;

    final action = await ErrorPopupWidget.showLowConfidenceChoice(context);
    if (action != IngredientInputAction.photo) return;

    final ok = await _captureAndSubmitIngredientsPhoto(imageId);
    if (!ok && mounted) {
      await ErrorPopupWidget.show(context, ErrorPopupType.ingredientsNotFound);
    }
  }

  Future<void> _handleIngredientsNotFound({
    required int imageId,
    required String? languageCode,
  }) async {
    var result = await ErrorPopupWidget.showIngredientInput(context);

    // Photo path: OCR the panel server-side; on failure fall back to the
    // manual dialog once more, then give up via the cancel path below.
    var savedViaPhoto = false;
    if (result?.action == IngredientInputAction.photo) {
      FFAppState().Producanalysstate = 3;
      safeSetState(() {});
      savedViaPhoto = await _captureAndSubmitIngredientsPhoto(imageId);
      if (!savedViaPhoto) {
        result = await ErrorPopupWidget.showIngredientInput(context);
        if (result?.action == IngredientInputAction.photo) {
          savedViaPhoto = await _captureAndSubmitIngredientsPhoto(imageId);
        }
      }
    }

    final manualText = result?.action == IngredientInputAction.manualText
        ? (result?.text ?? '').trim()
        : '';

    if (!savedViaPhoto && manualText.isEmpty) {
      FFAppState().uploadedimageurl = '';
      FFAppState().analysisloading = false;
      FFAppState().Producanalysstate = 0;
      safeSetState(() {});
      await ImagesTable().delete(
        matchingRows: (rows) => rows.eqOrNull('id', imageId),
      );
      return;
    }

    FFAppState().Producanalysstate = 3;
    safeSetState(() {});

    if (!savedViaPhoto) {
      final setResult = await SetProductIngredientsCall.call(
        imageId: imageId,
        ingredients: manualText,
        token: currentJwtToken,
      );

      if (!setResult.succeeded) {
        await ErrorPopupWidget.show(context, ErrorPopupType.generic);
        FFAppState().uploadedimageurl = '';
        FFAppState().analysisloading = false;
        FFAppState().Producanalysstate = 0;
        safeSetState(() {});
        await ImagesTable().delete(
          matchingRows: (rows) => rows.eqOrNull('id', imageId),
        );
        return;
      }
    }

    final analysisResult = await ScientificanalysisNEWBCNDCall.call(
      host: FFDevEnvironmentValues().backendhost,
      imageId: imageId.toString(),
      userId: currentUserUid,
      languageCode: languageCode,
      token: currentJwtToken,
    );

    if (analysisResult.succeeded) {
      if ((analysisResult.statusCode ?? 200) == 202) {
        await _showPendingResearchDialog(context);
        unawaited(ResearchAndAnalyzeCall.call(
          host: FFDevEnvironmentValues().backendhost,
          imageId: imageId,
          languageCode: FFLocalizations.of(context).languageCode,
          token: currentJwtToken,
        ));
      }
      unawaited(AnalyticsService.instance.trackAnalysisCompleted(
        imageId: imageId,
        score: ScientificanalysisNEWBCNDCall.compositescore(
          analysisResult.jsonBody,
        ),
        productType: ScientificanalysisNEWBCNDCall.producttype(
          analysisResult.jsonBody,
        ),
      ));
      FFAppState().feedbackPendingScan = true;
      if (!mounted) {
        FFAppState().uploadedimageurl = '';
        FFAppState().analysisloading = false;
        FFAppState().Producanalysstate = 0;
        final navCtx = appNavigatorKey.currentContext;
        if (navCtx != null) {
          navCtx.pushNamed(
            Itemcard2Widget.routeName,
            queryParameters: {
              'imageid': serializeParam(imageId, ParamType.int),
            }.withoutNulls,
          );
        }
        return;
      }
      await context.pushNamed(
        Itemcard2Widget.routeName,
        queryParameters: {
          'imageid': serializeParam(imageId, ParamType.int),
        }.withoutNulls,
      );
      FFAppState().uploadedimageurl = '';
      FFAppState().analysisloading = false;
      FFAppState().Producanalysstate = 0;
      safeSetState(() {});
    } else {
      if ((analysisResult.statusCode ?? 0) == 422) {
        await ErrorPopupWidget.show(context, ErrorPopupType.unsupported);
      } else {
        await ErrorPopupWidget.show(context, ErrorPopupType.generic);
      }
      FFAppState().uploadedimageurl = '';
      FFAppState().analysisloading = false;
      FFAppState().Producanalysstate = 0;
      safeSetState(() {});
      await ImagesTable().delete(
        matchingRows: (rows) => rows.eqOrNull('id', imageId),
      );
    }
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
    return AppButton(
      label: FFLocalizations.of(context).getText(
        'xirptk6c' /* Take a photo */,
      ),
      icon: Icons.camera_alt,
      onPressed: () async {
        // No local quota gate: the server refuses over-quota scans with a 429
        // on /extract-product-info, which is the single source of truth for
        // both the limit and the reset date.
        var _shouldSetState = false;
        _shouldSetState = true;
        await _ensureCountrySet();
        {
          List<SelectedFile>? selectedMedia;
          try {
            selectedMedia = await selectMedia(
              storageFolderPath: 'users_images',
              multiImage: false,
            );
          } catch (e, s) {
            FirebaseCrashlytics.instance.recordError(e, s, fatal: false, reason: 'selectMedia (camera) failed');
            if (_shouldSetState) safeSetState(() {});
            return;
          }
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
            } catch (e, s) {
              FirebaseCrashlytics.instance.recordError(e, s, fatal: false, reason: 'Supabase upload failed (camera)');
              if (_shouldSetState) safeSetState(() {});
              return;
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
              token: currentJwtToken,
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
                token: currentJwtToken,
              );

              _shouldSetState = true;
            } else {
              // Camera: extract-product-info failed.
              if ((_model.extractedproductcamera?.statusCode ?? 0) == 429) {
                if (context.read<FFAppState>().isprouser) {
                  await ErrorPopupWidget.show(context, ErrorPopupType.subscriptionSync);
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
                          child: LimitOutWidget(
                            limit: ExtractproductinfoNEWBCNDCopyCall.quotaUsed(
                                      (_model.extractedproductcamera?.jsonBody ??
                                          ''),
                                    ) ??
                                FFAppState().freeScanLimit,
                            date: ExtractproductinfoNEWBCNDCopyCall.resetTime(
                                      (_model.extractedproductcamera?.jsonBody ??
                                          ''),
                                    ) ??
                                '',
                            isPro: false,
                          ),
                        ),
                      );
                    },
                  ).then((value) => safeSetState(() {}));
                }
                // No image was created (quota check ran before image creation).
              } else {
                await TelegrammessegeCall.call(
                  messega:
                      '${_model.uploadedFileUrl_uploadImageSupabaseCamera}на этапе extract product info, camera',
                  email: 'from mobile app',
                  form: 'tech message',
                );

                await ErrorPopupWidget.show(context, ErrorPopupType.productNotFound);
                final _camImgId = ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                  (_model.extractedproductcamera?.jsonBody ?? ''),
                );
                if (_camImgId != null) {
                  await ImagesTable().delete(
                    matchingRows: (rows) => rows.eqOrNull('id', _camImgId),
                  );
                }
              }
              FFAppState().uploadedimageurl = '';
              FFAppState().analysisloading = false;
              safeSetState(() {});
              if (_shouldSetState) safeSetState(() {});
              return;
            }

            if ((_model.analyseImageProductNameCamera?.statusCode ??
                    0) ==
                200) {
              await _maybeOfferIngredientsPhoto(
                searchJsonBody:
                    _model.analyseImageProductNameCamera?.jsonBody ?? '',
                imageId: ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                  (_model.extractedproductcamera?.jsonBody ?? ''),
                ),
              );
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
                token: currentJwtToken,
              );

              _shouldSetState = true;
              if ((_model.scientificanalysresultgalary?.succeeded ??
                  true)) {
                if ((_model.scientificanalysresultgalary?.statusCode ?? 200) == 202) {
                  await _showPendingResearchDialog(context);
                  unawaited(ResearchAndAnalyzeCall.call(
                    host: FFDevEnvironmentValues().backendhost,
                    imageId: ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                      (_model.extractedproductcamera?.jsonBody ?? ''),
                    ),
                    languageCode: FFLocalizations.of(context).languageCode,
                    token: currentJwtToken,
                  ));
                }
                final _completedImageId =
                    ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                  (_model.extractedproductcamera?.jsonBody ?? ''),
                );
                if (_completedImageId != null) {
                  unawaited(AnalyticsService.instance.trackAnalysisCompleted(
                    imageId: _completedImageId,
                    score: ScientificanalysisNEWBCNDCall.compositescore(
                      (_model.scientificanalysresultgalary?.jsonBody ?? ''),
                    ),
                    productType: ScientificanalysisNEWBCNDCall.producttype(
                      (_model.scientificanalysresultgalary?.jsonBody ?? ''),
                    ),
                  ));
                }
                FFAppState().feedbackPendingScan = true;
                if (!mounted) {
                  FFAppState().uploadedimageurl = '';
                  FFAppState().analysisloading = false;
                  FFAppState().Producanalysstate = 0;
                  final navCtx = appNavigatorKey.currentContext;
                  if (navCtx != null) {
                    navCtx.pushNamed(
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
                  }
                  return;
                }
                await context.pushNamed(
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
                  await ErrorPopupWidget.show(context, ErrorPopupType.unsupported);
                } else {
                  await TelegrammessegeCall.call(
                    messega:
                        '${_model.uploadedFileUrl_uploadImageSupabaseCamera} на этапе scientific research, camera',
                    email: 'from mobile app',
                    form: 'tech message',
                  );
                  await ErrorPopupWidget.show(context, ErrorPopupType.productNotFound);
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
                await ErrorPopupWidget.show(context, ErrorPopupType.productNotFound);
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
                  if (context.read<FFAppState>().isprouser) {
                    await ErrorPopupWidget.show(context, ErrorPopupType.subscriptionSync);
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
                              isPro: false,
                            ),
                          ),
                        );
                      },
                    ).then((value) => safeSetState(() {}));
                  }

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
                    FirebaseCrashlytics.instance.log(
                      'Backend 500 on camera analysis: body=${_model.analyseImageProductNameCamera?.jsonBody}',
                    );
                    context.pushNamed(HomeWidget.routeName);

                    await ImagesTable().delete(
                      matchingRows: (rows) => rows.eqOrNull(
                        'id',
                        ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                          (_model.extractedproductcamera?.jsonBody ?? ''),
                        ),
                      ),
                    );
                    await ErrorPopupWidget.show(context, ErrorPopupType.generic);
                    safeSetState(() {});
                    FFAppState().uploadedimageurl = '';
                    FFAppState().analysisloading = false;
                    FFAppState().Producanalysstate = 0;
                    safeSetState(() {});
                  } else if ((_model.analyseImageProductNameCamera
                              ?.statusCode ??
                          200) ==
                      422) {
                    await ErrorPopupWidget.show(context, ErrorPopupType.unsupported);
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
                  } else if ((_model.analyseImageProductNameCamera
                              ?.statusCode ??
                          200) ==
                      404) {
                    final _camImgId = ExtractproductinfoNEWBCNDCopyCall.iamgeID(
                      (_model.extractedproductcamera?.jsonBody ?? ''),
                    );
                    if (_camImgId != null) {
                      await _handleIngredientsNotFound(
                        imageId: _camImgId,
                        languageCode: ExtractproductinfoNEWBCNDCopyCall.langcode(
                          (_model.extractedproductcamera?.jsonBody ?? ''),
                        ),
                      );
                    } else {
                      FFAppState().uploadedimageurl = '';
                      FFAppState().analysisloading = false;
                      FFAppState().Producanalysstate = 0;
                      safeSetState(() {});
                    }
                    if (_shouldSetState) safeSetState(() {});
                    return;
                  } else {
                    await TelegrammessegeCall.call(
                      messega:
                          '${_model.uploadedFileUrl_uploadImageSupabaseCamera} на этапе поиска ингредиентов, с камеры',
                      email: 'from mobile app',
                      form: 'tech message',
                    );

                    await ErrorPopupWidget.show(context, ErrorPopupType.productNotFound);
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
        }

        if (_shouldSetState) safeSetState(() {});
      },
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
    return AppButton(
      label: FFLocalizations.of(context).getText(
        'pznd0mgm' /* Choose from gallery */,
      ),
      icon: Icons.photo_library,
      onPressed: () async {
        debugPrint('[gallery] tap: '
            'host=${FFDevEnvironmentValues().backendhost} '
            'tokenEmpty=${currentJwtToken.isEmpty}');
        // No local quota gate — see _buildCameraButton.
        var _shouldSetState = false;
        _shouldSetState = true;
        await _ensureCountrySet();
        List<SelectedFile>? selectedMedia;
        try {
          selectedMedia = await selectMedia(
            storageFolderPath: 'users_images',
            mediaSource: MediaSource.photoGallery,
            multiImage: false,
          );
        } catch (e, s) {
          debugPrint('[gallery] selectMedia threw: $e');
          FirebaseCrashlytics.instance.recordError(e, s, fatal: false, reason: 'selectMedia (gallery) failed');
          if (_shouldSetState) safeSetState(() {});
          return;
        }
        debugPrint('[gallery] selectMedia returned: '
            '${selectedMedia == null ? "null (cancelled)" : "${selectedMedia.length} file(s)"}');
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
          } catch (e, s) {
            debugPrint('[gallery] Supabase upload threw: $e');
            FirebaseCrashlytics.instance.recordError(e, s, fatal: false, reason: 'Supabase upload failed (gallery)');
            if (_shouldSetState) safeSetState(() {});
            return;
          } finally {
            _model.isDataUploading_uploadImageSupabaseGallary = false;
          }
          debugPrint('[gallery] uploaded: files=${selectedUploadedFiles.length} '
              'urls=${downloadUrls.length} firstUrl='
              '${downloadUrls.isNotEmpty ? downloadUrls.first : "<none>"}');
          if (selectedUploadedFiles.length == selectedMedia.length &&
              downloadUrls.length == selectedMedia.length) {
            safeSetState(() {
              _model.uploadedLocalFile_uploadImageSupabaseGallary =
                  selectedUploadedFiles.first;
              _model.uploadedFileUrl_uploadImageSupabaseGallary =
                  downloadUrls.first;
            });
          } else {
            debugPrint('[gallery] upload count mismatch → abort');
            safeSetState(() {});
            return;
          }
        } else {
          // User cancelled picker or invalid format — don't proceed
          debugPrint('[gallery] no media / invalid format → abort');
          if (_shouldSetState) safeSetState(() {});
          return;
        }

        debugPrint('[gallery] starting analysis chain, '
            'url=${_model.uploadedFileUrl_uploadImageSupabaseGallary}');
        await _runGalleryAnalysisFromModel(context);
        if (_shouldSetState) safeSetState(() {});
        return;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();

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
            if (!appState.analysisloading)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 56,
                    // Hand-tuned around the navbar + action zone; see the
                    // kNavBarHeight note in design_system/foundations/layout.dart
                    // before changing.
                    bottom: 320,
                  ),
                  child: const _ScannerIllustration(),
                ),
              ),

            // ── Bottom action zone (thumb reach) ──
            if (!appState.analysisloading)
              Positioned(
                left: 16,
                right: 16,
                // Hand-tuned thumb-reach offset above the navbar (see the
                // kNavBarHeight note in design_system/foundations/layout.dart).
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
            if (appState.analysisloading)
              const Positioned.fill(child: AnalysisLoadingWidget()),

            // ── Navbar ──
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.navbarModel,
                updateCallback: () => safeSetState(() {}),
                child: NavbarWidget(
                  activePage: 5,
                  analysesused: appState.analysesused,
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
// Animated scanner illustration
// ─────────────────────────────────────────────

class _ScannerIllustration extends StatefulWidget {
  const _ScannerIllustration();

  @override
  State<_ScannerIllustration> createState() => _ScannerIllustrationState();
}

class _ScannerIllustrationState extends State<_ScannerIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = FlutterFlowTheme.of(context).primary;
    const dark = Color(0xFF3A5CB8);
    const size = 200.0;
    const half = size / 2;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;
            final beamOffset = math.sin(t * 2 * math.pi) * 40;

            Widget pulseRing(double phase) {
              final tp = (t + phase) % 1.0;
              final scale = 1.0 + tp * 0.6;
              final opacity = (0.5 * (1.0 - tp)).clamp(0.0, 0.5);
              return Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                // Radial background glow
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [primary.withOpacity(0.08), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3 staggered pulse rings
                pulseRing(0.0),
                pulseRing(1 / 3),
                pulseRing(2 / 3),

                // Center gradient circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5C85D9), dark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                // Scan beam
                Positioned(
                  top: half + beamOffset,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.7),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
                  fontWeight: FontWeight.w700,
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
                      fontWeight: FontWeight.w700,
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
