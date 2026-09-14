import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/analytics_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/design_system/components/app_text_field.dart';
import '/design_system/components/app_button.dart';
import 'dart:async';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'log_in_page_model.dart';
export 'log_in_page_model.dart';

/// Вход и регистрация одним экраном с двумя вкладками.
///
/// Обе вкладки собирает один `_authForm`: раскладка у них обязана совпадать
/// до пикселя, иначе при переключении поля и кнопки прыгают по вертикали.
/// Различаются только подписи, контроллеры и обработчики. Соглашение об
/// использовании вынесено из вкладок вниз экрана — оно одинаковое для обеих,
/// и на месте оно тоже не даёт разметке дёргаться.
///
/// Раньше рядом жил отдельный экран `/create-account` с той же формой. Он
/// повторял вкладку регистрации и успел от неё отстать, поэтому удалён: те,
/// кто вёл на него, открывают этот экран с `?tab=register`.
class LogInPageWidget extends StatefulWidget {
  const LogInPageWidget({super.key, this.startOnRegister = false});

  static String routeName = 'LogInPage';
  static String routePath = '/log-in';

  /// Открыть сразу вкладку «Создать аккаунт» (query-параметр `tab=register`).
  final bool startOnRegister;

  @override
  State<LogInPageWidget> createState() => _LogInPageWidgetState();
}

