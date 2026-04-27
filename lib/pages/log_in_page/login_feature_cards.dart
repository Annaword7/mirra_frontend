import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

// Shared card style
const _kCardBg = Color(0xFFF5F8FF);
const _kTextPrimary = Color(0xFF1A1F2E);
const _kTextSecondary = Color(0xFF6B7280);

BoxDecoration _cardDecoration(Color primary) => BoxDecoration(
      color: _kCardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: primary.withOpacity(0.15)),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        const BoxShadow(
          color: Color(0x14000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    );

// ── Card 1: Score reveal ─────────────────────────────────────────────────────

class FeatureScoreCard extends StatefulWidget {
  const FeatureScoreCard({super.key});

  @override
  State<FeatureScoreCard> createState() => _FeatureScoreCardState();
}

class _FeatureScoreCardState extends State<FeatureScoreCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;

  static const _scoreColor = Color(0xFF43A047);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween(begin: 0.2, end: 0.45).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(FlutterFlowTheme.of(context).primary),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _glow,
            builder: (_, child) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _scoreColor.withOpacity(_glow.value),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: child,
            ),
            child: CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 6.0,
              percent: 0.94,
              backgroundColor: _scoreColor.withOpacity(0.12),
              progressColor: _scoreColor,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1200,
              center: const Text(
                'A',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            FFLocalizations.of(context).getText('lfc_score_label'),
            style: const TextStyle(
              color: _kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '94 / 100',
            style: TextStyle(
              color: _kTextSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 2: Scanner ──────────────────────────────────────────────────────────

class FeatureScanCard extends StatefulWidget {
  const FeatureScanCard({super.key});

  @override
  State<FeatureScanCard> createState() => _FeatureScanCardState();
}

class _FeatureScanCardState extends State<FeatureScanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = FlutterFlowTheme.of(context).primary;
    const dark = Color(0xFF3A5CB8);
    const size = 80.0;
    const half = size / 2;

    return Container(
      decoration: _cardDecoration(primary),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final t = _ctrl.value;
                final beamOffset = math.sin(t * 2 * math.pi) * 18;

                Widget pulseRing(double phase) {
                  final tp = (t + phase) % 1.0;
                  final scale = 1.0 + tp * 0.6;
                  final opacity = (0.5 * (1.0 - tp)).clamp(0.0, 0.5);
                  return Positioned.fill(
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    pulseRing(0.0),
                    pulseRing(1 / 3),
                    pulseRing(2 / 3),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF5C85D9), dark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    Positioned(
                      top: half + beamOffset,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.7),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            FFLocalizations.of(context).getText('lfc_scan_title'),
            style: const TextStyle(
              color: _kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            FFLocalizations.of(context).getText('lfc_scan_subtitle'),
            style: TextStyle(
              color: _kTextSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 3: Ingredients ──────────────────────────────────────────────────────

class FeatureIngredientsCard extends StatefulWidget {
  const FeatureIngredientsCard({super.key});

  @override
  State<FeatureIngredientsCard> createState() => _FeatureIngredientsCardState();
}

class _FeatureIngredientsCardState extends State<FeatureIngredientsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _pills = [
    (label: 'Retinol', color: Color(0xFF5DBBAA)),
    (label: 'Hyaluronic Acid', color: Color(0xFF5C85D9)),
    (label: 'Ceramide', color: Color(0xFF9489F5)),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 3600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _pillOpacity(int index, double t) {
    final phase = (t + index / 3) % 1.0;
    if (phase < 0.2) return phase / 0.2;
    if (phase < 0.8) return 1.0;
    return 1.0 - (phase - 0.8) / 0.2;
  }

  @override
  Widget build(BuildContext context) {
    final primary = FlutterFlowTheme.of(context).primary;

    return Container(
      decoration: _cardDecoration(primary),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FFLocalizations.of(context).getText('lfc_ingredients_title'),
            style: const TextStyle(
              color: _kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = _ctrl.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_pills.length, (i) {
                  final pill = _pills[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Opacity(
                      opacity: _pillOpacity(i, t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: pill.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: pill.color.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: pill.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pill.label,
                              style: const TextStyle(
                                color: _kTextPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
