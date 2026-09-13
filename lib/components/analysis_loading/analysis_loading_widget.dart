import 'dart:async';
import 'dart:math';

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

/// Экран ожидания разбора: снятое фото сверху, шаги и факт снизу.
///
/// Фон белый, как у остальных экранов. Раньше он был `secondaryBackground`
/// (#CBDDFE) — голубое полотно, которого больше нигде в приложении нет, да и
/// фото уезжало в него градиентом.
class AnalysisLoadingWidget extends StatefulWidget {
  const AnalysisLoadingWidget({super.key});

  @override
  State<AnalysisLoadingWidget> createState() => _AnalysisLoadingWidgetState();
}

class _AnalysisLoadingWidgetState extends State<AnalysisLoadingWidget> {
  late AnalysisLoadingModel _model;
  Timer? _factTimer;

  /// Доля высоты под фото: остаток отдан шагам и факту.
  static const double _photoHeightFactor = 0.55;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AnalysisLoadingModel());
    _model.factIndex = Random().nextInt(_factKeys.length);
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

  String _t(String key) => FFLocalizations.of(context).getText(key);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = context.watch<FFAppState>();

    final currentStep = appState.Producanalysstate;
    final productName = appState.extractedProductName;
    final brand = appState.extractedBrand;

    final photoHeight = MediaQuery.sizeOf(context).height * _photoHeightFactor;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: theme.alternate,
      child: Stack(
        children: [
          // ── Фото на верхние 55% экрана ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: appState.uploudedimagepath.isNotEmpty
                ? Image.network(
                    appState.uploudedimagepath,
                    // Только что снятое фото — полноразмерное с камеры.
                    // Экран занимает половину высоты, 1080px хватает.
                    cacheWidth: 1080,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        ColoredBox(color: theme.surfaceMuted),
                  )
                : ColoredBox(color: theme.surfaceMuted),
          ),

          // ── Градиент: лёгкое затемнение сверху, уход в фон снизу ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: theme.opacity.o08),
                    Colors.black.withValues(alpha: 0.0),
                    theme.alternate,
                  ],
                ),
              ),
            ),
          ),

          // ── Название продукта у нижнего края фото ──
          Positioned(
            left: theme.space.s20,
            right: theme.space.s20,
            top: photoHeight - 72,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: productName.isEmpty
                  ? const SizedBox(height: 20, key: ValueKey('placeholder'))
                  : Column(
                      key: const ValueKey('product'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (brand.isNotEmpty)
                          Text(
                            brand,
                            style: theme.bodySmall.override(
                              color: Colors.white
                                  .withValues(alpha: theme.opacity.o80),
                              letterSpacing: 0,
                            ),
                          ),
                        SizedBox(height: theme.space.s2),
                        Text(
                          productName,
                          style: theme.titleMedium.override(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // ── Нижняя панель: шаги и факт ──
          Positioned(
            left: 0,
            right: 0,
            top: photoHeight,
            bottom: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(theme.space.s20, theme.space.s24,
                  theme.space.s20, theme.space.s24 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _stepKeys.length; i++)
                    _step(theme, index: i, currentStep: currentStep),
                  Divider(color: theme.divider, thickness: 1, height: 28),
                  _fact(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Шаг разбора: пройденный, текущий или ещё не начатый.
  Widget _step(FlutterFlowTheme theme,
      {required int index, required int currentStep}) {
    final stepNum = index + 1;
    final isDone = currentStep > stepNum;
    final isActive = currentStep == stepNum;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          _StepIcon(isDone: isDone, isActive: isActive),
          SizedBox(width: theme.space.s12),
          Expanded(
            child: Text(
              _t(_stepKeys[index]),
              style: theme.bodyMedium.override(
                // Будущие шаги приглушены: иначе все три выглядят одинаково
                // важными и непонятно, где приложение сейчас.
                color: isActive
                    ? theme.primary
                    : (isDone ? theme.primaryText : theme.secondaryText),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// «А вы знали» — факт, который меняется раз в пять секунд.
  Widget _fact(FlutterFlowTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lightbulb_outline_rounded,
            size: theme.size.iconXs + 2, color: theme.primary),
        SizedBox(width: theme.space.s8 + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('al_did_you_know'),
                style: theme.bodySmall.override(
                  color: theme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: theme.space.s4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _t(_factKeys[_model.factIndex % _factKeys.length]),
                  key: ValueKey(_model.factIndex),
                  style: theme.bodyMedium.override(
                    color: theme.primaryText,
                    letterSpacing: 0,
                    lineHeight: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.isDone, required this.isActive});
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: theme.primary.withValues(alpha: theme.opacity.o16),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, size: 14, color: theme.primary),
      );
    }
    if (isActive) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
        ),
      ).animate(onPlay: (c) => c.repeat()).rotate(
            duration: 1200.ms,
            curve: Curves.linear,
          );
    }
    // Рамка `border`, а не `alternate`: последний — белый, и на белом фоне
    // кружок будущего шага исчезал совсем.
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: theme.border, width: 2),
        shape: BoxShape.circle,
      ),
    );
  }
}
