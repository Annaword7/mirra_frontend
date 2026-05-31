import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/internationalization.dart';
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'onboarding_carousel_model.dart';
export 'onboarding_carousel_model.dart';
import '/pages/onboarding_analysis/onboarding_analysis_widget.dart';
import '/pages/onboarding_top_cards/onboarding_top_cards_body.dart';
import '/pages/onboarding_share/onboarding_share_body.dart';

// ── Localized slide content ──────────────────────────────────────────────────

class _SlideData {
  final String videoAsset; // empty = no video (custom animated slide)
  final String titleRu, titleEn, titleEs;
  final String subtitleRu, subtitleEn, subtitleEs;

  const _SlideData({
    this.videoAsset = '',
    required this.titleRu,
    required this.titleEn,
    required this.titleEs,
    required this.subtitleRu,
    required this.subtitleEn,
    required this.subtitleEs,
  });
}

String _t(BuildContext context, String ru, String en, String es) {
  final lang = FFLocalizations.of(context).languageCode;
  return lang == 'ru' ? ru : lang == 'es' ? es : en;
}

// ── Slide definitions ────────────────────────────────────────────────────────
// Slide 0 = video (onboarding_1.mp4)
// Slide 1 = OnboardingAnalysisBody animation (no video)

const _slides = [
  _SlideData(
    videoAsset: 'assets/videos/onboarding_1.mp4',
    titleRu: 'Сканируйте косметические продукты',
    titleEn: 'Scan cosmetic products',
    titleEs: 'Escanea productos cosméticos',
    subtitleRu: 'перед покупкой',
    subtitleEn: 'before you buy',
    subtitleEs: 'antes de comprar',
  ),
  _SlideData(
    // index 1 — animated analysis demo (no video)
    titleRu: 'Получите полноценный анализ',
    titleEn: 'Get a full ingredient analysis',
    titleEs: 'Obtén un análisis completo',
    subtitleRu: 'всего за 30 секунд',
    subtitleEn: 'in just 30 seconds',
    subtitleEs: 'en solo 30 segundos',
  ),
  _SlideData(
    videoAsset: 'assets/videos/onboarding_3.mp4',
    titleRu: 'В любой момент возвращайтесь',
    titleEn: 'Come back anytime',
    titleEs: 'Vuelve cuando quieras',
    subtitleRu: 'к своей коллекции',
    subtitleEn: 'to your collection',
    subtitleEs: 'a tu colección',
  ),
  _SlideData(
    // index 3 — top cards auto-scroll widget (no video)
    titleRu: 'Топ продукты от сообщества',
    titleEn: 'Community top products',
    titleEs: 'Los mejores productos',
    subtitleRu: 'Быстро находите то, что уже проверено',
    subtitleEn: 'Quickly find what\'s already been tested',
    subtitleEs: 'Encuentra lo que ya está probado',
  ),
  _SlideData(
    // index 4 — share card demo (no video)
    titleRu: 'Быстро делитесь находками',
    titleEn: 'Share your discoveries fast',
    titleEs: 'Comparte tus descubrimientos',
    subtitleRu: 'и создавайте посты в социальных сетях',
    subtitleEn: 'and create posts for social media',
    subtitleEs: 'y crea publicaciones en redes sociales',
  ),
];

// ── Widget ───────────────────────────────────────────────────────────────────

class OnboardingCarouselWidget extends StatefulWidget {
  const OnboardingCarouselWidget({super.key});

  static String routeName = 'OnboardingCarousel';
  static String routePath = '/onboardingCarousel';

  @override
  State<OnboardingCarouselWidget> createState() =>
      _OnboardingCarouselWidgetState();
}

class _OnboardingCarouselWidgetState extends State<OnboardingCarouselWidget> {
  late OnboardingCarouselModel _model;

  // Video controllers for slides 1–4 (slide 0 is the animation, no video)
  late final List<VideoPlayerController> _controllers;

  static const _bgColor = Color(0xFF060D1E);

  // Video slides are _slides entries with a non-empty videoAsset
  static final _videoSlides =
      _slides.where((s) => s.videoAsset.isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingCarouselModel());

    _controllers = _videoSlides
        .map((s) => VideoPlayerController.asset(s.videoAsset))
        .toList();

    for (final c in _controllers) {
      c.initialize().then((_) {
        c.setLooping(true);
        c.setVolume(0);
        c.play();
        safeSetState(() {});
      }).catchError((_) {});
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

    // Prefetch slide-4 cards + images while user is on slide 1
    prefetchOnboardingCards();
  }

