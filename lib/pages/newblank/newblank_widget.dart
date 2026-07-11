import 'dart:async';

import '/components/guest_prefs_sheet/guest_prefs_sheet_widget.dart';

import '/flutter_flow/flutter_flow_theme.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/flutter_flow/nav/nav.dart';
import '/index.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'newblank_model.dart';

export 'newblank_model.dart';

class NewblankWidget extends StatefulWidget {

  const NewblankWidget({super.key});

  static String routeName = 'Newblank';

  static String routePath = '/newblank';

  @override

  State<NewblankWidget> createState() => _NewblankWidgetState();

}

class _NewblankWidgetState extends State<NewblankWidget> {

  late NewblankModel _model;


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


  Future<void> _tryAnonymously() async {

    HapticFeedback.lightImpact();

    if (!mounted) return;

    // Show prefs sheet FIRST — user is created only on "Continue" inside it.
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GuestPrefsSheet(),
    );

    // Tapping outside returns null — stay on page.
    if (saved != true) return;

    // GuestPrefsSheet.save() created the user and set the language.
    // Navigate using the global key in case the widget was replaced.
    final navCtx = appNavigatorKey.currentContext;
    if (navCtx == null) return;
    navCtx.goNamed(
      TakeorUploadPageWidget.routeName,
      extra: <String, dynamic>{
        '__transition_info__': TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
        ),
      },
    );

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

        backgroundColor: Colors.white,

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

                  FFLocalizations.of(context).getText('nb_check_30s'),

                  textAlign: TextAlign.center,

                  style: FlutterFlowTheme.of(context).displaySmall.override(

                        fontFamily:

                            FlutterFlowTheme.of(context).displaySmallFamily,
                        color: Colors.black,

                        fontSize: 24.0,

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

                  FFLocalizations.of(context).getText('nb_subtitle'),

                  textAlign: TextAlign.center,

                  style: FlutterFlowTheme.of(context).bodyLarge.override(

                        fontFamily:

                            FlutterFlowTheme.of(context).bodyLargeFamily,
                        fontSize: 16.0,

                        color: Colors.black,

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

                    onPressed: _tryAnonymously,

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

                    child: Row(

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [

                              Text(

                                FFLocalizations.of(context)
                                    .getText('nb_try_free'),

                                style: FlutterFlowTheme.of(context)

                                    .titleSmall

                                    .override(

                                      fontFamily: FlutterFlowTheme.of(context)

                                          .titleSmallFamily,
                                      fontSize: 16.0,

                                      color: Colors.white,

                                      letterSpacing: 0,

                                      fontWeight: FontWeight.w600,

                                      useGoogleFonts:

                                          !FlutterFlowTheme.of(context)

                                              .titleSmallIsCustom,

                                    ),

                              ),

                              const SizedBox(width: 8),

                              const Icon(

                                Icons.arrow_forward_rounded,

                                color: Colors.white,

                                size: 18,

                              ),

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

                    // Use appNavigatorKey so navigation works even if this
                    // widget's context was replaced after anonymous sign-in.
                    final navCtx = appNavigatorKey.currentContext;
                    if (navCtx == null) return;
                    navCtx.goNamed(

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

                      FFLocalizations.of(context)
                          .getText('nb_signin_register'),

                      style: FlutterFlowTheme.of(context).bodyMedium.override(

                            fontFamily:

                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 16.0,

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