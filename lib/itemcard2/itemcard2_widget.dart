import 'dart:async';
import 'dart:math' show sin, pi;
import '/auth/supabase_auth/auth_util.dart';
import '/components/feedback_collector/feedback_collector_widget.dart';
import '/components/feedback_collector/feedback_service.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '/flutter_flow/analytics_service.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/database/tables/ingredients_efficacy.dart';
import '/backend/supabase/database/tables/product_prices.dart';
import '/backend/supabase/supabase.dart';
import '/app_state.dart';
import '/boards/albumslist/albumslist_widget.dart';
import '/components/new_album/new_album_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item_card/deleteitem/deleteitem_widget.dart';
import '/item_card/ingridients/ingridients_widget.dart';
import '/components/score_breakdown/score_breakdown_widget.dart';
import '/item_card/markasspam/markasspam_widget.dart';
import '/topratings/copyitem/copyitem_widget.dart';
import '/topratings/hidenavailability/hidenavailability_widget.dart';
import '/topratings/makeprivate/makeprivate_widget.dart';
import '/topratings/makepublic/makepublic_widget.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:octo_image/octo_image.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  var hasContainerTriggered1 = false;
  var hasContainerTriggered2 = false;
  bool? _feedbackVote; // true = helpful, false = not helpful, null = no vote
  bool _proPreviewActive = false;
  bool _proPreviewUsed = false;
  late AnimationController _proPreviewPulse;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Itemcard2Model());
    _loadFeedbackVote();
    _loadProPreviewState();
    _proPreviewPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0.65,
      upperBound: 1.0,
    )..repeat(reverse: true);

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      unawaited(AnalyticsService.instance.trackCardOpened(
        imageId: widget.imageid ?? 0,
        source: 'direct',
      ));
      _model.imageraw = await ImagesTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          widget.imageid,
        ),
      );
      final _img = _model.imageraw?.firstOrNull;
      if (_img != null) {
        final _nameKey = (_img.productName ?? '').toLowerCase().trim();
        final _brandKey = (_img.brand ?? '').toLowerCase().trim();
        final _countryCode = FFAppState().countrycodeiso;
        if (_nameKey.isNotEmpty && _brandKey.isNotEmpty && _countryCode.isNotEmpty) {
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
      _model.skinCompabilityRaw = await ImageSkinCompatibilityTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'image_id',
          widget.imageid,
        ),
      );
      _model.topIngredientsRaw = await ImageTopIngredientsTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'image_id',
          widget.imageid,
        ),
      );
      _model.ingredientIssuesRaw =
          await ImageIngredientIssuesTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'image_id',
          widget.imageid,
        ),
      );
      _loadEfficacyDescriptions();
      _model.loading = false;
      _model.overallscore = valueOrDefault<int>(
        (valueOrDefault<double>(
                  _model.imageraw?.firstOrNull?.saCompositeScore,
                  0.0,
                ) ??
                0)
            .round(),
        0,
      );
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
          _model.imageraw = await ImagesTable().queryRows(
            queryFn: (q) => q.eqOrNull('id', widget.imageid),
          );
          _model.skinCompabilityRaw =
              await ImageSkinCompatibilityTable().queryRows(
            queryFn: (q) => q.eqOrNull('image_id', widget.imageid),
          );
          _model.topIngredientsRaw =
              await ImageTopIngredientsTable().queryRows(
            queryFn: (q) => q.eqOrNull('image_id', widget.imageid),
          );
          _model.ingredientIssuesRaw =
              await ImageIngredientIssuesTable().queryRows(
            queryFn: (q) => q.eqOrNull('image_id', widget.imageid),
          );
          _loadEfficacyDescriptions();
          _model.overallscore = valueOrDefault<int>(
            (valueOrDefault<double>(
                          _model.imageraw?.firstOrNull?.saCompositeScore,
                          0.0,
                        ) ??
                        0)
                    .round(),
            0,
          );
          safeSetState(() {});
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
        await FirebaseAnalytics.instance.logEvent(name: 'feedback_prompt_shown');
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

    _model.textFieldFocusNode ??= FocusNode();

    animationsMap.addAll({
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOutQuint,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.105,
            end: 1.0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOutQuint,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.105,
            end: 1.0,
          ),
        ],
      ),
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
    _proPreviewPulse.dispose();
    _model.dispose();

    super.dispose();
  }

  Future<void> _loadFeedbackVote() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'feedback_vote_${widget.imageid}';
    if (prefs.containsKey(key)) {
      safeSetState(() => _feedbackVote = prefs.getBool(key));
    }
  }

  Future<void> _loadProPreviewState() async {
    final prefs = await SharedPreferences.getInstance();
    safeSetState(() {
      _proPreviewUsed = prefs.getBool('pro_preview_used') ?? false;
    });
  }

  Future<void> _activateProPreview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_preview_used', true);
    safeSetState(() {
      _proPreviewActive = true;
      _proPreviewUsed = true;
    });
  }

  Future<void> _saveFeedbackVote(bool vote) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('feedback_vote_${widget.imageid}', vote);
  }

  Color _scoreColor(int s) {
    if (s >= 75) return const Color(0xFF1B5E20);
    if (s >= 65) return const Color(0xFF43A047);
    if (s >= 55) return const Color(0xFFC0CA33);
    if (s >= 45) return const Color(0xFFFFB300);
    if (s >= 35) return const Color(0xFFFF7043);
    return const Color(0xFFD32F2F);
  }

  Future<void> _loadEfficacyDescriptions() async {
    final names = [
      ...?_model.topIngredientsRaw?.map((r) => r.ingredientName),
      ...?_model.ingredientIssuesRaw?.map((r) => r.ingredientName),
    ];
    if (names.isEmpty) return;
    try {
      final rows = await IngredientsEfficacyTable().queryRows(
        queryFn: (q) => q.inFilterOrNull('inci_name', names),
      );
      _model.efficacyDescMap = {
        for (final r in rows) r.inciName.toLowerCase(): r,
      };
      if (mounted) safeSetState(() {});
    } catch (_) {}
  }

  String _efficacyDesc(String ingredientName, String lang, String? fallback) {
    final row = _model.efficacyDescMap[ingredientName.toLowerCase()];
    if (row == null) return fallback ?? '';
    if (lang == 'ru') return row.descriptionRu ?? row.descriptionEn ?? fallback ?? '';
    if (lang == 'es') return row.descriptionEs ?? row.descriptionEn ?? fallback ?? '';
    return row.descriptionEn ?? fallback ?? '';
  }

  String _currencySymbol(String? code) {
    const symbols = {
      'ARS': 'AR\$', 'CAD': 'CA\$', 'CLP': 'CL\$', 'CNY': '¥',
      'COP': 'CO\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
      'KRW': '₩', 'MXN': 'MX\$', 'PEN': 'S/', 'RUB': '₽', 'USD': '\$',
    };
    return symbols[code] ?? code ?? '';
  }