  @override
  void dispose() {
    _model.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Returns the video controller for page [i].
  /// Slide 0 and 2 have videos → _controllers[0] and [1].
  VideoPlayerController? _controllerFor(int i) {
    if (i == 0) return _controllers.isNotEmpty ? _controllers[0] : null;
    if (i == 2) return _controllers.length > 1 ? _controllers[1] : null;
    return null;
  }

  Widget _buildVideoSlide(VideoPlayerController controller) {
    if (!controller.value.isInitialized) {
      return const SizedBox.expand();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        // Width fixed, height cropped to leave ~55% for text
        final vw = w * 0.78;
        final vh = h * 0.55;
        final aspect = controller.value.aspectRatio;
        // Natural video height at this width — will overflow and be clipped
        final naturalVh = vw / aspect;
        return Align(
          alignment: const Alignment(0, -0.82),
          child: Container(
            width: vw,
            height: vh,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxWidth: vw,
                maxHeight: naturalVh,
                child: SizedBox(
                  width: vw,
                  height: naturalVh,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final currentIdx = _model.pageViewCurrentIndex;
    final isLast = currentIdx == _slides.length - 1;
    final slide = _slides[currentIdx];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
          children: [
            // 1. Animated background
            Positioned.fill(
              child: custom_widgets.AnimatedPaywallBg(
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // 2. Column: skip button above video area
            Column(
              children: [
                // 2a. Skip button (above video)
                SafeArea(
                  bottom: false,
                  child: GestureDetector(
                    onTap: () {
                      FFAppState().onboardingDone = true;
                      context.goNamed(PaywallpageWidget.routeName);
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Text(
                          _t(context, 'Пропустить', 'Skip', 'Omitir'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.28),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2b. Video / slide area
                Expanded(
                  child: Stack(
                    children: [
                      // Page content (animation or video)
                      Positioned.fill(
                        child: PageView.builder(
                          controller: _model.pageViewController ??=
                              PageController(initialPage: 0),
                          onPageChanged: (i) {
                            final activeCtrl = _controllerFor(i);
                            for (final c in _controllers) {
                              if (!c.value.isInitialized) continue;
                              c == activeCtrl ? c.play() : c.pause();
                            }
                            safeSetState(() {});
                          },
                          itemCount: _slides.length,
                          itemBuilder: (_, i) {
                            if (i == 1) return const OnboardingAnalysisBody();
                            if (i == 3) return const OnboardingTopCardsBody();
                            if (i == 4) return const OnboardingShareBody();
                            final ctrl = _controllerFor(i);
                            if (ctrl == null) return const SizedBox.shrink();
                            return _buildVideoSlide(ctrl);
                          },
                        ),
                      ),

                      // Bottom gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: MediaQuery.sizeOf(context).height * 0.52,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 0.75],
                              colors: [Color(0x00060D1E), _bgColor],
                            ),
                          ),
                        ),
                      ),

                      // Text + dots + button
                      Positioned.fill(
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            _t(context, slide.titleRu, slide.titleEn,
                                slide.titleEs),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineSmallFamily,
                                  color: Colors.white,
                                  fontSize: 22,
                                  letterSpacing: 0,
                                  useGoogleFonts:
                                      !FlutterFlowTheme.of(context)
                                          .headlineSmallIsCustom,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _t(context, slide.subtitleRu, slide.subtitleEn,
                                slide.subtitleEs),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: Colors.white.withAlpha(178),
                                  letterSpacing: 0,
                                  lineHeight: 1.4,
                                  useGoogleFonts:
                                      !FlutterFlowTheme.of(context)
                                          .bodyMediumIsCustom,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    smooth_page_indicator.SmoothPageIndicator(
                      controller: _model.pageViewController ??=
                          PageController(initialPage: 0),
                      count: _slides.length,
                      axisDirection: Axis.horizontal,
                      onDotClicked: (i) async {
                        await _model.pageViewController!.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                        safeSetState(() {});
                      },
                      effect: smooth_page_indicator.ExpandingDotsEffect(
                        expansionFactor: 3.0,
                        spacing: 6.0,
                        radius: 16.0,
                        dotWidth: 25.0,
                        dotHeight: 8.0,
                        dotColor: const Color(0x805C85D9),
                        activeDotColor: FlutterFlowTheme.of(context).primary,
                        paintStyle: PaintingStyle.fill,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: FFButtonWidget(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          if (isLast) {
                            FFAppState().onboardingDone = true;
                            context.goNamed(PaywallpageWidget.routeName);
                          } else {
                            await _model.pageViewController?.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                        text: isLast
                            ? _t(context, 'Начать', 'Get started', 'Comenzar')
                            : _t(context, 'Продолжить', 'Continue',
                                'Continuar'),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 55,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20, 0, 20, 0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleSmallFamily,
                                color: Colors.white,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleSmallIsCustom,
                              ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
