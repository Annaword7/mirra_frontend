import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import '/index.dart';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'log_in_page_model.dart';
export 'log_in_page_model.dart';

class LogInPageWidget extends StatefulWidget {
  const LogInPageWidget({super.key});

  static String routeName = 'LogInPage';
  static String routePath = '/log-in';

  @override
  State<LogInPageWidget> createState() => _LogInPageWidgetState();
}

class _LogInPageWidgetState extends State<LogInPageWidget>
    with TickerProviderStateMixin {
  late LogInPageModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LogInPageModel());
    _tabController = TabController(length: 2, vsync: this);

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();
    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.emailRegisterTextController ??= TextEditingController();
    _model.emailRegisterFocusNode ??= FocusNode();
    _model.passwordRegisterTextController ??= TextEditingController();
    _model.passwordRegisterFocusNode ??= FocusNode();

    animationsMap.addAll({
      'columnOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, -20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'transformOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 60.0),
            end: Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  // ── Shared input decoration ───────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
            letterSpacing: 0.0,
            useGoogleFonts:
                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).error,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).error,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      filled: true,
      fillColor: FlutterFlowTheme.of(context).alternate,
      suffixIcon: suffix,
    );
  }

  TextStyle get _inputTextStyle =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
            color: FlutterFlowTheme.of(context).primaryText,
            letterSpacing: 0.0,
            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
          );

  Widget _visibilityIcon(bool visible, VoidCallback onTap) => InkWell(
        onTap: onTap,
        focusNode: FocusNode(skipTraversal: true),
        child: Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: FlutterFlowTheme.of(context).secondaryText,
          size: 18.0,
        ),
      );

  // ── Terms footer ──────────────────────────────────────────────────────────

  Widget _termsFooter() => Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: FFLocalizations.of(context)
                          .getText('9jzxfvzw' /* By continuing, you agree to ou... */),
                      style: const TextStyle(),
                    ),
                  ],
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: FFLocalizations.of(context)
                          .getText('oksxunlm' /* Terms and Privacy Policy */),
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodySmallIsCustom,
                          ),
                    ),
                  ],
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ),
            ),
          ].divide(const SizedBox(height: 5.0)),
        ),
      );

  // ── Apple button ──────────────────────────────────────────────────────────

  Widget _appleButton({required bool isRegister}) => Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
        child: FFButtonWidget(
          onPressed: () async {
            GoRouter.of(context).prepareAuthEvent();
            final user = await authManager.signInWithApple(context);
            if (user == null) return;
            if (isRegister) {
              unawaited(AnalyticsService.instance.trackSignUp(method: 'apple'));
              if (context.mounted) {
                context.goNamedAuth(
                  OnboardingProfileWidget.routeName,
                  context.mounted,
                  extra: <String, dynamic>{
                    '__transition_info__': TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                    ),
                  },
                );
              }
            } else {
              unawaited(AnalyticsService.instance.trackLogin(method: 'apple'));
              if (context.mounted) {
                context.goNamedAuth(HomeWidget.routeName, context.mounted);
              }
            }
          },
          text: FFLocalizations.of(context).getText('gbhzkxej' /* Continue with Apple */),
          icon: const Icon(Icons.apple, size: 15.0),
          options: FFButtonOptions(
            width: double.infinity,
            height: 55.0,
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
            color: FlutterFlowTheme.of(context).primaryText,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleSmallIsCustom,
                ),
            elevation: 0.0,
            borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
      );

  // ── Login tab content ─────────────────────────────────────────────────────

  Widget _loginForm() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FFLocalizations.of(context).getText('s2sex1cq' /* Welcome back */),
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily:
                        FlutterFlowTheme.of(context).headlineMediumFamily,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                  ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 24.0),
              child: Text(
                FFLocalizations.of(context)
                    .getText('i7sno6fc' /* Enter your details to continue */),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
            // Email
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
              child: TextFormField(
                key: const ValueKey('emailAddress_jmyt'),
                controller: _model.emailAddressTextController,
                focusNode: _model.emailAddressFocusNode,
                autofocus: false,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                obscureText: false,
                decoration: _inputDecoration(
                  FFLocalizations.of(context).getText('v6o9xcii' /* Email address */),
                ),
                style: _inputTextStyle,
                keyboardType: TextInputType.emailAddress,
                cursorColor: FlutterFlowTheme.of(context).primary,
                validator: _model.emailAddressTextControllerValidator
                    .asValidator(context),
              ),
            ),
            // Password
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
              child: TextFormField(
                controller: _model.passwordTextController,
                focusNode: _model.passwordFocusNode,
                autofocus: false,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                obscureText: !_model.passwordVisibility,
                decoration: _inputDecoration(
                  FFLocalizations.of(context).getText('8o8sm32x' /* Password */),
                  suffix: _visibilityIcon(
                    _model.passwordVisibility,
                    () => safeSetState(
                        () => _model.passwordVisibility = !_model.passwordVisibility),
                  ),
                ),
                style: _inputTextStyle,
                cursorColor: FlutterFlowTheme.of(context).primary,
                validator: _model.passwordTextControllerValidator
                    .asValidator(context),
              ),
            ),
            // Log in button
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
              child: FFButtonWidget(
                key: const ValueKey('Button_mqqr'),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  GoRouter.of(context).prepareAuthEvent();
                  final user = await authManager.signInWithEmail(
                    context,
                    _model.emailAddressTextController.text,
                    _model.passwordTextController.text,
                  );
                  if (user == null) return;
                  unawaited(AnalyticsService.instance.trackLogin());
                  if (context.mounted) {
                    context.goNamedAuth(HomeWidget.routeName, context.mounted);
                  }
                },
                text: FFLocalizations.of(context).getText('jvlhc56j' /* Log in */),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 55.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleSmallFamily,
                        color: Colors.white,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleSmallIsCustom,
                      ),
                  elevation: 0.0,
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 1.0),
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
            // Apple sign-in (iOS only)
            if (!isAndroid) _appleButton(isRegister: false),
            // Forgot password
            Column(
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      context.pushNamed(ForgotPasswordWidget.routeName);
                    },
                    child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: FFLocalizations.of(context)
                                .getText('k1r81ycx' /* Forgot password?  */),
                            style: const TextStyle(),
                          ),
                          TextSpan(
                            text: FFLocalizations.of(context)
                                .getText('f4zg2rq8' /* Reset */),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts:
                                      !FlutterFlowTheme.of(context)
                                          .bodyMediumIsCustom,
                                ),
                          ),
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                  ),
                ),
              ]
                  .divide(const SizedBox(height: 16.0))
                  .around(const SizedBox(height: 16.0)),
            ),
            _termsFooter(),
          ],
        ),
      );

  // ── Register tab content ──────────────────────────────────────────────────

  Widget _registerForm() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 40.0),
        child: Form(
          key: _model.formKeyRegister,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FFLocalizations.of(context)
                    .getText('v4ogufdc' /* Create your profile */),
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).headlineMediumFamily,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                    ),
              ),
              const SizedBox(height: 24.0),
              // Email
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                child: TextFormField(
                  controller: _model.emailRegisterTextController,
                  focusNode: _model.emailRegisterFocusNode,
                  autofocus: false,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  obscureText: false,
                  decoration: _inputDecoration(
                    FFLocalizations.of(context).getText('fzz6pquo' /* Email address */),
                  ),
                  style: _inputTextStyle,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: FlutterFlowTheme.of(context).primary,
                  validator: _model.emailRegisterTextControllerValidator
                      .asValidator(context),
                ),
              ),
              // Password
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                child: TextFormField(
                  controller: _model.passwordRegisterTextController,
                  focusNode: _model.passwordRegisterFocusNode,
                  autofocus: false,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  obscureText: !_model.passwordRegisterVisibility,
                  decoration: _inputDecoration(
                    FFLocalizations.of(context).getText('jl6rrleg' /* Password */),
                    suffix: _visibilityIcon(
                      _model.passwordRegisterVisibility,
                      () => safeSetState(() => _model.passwordRegisterVisibility =
                          !_model.passwordRegisterVisibility),
                    ),
                  ),
                  style: _inputTextStyle,
                  cursorColor: FlutterFlowTheme.of(context).primary,
                  validator: _model.passwordRegisterTextControllerValidator
                      .asValidator(context),
                ),
              ),
              // Create account button
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    if (_model.formKeyRegister.currentState == null ||
                        !_model.formKeyRegister.currentState!.validate()) {
                      return;
                    }
                    GoRouter.of(context).prepareAuthEvent();
                    final user = await authManager.createAccountWithEmail(
                      context,
                      _model.emailRegisterTextController.text,
                      _model.passwordRegisterTextController.text,
                    );
                    if (user == null) return;
                    unawaited(AnalyticsService.instance.trackSignUp());
                    if (context.mounted) {
                      context.goNamedAuth(
                        OnboardingProfileWidget.routeName,
                        context.mounted,
                        extra: <String, dynamic>{
                          '__transition_info__': TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                          ),
                        },
                      );
                    }
                  },
                  text: FFLocalizations.of(context)
                      .getText('o5q6qmi9' /* Create account */),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 55.0,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              color: Colors.white,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                    elevation: 0.0,
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 1.0),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
              ),
              // Apple sign-up (iOS only)
              if (!isAndroid) _appleButton(isRegister: true),
              _termsFooter(),
            ],
          ),
        ),
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 30.0,
              ),
              onPressed: () async {
                context.pushNamed(NewblankWidget.routeName);
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 12.0),
                child: Container(
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).alternate,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        FlutterFlowTheme.of(context).secondaryText,
                    labelStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                    unselectedLabelStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).titleSmallFamily,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .titleSmallIsCustom,
                            ),
                    tabs: [
                      Tab(
                        text: FFLocalizations.of(context)
                            .getText('jvlhc56j' /* Log in */),
                      ),
                      Tab(
                        text: FFLocalizations.of(context)
                            .getText('o5q6qmi9' /* Create account */),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: const [],
            centerTitle: false,
            elevation: 0.0,
          ),
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                // Carousel background (hidden when keyboard visible)
                if (!(isWeb
                    ? MediaQuery.viewInsetsOf(context).bottom > 0
                    : _isKeyboardVisible))
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.88),
                    child: Transform.scale(
                      scaleX: 1.2,
                      scaleY: 1.2,
                      child: Transform.rotate(
                        angle: 8.0 * (math.pi / 180),
                        child: SizedBox(
                          width: double.infinity,
                          height: 225.0,
                          child: CarouselSlider(
                            items: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset('assets/images/image12.png',
                                    width: 300.0,
                                    height: 200.0,
                                    fit: BoxFit.cover),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset('assets/images/image11.png',
                                    width: 300.0,
                                    height: 200.0,
                                    fit: BoxFit.cover),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset('assets/images/image13.png',
                                    width: 300.0,
                                    height: 200.0,
                                    fit: BoxFit.cover),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset('assets/images/image14.png',
                                    width: 300.0,
                                    height: 200.0,
                                    fit: BoxFit.cover),
                              ),
                            ],
                            carouselController:
                                _model.carouselController ??=
                                    CarouselSliderController(),
                            options: CarouselOptions(
                              initialPage: 1,
                              viewportFraction: 0.6,
                              disableCenter: true,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.25,
                              enableInfiniteScroll: true,
                              scrollDirection: Axis.horizontal,
                              autoPlay: true,
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              autoPlayInterval:
                                  const Duration(milliseconds: 4800),
                              autoPlayCurve: Curves.linear,
                              pauseAutoPlayInFiniteScroll: true,
                              onPageChanged: (index, _) =>
                                  _model.carouselCurrentIndex = index,
                            ),
                          ),
                        ),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['transformOnPageLoadAnimation']!),
                  ),
                // Tab content
                TabBarView(
                  controller: _tabController,
                  children: [
                    _loginForm(),
                    _registerForm(),
                  ],
                ).animateOnPageLoad(
                    animationsMap['columnOnPageLoadAnimation']!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