String _formatPrice(double price, String? code) {
    final sym = _currencySymbol(code);
    return '$sym${price.round()}';
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
                  fontWeight: FontWeight.bold,
                  useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            FFLocalizations.of(context).getText('analysis_pending_body'),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  String _scoreGrade(int s) {
    if (s >= 75) return 'A';
    if (s >= 65) return 'B';
    if (s >= 55) return 'C';
    if (s >= 45) return 'D';
    return 'F';
  }

  Widget _axisBar(BuildContext context, String label, double? value) {
    final v = (value ?? 0.0).clamp(0.0, 100.0);
    final color = _scoreColor(v.round());
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                value == null ? '—' : '${v.round()}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: value == null
                      ? FlutterFlowTheme.of(context).secondaryText
                      : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            percent: v / 100.0,
            lineHeight: 6.0,
            backgroundColor: color.withOpacity(0.12),
            progressColor: value == null ? Colors.transparent : color,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            animation: true,
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
                    unawaited(AnalyticsService.instance.trackShareLinkTapped(imageId: widget.imageid ?? 0));
                    await Future.delayed(const Duration(milliseconds: 300));
                    final size = MediaQuery.of(context).size;
                    await Share.share(
                      'https://mirra.up.railway.app/product/${widget.imageid}',
                      sharePositionOrigin: Rect.fromLTWH(size.width / 2, size.height / 2, 1, 1),
                    );
                  },
                ),
                // Add to album
                SpeedDialChild(
                  child: const Icon(Icons.add_box),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  label: FFLocalizations.of(context).getText('fab_add_to_album'),
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
                  label: FFLocalizations.of(context).getText('fab_add_favourite'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    await ImagesTable().update(
                      data: {'favourite': true},
                      matchingRows: (rows) => rows.eqOrNull('id', widget.imageid),
                    );
                    unawaited(AnalyticsService.instance.trackFavouriteAdded(imageId: widget.imageid ?? 0));
                    safeSetState(() {});
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        FFLocalizations.of(context).getText('fab_favourite_added'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                  label: FFLocalizations.of(context).getText('fab_remove_favourite'),
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium,
                  onTap: () async {
                    await ImagesTable().update(
                      data: {'favourite': false},
                      matchingRows: (rows) => rows.eqOrNull('id', widget.imageid),
                    );
                    unawaited(AnalyticsService.instance.trackFavouriteRemoved(imageId: widget.imageid ?? 0));
                    safeSetState(() {});
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        FFLocalizations.of(context).getText('fab_favourite_removed'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                        matchingRows: (rows) => rows.eqOrNull('id', widget.imageid),
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
                      matchingRows: (rows) => rows.eqOrNull('id', widget.imageid),
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
                          FFLocalizations.of(context).getText('spam_hidden_toast'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: FlutterFlowTheme.of(context).primaryText,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                                          width: MediaQuery.sizeOf(context).width,
                                          height: MediaQuery.sizeOf(context).height * 0.5,
                                          child: OctoImage(
                                            placeholderBuilder: (_) =>
                                                SizedBox.expand(
                                              child: Image(
                                                image: BlurHashImage(
                                                    'L6PZfSi_.AyE_3t7t7R**0o#DgR4'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            image: NetworkImage(
                                              _model.imageraw!.firstOrNull!
                                                  .imageUrl,
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
                                                            FontWeight.bold,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                                ),
                                              ].divide(SizedBox(height: 10.0)),
                                            ),
                                          ),
                                          if (_model.imageraw?.firstOrNull?.saCompositeScore != null)
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.flask,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    size: 24.0,
                                                  ),
                                                  Text(
                                                    '${valueOrDefault<String>(
                                                      ((int recog, int total) {
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
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                              FontWeight.bold,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(width: 10.0)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 20.0),
                                      child: Builder(
                                        builder: (context) {
                                          final bestfor = _model.imageraw
                                                  ?.firstOrNull?.saBestForTags
                                                  .toList() ??
                                              [];

                                          return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: List.generate(
                                                  bestfor.length,
                                                  (bestforIndex) {
                                                final bestforItem =
                                                    bestfor[bestforIndex];
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0x62FFFFFF),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(12.0, 8.0,
                                                                12.0, 8.0),
                                                    child: Text(
                                                      bestforItem,
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
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              }).divide(SizedBox(width: 10.0)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_model.imageraw?.firstOrNull?.saCompositeScore == null)
                          _buildPendingPlaceholder(context)
                        else ...[
                        // ── Verdict card (all users) ──
                        Builder(builder: (context) {
                          final score = _model.overallscore ?? 0;
                          final sColor = _scoreColor(score);
                          final grade = _scoreGrade(score);
                          final ratingText = _model.imageraw?.firstOrNull?.saRatingText ?? '';
                          final summary = _model.imageraw?.firstOrNull?.saQuickSummary ?? '';
                          return Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 16.0, 16.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F8FF),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 24.0,
                                    color: sColor.withOpacity(0.28),
                                    offset: const Offset(0.0, 6.0),
                                  ),
                                  const BoxShadow(
                                    blurRadius: 8.0,
                                    color: Color(0x1A000000),
                                    offset: Offset(0.0, 2.0),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Score ring with glow
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: sColor.withOpacity(0.35),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: CircularPercentIndicator(
                                        radius: 46.0,
                                        lineWidth: 8.0,
                                        percent: (score / 100.0).clamp(0.0, 1.0),
                                        backgroundColor:
                                            sColor.withOpacity(0.12),
                                        progressColor: sColor,
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        animation: true,
                                        center: Text(
                                          grade,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: sColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Rating + summary
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (ratingText.isNotEmpty)
                                            Text(
                                              ratingText,
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                            ),
                                          if (ratingText.isNotEmpty)
                                            const SizedBox(height: 6),
                                          if (summary.isNotEmpty)
                                            Text(
                                              summary,
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        // ── Axis scores (all users) ──
                        Builder(builder: (context) {
                          final raw = _model.imageraw?.firstOrNull;
                          if (raw == null) return const SizedBox.shrink();
                          final lang =
                              FFLocalizations.of(context).languageCode;
                          final axes = [
                            (_axisLabel(lang, 'efficacy'), raw.saEfficacyScore),
                            (_axisLabel(lang, 'safety'), raw.saSafetyScore),
                            (_axisLabel(lang, 'stability'), raw.saStabilityScore),
                            (_axisLabel(lang, 'experience'), raw.saUxScore),
                            (_axisLabel(lang, 'pore_safety'), raw.saComedogenicityScore),
                          ];
                          if (axes.every((e) => e.$2 == null)) {
                            return const SizedBox.shrink();
                          }
                          final left = [axes[0], axes[2], axes[4]];
                          final right = [axes[1], axes[3]];
                          return Padding(
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
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: left
                                            .map((e) => _axisBar(
                                                context, e.$1, e.$2))
                                            .toList(),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: right
                                            .map((e) => _axisBar(
                                                context, e.$1, e.$2))
                                            .toList(),
                                      ),
                                    ),
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
                          final lang = FFLocalizations.of(context).languageCode;

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
                                        horizontal: 20.0, vertical: 16.0),
                                    child: content,
                                  ),
                                ),
                              );

                          return _priceCard(Row(
                              children: [
                                Icon(Icons.sell_outlined,
                                    color:
                                        FlutterFlowTheme.of(context).primary,
                                    size: 28.0),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        lang == 'ru'
                                            ? 'Средняя цена'
                                            : lang == 'es'
                                                ? 'Precio promedio'
                                                : 'Average Price',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color: FlutterFlowTheme.of(
                                                      context)
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
                                        _formatPrice(avg, code),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      if (min != null && max != null)
                                        Text(
                                          '${_formatPrice(min, code)} – ${_formatPrice(max, code)}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color: FlutterFlowTheme.of(
                                                        context)
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
                                      borderRadius:
                                          BorderRadius.circular(8.0),
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
                        // ── SPF block (all users, only when product contains UV filters) ──
                        Builder(builder: (context) {
                          final raw = _model.imageraw?.firstOrNull;
                          if (raw == null || !raw.saHasSpf) {
                            return const SizedBox.shrink();
                          }
                          final log = raw.saScoringLog;
                          final spfInfo = (log is Map) ? log['spf_info'] as Map? : null;
                          final filterType   = spfInfo?['filter_type'] as String? ?? '';
                          final broadSpectrum = spfInfo?['broad_spectrum'] == true;
                          final filters = (spfInfo?['filters'] as List?)
                              ?.map((f) => f['name'] as String? ?? '')
                              .where((n) => n.isNotEmpty)
                              .toList() ?? [];
                          final lang = FFLocalizations.of(context).languageCode;

                          String filterTypeLabel() {
                            if (lang == 'ru') {
                              if (filterType == 'mineral') return 'Минеральный';
                              if (filterType == 'chemical') return 'Химический';
                              return 'Минеральный + химический';
                            } else if (lang == 'es') {
                              if (filterType == 'mineral') return 'Mineral';
                              if (filterType == 'chemical') return 'Químico';
                              return 'Mineral + químico';
                            } else {
                              if (filterType == 'mineral') return 'Mineral';
                              if (filterType == 'chemical') return 'Chemical';
                              return 'Mineral + chemical';
                            }
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
                                    horizontal: 20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header row: badge + title
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1565C0),
                                            borderRadius: BorderRadius.circular(8),
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
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          lang == 'ru'
                                              ? 'Солнцезащитный фильтр'
                                              : lang == 'es'
                                                  ? 'Filtro solar'
                                                  : 'UV Protection',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMediumFamily,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(context)
                                                        .bodyMediumIsCustom,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Legend rows
                                    _SpfLegendRow(
                                      icon: Icons.science_rounded,
                                      label: lang == 'ru'
                                          ? 'Тип фильтра'
                                          : lang == 'es'
                                              ? 'Tipo de filtro'
                                              : 'Filter type',
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
                                      label: lang == 'ru'
                                          ? 'Широкий спектр (UVA + UVB)'
                                          : lang == 'es'
                                              ? 'Espectro amplio (UVA + UVB)'
                                              : 'Broad spectrum (UVA + UVB)',
                                      value: '',
                                    ),
                                    if (filters.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      _SpfLegendRow(
                                        icon: Icons.list_rounded,
                                        label: lang == 'ru'
                                            ? 'Фильтры'
                                            : lang == 'es'
                                                ? 'Filtros'
                                                : 'Filters',
                                        value: filters.join(', '),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (appState.isprouser || _proPreviewActive)
                          Builder(builder: (context) {
                            final log = _model.imageraw?.firstOrNull?.saScoringLog;
                            if (log == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 0.0),
                              child: ScoreBreakdownWidget(scoringLog: log),
                            );
                          }),
                        if (appState.isprouser || _proPreviewActive)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 24.0, 16.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F8FF),
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border(
                                left: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
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
                                      16.0, 16.0, 16.0, 16.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.fire,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 30.0,
                                      ),
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          'cox122eb' /* Expert Analysis */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 16.0),
                                  child: Text(
                                    valueOrDefault<String>(
                                      _model.imageraw?.firstOrNull
                                          ?.saExpertAnalysis,
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
                        if (appState.isprouser || _proPreviewActive)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F8FF),
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border(
                                left: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
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
                                      16.0, 16.0, 16.0, 16.0),
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
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 16.0),
                                  child: Text(
                                    valueOrDefault<String>(
                                      _model.imageraw?.firstOrNull?.saHowToUse,
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
                        if (appState.isprouser || _proPreviewActive)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 24.0, 0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'pt08joyi' /* Skin Type Compatibility */,
                            ),
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ),
                        if (appState.isprouser || _proPreviewActive)
                        Builder(
                          builder: (context) {
                            final skintypecompatibility = _model
                                    .skinCompabilityRaw
                                    ?.map((e) => e)
                                    .toList()
                                    .toList() ??
                                [];

                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  List.generate(skintypecompatibility.length,
                                      (skintypecompatibilityIndex) {
                                final skintypecompatibilityItem =
                                    skintypecompatibility[
                                        skintypecompatibilityIndex];
                                return Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 12.0, 16.0, 0.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      borderRadius: BorderRadius.circular(24.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  _skinTypeLabel(
                                                    skintypecompatibilityItem
                                                        .skinType,
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        0.35,
                                                    child:
                                                        LinearPercentIndicator(
                                                      percent:
                                                          (valueOrDefault<int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) ??
                                                                  0) /
                                                              100,
                                                      lineHeight: 12.0,
                                                      animation: true,
                                                      animateFromLastPercent:
                                                          true,
                                                      progressColor:
                                                          valueOrDefault<Color>(
                                                        () {
                                                          if (valueOrDefault<
                                                                  int>(
                                                                skintypecompatibilityItem
                                                                    .compatibilityScore,
                                                                0,
                                                              ) >=
                                                              75) {
                                                            return Color(
                                                                0xFF1B5E20);
                                                          } else if ((valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) <
                                                                  75) &&
                                                              (valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) >=
                                                                  65)) {
                                                            return Color(
                                                                0xFF43A047);
                                                          } else if ((valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) <
                                                                  65) &&
                                                              (valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) >=
                                                                  55)) {
                                                            return Color(
                                                                0xFFC0CA33);
                                                          } else if ((valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) <
                                                                  55) &&
                                                              (valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) >=
                                                                  45)) {
                                                            return Color(
                                                                0xFFFFB300);
                                                          } else if ((valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) <
                                                                  45) &&
                                                              (valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) >=
                                                                  35)) {
                                                            return Color(
                                                                0xFFFF7043);
                                                          } else if ((valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) <
                                                                  35) &&
                                                              (valueOrDefault<
                                                                      int>(
                                                                    skintypecompatibilityItem
                                                                        .compatibilityScore,
                                                                    0,
                                                                  ) >=
                                                                  25)) {
                                                            return Colors.red;
                                                          } else {
                                                            return Color(
                                                                0xFFD32F2F);
                                                          }
                                                        }(),
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText,
                                                      ),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                      barRadius:
                                                          Radius.circular(16.0),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ),
                                                  Text(
                                                    valueOrDefault<String>(
                                                      skintypecompatibilityItem
                                                          .compatibilityScore
                                                          .toString(),
                                                      '0',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(width: 16.0)),
                                              ),
                                            ],
                                          ),
                                        ].divide(SizedBox(height: 10.0)),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                        // ── Top Negative Ingredients ──
                        Builder(builder: (context) {
                          final isPro = appState.isprouser || _proPreviewActive;
                          final lang = FFLocalizations.of(context).languageCode;
                          final allNegative = _model.ingredientIssuesRaw?.toList() ?? [];
                          if (allNegative.isEmpty) return const SizedBox.shrink();
                          final shown = isPro ? allNegative : allNegative.take(1).toList();
                          final hiddenCount = allNegative.length - shown.length;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                                child: Text(
                                  FFLocalizations.of(context).getText('top_negative_ingredients'),
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                      ),
                                ),
                              ),
                              ...shown.map((issue) => Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).alternate,
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color: const Color(0xFFFF7043).withOpacity(0.35),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('⚠️', style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                issue.ingredientName,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                      fontSize: 16.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.bold,
                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                    ),
                                              ),
                                              if (_efficacyDesc(issue.ingredientName, lang, issue.description ?? issue.issueType).isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  _efficacyDesc(issue.ingredientName, lang, issue.description ?? issue.issueType),
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                        color: FlutterFlowTheme.of(context).secondaryText,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
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
                              )),
                              if (!isPro && hiddenCount > 0)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                                  child: InkWell(
                                    onTap: () => context.pushNamed(PaywallpageWidget.routeName),
                                    child: Text(
                                      '+$hiddenCount ${FFLocalizations.of(context).getText('more_in_pro')}',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context).primary,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                        // ── Top Active Ingredients ──
                        Builder(
                          builder: (context) {
                            final isPro = appState.isprouser || _proPreviewActive;
                            final lang = FFLocalizations.of(context).languageCode;
                            final allIngredients = _model.topIngredientsRaw?.toList() ?? [];
                            if (allIngredients.isEmpty) return const SizedBox.shrink();
                            final topIngredients = isPro ? allIngredients : allIngredients.take(3).toList();
                            final hiddenCount = allIngredients.length - topIngredients.length;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                                child: Text(
                                  FFLocalizations.of(context).getText('gs46omyo'),
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                      ),
                                ),
                              ),
                              ...List.generate(topIngredients.length, (topIngredientsIndex) {
                                final topIngredientsItem =
                                    topIngredients[topIngredientsIndex];
                                return Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 12.0, 16.0, 0.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      borderRadius: BorderRadius.circular(24.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      valueOrDefault<String>(
                                                        topIngredientsItem
                                                            .ingredientName,
                                                        '-',
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                    Text(
                                                      valueOrDefault<String>(
                                                        topIngredientsItem.category,
                                                        '-',
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            fontSize: 11.0,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                    Text(
                                                      _efficacyDesc(
                                                        topIngredientsItem.ingredientName,
                                                        lang,
                                                        topIngredientsItem.description,
                                                      ).isNotEmpty
                                                          ? _efficacyDesc(topIngredientsItem.ingredientName, lang, topIngredientsItem.description)
                                                          : (topIngredientsItem.description ?? '-'),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 12.0)),
                                                ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'sgfwkpt4' /* Position */,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                  Text(
                                                    '#${valueOrDefault<String>(
                                                      topIngredientsItem
                                                          .inciPosition
                                                          ?.toString(),
                                                      '0',
                                                    )}',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          fontSize: 20.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ].divide(
                                                    SizedBox(height: 10.0)),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  '92xu2duz' /* Efficacy Contribution */,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          fontSize: 11.0,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                              Text(
                                                '${valueOrDefault<String>(
                                                  topIngredientsItem
                                                      .efficacyContribution
                                                      ?.toString(),
                                                  '0',
                                                )}%',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ].divide(SizedBox(height: 10.0)),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              if (!isPro && hiddenCount > 0)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                                  child: InkWell(
                                    onTap: () => context.pushNamed(PaywallpageWidget.routeName),
                                    child: Text(
                                      '+$hiddenCount ${FFLocalizations.of(context).getText('more_in_pro')}',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context).primary,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                        // ── Paywall upsell (free users only) ──
                        if (!appState.isprouser && !_proPreviewActive)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 24.0, 16.0, 32.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.lock_outline_rounded,
                                            color: FlutterFlowTheme.of(context).primary,
                                            size: 22.0),
                                        SizedBox(width: 10),
                                        Text(
                                          FFLocalizations.of(context).languageCode == 'ru'
                                              ? 'Полный анализ — в Pro'
                                              : FFLocalizations.of(context).languageCode == 'es'
                                                  ? 'Análisis completo en Pro'
                                                  : 'Full Analysis in Pro',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.0,
                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 14),
                                    _PaywallBullet(
                                      icon: Icons.all_inclusive_rounded,
                                      label: FFLocalizations.of(context).languageCode == 'ru'
                                          ? 'Безлимитное количество сканов'
                                          : FFLocalizations.of(context).languageCode == 'es'
                                              ? 'Escaneos ilimitados'
                                              : 'Unlimited scans',
                                    ),
                                    _PaywallBullet(
                                      icon: Icons.science_outlined,
                                      label: FFLocalizations.of(context).languageCode == 'ru'
                                          ? 'Экспертный разбор состава'
                                          : FFLocalizations.of(context).languageCode == 'es'
                                              ? 'Análisis experto de ingredientes'
                                              : 'Expert ingredient breakdown',
                                    ),
                                    _PaywallBullet(
                                      icon: Icons.list_alt_rounded,
                                      label: FFLocalizations.of(context).languageCode == 'ru'
                                          ? 'Полный состав INCI'
                                          : FFLocalizations.of(context).languageCode == 'es'
                                              ? 'Lista completa de ingredientes INCI'
                                              : 'Full INCI ingredient list',
                                    ),
                                    _PaywallBullet(
                                      icon: Icons.lightbulb_outline_rounded,
                                      label: FFLocalizations.of(context).languageCode == 'ru'
                                          ? 'Как правильно использовать'
                                          : FFLocalizations.of(context).languageCode == 'es'
                                              ? 'Cómo usar correctamente'
                                              : 'How-to-use guide',
                                    ),
                                    _PaywallBullet(
                                      icon: Icons.face_retouching_natural,
                                      label: FFLocalizations.of(context).languageCode == 'ru'
                                          ? 'Совместимость с 5 типами кожи'
                                          : FFLocalizations.of(context).languageCode == 'es'
                                              ? 'Compatibilidad con 5 tipos de piel'
                                              : 'Skin compatibility for 5 skin types',
                                    ),
                                    _PaywallBullet(
                                      icon: Icons.list_alt_rounded,
                                      label: FFLocalizations.of(context).languageCode == 'ru'
                                          ? 'Все активные ингредиенты с эффективностью'
                                          : FFLocalizations.of(context).languageCode == 'es'
                                              ? 'Todos los ingredientes con eficacia'
                                              : 'All active ingredients with efficacy scores',
                                    ),
                                    _PaywallBullet(
                                      icon: Icons.notes_rounded,
                                      label: FFLocalizations.of(context).languageCode == 'ru'
                                          ? 'Личные заметки к продукту'
                                          : FFLocalizations.of(context).languageCode == 'es'
                                              ? 'Notas personales del producto'
                                              : 'Personal notes for your product',
                                    ),
                                    SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => context.pushNamed(PaywallpageWidget.routeName),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: FlutterFlowTheme.of(context).primary,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(vertical: 14.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        ),
                                        child: Text(
                                          FFLocalizations.of(context).languageCode == 'ru'
                                              ? 'Перейти на Pro'
                                              : FFLocalizations.of(context).languageCode == 'es'
                                                  ? 'Ir a Pro'
                                                  : 'Upgrade to Pro',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.0,
                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                    if (!_proPreviewUsed) ...[
                                      SizedBox(height: 16),
                                      Center(
                                        child: AnimatedBuilder(
                                          animation: _proPreviewPulse,
                                          builder: (context, child) => Opacity(
                                            opacity: _proPreviewPulse.value,
                                            child: child,
                                          ),
                                          child: GestureDetector(
                                            onTap: _activateProPreview,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  width: 1.5,
                                                ),
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                FFLocalizations.of(context).languageCode == 'ru'
                                                    ? 'Посмотреть Pro-анализ один раз бесплатно →'
                                                    : FFLocalizations.of(context).languageCode == 'es'
                                                        ? 'Ver análisis Pro una vez gratis →'
                                                        : 'Preview Pro analysis once for free →',
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w600,
                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (appState.isprouser)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 24.0, 16.0, 24.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).alternate,
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      'ijod64a2' /* Your feedback */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      'e2fxci9s' /* Was this analysis helpful?  */,
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
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          if (animationsMap[
                                                  'containerOnActionTriggerAnimation1'] !=
                                              null) {
                                            safeSetState(() =>
                                                hasContainerTriggered1 = true);
                                            SchedulerBinding.instance
                                                .addPostFrameCallback(
                                                    (_) async => animationsMap[
                                                            'containerOnActionTriggerAnimation1']!
                                                        .controller
                                                        .forward(from: 0.0));
                                          }
                                          _model.apiResult6oo =
                                              await FeedbackNEWBCNDCall.call(
                                            host: FFDevEnvironmentValues()
                                                .backendhost,
                                            imageId:
                                                widget.imageid?.toString(),
                                            userId: currentUserUid,
                                            vote: true,
                                            token: currentJwtToken,
                                          );

                                          if ((_model.apiResult6oo?.succeeded ??
                                              true)) {
                                            safeSetState(
                                                () => _feedbackVote = true);
                                            unawaited(_saveFeedbackVote(true));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Thnaks for your feedback!',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 4000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Ups! Something went wrong!',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 4000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                              ),
                                            );
                                          }

                                          safeSetState(() {});
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _feedbackVote == true
                                                ? const Color(0xFF43A047)
                                                    .withOpacity(0.1)
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: _feedbackVote == true
                                                  ? const Color(0xFF43A047)
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              width:
                                                  _feedbackVote == true ? 2.0 : 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    22.0, 18.0, 22.0, 18.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.thumb_up_rounded,
                                                  color: _feedbackVote == true
                                                      ? const Color(0xFF43A047)
                                                      : const Color(0xE61A1A1A),
                                                  size: 24.0,
                                                ),
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'on05z6xe' /* Helpful */,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        color: _feedbackVote ==
                                                                true
                                                            ? const Color(
                                                                0xFF43A047)
                                                            : const Color(
                                                                0xEA1A1A1A),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                                ),
                                              ].divide(SizedBox(width: 10.0)),
                                            ),
                                          ),
                                        ),
                                      ).animateOnActionTrigger(
                                          animationsMap[
                                              'containerOnActionTriggerAnimation1']!,
                                          hasBeenTriggered:
                                              hasContainerTriggered1),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          if (animationsMap[
                                                  'containerOnActionTriggerAnimation2'] !=
                                              null) {
                                            safeSetState(() =>
                                                hasContainerTriggered2 = true);
                                            SchedulerBinding.instance
                                                .addPostFrameCallback(
                                                    (_) async => animationsMap[
                                                            'containerOnActionTriggerAnimation2']!
                                                        .controller
                                                        .forward(from: 0.0));
                                          }
                                          _model.apiResult6oo8 =
                                              await FeedbackNEWBCNDCall.call(
                                            host: FFDevEnvironmentValues()
                                                .backendhost,
                                            imageId:
                                                widget.imageid?.toString(),
                                            userId: currentUserUid,
                                            vote: false,
                                            token: currentJwtToken,
                                          );

                                          if ((_model
                                                  .apiResult6oo8?.succeeded ??
                                              true)) {
                                            safeSetState(
                                                () => _feedbackVote = false);
                                            unawaited(_saveFeedbackVote(false));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Thnaks for your feedback!',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 4000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Ups! Something went wrong!',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 4000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                              ),
                                            );
                                          }

                                          safeSetState(() {});
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _feedbackVote == false
                                                ? const Color(0xFFD32F2F)
                                                    .withOpacity(0.1)
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: _feedbackVote == false
                                                  ? const Color(0xFFD32F2F)
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              width: _feedbackVote == false
                                                  ? 2.0
                                                  : 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    22.0, 18.0, 22.0, 18.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.thumb_down_rounded,
                                                  color: _feedbackVote == false
                                                      ? const Color(0xFFD32F2F)
                                                      : const Color(0xE61A1A1A),
                                                  size: 24.0,
                                                ),
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    '330wbi7z' /* Not Helpful */,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        color: _feedbackVote ==
                                                                false
                                                            ? const Color(
                                                                0xFFD32F2F)
                                                            : const Color(
                                                                0xE61A1A1A),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                                ),
                                              ].divide(SizedBox(width: 10.0)),
                                            ),
                                          ),
                                        ),
                                      ).animateOnActionTrigger(
                                          animationsMap[
                                              'containerOnActionTriggerAnimation2']!,
                                          hasBeenTriggered:
                                              hasContainerTriggered2),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 1.0,
                                    color: FlutterFlowTheme.of(context).info,
                                  ),
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      '5a7j03ug' /* Personal Notes */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                  TextFormField(
                                    controller: _model.textController ??=
                                        TextEditingController(
                                      text: itemcard2ImagesRow?.personalNotes,
                                    ),
                                    focusNode: _model.textFieldFocusNode,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.textController',
                                      Duration(milliseconds: 2000),
                                      () async {
                                        await ImagesTable().update(
                                          data: {
                                            'personal_notes':
                                                _model.textController.text,
                                          },
                                          matchingRows: (rows) => rows.eqOrNull(
                                            'id',
                                            widget.imageid,
                                          ),
                                        );
                                        safeSetState(() {});
                                      },
                                    ),
                                    autofocus: false,
                                    enabled: true,
                                    textInputAction: TextInputAction.done,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText:
                                          FFLocalizations.of(context).getText(
                                        'abj9484s' /* There is nothing here at the m... */,
                                      ),
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelMediumFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .labelMediumIsCustom,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x65F2EBB4),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      filled: true,
                                      fillColor: Color(0x66F2EBB4),
                                      hoverColor: Color(0x87F2EBB4),
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
                                    maxLines: 4,
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    enableInteractiveSelection: true,
                                    validator: _model.textControllerValidator
                                        .asValidator(context),
                                  ),
                                ].divide(SizedBox(height: 10.0)),
                              ),
                            ),
                          ),
                        ),
                        // bottom padding so sticky banner doesn't overlap content
                        if (currentUserIsAnonymous)
                          const SizedBox(height: 80),
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

  String _axisLabel(String lang, String axis) {
    const labels = {
      'efficacy':   {'en': 'Efficacy',    'ru': 'Эффективность', 'es': 'Eficacia'},
      'safety':     {'en': 'Safety',      'ru': 'Безопасность',  'es': 'Seguridad'},
      'stability':  {'en': 'Stability',   'ru': 'Стабильность',  'es': 'Estabilidad'},
      'experience': {'en': 'Experience',  'ru': 'Ощущения',      'es': 'Experiencia'},
      'pore_safety':{'en': 'Non-Comedogenic', 'ru': 'Некомедогенность', 'es': 'No Comedogénico'},
    };
    return labels[axis]?[lang] ?? labels[axis]?['en'] ?? axis;
  }

  String _skinTypeLabel(String skinType) {
    final lang = FFLocalizations.of(context).languageCode;
    const labels = {
      'dry':        {'en': 'Dry',          'ru': 'Сухая',               'es': 'Seca'},
      'oily':       {'en': 'Oily',         'ru': 'Жирная',              'es': 'Grasa'},
      'normal':     {'en': 'Normal',       'ru': 'Нормальная',          'es': 'Normal'},
      'combination':{'en': 'Combination',  'ru': 'Комбинированная',     'es': 'Mixta'},
      'sensitive':  {'en': 'Sensitive',    'ru': 'Чувствительная',      'es': 'Sensible'},
      'acne_prone': {'en': 'Acne-Prone',   'ru': 'Склонная к акне',     'es': 'Propensa al acné'},
    };
    return labels[skinType]?[lang] ?? labels[skinType]?['en'] ?? skinType;
  }

}

