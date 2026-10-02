import 'dart:async';
import 'dart:math' show sin, pi;
import '/auth/supabase_auth/auth_util.dart';
import '/components/feedback_collector/feedback_collector_widget.dart';
import '/components/feedback_collector/feedback_service.dart';
import '/flutter_flow/analytics_service.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/app_state.dart';
import '/domain/cosmetic_bag/cosmetic_bag_service.dart';
import '/domain/client_card/client_card_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/screen_loader.dart';
import '/design_system/components/constrained_content.dart';
import '/item_card/deleteitem/deleteitem_widget.dart';
import '/components/product_card_v3/card_data.dart';
import '/components/product_card_v3/card_tokens.dart';
import '/components/product_card_v3/product_card_v3_widget.dart';
import '/design_system/components/mirra_bottom_sheet.dart';
import '/item_card/markasspam/markasspam_widget.dart';
import '/topratings/copyitem/copyitem_widget.dart';
import '/topratings/makeprivate/makeprivate_widget.dart';
import '/topratings/makepublic/makepublic_widget.dart';
import '/index.dart';
import '/paywall/show_paywall.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'itemcard2_model.dart';
export 'itemcard2_model.dart';

/// После какого по счёту удачного разбора предлагать подписку на карточке
/// результата. Совпадает с бесплатной квотой (app_config.free_scan_limit = 5):
/// пятый разбор — последний бесплатный, и карточка с его результатом — последний
/// момент продать до того, как упрёмся в стену на шестом.
const int _kSoftPaywallAfterScans = 5;

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

class _Itemcard2WidgetState extends State<Itemcard2Widget> {
  late Itemcard2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _pendingPollingTimer;

  /// Бэкенд ответил 422 unsupported_product_type: волосы, тело, декоративка.
  /// Такой скан не ждёт разбора, ему показывается своя заглушка.
  bool _unsupported = false;

