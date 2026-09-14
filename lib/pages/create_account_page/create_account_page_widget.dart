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
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'create_account_page_model.dart';
export 'create_account_page_model.dart';

/// Отдельный экран регистрации (с карточки продукта, из профиля, с пейвола).
///
/// Разметка намеренно повторяет вкладку «Создать аккаунт» на [LogInPageWidget]:
/// заголовок, почта, пароль, кнопка, Apple, соглашение внизу. Пользователь
/// попадает то сюда, то туда, и расхождение выглядело бы как два разных
/// приложения.
class CreateAccountPageWidget extends StatefulWidget {
  const CreateAccountPageWidget({super.key});

  static String routeName = 'CreateAccountPage';
  static String routePath = '/create-account';

  @override
  State<CreateAccountPageWidget> createState() =>
      _CreateAccountPageWidgetState();
}

class _CreateAccountPageWidgetState extends State<CreateAccountPageWidget> {
  late CreateAccountPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateAccountPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        Duration(
          milliseconds: 600,
        ),
      );
      HapticFeedback.lightImpact();
    });

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    // «Тапнул на строку» = поле получило фокус: в пароль попадают и кнопкой
    // «дальше» с клавиатуры, а не только тапом.
    _model.emailAddressFocusNode!.addListener(_onEmailFocus);
    _model.passwordFocusNode!.addListener(_onPasswordFocus);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.emailAddressFocusNode?.removeListener(_onEmailFocus);
    _model.passwordFocusNode?.removeListener(_onPasswordFocus);
    _model.dispose();
    super.dispose();
  }

  void _onEmailFocus() {
    if (_model.emailAddressFocusNode?.hasFocus ?? false) {
      unawaited(AnalyticsService.instance.trackCreateProfileEmailTap());
    }
  }

  void _onPasswordFocus() {
    if (_model.passwordFocusNode?.hasFocus ?? false) {
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
          _t('gxuca5l4' /* By continuing, you agree to ou... */),
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

  Widget _appleButton() {
    final theme = FlutterFlowTheme.of(context);
    return FFButtonWidget(
      onPressed: () async {
        unawaited(AnalyticsService.instance.trackCreateProfileAppleId());
        GoRouter.of(context).prepareAuthEvent();
        final user = await authManager.signInWithApple(context);
        if (user == null) return;
        unawaited(AnalyticsService.instance
            .trackCreateAccount(from: 'create_account_page'));
        if (context.mounted) _goToProfile();
      },
      text: _t('wvkbomvg' /* Continue with Apple */),
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

  void _goToProfile() => context.goNamedAuth(
        OnboardingProfileWidget.routeName,
        context.mounted,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
          ),
        },
      );

  Future<void> _createAccount() async {
    HapticFeedback.lightImpact();
    if (_model.formKey.currentState == null ||
        !_model.formKey.currentState!.validate()) {
      return;
    }
    GoRouter.of(context).prepareAuthEvent();
    final user = await authManager.createAccountWithEmail(
      context,
      _model.emailAddressTextController.text,
      _model.passwordTextController.text,
    );
    if (user == null) return;
    unawaited(AnalyticsService.instance
        .trackCreateAccount(from: 'create_account_page'));
    if (context.mounted) _goToProfile();
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
                // Return to the previous screen (e.g. a scan result for an
                // anonymous user) rather than always jumping to the welcome
                // screen and stranding the user's accumulated scans.
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(NewblankWidget.routeName);
                }
              },
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(theme.space.s24),
                    // heightFactor обязателен: внутри скролла высота не
                    // ограничена, и Center без него пытается растянуться в
                    // бесконечность.
                    child: Center(
                      heightFactor: 1.0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600.0),
                        child: Form(
                          key: _model.formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('v4ogufdc' /* Create account */),
                                style: theme.headlineMedium.override(
                                  fontFamily: theme.headlineMediumFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !theme.headlineMediumIsCustom,
                                ),
                              ),
                              SizedBox(height: theme.space.s24),
                              AppTextField(
                                controller: _model.emailAddressTextController,
                                focusNode: _model.emailAddressFocusNode,
                                autofocus: true,
                                hintText: _t('fzz6pquo' /* Email address */),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: _model
                                    .emailAddressTextControllerValidator
                                    .asValidator(context),
                              ),
                              SizedBox(height: theme.space.s16),
                              AppTextField.password(
                                controller: _model.passwordTextController,
                                focusNode: _model.passwordFocusNode,
                                hintText: _t('jl6rrleg' /* Password */),
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.newPassword
                                ],
                                validator: _model
                                    .passwordTextControllerValidator
                                    .asValidator(context),
                              ),
                              SizedBox(height: theme.space.s24),
                              AppButton(
                                label: _t('o5q6qmi9' /* Create account */),
                                onPressed: _createAccount,
                              ),
                              if (!isAndroid) ...[
                                SizedBox(height: theme.space.s12),
                                _appleButton(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
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
