import 'dart:async';

import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'analysis_loading_model.dart';
export 'analysis_loading_model.dart';

// Ingredient facts per language. Keys: 'en', 'ru', 'es'
const _facts = {
  'en': [
    'Hyaluronic acid can hold up to 1000× its weight in water',
    'Niacinamide reduces pores and evens skin tone at just 2–5%',
    'Vitamin C works best at pH below 3.5 — so formula matters',
    'Retinol speeds up cell turnover — start slow to avoid irritation',
    'Ceramides are the "mortar" between skin cells — they lock moisture in',
    'SPF 30 blocks ~97% of UVB rays; SPF 50 blocks ~98%',
    'Peptides are short amino acid chains that signal skin to produce collagen',
    'Glycerin is one of the most effective and affordable humectants',
    'AHAs exfoliate the surface; BHAs penetrate deep into pores',
    'Squalane mimics your skin\'s natural sebum — great for all skin types',
  ],
  'ru': [
    'Гиалуроновая кислота удерживает до 1000× своего веса в воде',
    'Ниацинамид сужает поры и выравнивает тон при концентрации 2–5%',
    'Витамин C работает эффективно только при pH ниже 3.5',
    'Ретинол ускоряет обновление клеток — начинайте с малых доз',
    'Керамиды — это «цемент» между клетками кожи, удерживающий влагу',
    'SPF 30 блокирует ~97% UVB-лучей, SPF 50 — ~98%',
    'Пептиды — короткие цепочки аминокислот, стимулирующие выработку коллагена',
    'Глицерин — один из самых эффективных и доступных увлажняющих компонентов',
    'AHA-кислоты обновляют поверхность кожи; BHA проникают вглубь пор',
    'Скваланс имитирует натуральное себум кожи — подходит для всех типов',
  ],
  'es': [
    'El ácido hialurónico puede retener hasta 1000× su peso en agua',
    'La niacinamida reduce los poros y unifica el tono a 2–5%',
    'La vitamina C funciona mejor a un pH por debajo de 3.5',
    'El retinol acelera la renovación celular — empieza despacio',
    'Las ceramidas son el "cemento" entre células de la piel',
    'SPF 30 bloquea ~97% de rayos UVB; SPF 50 bloquea ~98%',
    'Los péptidos son cadenas cortas de aminoácidos que estimulan el colágeno',
    'La glicerina es uno de los humectantes más eficaces y asequibles',
    'Los AHA exfolian la superficie; los BHA penetran profundamente',
    'El escualano imita el sebo natural de la piel — apto para todos',
  ],
};

const _stepLabels = {
  'en': ['Recognizing product', 'Searching ingredients', 'Running analysis'],
  'ru': ['Распознаём продукт', 'Ищем состав', 'Анализируем'],
  'es': ['Reconociendo producto', 'Buscando ingredientes', 'Analizando'],
};

const _didYouKnow = {
  'en': 'Did you know?',
  'ru': 'А вы знали?',
  'es': '¿Lo sabías?',
};

class AnalysisLoadingWidget extends StatefulWidget {
  const AnalysisLoadingWidget({super.key});

  @override
  State<AnalysisLoadingWidget> createState() => _AnalysisLoadingWidgetState();
}

class _AnalysisLoadingWidgetState extends State<AnalysisLoadingWidget> {
  late AnalysisLoadingModel _model;
  Timer? _factTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AnalysisLoadingModel());
    _factTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final lang = FFLocalizations.of(context).languageCode;
      final facts = _facts[lang] ?? _facts['en']!;
      setState(() {
        _model.factIndex = (_model.factIndex + 1) % facts.length;
      });
    });
  }

  @override
  void dispose() {
    _factTimer?.cancel();
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final lang = FFLocalizations.of(context).languageCode;
    final facts = _facts[lang] ?? _facts['en']!;
    final steps = _stepLabels[lang] ?? _stepLabels['en']!;
    final currentStep = FFAppState().Producanalysstate; // 1, 2 or 3

    final productName = FFAppState().extractedProductName;
    final brand = FFAppState().extractedBrand;
    final hasProduct = productName.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(26.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top: blurred image + product identity ──
          Stack(
            children: [
              // Blurred photo
              SizedBox(
                height: 220,
                width: double.infinity,
                child: FFAppState().uploudedimagepath.isNotEmpty
                    ? Image.network(
                        FFAppState().uploudedimagepath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderBox(context),
                      )
                    : _placeholderBox(context),
              ),
              // Dark gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Product name / brand at the bottom of the image
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: hasProduct
                      ? Column(
                          key: const ValueKey('product'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleMediumFamily,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleMediumIsCustom,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              brand,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    color: Colors.white70,
                                    letterSpacing: 0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodySmallIsCustom,
                                  ),
                            ),
                          ],
                        )
                      : _shimmerLine(context, key: const ValueKey('shimmer')),
                ),
              ),
            ],
          ),

          // ── Steps ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(3, (i) {
                final stepNum = i + 1;
                final isDone = currentStep > stepNum;
                final isActive = currentStep == stepNum;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      _StepIcon(isDone: isDone, isActive: isActive),
                      const SizedBox(width: 12),
                      Text(
                        steps[i],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: isActive
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context).primaryText,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              letterSpacing: 0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // ── Divider ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Divider(
              color: FlutterFlowTheme.of(context).alternate,
              thickness: 1,
            ),
          ),

          // ── Rotating fact ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _didYouKnow[lang] ?? _didYouKnow['en']!,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: child,
                        ),
                        child: Text(
                          facts[_model.factIndex % facts.length],
                          key: ValueKey(_model.factIndex),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                color:
                                    FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBox(BuildContext context) => Container(
        color: FlutterFlowTheme.of(context).alternate,
      );

  Widget _shimmerLine(BuildContext context, {Key? key}) => Container(
        key: key,
        height: 16,
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn(duration: 600.ms)
          .then()
          .fadeOut(duration: 600.ms);
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.isDone, required this.isActive});
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 14,
          color: FlutterFlowTheme.of(context).primary,
        ),
      );
    }
    if (isActive) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .rotate(duration: 1200.ms, curve: Curves.linear);
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