class _AnonSaveBanner extends StatelessWidget {
  const _AnonSaveBanner();

  void _showSheet(BuildContext context) {
    final lang = FFLocalizations.of(context).languageCode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AnonSaveSheet(lang: lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = FFLocalizations.of(context).languageCode;
    final label = lang == 'ru'
        ? 'Сохранить в историю'
        : lang == 'es'
            ? 'Guardar en historial'
            : 'Save to history';
    final cta = lang == 'ru'
        ? 'Войти / Создать аккаунт'
        : lang == 'es'
            ? 'Entrar / Crear cuenta'
            : 'Sign in / Create account';

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
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .bodyMediumIsCustom,
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
  const _AnonSaveSheet({required this.lang});
  final String lang;

  String _t(Map<String, String> map) => map[lang] ?? map['en']!;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                _t({
                  'ru': 'Сохраните свои анализы',
                  'es': 'Guarda tus análisis',
                  'en': 'Save your analyses',
                }),
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      letterSpacing: 0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _t({
                  'ru':
                      'Создайте аккаунт — и все продукты, которые вы уже проанализировали, сохранятся в вашу историю.',
                  'es':
                      'Crea una cuenta y todos los productos que ya analizaste se guardarán en tu historial.',
                  'en':
                      'Create an account and all the products you\'ve already scanned will be saved to your history.',
                }),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodyMediumFamily,
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
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed(CreateAccountPageWidget.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    _t({
                      'ru': 'Создать аккаунт',
                      'es': 'Crear cuenta',
                      'en': 'Create account',
                    }),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .bodyMediumIsCustom,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed(LogInPageWidget.routeName);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FlutterFlowTheme.of(context).primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _t({
                      'ru': 'Войти',
                      'es': 'Entrar',
                      'en': 'Sign in',
                    }),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .bodyMediumIsCustom,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  _t({
                    'ru': 'Пока нет',
                    'es': 'Ahora no',
                    'en': 'Not now',
                  }),
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

class _PaywallBullet extends StatelessWidget {
  const _PaywallBullet({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.0, color: FlutterFlowTheme.of(context).primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
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

class _LoginRequiredSheet extends StatelessWidget {
  const _LoginRequiredSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).alternate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          Icon(
            Icons.lock_outline_rounded,
            size: 48,
            color: FlutterFlowTheme.of(context).primary,
          ),
          SizedBox(height: 16),
          Text(
            FFLocalizations.of(context).getText('copy_login_title' /* Sign in to copy */),
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          SizedBox(height: 8),
          Text(
            FFLocalizations.of(context).getText(
                'copy_login_body' /* Create a free account to save products to your collection. */),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed(LogInPageWidget.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: FlutterFlowTheme.of(context).info,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                FFLocalizations.of(context).getText('copy_login_btn' /* Sign in */),
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleSmallFamily,
                      color: FlutterFlowTheme.of(context).info,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleSmallIsCustom,
                    ),
              ),
            ),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              FFLocalizations.of(context).getText('copy_login_cancel' /* Cancel */),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
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
      path.moveTo(0,
          liquidY + waveAmp * sin((t + phaseOffset) * 2 * pi));
      for (double x = 0; x <= w; x++) {
        path.lineTo(
          x,
          liquidY +
              waveAmp * sin((x / w * 2.5 + t + phaseOffset) * 2 * pi),
        );
      }
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.close();
      canvas.drawPath(path, Paint()..color = color.withAlpha((255 * opacity).round()));
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
                if (value.isNotEmpty)
                  TextSpan(text: ':  $value'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
