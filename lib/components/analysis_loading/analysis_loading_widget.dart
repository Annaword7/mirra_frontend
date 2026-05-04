import 'dart:async';
import 'dart:math';

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
    'Fragrance is the #1 cause of cosmetic allergic reactions',
    'Parabens have been used as preservatives in cosmetics since the 1950s',
    'Zinc oxide is both a sunscreen and a calming anti-inflammatory agent',
    'Caffeine in skincare temporarily reduces puffiness by constricting blood vessels',
    'Salicylic acid is oil-soluble — that\'s why it can clear inside the pore',
    'Tranexamic acid is one of the most effective ingredients for hyperpigmentation',
    'The "natural" label has no legal definition in cosmetics — always check the INCI',
    'Panthenol (pro-vitamin B5) attracts moisture and supports skin barrier repair',
    'Silicones fill in fine lines temporarily — they don\'t clog pores for most people',
    'Lactic acid is an AHA derived from milk — gentler than glycolic acid',
    'Bakuchiol is a plant-based alternative to retinol with fewer side effects',
    'The skin barrier is mostly made of fatty acids, cholesterol and ceramides',
    'Ferulic acid doubles the stability and effectiveness of vitamins C and E',
    'More than 70% of skincare products contain water as the first ingredient',
    'Azelaic acid works on acne, redness and uneven tone — and is safe in pregnancy',
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
    'Отдушки — причина №1 аллергических реакций на косметику',
    'Парабены используются как консерванты в косметике с 1950-х годов',
    'Оксид цинка одновременно защищает от солнца и снимает воспаление',
    'Кофеин в косметике временно уменьшает отёки, сужая сосуды',
    'Салициловая кислота жирорастворима — поэтому она очищает поры изнутри',
    'Транексамовая кислота — один из самых эффективных компонентов против пигментации',
    'Слово «натуральный» на косметике не имеет юридического определения — всегда читайте INCI',
    'Пантенол (провитамин B5) притягивает влагу и помогает восстановить барьер кожи',
    'Силиконы заполняют морщины временно — у большинства людей они не забивают поры',
    'Молочная кислота — AHA из молока, мягче гликолевой',
    'Бакухиол — растительная альтернатива ретинолу с меньшим числом побочных эффектов',
    'Кожный барьер состоит в основном из жирных кислот, холестерина и керамидов',
    'Феруловая кислота удваивает стабильность и эффективность витаминов C и E',
    'Более 70% средств по уходу за кожей содержат воду как первый ингредиент',
    'Азелаиновая кислота борется с акне, покраснением и пигментацией — безопасна при беременности',
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
    'Las fragancias son la causa nº1 de reacciones alérgicas en cosmética',
    'Los parabenos se usan como conservantes en cosmética desde los años 50',
    'El óxido de zinc protege del sol y calma la inflamación a la vez',
    'La cafeína tópica reduce temporalmente la hinchazón al contraer los vasos',
    'El ácido salicílico es liposoluble — por eso puede limpiar dentro del poro',
    'El ácido tranexámico es uno de los más eficaces contra la hiperpigmentación',
    'La etiqueta "natural" no tiene definición legal en cosmética — lee siempre el INCI',
    'El pantenol (pro-vitamina B5) atrae la humedad y repara la barrera cutánea',
    'Las siliconas rellenan líneas temporalmente — no obstruyen poros en la mayoría',
    'El ácido láctico es un AHA derivado de la leche — más suave que el glicólico',
    'El bakuchiol es una alternativa vegetal al retinol con menos efectos secundarios',
    'La barrera cutánea está formada principalmente por ácidos grasos, colesterol y ceramidas',
    'El ácido ferúlico duplica la estabilidad y eficacia de las vitaminas C y E',
    'Más del 70% de los productos de cuidado contienen agua como primer ingrediente',
    'El ácido azelaico trata el acné, la rojez y el tono irregular — seguro en el embarazo',
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
    _model.factIndex = Random().nextInt(25);
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
    final lang = FFLocalizations.of(context).languageCode;
    final facts = _facts[lang] ?? _facts['en']!;
    final steps = _stepLabels[lang] ?? _stepLabels['en']!;
    final appState = context.watch<FFAppState>();

    final currentStep = appState.Producanalysstate;
    final productName = appState.extractedProductName;
    final brand = appState.extractedBrand;
    final hasProduct = productName.isNotEmpty;

    final screenH = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      child: Stack(
        children: [
          // ── Full-screen photo (edge to edge, top to bottom) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.55,
            child: appState.uploudedimagepath.isNotEmpty
                ? Image.network(
                    appState.uploudedimagepath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  )
                : Container(
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
          ),

          // ── Gradient over photo (bottom fade to background) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.0),
                    FlutterFlowTheme.of(context).secondaryBackground,
                  ],
                ),
              ),
            ),
          ),

          // ── Product name at the bottom of the photo zone ──
          Positioned(
            left: 20,
            right: 20,
            top: screenH * 0.55 - 72,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: hasProduct
                  ? Column(
                      key: const ValueKey('product'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (brand.isNotEmpty)
                          Text(
                            brand,
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily:
                                      FlutterFlowTheme.of(context).bodySmallFamily,
                                  color: Colors.white70,
                                  letterSpacing: 0,
                                  useGoogleFonts:
                                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          productName,
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                fontFamily:
                                    FlutterFlowTheme.of(context).titleMediumFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleMediumIsCustom,
                              ),
                        ),
                      ],
                    )
                  : const SizedBox(
                      height: 20,
                      key: ValueKey('placeholder'),
                    ),
            ),
          ),

          // ── Bottom panel: steps + fact ──
          Positioned(
            left: 0,
            right: 0,
            top: screenH * 0.55,
            bottom: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Steps
                  ...List.generate(3, (i) {
                    final stepNum = i + 1;
                    final isDone = currentStep > stepNum;
                    final isActive = currentStep == stepNum;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          _StepIcon(isDone: isDone, isActive: isActive),
                          const SizedBox(width: 12),
                          Text(
                            steps[i],
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily:
                                      FlutterFlowTheme.of(context).bodyMediumFamily,
                                  color: isActive
                                      ? FlutterFlowTheme.of(context).primary
                                      : FlutterFlowTheme.of(context).primaryText,
                                  fontWeight:
                                      isActive ? FontWeight.w600 : FontWeight.normal,
                                  letterSpacing: 0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ],
                      ),
                    );
                  }),

                  Divider(
                    color: FlutterFlowTheme.of(context).alternate,
                    thickness: 1,
                    height: 28,
                  ),

                  // Rotating fact
                  Row(
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
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
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
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
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
          ),
        ],
      ),
    );
  }
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