import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'onboarding_carousel_model.dart';
export 'onboarding_carousel_model.dart';

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
  late final List<VideoPlayerController> _controllers;

  static const _bgColor = Color(0xFF060D1E);

  static const _slides = [
    _SlideData(
      videoAsset: 'assets/videos/onboarding_1.mp4',
      title: 'Сканируйте косметические продукты',
      subtitle: 'перед покупкой',
    ),
    _SlideData(
      videoAsset: 'assets/videos/onboarding_2.mp4',
      title: 'Получите полноценный анализ',
      subtitle: 'всего за 30 секунд',
    ),
    _SlideData(
      videoAsset: 'assets/videos/onboarding_3.mp4',
      title: 'В любой момент возвращайтесь',
      subtitle: 'к своей коллекции',
    ),
    _SlideData(
      videoAsset: 'assets/videos/onboarding_4.mp4',
      title: 'Коллекция топ продуктов от сообщества',
      subtitle: 'Быстро находите то, что уже проверено',
    ),
    _SlideData(
      videoAsset: 'assets/videos/onboarding_5.mp4',
      title: 'Быстро делитесь находками',
      subtitle: 'и создавайте посты в социальных сетях',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingCarouselModel());

    _controllers = _slides
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
  }

  @override
  void dispose() {
    _model.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Просто видео на весь слайд, без градиентов — они теперь общие поверх PageView
  Widget _buildVideoSlide(VideoPlayerController controller) {
    if (!controller.value.isInitialized) {
      return const ColoredBox(color: Color(0xFF0C1A35));
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isLast = _model.pageViewCurrentIndex == _slides.length - 1;
    final slide = _slides[_model.pageViewCurrentIndex];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
          children: [
            // 1. Анимированный фон
            Positioned.fill(
              child: custom_widgets.AnimatedPaywallBg(
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // 2. Видео — подложка на весь экран
            Positioned.fill(
              child: PageView.builder(
                controller: _model.pageViewController ??=
                    PageController(initialPage: 0),
                onPageChanged: (i) {
                  for (int j = 0; j < _controllers.length; j++) {
                    if (_controllers[j].value.isInitialized) {
                      j == i
                          ? _controllers[j].play()
                          : _controllers[j].pause();
                    }
                  }
                  safeSetState(() {});
                },
                itemCount: _slides.length,
                itemBuilder: (_, i) => _buildVideoSlide(_controllers[i]),
              ),
            ),

            // 3. Верхний градиент (фон → прозрачный)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_bgColor, Color(0x00060D1E)],
                  ),
                ),
              ),
            ),

            // 4. Нижний градиент (прозрачный → фон)
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

            // 5. Контент поверх всего
            Positioned.fill(
              child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Текст слайда
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .headlineSmallFamily,
                                color: Colors.white,
                                fontSize: 22,
                                letterSpacing: 0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .headlineSmallIsCustom,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                color: Colors.white.withAlpha(178),
                                letterSpacing: 0,
                                lineHeight: 1.4,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Индикатор страниц
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

                  // Кнопка
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
                      text: isLast ? 'Начать' : 'Продолжить',
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
            )),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final String videoAsset;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.videoAsset,
    required this.title,
    required this.subtitle,
  });
}
