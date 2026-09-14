import 'dart:async';
import 'dart:ui';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/confetti_overlay.dart';
import '/components/premium_features_list/premium_features_list_widget.dart';
import '/components/save_subscription_sheet.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/design_system/components/app_button.dart';
import '/design_system/components/plan_card.dart';
import '/design_system/components/pro_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'paywallpage_model.dart';
export 'paywallpage_model.dart';

class PaywallpageWidget extends StatefulWidget {
  const PaywallpageWidget({super.key});

  static String routeName = 'Paywallpage';
  static String routePath = '/paywallpage';

  @override
  State<PaywallpageWidget> createState() => _PaywallpageWidgetState();
}

class _PaywallpageWidgetState extends State<PaywallpageWidget> {
  late PaywallpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _offeringsLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaywallpageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Default to annual plan (better value)
      FFAppState().subscriptionmonth = false;
      safeSetState(() {});

      try {
        // Load offerings if not already available
        if (revenue_cat.offerings?.current?.weekly == null ||
            revenue_cat.offerings?.current?.annual == null) {
          safeSetState(() => _offeringsLoading = true);
          await revenue_cat.loadOfferings();
          if (mounted) safeSetState(() => _offeringsLoading = false);
        }
      } finally {
        // loadOfferings() only catches PlatformException, so anything else
        // would abort this callback and lose the one event that reveals a
        // dead-end paywall. Reporting from a finally makes the signal
        // unconditional: the state it leaves behind is what we measure.
        unawaited(AnalyticsService.instance.trackPaywallOfferingsLoaded(
          ready: _offeringsReady,
          configured: revenue_cat.isConfigured,
        ));
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  bool get _offeringsReady =>
      revenue_cat.offerings?.current?.weekly != null &&
      revenue_cat.offerings?.current?.annual != null;

  /// Общий «выезд» блоков пейвола: одна кривая, один шаг задержки. Было пять
  /// копий одной и той же цепочки animate().fadeIn().slideY().
  Widget _rise(Widget child, {int delayMs = 0}) =>
      child.animate().fadeIn(duration: 500.ms, delay: delayMs.ms).slideY(
          begin: 0.12,
          end: 0.0,
          duration: 500.ms,
          delay: delayMs.ms,
          curve: Curves.easeOut);

  /// Текстовая ссылка пейвола (восстановить покупки, политика, условия) —
  /// кнопка дизайн-системы вместо трёх самодельных InkWell + Text.
  Widget _link(String label, FutureOr<void> Function() onTap) => AppButton(
        label: label,
        variant: AppButtonVariant.text,
        size: AppButtonSize.sm,
        fullWidth: false,
        onPressed: onTap,
      );

  void _toast(String key) {
    final theme = FlutterFlowTheme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(FFLocalizations.of(context).getText(key),
          style: TextStyle(color: theme.primaryText)),
      duration: const Duration(milliseconds: 4000),
      backgroundColor: theme.secondary,
    ));
  }

  Future<void> _restorePurchases() async {
    // Ни одна ветка ниже не сообщает об отказе наружу: пользователь видит тост,
    // и на этом всё. Исход считаем из finally — так он доезжает и когда цепочка
    // обрывается исключением, а именно этот случай и есть «заплатил, а доступ
    // не вернулся».
    var result = 'error';
    try {
      _model.rCUserID3 = await actions.rcEnsureLogin(context, currentUserUid);
      await revenue_cat.restorePurchases();
      final isEntitled =
          await revenue_cat.isEntitled('EntitlementMirra') ?? false;
      if (!isEntitled) {
        result = 'nothing_to_restore';
        await revenue_cat.loadOfferings();
        if (mounted) _toast('rf9m3wk5');
        safeSetState(() {});
        return;
      }
      // Restore only moved the entitlement inside RevenueCat; premium in our own
      // database is what the app and the scan quota read. The TRANSFER webhook
      // writes it too, but this is the path the user is actively waiting on, so
      // don't make them wait for delivery.
      await SubscriptionSyncCall.call(token: currentJwtToken);
      FFAppState().isprouser = true;
      // Только здесь: до записи в нашу базу доступа для приложения ещё нет,
      // и рапортовать об успехе было бы враньём.
      result = 'restored';
      if (!mounted) return;
      _toast('rs4p1dq2');
      safeSetState(() {});
    } finally {
      unawaited(AnalyticsService.instance.trackPurchaseRestore(result: result));
    }
  }

  /// Leaves the paywall in either presentation. Navigator, not go_router: shown
  /// as a modal sheet the top route is an imperative one that go_router's pop()
  /// does not own, and the close button would dismiss the page underneath.
  void _dismiss() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      context.goNamed(HomeWidget.routeName);
    }
  }

  /// A guest who has just paid holds the subscription through an anonymous
  /// session that exists only on this device — losing it means losing access,
  /// recoverable in practice only by a "restore purchases" tap nobody thinks to
  /// make. Offer an account once, after the charge, never as a condition of it.
  ///
  /// Runs after the paywall is dismissed and off the widget's own context: this
  /// State is being torn down, and the two sheets would otherwise stack.
  Future<void> _offerToSaveSubscription() async {
    if (!currentUserIsAnonymous) return;
    final app = FFAppState();
    if (app.saveProPromptShown) return;
    app.saveProPromptShown = true;

    // Let the paywall finish leaving before the next sheet arrives.
    await Future.delayed(const Duration(milliseconds: 350));
    var ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;

    final theme = FlutterFlowTheme.of(ctx);
    unawaited(HapticFeedback.heavyImpact());

    final wantsAccount = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Full-height stack so the confetti falls across the screen behind the
      // sheet. Nothing here absorbs touches outside the sheet itself, so a tap
      // above it still reaches the barrier and dismisses.
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ConfettiOverlay(
                colors: [
                  theme.primary,
                  theme.secondary,
                  theme.tertiary,
                  const Color(0xFFFFC93C),
                  const Color(0xFFFF7BA9),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SaveSubscriptionSheet(),
          ),
        ],
      ),
    );
    if (wantsAccount != true) return;

    ctx = appNavigatorKey.currentContext;
    // createAccountWithEmail links the address to this anonymous account and
    // keeps the uuid; the Apple path mints a new one, and the sync call in
    // _claimAnonScans is what carries the subscription across.
    ctx?.pushNamed(
      LogInPageWidget.routeName,
      queryParameters: {
        'tab': serializeParam('register', ParamType.String),
      }.withoutNulls,
    );
  }

  // Single RevenueCat purchase flow for both plans (was copy-pasted per card).
  Future<void> _purchasePlan({
    required bool isMonth,
    required String package,
    required int durationDays,
    required String telegramForm,
    required String telegramMessage,
  }) async {
    FFAppState().subscriptionmonth = isMonth;
    safeSetState(() {});
    await actions.rcEnsureLogin(context, currentUserUid);
    unawaited(AnalyticsService.instance.trackPurchaseStarted(package: package));
    final payment = await actions.rcPurchasePackage(
      context,
      'defaultmirra',
      package,
      currentUserUid,
    );
    if (MessegefrompaymentStruct.maybeFromMap(payment)?.hasOk() == true) {
      final refreshed =
          await actions.rcRefreshEntitlement(context, 'EntitlementMirra');
      if (MessegefrompaymentStruct.maybeFromMap(payment)?.ok == true) {
        if (refreshed) {
          unawaited(AnalyticsService.instance
              .trackPurchaseCompleted(package: package));
        } else {
          // Charged by the store but the entitlement never turned on — the
          // user paid and stays on free.
          unawaited(AnalyticsService.instance.trackPurchaseFailed(
            package: package,
            code: 'entitlement_not_active',
            cancelled: false,
          ));
        }
      }
      if (refreshed!) {
        FFAppState().isprouser = true;
        safeSetState(() {});
        // Write the premium row now instead of waiting on the RevenueCat
        // webhook. The webhook still runs and remains the backstop, but until
        // it lands the server meters this user as free — so the scan they just
        // paid for is refused, and Home reads `free` back over the local flag
        // above. /subscription/sync takes no arguments and verifies the
        // entitlement against RevenueCat itself, which is why it can be called
        // from the client at all: there is nothing here to forge.
        await SubscriptionSyncCall.call(token: currentJwtToken);
        await SendAppMessageCall.call(
          token: currentJwtToken,
          email: currentUserEmail,
          form: telegramForm,
          message: telegramMessage,
        );
        // Leave the paywall. Without this the user pays, Apple confirms, and
        // the purchase screen just stays put with its spinner gone — which
        // reads as "charged me and gave me nothing" and invites a refund.
        if (mounted) _dismiss();
        await _offerToSaveSubscription();
        return;
      }
    }
    {
      final _r = MessegefrompaymentStruct.maybeFromMap(payment!);
      if (_r != null && !_r.ok) {
        unawaited(AnalyticsService.instance.trackPurchaseFailed(
          package: package,
          code: _r.code.isNotEmpty ? _r.code : 'unknown',
          cancelled: _r.cancelled,
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _r.cancelled
                  ? FFLocalizations.of(context).getText('pu7x1ck3')
                  : FFLocalizations.of(context).getText('pe2n5jf8'),
              style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).secondary,
          ),
        );
      }
    }
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final t = FFLocalizations.of(context);

    // Paywall dark-surface palette (Initiative 10) — grouped file-locally;
    // the color-token track is paused, so these are not theme tokens yet.
    const paywallScaffold = Color(0xFF060D1E);
    // Contrast scrim over the animated background (used to be a rounded shell
    // container around the content, whose edge showed at the bottom).
    final paywallScrim = const Color(0xFF0C1A35).withValues(alpha: 0.80);
    final paywallIconMuted = Colors.white.withValues(alpha: 0.8);
    final paywallTextMuted = Colors.white.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: paywallScaffold,
        body: Stack(
          children: [
            custom_widgets.AnimatedPaywallBg(
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: paywallScrim)),
            ),
            SafeArea(
              top: true,
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 600.0,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 12.0, 16.0, 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _rise(Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.close,
                                    color: paywallIconMuted,
                                    size: theme.size.iconSm),
                                // 44 — минимальный тап-таргет (Initiative 3.3).
                                constraints: const BoxConstraints(
                                    minWidth: 44.0, minHeight: 44.0),
                                onPressed: _dismiss,
                              ),
                              ProPill(label: t.getText('7n2kv1iq')),
                              // Балансир крестика: пилюля остаётся по центру.
                              const SizedBox(width: 44.0),
                            ],
                          )),
                          _rise(const PremiumFeaturesListWidget(), delayMs: 80),
                          if (_offeringsLoading || !_offeringsReady)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          else ...[
                            _rise(
                                PlanCard(
                                  title: valueOrDefault<String>(
                                    revenue_cat.offerings!.current!.weekly!
                                        .storeProduct.title,
                                    '-',
                                  ),
                                  priceString: valueOrDefault<String>(
                                    revenue_cat.offerings!.current!.weekly!
                                        .storeProduct.priceString,
                                    '-',
                                  ),
                                  perMonthPrice: valueOrDefault<String>(
                                    (double.parse(((revenue_cat
                                                    .offerings!
                                                    .current!
                                                    .weekly!
                                                    .storeProduct
                                                    .price) *
                                                52 /
                                                12)
                                            .toStringAsFixed(2)))
                                        .toString(),
                                    '0',
                                  ),
                                  approxSign: FFLocalizations.of(context)
                                      .getText('8u51n3um' /*  ≈  */),
                                  perMonthSuffix: FFLocalizations.of(context)
                                      .getText('9w0g4j4t' /* / month */),
                                  ctaLabel: FFLocalizations.of(context)
                                      .getText('1g94zlat' /* Continue */),
                                  selected: FFAppState().subscriptionmonth,
                                  onSelect: () {
                                    FFAppState().subscriptionmonth = true;
                                    safeSetState(() {});
                                  },
                                  onContinue: () => _purchasePlan(
                                    isMonth: true,
                                    package: '\$rc_weekly',
                                    durationDays: 7,
                                    telegramForm: 'Monthpayment',
                                    telegramMessage:
                                        'Wow! You have a new month subscription!',
                                  ),
                                ),
                                delayMs: 240),
                            Padding(
                              padding: EdgeInsets.only(top: theme.space.s12),
                              child: _rise(
                                  PlanCard(
                                    title: valueOrDefault<String>(
                                      revenue_cat.offerings!.current!.annual!
                                          .storeProduct.title,
                                      '-',
                                    ),
                                    priceString: valueOrDefault<String>(
                                      revenue_cat.offerings!.current!.annual!
                                          .storeProduct.priceString,
                                      '-',
                                    ),
                                    perMonthPrice: valueOrDefault<String>(
                                      (double.parse(((revenue_cat
                                                      .offerings!
                                                      .current!
                                                      .annual!
                                                      .storeProduct
                                                      .price) /
                                                  12)
                                              .toStringAsFixed(2)))
                                          .toString(),
                                      '0',
                                    ),
                                    approxSign: FFLocalizations.of(context)
                                        .getText('88jhwjj4' /*  ≈  */),
                                    perMonthSuffix: FFLocalizations.of(context)
                                        .getText('yzzh1a7x' /* / month */),
                                    ctaLabel: FFLocalizations.of(context)
                                        .getText('ps8msu6e' /* Continue */),
                                    ribbonLabel: FFLocalizations.of(context)
                                        .getText('bv3k9mp1' /* BEST VALUE */),
                                    savingsLabel: FFLocalizations.of(context)
                                        .getText(
                                            'x8c6hh46' /* TWO MONTHS FREE */),
                                    selected: !FFAppState().subscriptionmonth,
                                    onSelect: () {
                                      FFAppState().subscriptionmonth = false;
                                      safeSetState(() {});
                                    },
                                    onContinue: () => _purchasePlan(
                                      isMonth: false,
                                      package: '\$rc_annual',
                                      durationDays: 365,
                                      telegramForm: 'subscription year',
                                      telegramMessage:
                                          'Wow! You have a new YEAR subscription!',
                                    ),
                                  ),
                                  delayMs: 320),
                            ),
                          ], // end of offerings-ready block
                          Padding(
                            padding: EdgeInsets.only(top: theme.space.s16),
                            child: Text(
                              t.getText('ca7s2xqt'),
                              textAlign: TextAlign.center,
                              style: theme.bodySmall.override(
                                color: paywallTextMuted,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: theme.space.s8),
                            child:
                                _link(t.getText('ebqccf7f'), _restorePurchases),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(theme.space.s24,
                                theme.space.s24, theme.space.s24, 0.0),
                            child: Text(
                              t.getText('whubf4jp'),
                              textAlign: TextAlign.center,
                              style: theme.bodyMedium.override(
                                color: paywallTextMuted,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: theme.space.s16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _link(
                                    t.getText('j321mb3y'),
                                    () => launchURL(
                                        'https://mirra.up.railway.app/privacy.html')),
                                _link(
                                    t.getText('r6swa5sg'),
                                    () => launchURL(
                                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/')),
                              ],
                            ),
                          ),
                        ],
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
  }
}
