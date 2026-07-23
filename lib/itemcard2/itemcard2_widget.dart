import 'dart:async';
import 'dart:math' show sin, pi;
import '/auth/supabase_auth/auth_util.dart';
import '/components/feedback_collector/feedback_collector_widget.dart';
import '/components/feedback_collector/feedback_service.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '/flutter_flow/analytics_service.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/database/tables/product_prices.dart';
import '/backend/supabase/supabase.dart';
import '/app_state.dart';
import '/boards/albumslist/albumslist_widget.dart';
import '/components/new_album/new_album_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import '/design_system/foundations/format_price.dart';
import '/item_card/deleteitem/deleteitem_widget.dart';
import '/item_card/ingridients/ingridients_widget.dart';
import '/components/product_card_v2/product_card_v2_widget.dart';
import '/components/score_breakdown/score_breakdown_widget.dart';
import '/item_card/markasspam/markasspam_widget.dart';
import '/topratings/copyitem/copyitem_widget.dart';
import '/topratings/hidenavailability/hidenavailability_widget.dart';
import '/topratings/makeprivate/makeprivate_widget.dart';
import '/topratings/makepublic/makepublic_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'itemcard2_model.dart';
export 'itemcard2_model.dart';

class Itemcard2Widget extends StatefulWidget {
  const Itemcard2Widget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  static String routeName = 'itemcard2';
  static String routePath = '/itemcard2';

  @override
  State<Itemcard2Widget> createState() => _Itemcard2WidgetState();
}