  /// Этот продукт уже в Косметичке — тогда действие обратное: убрать. Для
  /// чужого продукта всегда false: в набор попадает его копия с другим id, и
  /// связать её с исходной карточкой нельзя.
  bool _inBag = false;

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
      await _refreshBagState();
      // Skin profile from onboarding — default viewing context for the fit card.
      if (currentUserUid.isNotEmpty) {
        try {
          final userRows = await UsersTable().queryRows(
            queryFn: (q) => q.eq('id', currentUserUid),
            limit: 1,
          );
          final u = userRows.firstOrNull;
          _model.profileRow = u;
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
      if (_needsAnalysis(_model.imageraw?.firstOrNull) &&
          widget.imageid != null) {
        final ready = await _requestAnalysis();
        if (!ready && mounted) {
          // Analysis still pending (202) — poll Supabase until score appears.
          _startPendingPolling();
        }
      }

      // Карточка последнего бесплатного разбора: предлагаем подписку один раз,
      // мягко. К этому моменту продукт показал себя пять раз, а квота как раз
      // кончилась — следующий тап по камере упрётся в стену. Свои разборы
      // только: чужая ссылка, открытая посторонним, — не повод продавать.
      if (!mounted) return;
      final softState = context.read<FFAppState>();
      if (!softState.softPaywallShown &&
          !softState.isprouser &&
          softState.successfulScans >= _kSoftPaywallAfterScans &&
          _model.imageraw?.firstOrNull?.user == currentUserUid) {
        softState.softPaywallShown = true;
        // Long enough to read the verdict and scroll the card a little before
        // being asked for money. This delay is the knob if conversion is off.
        await Future.delayed(const Duration(seconds: 5));
        if (!context.mounted) return;
        unawaited(AnalyticsService.instance
            .trackUpgradePromptShown(trigger: 'fifth_result'));
        // Мягкая подача листом: карточка остаётся видна за ним, свайп вниз
        // закрывает.
        await showPaywall(context, from: 'fifth_result', asSheet: true);
        // The feedback prompt below would stack a second modal on top of the
        // paywall. It keeps its pending flag and gets the next scan instead.
        return;
      }

      // Show feedback prompt after the card has rendered and user has had
      // time to see the results.
      if (!mounted) return;
      final feedbackState = context.read<FFAppState>();
      if (feedbackState.feedbackPendingScan &&
          FeedbackService.shouldShowPrompt(feedbackState)) {
        feedbackState.feedbackPendingScan = false;
        await Future.delayed(const Duration(seconds: 3));
        if (context.mounted) {
          // Порог засчитывается только при реальном показе: если за три
          // секунды ушли с карточки, просилка вернётся на следующем скане.
          FeedbackService.recordShown(feedbackState);
          // Событие именно здесь, а не до задержки: за эти три секунды человек
          // успевает уйти с карточки, окно тогда не появляется — а событие
          // описано как «появилось окно» и завышало бы знаменатель для
          // popup_reviews_yes и popup_reviews_no.
          unawaited(AnalyticsService.instance.trackPopupReviewsShow());
          await showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withAlpha(100),
            builder: (context) => const FeedbackCollectorWidget(),
          );
        }
      }
    });

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
  }

  /// Карточке нужны оценка и объект sa_card. Старый разбор без карточки
  /// досчитывается бэкендом по запросу с card_version=3.
  bool _needsAnalysis(ImagesRow? row) =>
      row == null ||
      row.saCompositeScore == null ||
      ProductCard.parse(row.saCard) == null;

  /// Просим бэкенд досчитать разбор или только карточку. true, если после
  /// ответа карточка на месте.
  Future<bool> _requestAnalysis() async {
    final retry = await ScientificanalysisNEWBCNDCall.call(
      imageId: widget.imageid?.toString(),
      userId: currentUserUid,
      languageCode: FFLocalizations.of(context).languageCode,
      token: currentJwtToken,
    );
    if (!mounted) return false;
    if ((retry?.succeeded ?? false) && (retry?.statusCode ?? 0) == 200) {
      await _loadAnalysis();
      if (mounted) safeSetState(() {});
      return !_needsAnalysis(_model.imageraw?.firstOrNull);
    }
    if ((retry?.statusCode ?? 0) == 422 &&
        getJsonField(retry?.jsonBody, r'$.status') ==
            'unsupported_product_type') {
      // Ждать нечего: разбора у этого средства не будет.
      _unsupported = true;
      if (mounted) safeSetState(() {});
      return true;
    }
    return false;
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
        if (!mounted) return;
        // Фоновый разбор мог пройти без карточки: достраиваем одним вызовом.
        if (_needsAnalysis(_model.imageraw?.firstOrNull)) await _requestAnalysis();
        if (mounted) safeSetState(() {});
      }
    });
  }

  Future<void> _refreshBagState() async {
    if (currentUserUid.isEmpty) return;
    try {
      final bag = await CosmeticBagService.instance.items();
      if (!mounted) return;
      safeSetState(() {
        _inBag = bag.any((i) => i.imageId == widget.imageid);
      });
    } catch (e) {
      debugPrint('card: bag state unavailable: $e');
    }
  }

  Future<void> _removeFromBag() async {
    final id = widget.imageid;
    if (id == null) return;
    await CosmeticBagService.instance.remove(id);
    if (!mounted) return;
    safeSetState(() => _inBag = false);
    _toast(FFLocalizations.of(context).getText('cb_removed_toast'));
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: FlutterFlowTheme.of(context).primary,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ));
  }

  /// «Добавить в косметичку»: чужое средство сначала копируется в свои продукты,
  /// затем копия кладётся в косметичку. Свой продукт копировать не нужно —
  /// добавляем его как есть.
  Future<void> _addToBag(bool isOwner) async {
    // Гостю Косметичка доступна: анонимная сессия — полноценный auth.uid(), и
    // RLS bag_items её принимает. Аккаунт нужен только там, где сессии нет
    // вовсе.
    if (currentUserUid.isEmpty) {
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        context: context,
        builder: (context) => const _LoginRequiredSheet(
          titleKey: 'cb_login_title',
          bodyKey: 'cb_login_body',
        ),
      );
      return;
    }
    // Пейволл: у бесплатного тарифа косметичка ограничена kFreeBagSlots.
    final bag = await CosmeticBagService.instance.items();
    if (!FFAppState().isprouser && bag.length >= kFreeBagSlots) {
      if (!context.mounted) return;
      unawaited(AnalyticsService.instance
          .trackPremiumTap(from: 'bag_add_from_card'));
      unawaited(showPaywall(context, from: 'bag_add_from_card'));
      return;
    }
    int? targetId = widget.imageid;
    if (!isOwner) {
      final resp = await CopyproductNEWBCNDCall.call(
        sourceImageId: widget.imageid,
        targetUserId: currentUserUid,
        token: currentJwtToken,
      );
      targetId = CopyproductNEWBCNDCall.newimageid(resp?.jsonBody ?? '');
      if (targetId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(FFLocalizations.of(context).getText('copy_failed')),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
    }
    if (targetId == null) return;
    await CosmeticBagService.instance.add(targetId);
    if (!mounted) return;
    // Свой продукт лежит в наборе под тем же id — кнопка сразу переключается
    // на «убрать». У копии чужого id другой, и переключать нечего.
    if (isOwner) safeSetState(() => _inBag = true);
    _toast(FFLocalizations.of(context).getText('cb_added_toast'));
  }

  /// «Это не уход за лицом»: волосы, тело, декоративка. Бэкенд их не
  /// разбирает, карточки не будет.
  Widget _buildUnsupportedPlaceholder(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.do_not_disturb_on_outlined,
              size: 48, color: theme.secondaryText),
          const SizedBox(height: 16),
          Text(
            FFLocalizations.of(context).getText('analysis_unsupported_title'),
            textAlign: TextAlign.center,
            style: theme.titleMedium.override(
              fontFamily: theme.titleMediumFamily,
              color: theme.primaryText,
              fontWeight: FontWeight.w700,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            FFLocalizations.of(context).getText('analysis_unsupported_body'),
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
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

  /// Фото продукта для слайдера: каталожное (публичное) первым, затем скан
  /// самого пользователя — но ТОЛЬКО если это его продукт. На чужих продуктах
  /// (top rated, user_id не совпадает) приватный скан не показываем — лишь
  /// каталожное фото, а если его нет — заплатку (пустой список).
  List<String> _productPhotos() {
    final row = _model.imageraw?.firstOrNull;
    if (row == null) return const [];
    final out = <String>[];
    final catalog = row.catalogImageUrl;
    if (catalog != null && catalog.isNotEmpty) out.add(catalog);
    if (row.user == currentUserUid && row.imageUrl.isNotEmpty) {
      out.add(row.imageUrl);
    }
    return out;
  }

  Future<void> _openPhotos(BuildContext context, List<String> photos) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: SizedBox(
            height: 380.0,
            child: _ProductPhotos(photos: photos, height: 380.0),
          ),
        ),
      ),
    );
  }

  // ── Меню «⋯» ─────────────────────────────────────────────────────────────

  String _t(String key) => FFLocalizations.of(context).getText(key);

  Future<void> _shareLink() async {
    unawaited(AnalyticsService.instance.trackProductSettingShare());
    unawaited(AnalyticsService.instance
        .trackShareLinkTapped(imageId: widget.imageid ?? 0));
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    await Share.share(
      'https://mirra.up.railway.app/product/${widget.imageid}',
      sharePositionOrigin:
          Rect.fromLTWH(size.width / 2, size.height / 2, 1, 1),
    );
  }

  void _openSocialCard() {
    unawaited(AnalyticsService.instance.trackProductSettingPrint());
    context.pushNamed(
      ShareproductWidget.routeName,
      queryParameters: {
        'imageid': serializeParam(widget.imageid, ParamType.int),
      }.withoutNulls,
    );
  }

  Future<void> _toggleFavourite(ImagesRow row) async {
    final next = !(row.favourite ?? false);
    await ImagesTable().update(
      data: {'favourite': next},
      matchingRows: (rows) => rows.eqOrNull('id', widget.imageid),
    );
    unawaited(next
        ? AnalyticsService.instance.trackFavouriteAdded(imageId: widget.imageid ?? 0)
        : AnalyticsService.instance.trackFavouriteRemoved(imageId: widget.imageid ?? 0));
    if (!mounted) return;
    safeSetState(() {});
    _toast(_t(next ? 'fab_favourite_added' : 'fab_favourite_removed'));
  }

  /// Скрытие — отказ от публикации своего скана в общем каталоге, а не
  /// привилегия: доступно всем владельцам скана, включая гостя.
  Future<void> _toggleHidden(ImagesRow row) async {
    final hide = !(row.hided ?? false);
    unawaited(hide
        ? AnalyticsService.instance.trackProductHidden()
        : AnalyticsService.instance.trackProductPublicCatalog());
    await ImagesTable().update(
      data: {'hided': hide},
      matchingRows: (rows) => rows.eqOrNull('id', widget.imageid),
    );
    if (!mounted) return;
    safeSetState(() {});
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) => hide
          ? Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: MakeprivateWidget(imageid: widget.imageid!),
            )
          : const MakepublicWidget(),
    ).then((value) => safeSetState(() {}));
  }

  Future<void> _reportSpam() async {
    unawaited(AnalyticsService.instance.trackProductSettingsSpam());
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
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_t('spam_hidden_toast'),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ));
      context.safePop();
    }
  }

  Future<void> _copyProduct() async {
    unawaited(AnalyticsService.instance.trackProductSettingsCopy());
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
    if (!mounted) return;
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
  }

  Future<void> _deleteProduct() async {
    unawaited(AnalyticsService.instance.trackProductDelete());
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
  }

  /// Действия с карточкой вместо плавающей кнопки: картинка для соцсетей,
  /// ссылка, затем действия владельца или гостя, удаление отдельно внизу.
  Future<void> _openMenu(ImagesRow row) async {
    unawaited(AnalyticsService.instance.trackProductSettings());
    final theme = FlutterFlowTheme.of(context);
    final isOwner = row.user == currentUserUid;

    Widget item({
      required IconData icon,
      required String title,
      String? subtitle,
      Color? iconBg,
      Color? iconColor,
      required Future<void> Function() onTap,
    }) =>
        Builder(
          builder: (sheetContext) => InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(onTap());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBg ?? CardTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: iconColor ?? theme.primaryText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: cardText(theme, size: 15, weight: FontWeight.w500)),
                        if (subtitle != null)
                          Text(subtitle,
                              style: cardText(theme, size: 12, color: theme.secondaryText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MirraBottomSheet(
        surfaceColor: theme.alternate,
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            item(
              icon: LucideIcons.image,
              iconColor: theme.primaryVariant,
              title: _t('card_menu_social'),
              subtitle: _t('card_menu_social_sub'),
              onTap: () async => _openSocialCard(),
            ),
            item(
              icon: LucideIcons.share,
              title: _t('card_menu_share_link'),
              onTap: _shareLink,
            ),
            Divider(height: 9, color: theme.divider, indent: 10, endIndent: 10),
            if (isOwner) ...[
              item(
                icon: (row.favourite ?? false) ? LucideIcons.heartOff : LucideIcons.heart,
                title: _t((row.favourite ?? false)
                    ? 'fab_remove_favourite'
                    : 'fab_add_favourite'),
                onTap: () => _toggleFavourite(row),
              ),
              item(
                icon: (row.hided ?? false)
                    ? LucideIcons.eye
                    : LucideIcons.eyeOff,
                title: _t((row.hided ?? false) ? 'fab_show' : 'fab_hide'),
                onTap: () => _toggleHidden(row),
              ),
            ] else ...[
              item(
                icon: LucideIcons.copy,
                title: _t('fab_copy'),
                onTap: _copyProduct,
              ),
              item(
                icon: LucideIcons.ban,
                title: _t('fab_spam'),
                onTap: _reportSpam,
              ),
            ],
            if (isOwner) ...[
              Divider(height: 9, color: theme.divider, indent: 10, endIndent: 10),
              item(
                icon: LucideIcons.trash2,
                iconBg: theme.errorBg,
                iconColor: theme.error,
                title: _t('card_menu_delete'),
                onTap: _deleteProduct,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Экран ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Подписка на FFAppState без локальной переменной: карточку надо
    // перестраивать после покупки PRO и изменений в косметичке.
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);

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
            backgroundColor: theme.alternate,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.circleAlert, color: theme.error, size: 48),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => safeSetState(() {}),
                    child: Text(_t('care_retry')),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.alternate,
            body: const Center(child: ScreenLoader()),
          );
        }
        final itemcard2ImagesRow = snapshot.data!.firstOrNull;
        if (itemcard2ImagesRow == null) {
          return Scaffold(
            backgroundColor: theme.alternate,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _t('item_not_found'),
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium,
                ),
              ),
            ),
          );
        }

        // Строка из модели свежее: она перечитывается после доразбора.
        final row = _model.imageraw?.firstOrNull ?? itemcard2ImagesRow;
        final card = ProductCard.parse(row.saCard);
        final photos = _productPhotos();
        final pregnant = _model.profileRow?.pregnancyStatus ==
            ClientCardService.pregnantOrNursing;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: theme.alternate,
            appBar: AppBar(
              backgroundColor: theme.alternate,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(LucideIcons.chevronLeft, size: 20, color: theme.primaryText),
                onPressed: () => context.safePop(),
              ),
              title: Text(_t('card_title'),
                  style: cardText(theme, size: 15, weight: FontWeight.w600)),
              actions: [
                IconButton(
                  icon: Icon(LucideIcons.ellipsis, color: theme.primaryText),
                  onPressed: () => _openMenu(row),
                ),
              ],
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (!_model.loading)
                  SingleChildScrollView(
                    child: ConstrainedContent(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_unsupported)
                            _buildUnsupportedPlaceholder(context)
                          else if (card == null ||
                              row.saCompositeScore == null)
                            _buildPendingPlaceholder(context)
                          else
                            ProductCardV3Widget(
                              card: card,
                              brand: row.brand ?? '',
                              productName: row.productName ?? '',
                              photoUrl: photos.firstOrNull,
                              onOpenPhotos: () => _openPhotos(context, photos),
                              profileSkinType: _model.userSkinType,
                              profileSensitive: _model.userIsSensitive,
                              profileAcneProne: _model.userIsAcneProne,
                              pregnant: pregnant,
                              inBag: _inBag,
                              onToggleBag: () => _inBag
                                  ? _removeFromBag()
                                  : _addToBag(row.user == currentUserUid),
                              onScanMore: () =>
                                  context.pushNamed(TakeorUploadPageWidget.routeName),
                              onEditProfile: () =>
                                  context.pushNamed(ProfileWidget.routeName),
                            ),
                          // Запас под липкий баннер «сохранить в историю» у гостя.
                          SizedBox(height: currentUserIsAnonymous ? 72.0 : 16.0),
                        ],
                      ),
                    ),
                  ),
                // Пока карточка догружается — белое полотно и общий спиннер.
                if (_model.loading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: theme.alternate,
                      child: const ScreenLoader(),
                    ),
                  ),
                if (currentUserIsAnonymous)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _AnonSaveBanner(),
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
                  LucideIcons.bookmark,
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
                  LucideIcons.chevronRight,
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
              Icon(LucideIcons.bookmark,
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
                    context.pushNamed(
                      LogInPageWidget.routeName,
                      queryParameters: {
                        'tab': serializeParam('register', ParamType.String),
                      }.withoutNulls,
                    );
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

/// Требование входа для действия, которому нужен аккаунт. Тексты приходят от
/// вызывающего: один и тот же лист закрывает и копирование чужого продукта, и
/// добавление в Косметичку, а объяснения у них разные.
class _LoginRequiredSheet extends StatelessWidget {
  const _LoginRequiredSheet({
    this.titleKey = 'copy_login_title',
    this.bodyKey = 'copy_login_body',
  });

  final String titleKey;
  final String bodyKey;

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
            LucideIcons.lock,
            size: 48,
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(height: 16),
          Text(
            FFLocalizations.of(context).getText(titleKey),
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
            FFLocalizations.of(context).getText(bodyKey),
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

/// Full-bleed фото продукта: одно фото, слайдер (если фото больше одного) или
/// заплатка (если список пуст). Верхний градиент — для читаемости статус-бара.
class _ProductPhotos extends StatefulWidget {
  const _ProductPhotos({required this.photos, required this.height});

  final List<String> photos;
  final double height;

  @override
  State<_ProductPhotos> createState() => _ProductPhotosState();
}

class _ProductPhotosState extends State<_ProductPhotos> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _photo(String url) => OctoImage(
        placeholderBuilder: (_) => SizedBox.expand(
          child: Image(
            image: BlurHashImage('L6PZfSi_.AyE_3t7t7R**0o#DgR4'),
            fit: BoxFit.cover,
          ),
        ),
        // Cap decode resolution: a huge source image otherwise decodes at
        // full size and OOM-kills the app.
        image: ResizeImage(NetworkImage(url), width: 1080),
        fit: BoxFit.cover,
      );

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: widget.height,
          child: photos.isEmpty
              ? Container(
                  color: const Color(0xFFF2F2F2),
                  child: const Center(
                    child: Icon(LucideIcons.imageOff,
                        color: Colors.black26, size: 48),
                  ),
                )
              : PageView.builder(
                  controller: _controller,
                  itemCount: photos.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _photo(photos[i]),
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
                colors: [Colors.black.withAlpha(80), Colors.transparent],
              ),
            ),
          ),
        ),
        // Page dots — only when there is more than one photo.
        if (photos.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
