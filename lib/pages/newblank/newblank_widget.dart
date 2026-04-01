import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'newblank_model.dart';
export 'newblank_model.dart';

class NewblankWidget extends StatefulWidget {
  const NewblankWidget({super.key});

  static String routeName = 'newblank';
  static String routePath = '/Splash';

  @override
  State<NewblankWidget> createState() => _NewblankWidgetState();
}

class _NewblankWidgetState extends State<NewblankWidget> {
  late NewblankModel _model;
  bool _loading = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewblankModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(BuildContext context, Map<String, String> map) {
    final lang = FFLocalizations.of(context).languageCode;
    return map[lang] ?? map['en']!;
  }

  Future<void> _tryAnonymously() async {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    final user = await authManager.signInAnonymously(context);
    if (mounted) setState(() => _loading = false);
    if (user != null && mounted) {
      context.goNamed(
        HomeWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
          ),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // ── Icon ──
                _HeroIcon()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 36),

                // ── Headline ──
                Text(
                  _t(context, {
                    'ru': 'Проверь состав\nза 30 секунд',
                    'es': 'Analiza el INCI\nen 30 segundos',
                    'en': 'Check ingredients\nin 30 seconds',
                  }),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).displaySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).displaySmallFamily,
                        fontSize: 34.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.2,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).displaySmallIsCustom,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 500.ms)
                    .slideY(begin: 0.15, end: 0, duration: 500.ms),

                const SizedBox(height: 16),

                // ── Subtitle ──
                Text(
                  _t(context, {
                    'ru':
                        'Сфотографируй косметику — узнай что внутри и безопасно ли это для твоей кожи',
                    'es':
                        'Fotografía cualquier cosmético y descubre qué hay dentro y si es seguro para tu piel',
                    'en':
                        'Photograph any cosmetic and find out what\'s inside and whether it\'s safe for your skin',
                  }),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyLargeFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                        lineHeight: 1.55,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 500.ms)
                    .slideY(begin: 0.15, end: 0, duration: 500.ms),

                const Spacer(flex: 3),

                // ── Primary CTA ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _tryAnonymously,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          FlutterFlowTheme.of(context).primary.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _t(context, {
                                  'ru': 'Попробовать',
                                  'es': 'Probar gratis',
                                  'en': 'Try it free',
                                }),
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleSmallFamily,
                                      color: Colors.white,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleSmallIsCustom,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms),

                const SizedBox(height: 16),

                // ── Secondary link ──
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.goNamed(
                      LogInPageWidget.routeName,
                      extra: <String, dynamic>{
                        '__transition_info__': TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                        ),
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      _t(context, {
                        'ru': 'Войти / Зарегистрироваться',
                        'es': 'Entrar / Crear cuenta',
                        'en': 'Sign in / Create account',
                      }),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 400.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = FlutterFlowTheme.of(context).primary;
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.08),
            ),
          ),
          // Inner circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.14),
            ),
          ),
          // Camera icon
          Icon(
            Icons.camera_alt_rounded,
            size: 52,
            color: primary,
          ),
          // Science badge — top right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FlutterFlowTheme.of(context).primaryBackground,
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.science_rounded,
                size: 18,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