class _Itemcard2WidgetState extends State<Itemcard2Widget>
    with TickerProviderStateMixin {
  late Itemcard2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _pendingPollingTimer;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Itemcard2Model());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      unawaited(AnalyticsService.instance.trackCardOpened(
        imageId: widget.imageid ?? 0,
        source: 'direct',
      ));
      await _loadAnalysis();
      // Average price for this product × the user's country (needs the loaded
      // image row for the product/brand keys).
      final _img = _model.imageraw?.firstOrNull;
      if (_img != null) {
        final _nameKey = (_img.productName ?? '').toLowerCase().trim();
        final _brandKey = (_img.brand ?? '').toLowerCase().trim();
        final _countryCode = FFAppState().countrycodeiso;
        if (_nameKey.isNotEmpty &&
            _brandKey.isNotEmpty &&
            _countryCode.isNotEmpty) {
          final _prices = await ProductPricesTable().queryRows(
            queryFn: (q) => q
                .eqOrNull('product_name_key', _nameKey)
                .eqOrNull('brand_key', _brandKey)
                .eqOrNull('country_code', _countryCode),
            limit: 1,
          );
          _model.priceRow = _prices.firstOrNull;
        }
      }
      // Skin profile from onboarding — default viewing context for the fit card.
      if (currentUserUid.isNotEmpty) {
        try {
          final userRows = await UsersTable().queryRows(
            queryFn: (q) => q.eq('id', currentUserUid),
            limit: 1,
          );
          final u = userRows.firstOrNull;
          _model.userSkinType = u?.skinType;
          _model.userIsSensitive =
              (u?.skinSensitivity ?? false) || u?.skinType == 'sensitive';
          _model.userIsAcneProne = u?.skinType == 'acne_prone' ||
              (u?.skinGoals.contains('acne') ?? false);
        } catch (_) {
          // Columns may not exist before the v2 migration — cold start.
        }
      }
      _model.loading = false;
      safeSetState(() {});

      // If analysis is pending (score not yet computed), retry scientific
      // analysis now — ingredients have likely been researched since the
      // 202 was returned during the original scan.
      if (!mounted) return;
      if (_model.imageraw?.firstOrNull?.saCompositeScore == null &&
          widget.imageid != null) {
        final retry = await ScientificanalysisNEWBCNDCall.call(
          imageId: widget.imageid?.toString(),
          userId: currentUserUid,
          languageCode: FFLocalizations.of(context).languageCode,
          token: currentJwtToken,
        );
        if ((retry?.succeeded ?? false) && (retry?.statusCode ?? 0) == 200) {
          await _loadAnalysis();
          if (mounted) safeSetState(() {});
        } else {
          // Analysis still pending (202) — poll Supabase until score appears.
          _startPendingPolling();
        }
      }

      // Show feedback prompt after the card has rendered and user has had
      // time to see the results.
      if (!mounted) return;
      final feedbackState = context.read<FFAppState>();
      if (feedbackState.feedbackPendingScan &&
          await FeedbackService.shouldShowPrompt(feedbackState)) {
        feedbackState.feedbackPendingScan = false;
        await FeedbackService.recordShown(feedbackState);
        await FirebaseAnalytics.instance
            .logEvent(name: 'feedback_prompt_shown');
        await Future.delayed(const Duration(seconds: 3));
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withAlpha(100),
            builder: (context) => const FeedbackCollectorWidget(),
          );
        }
      }
    });

    animationsMap.addAll({
      'iconOnPageLoadAnimation': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _pendingPollingTimer?.cancel();
    _model.dispose();

    super.dispose();
  }

  /// Loads the image row + its analysis tables (skin compatibility, top
  /// ingredients, issues). Shared by the initial page load and the
  /// pending-analysis retry/polling.
  Future<void> _loadAnalysis() async {
    if (widget.imageid == null) return;
    _model.imageraw = await ImagesTable().queryRows(
      queryFn: (q) => q.eqOrNull('id', widget.imageid),
    );
    _model.skinCompabilityRaw = await ImageSkinCompatibilityTable().queryRows(
      queryFn: (q) => q.eqOrNull('image_id', widget.imageid),
    );
    _model.topIngredientsRaw = await ImageTopIngredientsTable().queryRows(
      queryFn: (q) => q.eqOrNull('image_id', widget.imageid),
    );
    _model.ingredientIssuesRaw = await ImageIngredientIssuesTable().queryRows(
      queryFn: (q) => q.eqOrNull('image_id', widget.imageid),
    );
  }

  void _startPendingPolling() {
    _pendingPollingTimer?.cancel();
    _pendingPollingTimer =
        Timer.periodic(const Duration(seconds: 6), (_) async {
      if (!mounted) {
        _pendingPollingTimer?.cancel();
        return;
      }
      final rows = await ImagesTable().queryRows(
        queryFn: (q) => q.eqOrNull('id', widget.imageid),
      );
      if ((rows.firstOrNull?.saCompositeScore ?? 0) > 0) {
        _pendingPollingTimer?.cancel();
        await _loadAnalysis();
        if (mounted) safeSetState(() {});
      }
    });
  }


  Widget _buildPendingPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _FlaskResearchAnimation(),
          const SizedBox(height: 10),
          Text(
            FFLocalizations.of(context).getText('analysis_pending_title'),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontWeight: FontWeight.w700,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            FFLocalizations.of(context).getText('analysis_pending_body'),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();

    return FutureBuilder<List<ImagesRow>>(
      future: ImagesTable().querySingleRow(
        queryFn: (q) => q.eqOrNull(
          'id',
          widget.imageid,
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).alternate,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: FlutterFlowTheme.of(context).error, size: 48),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => safeSetState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).alternate,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<ImagesRow> itemcard2ImagesRowList = snapshot.data!;

        final itemcard2ImagesRow = itemcard2ImagesRowList.isNotEmpty
            ? itemcard2ImagesRowList.first
            : null;

        if (itemcard2ImagesRow == null) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  FFLocalizations.of(context).getText('item_not_found'),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).alternate,
            extendBodyBehindAppBar: true,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: SpeedDial(
              icon: Icons.tune,
              activeIcon: Icons.close,
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
              activeBackgroundColor: FlutterFlowTheme.of(context).primary,
              overlayOpacity: 0.3,
              overlayColor: Colors.black,
              spacing: 8,
              spaceBetweenChildren: 4,
              elevation: 4,
              children: [
                // Print label
                SpeedDialChild(
                  child: const Icon(Icons.local_print_shop_outlined),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context).getText('fab_print'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () => context.pushNamed(
                    ShareproductWidget.routeName,
                    queryParameters: {
                      'imageid': serializeParam(widget.imageid, ParamType.int),
                    }.withoutNulls,
                  ),
                ),
                // Share link
                SpeedDialChild(
                  child: const Icon(Icons.ios_share_rounded),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context).getText('fab_share'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    unawaited(AnalyticsService.instance
                        .trackShareLinkTapped(imageId: widget.imageid ?? 0));
                    await Future.delayed(const Duration(milliseconds: 300));
                    final size = MediaQuery.of(context).size;
                    await Share.share(
                      'https://mirra.up.railway.app/product/${widget.imageid}',
                      sharePositionOrigin:
                          Rect.fromLTWH(size.width / 2, size.height / 2, 1, 1),
                    );
                  },
                ),
                // Add to album
                SpeedDialChild(
                  child: const Icon(Icons.add_box),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label:
                      FFLocalizations.of(context).getText('fab_add_to_album'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    _model.albums = await AlbumTable().queryRows(
                      queryFn: (q) => q.eqOrNull('user', currentUserUid),
                    );
                    if (!context.mounted) return;
                    if (_model.albums?.length == 0) {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) => Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: NewAlbumWidget(),
                        ),
                      ).then((value) => safeSetState(() {}));
                    } else {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) => Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: AlbumslistWidget(
                            imageID: widget.imageid!,
                            albums: _model.albums ?? [],
                          ),
                        ),
                      ).then((value) => safeSetState(() {}));
                    }
                  },
                ),
                // Add to favourite (owner, not yet favourited)
                SpeedDialChild(
                  visible: !(itemcard2ImagesRow.favourite ?? false) &&
                      itemcard2ImagesRow.user == currentUserUid,
                  child: const Icon(Icons.favorite_border),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label:
                      FFLocalizations.of(context).getText('fab_add_favourite'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    await ImagesTable().update(
                      data: {'favourite': true},
                      matchingRows: (rows) =>
                          rows.eqOrNull('id', widget.imageid),
                    );
                    unawaited(AnalyticsService.instance
                        .trackFavouriteAdded(imageId: widget.imageid ?? 0));
                    safeSetState(() {});
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        FFLocalizations.of(context)
                            .getText('fab_favourite_added'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ));
                  },
                ),
                // Remove from favourite (owner, already favourited)
                SpeedDialChild(
                  visible: (itemcard2ImagesRow.favourite ?? false) &&
                      itemcard2ImagesRow.user == currentUserUid,
                  child: const Icon(Icons.favorite),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context)
                      .getText('fab_remove_favourite'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    await ImagesTable().update(
                      data: {'favourite': false},
                      matchingRows: (rows) =>
                          rows.eqOrNull('id', widget.imageid),
                    );
                    unawaited(AnalyticsService.instance
                        .trackFavouriteRemoved(imageId: widget.imageid ?? 0));
                    safeSetState(() {});
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        FFLocalizations.of(context)
                            .getText('fab_favourite_removed'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ));
                  },
                ),
                // Hide from public (owner, not yet hidden)
                SpeedDialChild(
                  visible: !(itemcard2ImagesRow.hided ?? false) &&
                      itemcard2ImagesRow.user == currentUserUid,
                  child: FaIcon(FontAwesomeIcons.eyeSlash),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context).getText('fab_hide'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    if (appState.isprouser) {
                      await ImagesTable().update(
                        data: {'hided': true},
                        matchingRows: (rows) =>
                            rows.eqOrNull('id', widget.imageid),
                      );
                      if (!context.mounted) return;
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) => Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: MakeprivateWidget(imageid: widget.imageid!),
                        ),
                      ).then((value) => safeSetState(() {}));
                    } else {
                      if (!context.mounted) return;
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) => Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: HidenavailabilityWidget(imageid: 0),
                        ),
                      ).then((value) => safeSetState(() {}));
                    }
                  },
                ),
                // Make public (owner, currently hidden)
                SpeedDialChild(
                  visible: (itemcard2ImagesRow.hided ?? false) &&
                      itemcard2ImagesRow.user == currentUserUid,
                  child: FaIcon(FontAwesomeIcons.eye),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context).getText('fab_show'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    await ImagesTable().update(
                      data: {'hided': false},
                      matchingRows: (rows) =>
                          rows.eqOrNull('id', widget.imageid),
                    );
                    safeSetState(() {});
                    if (!context.mounted) return;
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: false,
                      context: context,
                      builder: (context) => const MakepublicWidget(),
                    ).then((value) => safeSetState(() {}));
                  },
                ),
                // Mark as spam (not owner)
                SpeedDialChild(
                  visible: itemcard2ImagesRow.user != currentUserUid,
                  child: const Icon(Icons.block),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context).getText('fab_spam'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    final confirmed = await showModalBottomSheet<bool>(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: false,
                      context: context,
                      builder: (context) => Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: MarkasspamWidget(imageid: widget.imageid!),
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          FFLocalizations.of(context)
                              .getText('spam_hidden_toast'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            FlutterFlowTheme.of(context).primaryText,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ));
                      context.safePop();
                    }
                  },
                ),
                // Copy product (not owner)
                SpeedDialChild(
                  visible: itemcard2ImagesRow.user != currentUserUid,
                  child: const Icon(Icons.copy_all),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context).getText('fab_copy'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    if (currentUserUid.isEmpty || currentUserIsAnonymous) {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        context: context,
                        builder: (context) => _LoginRequiredSheet(),
                      );
                      return;
                    }
                    if (!context.mounted) return;
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: false,
                      context: context,
                      builder: (context) => Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: CopyitemWidget(imageid: widget.imageid!),
                      ),
                    ).then((value) => safeSetState(() {}));
                  },
                ),
                // Delete (owner)
                SpeedDialChild(
                  visible: itemcard2ImagesRow.user == currentUserUid,
                  child: const Icon(Icons.delete_outline),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context).getText('fab_delete'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: false,
                      context: context,
                      builder: (context) => Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: DeleteitemWidget(imageid: widget.imageid!),
                      ),
                    ).then((value) => safeSetState(() {}));
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                if (!_model.loading)
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).primary,
                                    Color(0xFFA7B6CC)
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Full-bleed image — overlaps status bar
                                    Stack(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.5,
                                          child: OctoImage(
                                            placeholderBuilder: (_) =>
                                                SizedBox.expand(
                                              child: Image(
                                                image: BlurHashImage(
                                                    'L6PZfSi_.AyE_3t7t7R**0o#DgR4'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            // Cap decode resolution: a huge
                                            // source image otherwise decodes at
                                            // full size and OOM-kills the app.
                                            image: ResizeImage(
                                              NetworkImage(
                                                _model.imageraw!.firstOrNull!
                                                    .imageUrl,
                                              ),
                                              width: 1080,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // Top gradient for status bar readability
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.black.withAlpha(80),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SelectableText(
                                                  valueOrDefault<String>(
                                                    _model.imageraw?.firstOrNull
                                                        ?.brand,
                                                    '-',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                                ),
                                                SelectableText(
                                                  valueOrDefault<String>(
                                                    _model.imageraw?.firstOrNull
                                                        ?.productName,
                                                    '-',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                                ),
                                              ].divide(SizedBox(height: 10.0)),
                                            ),
                                          ),
                                          if (_model.imageraw?.firstOrNull
                                                  ?.saCompositeScore !=
                                              null)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(0x39FFFFFF),
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 8.0, 12.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    FaIcon(
                                                      FontAwesomeIcons.flask,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      size: 24.0,
                                                    ),
                                                    Text(
                                                      '${valueOrDefault<String>(
                                                        ((int recog,
                                                                int total) {
                                                          return total > 0
                                                              ? ((recog / total) *
                                                                      100)
                                                                  .round()
                                                              : 0;
                                                        }(
                                                            valueOrDefault<int>(
                                                              _model
                                                                  .imageraw
                                                                  ?.firstOrNull
                                                                  ?.saIngredientsRecognized,
                                                              0,
                                                            ),
                                                            valueOrDefault<int>(
                                                              _model
                                                                  .imageraw
                                                                  ?.firstOrNull
                                                                  ?.saIngredientsTotal,
                                                              0,
                                                            ))).toString(),
                                                        '0',
                                                      )} %',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .alternate,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 10.0)),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 20.0),
                                      child: Builder(
                                        builder: (context) {
                                          final bestfor = _model.imageraw
                                                  ?.firstOrNull?.saBestForTags
                                                  .toList() ??
                                              [];

                                          return Wrap(
                                            spacing: 8.0,
                                            runSpacing: 8.0,
                                            alignment: WrapAlignment.start,
                                            children: bestfor
                                                .map((tag) => Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0x62FFFFFF),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24.0),
                                                      ),
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                              horizontal: 12.0,
                                                              vertical: 8.0),
                                                      child: Text(
                                                        tag,
                                                        maxLines: 1,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                      ),
                                                    ))
                                                .toList(),
                                          );
                                        },
                                      ),
                                    ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_model.imageraw?.firstOrNull?.saCompositeScore ==
                            null)
                          _buildPendingPlaceholder(context)
                        else ...[
                          // ── Fit card v2: verdict + tappable skin-type matrix +
                          // active dose statuses + addressed warnings + claim audit.
                          // Matrix taps are ephemeral previews (never written to profile).
                          if (_model.imageraw?.firstOrNull != null)
                            ProductCardV2Widget(
                              image: _model.imageraw!.first,
                              skinCompatibility:
                                  _model.skinCompabilityRaw ?? const [],
                              topIngredients:
                                  _model.topIngredientsRaw ?? const [],
                              ingredientIssues:
                                  _model.ingredientIssuesRaw ?? const [],
                              userSkinType: _model.userSkinType,
                              userIsSensitive: _model.userIsSensitive,
                              userIsAcneProne: _model.userIsAcneProne,
                              isPro: true,
                            ),
                          // ── SPF block (all users, only when product contains UV filters) ──
                          Builder(builder: (context) {
                            final raw = _model.imageraw?.firstOrNull;
                            if (raw == null || !raw.saHasSpf) {
                              return const SizedBox.shrink();
                            }
                            final log = raw.saScoringLog;
                            final spfInfo =
                                (log is Map) ? log['spf_info'] as Map? : null;
                            final filterType =
                                spfInfo?['filter_type'] as String? ?? '';
                            final broadSpectrum =
                                spfInfo?['broad_spectrum'] == true;
                            final filters = (spfInfo?['filters'] as List?)
                                    ?.map((f) => f['name'] as String? ?? '')
                                    .where((n) => n.isNotEmpty)
                                    .toList() ??
                                [];

                            String filterTypeLabel() {
                              final loc = FFLocalizations.of(context);
                              if (filterType == 'mineral')
                                return loc.getText('ic2_filter_mineral');
                              if (filterType == 'chemical')
                                return loc.getText('ic2_filter_chemical');
                              return loc.getText('ic2_filter_combined');
                            }

                            return Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F4FD),
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 8.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(0.0, 2.0),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header row: badge + title
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1565C0),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.wb_sunny_rounded,
                                                    size: 14,
                                                    color: Colors.white),
                                                SizedBox(width: 5),
                                                Text(
                                                  'SPF',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            FFLocalizations.of(context)
                                                .getText('ic2_uv_protection'),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Legend rows
                                      _SpfLegendRow(
                                        icon: Icons.science_rounded,
                                        label: FFLocalizations.of(context)
                                            .getText('ic2_filter_type'),
                                        value: filterTypeLabel(),
                                      ),
                                      const SizedBox(height: 6),
                                      _SpfLegendRow(
                                        icon: broadSpectrum
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked,
                                        iconColor: broadSpectrum
                                            ? const Color(0xFF2E7D32)
                                            : null,
                                        label: FFLocalizations.of(context)
                                            .getText('ic2_broad_spectrum'),
                                        value: '',
                                      ),
                                      if (filters.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        _SpfLegendRow(
                                          icon: Icons.list_rounded,
                                          label: FFLocalizations.of(context)
                                              .getText('ic2_filters'),
                                          value: filters.join(', '),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          // ── Average Price (hidden when not yet available) ──
                          Builder(builder: (context) {
                            final price = _model.priceRow;
                            final avg = price?.avgPrice;
                            if (avg == null) return const SizedBox.shrink();
                            final code = price?.priceCurrencyCode;
                            final min = price?.priceMin;
                            final max = price?.priceMax;

                            Widget _priceCard(Widget content) => Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 16.0, 16.0, 0.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F8FF),
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 8.0,
                                          color: Color(0x1A000000),
                                          offset: Offset(0.0, 2.0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 16.0),
                                      child: content,
                                    ),
                                  ),
                                );

                            return _priceCard(Row(
                              children: [
                                Icon(Icons.sell_outlined,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 28.0),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        FFLocalizations.of(context)
                                            .getText('ic2_avg_price'),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formatPrice(avg, code),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      if (min != null && max != null)
                                        Text(
                                          '${formatPrice(min, code)} – ${formatPrice(max, code)}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (code != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      code,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ));
                          }),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 16.0, 16.0, 0.0),
                            child: wrapWithModel(
                              model: _model.ingridientsModel,
                              updateCallback: () => safeSetState(() {}),
                              child: IngridientsWidget(
                                ingridients: valueOrDefault<String>(
                                  _model.imageraw?.firstOrNull?.ingredients,
                                  '-',
                                ),
                                topIngredients: _model.topIngredientsRaw
                                        ?.map((r) => r.ingredientName
                                            .toLowerCase()
                                            .trim())
                                        .toList() ??
                                    const [],
                                issueIngredients: _model.ingredientIssuesRaw
                                        ?.map((r) => r.ingredientName
                                            .toLowerCase()
                                            .trim())
                                        .toList() ??
                                    const [],
                              ),
                            ),
                          ),
                          Builder(builder: (context) {
                            final img = _model.imageraw?.firstOrNull;
                            final log = img?.saScoringLog;
                              if (log == null) return const SizedBox.shrink();
                              // Prefer the backend's parsed INCI list; fall back
                              // to a client split (keeps "1,2-Hexanediol" intact)
                              // so the 1% ring + issue dots work on old records.
                              final inci = (img?.saInciList.isNotEmpty ?? false)
                                  ? img!.saInciList
                                  : (img?.ingredients ?? '')
                                      .split(RegExp(r',(?!\s*\d)|\n'))
                                      .map((s) => s.trim())
                                      .where((s) => s.isNotEmpty)
                                      .toList();
                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 16.0, 16.0, 0.0),
                                child: ScoreBreakdownWidget(
                                  scoringLog: log,
                                  topIngredients:
                                      _model.topIngredientsRaw ?? const [],
                                  ingredientIssues:
                                      _model.ingredientIssuesRaw ?? const [],
                                  inciList: inci,
                                  onePercentLinePos: img?.saOnePercentLinePos,
                                ),
                              );
                            }),
                          Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F8FF),
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border(
                                    left: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 4.0,
                                    ),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 8.0,
                                      color: Color(0x14000000),
                                      offset: Offset(0.0, 2.0),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 16.0, 16.0, 16.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.lightbulb_circle,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 30.0,
                                          ),
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'sdd57mig' /* How to use */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w700,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 12.0)),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 0.0, 16.0, 16.0),
                                      child: Text(
                                        valueOrDefault<String>(
                                          _model.imageraw?.firstOrNull
                                              ?.saHowToUse,
                                          '-',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Trailing bottom spacer so the last block (e.g. "How
                          // to use" for pro users) is fully visible; extra height
                          // for the anonymous sticky save-banner.
                          SizedBox(
                              height: currentUserIsAnonymous ? 80.0 : 40.0),
                        ], // end of analysis sections
                      ],
                    ),
                  ),
                if (_model.loading)
                  Container(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: FaIcon(
                        FontAwesomeIcons.circleNotch,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 40.0,
                      ).animateOnPageLoad(
                          animationsMap['iconOnPageLoadAnimation']!),
                    ),
                  ),
                if (currentUserIsAnonymous)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _AnonSaveBanner(),
                  ),
                // Fixed back button — top-left corner
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: () => context.safePop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0x2B5C85D9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _AnonSaveBanner extends StatelessWidget {
  const _AnonSaveBanner();

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _AnonSaveSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = FFLocalizations.of(context).getText('ic2_save_to_history');
    final cta = FFLocalizations.of(context).getText('ic2_signin_create');

    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          border: Border(
            top: BorderSide(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.25),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Row(
              children: [
                Icon(
                  Icons.bookmark_border_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          letterSpacing: 0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                ),
                Text(
                  cta,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: FlutterFlowTheme.of(context).primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnonSaveSheet extends StatelessWidget {
  const _AnonSaveSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Icon(Icons.bookmark_rounded,
                  color: FlutterFlowTheme.of(context).primary, size: 36),
              const SizedBox(height: 12),
              Text(
                FFLocalizations.of(context).getText('ic2_save_title'),
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      color: Colors.black,
                      letterSpacing: 0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                FFLocalizations.of(context).getText('ic2_save_body'),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label:
                      FFLocalizations.of(context).getText('cm_create_account'),
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed(CreateAccountPageWidget.routeName);
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: FFLocalizations.of(context).getText('ic2_sign_in'),
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed(LogInPageWidget.routeName);
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  FFLocalizations.of(context).getText('ic2_not_now'),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyFactRow extends StatelessWidget {
  const _KeyFactRow({
    required this.isWarning,
    required this.name,
    required this.detail,
  });
  final bool isWarning;
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isWarning
                ? const Color(0xFFFF7043).withOpacity(0.35)
                : FlutterFlowTheme.of(context).primary.withOpacity(0.25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isWarning ? '⚠️' : '✅',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginRequiredSheet extends StatelessWidget {
  const _LoginRequiredSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.lock_outline_rounded,
            size: 48,
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(height: 16),
          Text(
            FFLocalizations.of(context)
                .getText('copy_login_title' /* Sign in to copy */),
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            FFLocalizations.of(context).getText(
                'copy_login_body' /* Create a free account to copy products to your profile. */),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: const Color(0xFF666666),
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: FFLocalizations.of(context)
                  .getText('copy_login_btn' /* Sign in */),
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed(LogInPageWidget.routeName);
              },
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              FFLocalizations.of(context)
                  .getText('copy_login_cancel' /* Cancel */),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlaskResearchAnimation extends StatefulWidget {
  const _FlaskResearchAnimation();

  @override
  State<_FlaskResearchAnimation> createState() =>
      _FlaskResearchAnimationState();
}

class _FlaskResearchAnimationState extends State<_FlaskResearchAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = FlutterFlowTheme.of(context).primary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(80, 94),
        painter: _FlaskPainter(t: _ctrl.value, color: color),
      ),
    );
  }
}

class _FlaskPainter extends CustomPainter {
  final double t;
  final Color color;

  const _FlaskPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Flask geometry
    final neckL = w * 0.38;
    final neckR = w * 0.62;
    final neckTop = h * 0.05;
    final neckBot = h * 0.35;
    final cx = w * 0.5;
    final cy = h * 0.71;
    final rx = w * 0.40;
    final ry = h * 0.26;

    // Flask outline path (Erlenmeyer style)
    final flaskPath = Path()
      ..moveTo(neckL, neckTop)
      ..lineTo(neckR, neckTop)
      ..lineTo(neckR, neckBot)
      ..quadraticBezierTo(neckR, cy - ry * 0.5, cx + rx, cy)
      ..arcToPoint(Offset(cx - rx, cy),
          radius: Radius.elliptical(rx, ry), clockwise: false)
      ..quadraticBezierTo(neckL, cy - ry * 0.5, neckL, neckBot)
      ..close();

    // Clip to flask shape for liquid + bubbles
    canvas.save();
    canvas.clipPath(flaskPath);

    // Liquid fill (two wave layers)
    final liquidY = cy - ry * 0.18;
    const waveAmp = 3.5;

    void drawWave(double phaseOffset, double opacity) {
      final path = Path();
      path.moveTo(0, liquidY + waveAmp * sin((t + phaseOffset) * 2 * pi));
      for (double x = 0; x <= w; x++) {
        path.lineTo(
          x,
          liquidY + waveAmp * sin((x / w * 2.5 + t + phaseOffset) * 2 * pi),
        );
      }
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.close();
      canvas.drawPath(
          path, Paint()..color = color.withAlpha((255 * opacity).round()));
    }

    drawWave(0.0, 0.22);
    drawWave(0.18, 0.16);

    // Rising bubbles
    const bubbles = [
      (0.30, 0.00, 3.5),
      (0.55, 0.37, 4.0),
      (0.42, 0.63, 2.5),
      (0.68, 0.18, 3.2),
      (0.22, 0.80, 2.0),
    ];
    for (final b in bubbles) {
      final xFrac = b.$1;
      final phase = b.$2;
      final r = b.$3;
      final bt = (t + phase) % 1.0;
      final startY = cy + ry * 0.75;
      final endY = liquidY - r * 1.5;
      final y = startY - (startY - endY) * bt;
      final x = w * xFrac + sin(bt * pi * 3) * 4.0;
      final alpha = bt > 0.75 ? (1.0 - bt) / 0.25 : 1.0;
      canvas.drawCircle(
        Offset(x, y),
        r * (0.5 + 0.5 * bt),
        Paint()..color = color.withAlpha((140 * alpha).round()),
      );
    }

    canvas.restore();

    // Flask stroke
    canvas.drawPath(
      flaskPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Opening rim
    canvas.drawLine(
      Offset(neckL - 3, neckTop),
      Offset(neckR + 3, neckTop),
      Paint()
        ..color = color
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // Floating sparkle dots (research effect)
    const sparks = [
      (0.07, 0.42, 0.00),
      (0.93, 0.48, 0.33),
      (0.87, 0.28, 0.66),
    ];
    for (final s in sparks) {
      final sx = w * s.$1;
      final sy = h * s.$2;
      final phase = s.$3;
      final st = (t + phase) % 1.0;
      final alpha = sin(st * pi);
      final dy = -sin(st * pi) * 9;
      canvas.drawCircle(
        Offset(sx, sy + dy),
        2.5,
        Paint()..color = color.withAlpha((160 * alpha).round()),
      );
    }
  }

  @override
  bool shouldRepaint(_FlaskPainter old) => old.t != t;
}

class _SpfLegendRow extends StatelessWidget {
  const _SpfLegendRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 16,
            color: iconColor ?? FlutterFlowTheme.of(context).secondaryText),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    fontSize: 13,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
              children: [
                TextSpan(
                  text: '$label',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (value.isNotEmpty) TextSpan(text: ':  $value'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