class _LogInPageWidgetState extends State<LogInPageWidget>
    with TickerProviderStateMixin {
  late LogInPageModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LogInPageModel());
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.startOnRegister ? 1 : 0,
    );

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();
    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.emailRegisterTextController ??= TextEditingController();
    _model.emailRegisterFocusNode ??= FocusNode();
    _model.passwordRegisterTextController ??= TextEditingController();
    _model.passwordRegisterFocusNode ??= FocusNode();

    // «Тапнул на строку» = поле получило фокус: в пароль попадают и кнопкой
    // «дальше» с клавиатуры, а не только тапом. События слушают только поля
    // регистрации — они и назывались create_profile_*, и до объединения
    // экранов жили на /create-account.
    _model.emailRegisterFocusNode!.addListener(_onRegisterEmailFocus);
    _model.passwordRegisterFocusNode!.addListener(_onRegisterPasswordFocus);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.emailRegisterFocusNode?.removeListener(_onRegisterEmailFocus);
    _model.passwordRegisterFocusNode?.removeListener(_onRegisterPasswordFocus);
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _onRegisterEmailFocus() {
    if (_model.emailRegisterFocusNode?.hasFocus ?? false) {
      unawaited(AnalyticsService.instance.trackCreateProfileEmailTap());
    }
  }

  void _onRegisterPasswordFocus() {
    if (_model.passwordRegisterFocusNode?.hasFocus ?? false) {
      unawaited(AnalyticsService.instance.trackCreateProfilePasswordTap());
    }
  }

  String _t(String key) => FFLocalizations.of(context).getText(key);

  // ── Соглашение об использовании ───────────────────────────────────────────

  Widget _termsFooter() {
    final theme = FlutterFlowTheme.of(context);
    final linkStyle = theme.bodySmall.override(
      fontFamily: theme.bodySmallFamily,
      color: theme.primary,
      letterSpacing: 0.0,
      useGoogleFonts: !theme.bodySmallIsCustom,
    );
    final plainStyle = theme.bodySmall.override(
      fontFamily: theme.bodySmallFamily,
      color: theme.secondaryText,
      letterSpacing: 0.0,
      useGoogleFonts: !theme.bodySmallIsCustom,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _t('9jzxfvzw' /* By continuing, you agree to ou... */),
          textAlign: TextAlign.center,
          style: plainStyle,
        ),
        SizedBox(height: theme.space.s4),
        // Wrap, а не Row: в немецком и турецком два названия документов в
        // строку не помещаются и Row уходил в переполнение.
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                await launchURL(
                    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
              },
              child: Text(_t('r6swa5sg' /* Terms of use */), style: linkStyle),
            ),
            Text(' · ', style: plainStyle),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                await launchURL('https://mirra.up.railway.app/privacy.html');
              },
              child:
                  Text(_t('j321mb3y' /* Privacy Policy */), style: linkStyle),
            ),
          ],
        ),
      ],
    );
  }

  // ── Вход через Apple ──────────────────────────────────────────────────────

  Widget _appleButton({required bool isRegister}) {
    final theme = FlutterFlowTheme.of(context);
    return FFButtonWidget(
      onPressed: () async {
        unawaited(AnalyticsService.instance.trackCreateProfileAppleId());
        GoRouter.of(context).prepareAuthEvent();
        final user = await authManager.signInWithApple(context);
        if (user == null) return;
        if (isRegister) {
          unawaited(
              AnalyticsService.instance.trackCreateAccount(from: 'log_in_page'));
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
          unawaited(AnalyticsService.instance.trackLogIn());
          if (context.mounted) {
            context.goNamedAuth(HomeWidget.routeName, context.mounted);
          }
        }
      },
      text: _t('gbhzkxej' /* Continue with Apple */),
      icon: const Icon(Icons.apple, size: 20.0),
      options: FFButtonOptions(
        width: double.infinity,
        // Та же высота, что у AppButton: иначе две кнопки подряд выглядят
        // разнокалиберными.
        height: theme.size.buttonLg,
        padding: EdgeInsets.zero,
        iconPadding: EdgeInsets.zero,
        color: theme.primaryText,
        textStyle: theme.labelLarge.override(
          fontFamily: theme.labelLargeFamily,
          color: theme.alternate,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w600,
          useGoogleFonts: !theme.labelLargeIsCustom,
        ),
        elevation: 0.0,
        borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
        borderRadius: BorderRadius.circular(theme.radii.full),
      ),
    );
  }

  // ── Форма: одна разметка на обе вкладки ───────────────────────────────────

  Widget _authForm({required bool isRegister}) {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.space.s24),
      child: Form(
        key: isRegister ? _model.formKeyRegister : _model.formKeyLogin,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              // Ключи читает integration_test/test.dart — на вкладке входа они
              // обязаны остаться.
              key: isRegister ? null : const ValueKey('emailAddress_jmyt'),
              controller: isRegister
                  ? _model.emailRegisterTextController
                  : _model.emailAddressTextController,
              focusNode: isRegister
                  ? _model.emailRegisterFocusNode
                  : _model.emailAddressFocusNode,
              hintText: isRegister
                  ? _t('fzz6pquo' /* Email address */)
                  : _t('v6o9xcii' /* Email address */),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (isRegister
                      ? _model.emailRegisterTextControllerValidator
                      : _model.emailAddressTextControllerValidator)
                  .asValidator(context),
            ),
            SizedBox(height: theme.space.s16),
            AppTextField.password(
              controller: isRegister
                  ? _model.passwordRegisterTextController
                  : _model.passwordTextController,
              focusNode: isRegister
                  ? _model.passwordRegisterFocusNode
                  : _model.passwordFocusNode,
              hintText: isRegister
                  ? _t('jl6rrleg' /* Password */)
                  : _t('8o8sm32x' /* Password */),
              textInputAction: TextInputAction.done,
              autofillHints: [
                isRegister ? AutofillHints.newPassword : AutofillHints.password
              ],
              validator: (isRegister
                      ? _model.passwordRegisterTextControllerValidator
                      : _model.passwordTextControllerValidator)
                  .asValidator(context),
            ),
            SizedBox(height: theme.space.s24),
            AppButton(
              key: isRegister ? null : const ValueKey('Button_mqqr'),
              label: isRegister
                  ? _t('o5q6qmi9' /* Create account */)
                  : _t('jvlhc56j' /* Sign in */),
              onPressed: isRegister ? _createAccount : _signIn,
            ),
            if (!isAndroid) ...[
              SizedBox(height: theme.space.s12),
              _appleButton(isRegister: isRegister),
            ],
            // «Забыли пароль?» стоит последним и только на вкладке входа:
            // появляясь снизу, он ничего выше себя не сдвигает.
            if (!isRegister) ...[
              SizedBox(height: theme.space.s24),
              Align(
                alignment: AlignmentDirectional.center,
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
                          text: _t('k1r81ycx' /* Forgot password?  */),
                          style: const TextStyle(),
                        ),
                        TextSpan(
                          text: _t('f4zg2rq8' /* Reset */),
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            color: theme.primary,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ],
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    HapticFeedback.lightImpact();
    GoRouter.of(context).prepareAuthEvent();
    final user = await authManager.signInWithEmail(
      context,
      _model.emailAddressTextController.text,
      _model.passwordTextController.text,
    );
    if (user == null) return;
    unawaited(AnalyticsService.instance.trackLogIn());
    if (context.mounted) {
      context.goNamedAuth(HomeWidget.routeName, context.mounted);
    }
  }

  Future<void> _createAccount() async {
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
    unawaited(AnalyticsService.instance.trackCreateAccount(from: 'log_in_page'));
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
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.alternate,
          appBar: AppBar(
            backgroundColor: theme.alternate,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: theme.primaryText,
                size: 30.0,
              ),
              onPressed: () async {
                // Return to wherever we came from (e.g. a scan result for an
                // anonymous user) instead of always jumping to the welcome
                // screen, which would strand the user's accumulated scans.
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(NewblankWidget.routeName);
                }
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    theme.space.s24, 0.0, theme.space.s24, theme.space.s12),
                child: Container(
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: theme.surfaceMuted,
                    borderRadius: BorderRadius.circular(theme.radii.full),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(theme.radii.full),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: theme.onPrimary,
                    unselectedLabelColor: theme.secondaryText,
                    labelStyle: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.titleSmallIsCustom,
                    ),
                    unselectedLabelStyle: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.titleSmallIsCustom,
                    ),
                    tabs: [
                      Tab(text: _t('jvlhc56j' /* Sign in */)),
                      Tab(text: _t('o5q6qmi9' /* Create account */)),
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
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _authForm(isRegister: false),
                      _authForm(isRegister: true),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(theme.space.s24, theme.space.s8,
                      theme.space.s24, theme.space.s12),
                  child: _termsFooter(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
