import 'dart:async';
import 'dart:ui';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/premium_features_list/premium_features_list_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/revenue_cat_util.dart' as revenue_cat;
import '/design_system/components/plan_card.dart';
import '/design_system/components/pro_pill.dart';
import 'package:flutter/material.dart';
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

      // Load offerings if not already available
      if (revenue_cat.offerings?.current?.weekly == null ||
          revenue_cat.offerings?.current?.annual == null) {
        safeSetState(() => _offeringsLoading = true);
        await revenue_cat.loadOfferings();
        if (mounted) safeSetState(() => _offeringsLoading = false);
      }

      // loadOfferings() swallows its errors, so the only signal that the
      // paywall is a dead end is the state it leaves behind.
      unawaited(AnalyticsService.instance.trackPaywallOfferingsLoaded(
        ready: _offeringsReady,
        configured: revenue_cat.isConfigured,
      ));
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
        await SubscriptionupgradeNEWBCNDCall.call(
          host: FFDevEnvironmentValues().backendhost,
          durationDays: durationDays,
          userId: currentUserUid,
        );
        await TelegrammessegeCall.call(
          email: currentUserEmail,
          form: telegramForm,
          messega: telegramMessage,
        );
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

    // Paywall dark-surface palette (Initiative 10) — grouped file-locally;
    // the color-token track is paused, so these are not theme tokens yet.
    const paywallScaffold = Color(0xFF060D1E);
    final paywallShell = const Color(0xFF0C1A35).withValues(alpha: 0.80);
    final paywallShellBorder = Colors.white.withValues(alpha: 0.09);
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
                  decoration: BoxDecoration(
                    color: paywallShell,
                    borderRadius: BorderRadius.circular(28.0),
                    border: Border.all(
                      color: paywallShellBorder,
                      width: 1.0,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 12.0, 16.0, 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FlutterFlowIconButton(
                                borderColor: Colors.transparent,
                                borderRadius: 30.0,
                                borderWidth: 1.0,
                                buttonSize: 44.0,
                                icon: Icon(
                                  Icons.close,
                                  color: paywallIconMuted,
                                  size: 20.0,
                                ),
                                onPressed: () async {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.goNamed(HomeWidget.routeName);
                                  }
                                },
                              ),
                              ProPill(
                                label: FFLocalizations.of(context)
                                    .getText('7n2kv1iq' /* UPGRADE TO PRO */),
                              ),
                              // Spacer to balance the close button
                              SizedBox(width: 44.0),
                            ],
                          ).animate().fadeIn(duration: 500.ms).slideY(
                              begin: 0.12,
                              end: 0.0,
                              duration: 500.ms,
                              curve: Curves.easeOut),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 6.0, 0.0, 0.0),
                            child: Text(
                              FFLocalizations.of(context).getText(
                                '2rjs2u6d' /* Increased Limit, Private Produ... */,
                              ),
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .headlineSmallFamily,
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w700,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .headlineSmallIsCustom,
                                  ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 80.ms)
                              .slideY(
                                  begin: 0.12,
                                  end: 0.0,
                                  duration: 500.ms,
                                  delay: 80.ms,
                                  curve: Curves.easeOut),
                          wrapWithModel(
                            model: _model.premiumFeaturesListModel,
                            updateCallback: () => safeSetState(() {}),
                            child: PremiumFeaturesListWidget(),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 160.ms)
                              .slideY(
                                  begin: 0.12,
                                  end: 0.0,
                                  duration: 500.ms,
                                  delay: 160.ms,
                                  curve: Curves.easeOut),
                          if (_offeringsLoading || !_offeringsReady)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          else ...[
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
                                (double.parse(((revenue_cat.offerings!.current!
                                                .weekly!.storeProduct.price) *
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
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 240.ms)
                                .slideY(
                                    begin: 0.12,
                                    end: 0.0,
                                    duration: 500.ms,
                                    delay: 240.ms,
                                    curve: Curves.easeOut),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 0.0),
                              child: PlanCard(
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
                                    .getText('x8c6hh46' /* TWO MONTHS FREE */),
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
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 320.ms)
                                .slideY(
                                    begin: 0.12,
                                    end: 0.0,
                                    duration: 500.ms,
                                    delay: 320.ms,
                                    curve: Curves.easeOut),
                          ], // end of offerings-ready block
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 16.0, 0.0, 0.0),
                            child: Text(
                              FFLocalizations.of(context).getText('ca7s2xqt'),
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    color: paywallTextMuted,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodySmallIsCustom,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.rCUserID3 = await actions.rcEnsureLogin(
                                  context,
                                  currentUserUid,
                                );
                                await revenue_cat.restorePurchases();
                                final isEntitled = await revenue_cat
                                        .isEntitled('EntitlementMirra') ??
                                    false;
                                if (!isEntitled) {
                                  await revenue_cat.loadOfferings();
                                }

                                if (isEntitled) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        FFLocalizations.of(context)
                                            .getText('rs4p1dq2'),
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        FFLocalizations.of(context)
                                            .getText('rf9m3wk5'),
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                }

                                safeSetState(() {});

                                safeSetState(() {});
                              },
                              child: Text(
                                FFLocalizations.of(context).getText(
                                  'ebqccf7f' /* Restore Purchases */,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w700,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 24.0, 24.0, 0.0),
                            child: Text(
                              FFLocalizations.of(context).getText(
                                'whubf4jp' /* Subscription price:
It is a sy... */
                                ,
                              ),
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color: paywallTextMuted,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 26.0, 0.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await launchURL(
                                        'https://mirra.up.railway.app/privacy.html');
                                  },
                                  child: Text(
                                    FFLocalizations.of(context).getText(
                                      'j321mb3y' /* Privacy Policy */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w700,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await launchURL(
                                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                                  },
                                  child: Text(
                                    FFLocalizations.of(context).getText(
                                      'r6swa5sg' /* Terms of use */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w700,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 5.0)),
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
