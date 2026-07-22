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

// Localized facts & steps live in kTranslationsMap as 'al_fact_<n>' / 'al_step_<n>'.
const _factKeys = [
  'al_fact_1', 'al_fact_2', 'al_fact_3', 'al_fact_4', 'al_fact_5', //
  'al_fact_6', 'al_fact_7', 'al_fact_8', 'al_fact_9', 'al_fact_10', //
  'al_fact_11', 'al_fact_12', 'al_fact_13', 'al_fact_14', 'al_fact_15', //
  'al_fact_16', 'al_fact_17', 'al_fact_18', 'al_fact_19', 'al_fact_20', //
  'al_fact_21', 'al_fact_22', 'al_fact_23', 'al_fact_24', 'al_fact_25', //
];
const _stepKeys = ['al_step_1', 'al_step_2', 'al_step_3'];

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
      setState(() {
        _model.factIndex = (_model.factIndex + 1) % _factKeys.length;
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
    final facts =
        _factKeys.map((k) => FFLocalizations.of(context).getText(k)).toList();
    final steps =
        _stepKeys.map((k) => FFLocalizations.of(context).getText(k)).toList();
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
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodySmallFamily,
                                  color: Colors.white70,
                                  letterSpacing: 0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                                ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          productName,
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleMediumFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: isActive
                                      ? FlutterFlowTheme.of(context).primary
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
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
                              FFLocalizations.of(context)
                                  .getText('al_did_you_know'),
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodySmallIsCustom,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(
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
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
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
