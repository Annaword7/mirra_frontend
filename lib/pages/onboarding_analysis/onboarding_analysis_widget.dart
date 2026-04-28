import 'dart:math' as math;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/internationalization.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onboarding_analysis_model.dart';
export 'onboarding_analysis_model.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

String _s(String lang, String ru, String en, String es) =>
    lang == 'ru' ? ru : lang == 'es' ? es : en;

/// sentiment: 1 = positive (green), -1 = warning (red), 0 = neutral
class _Property {
  const _Property({
    required this.labelRu,
    required this.labelEn,
    required this.labelEs,
    required this.valueRu,
    required this.valueEn,
    required this.valueEs,
    this.sentiment = 0,
  });
  final String labelRu, labelEn, labelEs;
  final String valueRu, valueEn, valueEs;
  final int sentiment;

  String label(String lang) => _s(lang, labelRu, labelEn, labelEs);
  String value(String lang) => _s(lang, valueRu, valueEn, valueEs);
}

class _Ingredient {
  const _Ingredient({
    required this.nameRu,
    required this.nameEn,
    required this.nameEs,
    required this.initial,
    required this.color,
    required this.angleDeg,
    required this.properties,
  });
  final String nameRu, nameEn, nameEs;
  final String initial;
  final Color color;
  final double angleDeg;
  final List<_Property> properties;

  String name(String lang) => _s(lang, nameRu, nameEn, nameEs);
}

const _kIngredients = [
  _Ingredient(
    nameRu: 'Ретинол',
    nameEn: 'Retinol',
    nameEs: 'Retinol',
    initial: 'R',
    color: Color(0xFFFF8B5C),
    angleDeg: -155,
    properties: [
      _Property(
        labelRu: 'Активность', labelEn: 'Activity', labelEs: 'Actividad',
        valueRu: 'высокая', valueEn: 'high', valueEs: 'alta',
        sentiment: 1,
      ),
      _Property(
        labelRu: 'Антиоксидант', labelEn: 'Antioxidant', labelEs: 'Antioxidante',
        valueRu: 'да', valueEn: 'yes', valueEs: 'sí',
        sentiment: 1,
      ),
      _Property(
        labelRu: 'Комедогенность', labelEn: 'Comedogenicity', labelEs: 'Comedogenicidad',
        valueRu: '1 / 5', valueEn: '1 / 5', valueEs: '1 / 5',
      ),
      _Property(
        labelRu: 'Фотостабильность', labelEn: 'Photostability', labelEs: 'Fotoestabilidad',
        valueRu: 'низкая', valueEn: 'low', valueEs: 'baja',
        sentiment: -1,
      ),
    ],
  ),
  _Ingredient(
    nameRu: 'Гиалуронат Na',
    nameEn: 'Sodium Hyaluronate',
    nameEs: 'Hialuronato Na',
    initial: 'H',
    color: Color(0xFF5DBBAA),
    angleDeg: -105,
    properties: [
      _Property(
        labelRu: 'Увлажнение', labelEn: 'Hydration', labelEs: 'Hidratación',
        valueRu: 'максимум', valueEn: 'maximum', valueEs: 'máxima',
        sentiment: 1,
      ),
      _Property(
        labelRu: 'Комедогенность', labelEn: 'Comedogenicity', labelEs: 'Comedogenicidad',
        valueRu: '0 / 5', valueEn: '0 / 5', valueEs: '0 / 5',
        sentiment: 1,
      ),
      _Property(
        labelRu: 'Синергия', labelEn: 'Synergy', labelEs: 'Sinergia',
        valueRu: '+ многие', valueEn: '+ many', valueEs: '+ muchos',
      ),
      _Property(
        labelRu: 'Тип', labelEn: 'Type', labelEs: 'Tipo',
        valueRu: 'гидрофильный', valueEn: 'hydrophilic', valueEs: 'hidrófilo',
      ),
    ],
  ),
  _Ingredient(
    nameRu: 'Витамин C',
    nameEn: 'Vitamin C',
    nameEs: 'Vitamina C',
    initial: 'C',
    color: Color(0xFFFFD166),
    angleDeg: -55,
    properties: [
      _Property(
        labelRu: 'Антиоксидант', labelEn: 'Antioxidant', labelEs: 'Antioxidante',
        valueRu: 'сильный', valueEn: 'strong', valueEs: 'fuerte',
        sentiment: 1,
      ),
      _Property(
        labelRu: 'Синергия', labelEn: 'Synergy', labelEs: 'Sinergia',
        valueRu: '+ Ниацинамид', valueEn: '+ Niacinamide', valueEs: '+ Niacinamida',
      ),
      _Property(
        labelRu: 'Фотонестаб.', labelEn: 'Photounstab.', labelEs: 'Fotoinesatb.',
        valueRu: 'умеренная', valueEn: 'moderate', valueEs: 'moderada',
        sentiment: -1,
      ),
      _Property(
        labelRu: 'pH', labelEn: 'pH', labelEs: 'pH',
        valueRu: '< 3.5', valueEn: '< 3.5', valueEs: '< 3.5',
      ),
    ],
  ),
  _Ingredient(
    nameRu: 'Ниацинамид',
    nameEn: 'Niacinamide',
    nameEs: 'Niacinamida',
    initial: 'N',
    color: Color(0xFFA882DD),
    angleDeg: -5,
    properties: [
      _Property(
        labelRu: 'Поры', labelEn: 'Pores', labelEs: 'Poros',
        valueRu: 'сужает', valueEn: 'minimizes', valueEs: 'minimiza',
        sentiment: 1,
      ),
      _Property(
        labelRu: 'Комедогенность', labelEn: 'Comedogenicity', labelEs: 'Comedogenicidad',
        valueRu: '0 / 5', valueEn: '0 / 5', valueEs: '0 / 5',
        sentiment: 1,
      ),
      _Property(
        labelRu: 'Синергия', labelEn: 'Synergy', labelEs: 'Sinergia',
        valueRu: '+ Ретинол', valueEn: '+ Retinol', valueEs: '+ Retinol',
      ),
      _Property(
        labelRu: 'pH', labelEn: 'pH', labelEs: 'pH',
        valueRu: '5 – 7', valueEn: '5 – 7', valueEs: '5 – 7',
      ),
    ],
  ),
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const _kBg = Color(0xFF060D1E);
const _kPrimary = Color(0xFF3A6FFF);
const _kArc = Color(0xFF5C85D9);
const _kRadius = 120.0;
const _kTotalMs = 17000;

const double _kArcEnd = 1100 / _kTotalMs;
const double _kPerIng = 3100 / _kTotalMs;

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAINTERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF5C85D9).withOpacity(0.07)
      ..style = PaintingStyle.fill;
    for (double x = 22; x < size.width; x += 22) {
      for (double y = 22; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({
    required this.cx,
    required this.cy,
    required this.arcProgress,
    required this.lineProgressList,
  });

  final double cx, cy, arcProgress;
  final List<double> lineProgressList;

  Offset _nodePos(double deg) {
    final r = deg * math.pi / 180;
    return Offset(cx + _kRadius * math.cos(r), cy + _kRadius * math.sin(r));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (arcProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: _kRadius),
        -155 * math.pi / 180,
        150 * math.pi / 180 * arcProgress,
        false,
        Paint()
          ..color = _kArc.withOpacity(0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
    for (int i = 0; i < _kIngredients.length; i++) {
      final lp = lineProgressList[i];
      if (lp <= 0) continue;
      final target = _nodePos(_kIngredients[i].angleDeg);
      _drawDash(
        canvas,
        Offset(cx, cy),
        Offset(cx + (target.dx - cx) * lp, cy + (target.dy - cy) * lp),
        _kIngredients[i].color.withOpacity(0.38),
      );
    }
  }

  void _drawDash(Canvas canvas, Offset a, Offset b, Color color) {
    final dist = (b - a).distance;
    if (dist < 1) return;
    final step = (b - a) / dist;
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    var d = 0.0;
    var draw = true;
    while (d < dist) {
      final next = math.min(d + (draw ? 4.0 : 5.0), dist);
      if (draw) canvas.drawLine(a + step * d, a + step * next, p);
      d = next;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.arcProgress != arcProgress ||
      old.lineProgressList != lineProgressList;
}

class _SpinArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      0,
      math.pi * 1.6,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = SweepGradient(
          colors: [
            Colors.transparent,
            _kArc.withOpacity(0.38),
            _kArc,
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_SpinArcPainter _) => false;
}

class _BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final arcColor = const Color(0xFF5C85D9);

    canvas.drawCircle(Offset(w / 2, 8), 5,
        Paint()..color = arcColor.withOpacity(0.28));
    canvas.drawCircle(Offset(w / 2, 8), 5,
        Paint()
          ..color = arcColor.withOpacity(0.52)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    canvas.drawCircle(Offset(w / 2, 8), 2.5,
        Paint()..color = arcColor.withOpacity(0.62));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.38, 13, w * 0.24, 7), const Radius.circular(2)),
      Paint()..color = arcColor.withOpacity(0.18),
    );

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, 20, w * 0.70, h - 22),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect,
        Paint()..color = const Color(0xFF08112E).withOpacity(0.93));
    canvas.drawRRect(bodyRect,
        Paint()
          ..color = arcColor.withOpacity(0.42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.24, 29, w * 0.52, h - 38),
          const Radius.circular(5)),
      Paint()..color = arcColor.withOpacity(0.055),
    );

    void line(double y, double wFrac, double op) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.28, y, w * wFrac, 2.2),
            const Radius.circular(1.1)),
        Paint()..color = Colors.white.withOpacity(op),
      );
    }

    line(34, 0.44, 0.48);
    line(41, 0.30, 0.20);
    line(49, 0.46, 0.10);
    line(55, 0.34, 0.10);
    line(61, 0.46, 0.09);
    line(67, 0.26, 0.07);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.17, 22, w * 0.09, h - 26),
          const Radius.circular(4)),
      Paint()..color = Colors.white.withOpacity(0.025),
    );
  }

  @override
  bool shouldRepaint(_BottlePainter _) => false;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color, required this.opacity});
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), Colors.transparent],
          ),
        ),
      );
}

class _RingWidget extends StatelessWidget {
  const _RingWidget({
    required this.cx,
    required this.cy,
    required this.radius,
    required this.opacity,
  });
  final double cx, cy, radius, opacity;

  @override
  Widget build(BuildContext context) => Positioned(
        left: cx - radius,
        top: cy - radius,
        child: IgnorePointer(
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _kArc.withOpacity(opacity.clamp(0.0, 1.0)),
                width: 1,
              ),
            ),
          ),
        ),
      );
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.child, this.borderColor});
  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF060C28).withOpacity(0.90),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor ?? _kArc.withOpacity(0.32),
            width: 0.5,
          ),
        ),
        child: child,
      );
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, required this.count});
  final int current;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: active ? 26 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: active ? _kArc : _kArc.withOpacity(0.28),
            ),
          );
        }),
      );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHARED MIXIN — animation logic reused by both widget and body
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mixin _AnalysisMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController scanCtrl;
  late final AnimationController pulseCtrl;
  late final AnimationController mainCtrl;

  void initAnimations() {
    scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kTotalMs),
    )..repeat();
  }

  void disposeAnimations() {
    scanCtrl.dispose();
    pulseCtrl.dispose();
    mainCtrl.dispose();
  }

  double get _t => mainCtrl.value;
  double get arcProgress => (_t / _kArcEnd).clamp(0.0, 1.0);

  double ingLocalT(int i) {
    final s = _kArcEnd + i * _kPerIng;
    final e = s + _kPerIng;
    return ((_t - s) / (e - s)).clamp(0.0, 1.0);
  }

  double lineProgress(int i) => (ingLocalT(i) / 0.38).clamp(0.0, 1.0);

  double nodePosT(int i) {
    final lt = ingLocalT(i);
    if (lt < 0.62) return 0.0;
    return Curves.easeOutCubic.transform(((lt - 0.62) / 0.22).clamp(0.0, 1.0));
  }

  double nodeScaleT(int i) {
    final lt = ingLocalT(i);
    if (lt < 0.62) return 0.0;
    return Curves.elasticOut.transform(((lt - 0.62) / 0.22).clamp(0.0, 1.0));
  }

  double panelOpacity(int i) {
    final lt = ingLocalT(i);
    if (lt < 0.04) return 0.0;
    if (lt < 0.10) return (lt - 0.04) / 0.06;
    if (lt < 0.74) return 1.0;
    if (lt < 0.82) return (0.82 - lt) / 0.08;
    return 0.0;
  }

  double propOpacity(int i, int propIdx) {
    final lt = ingLocalT(i);
    if (lt < 0.12) return 0.0;
    final p = ((lt - 0.12) / 0.50) - propIdx * 0.22;
    return Curves.easeOutCubic.transform(p.clamp(0.0, 1.0));
  }

  int get activePanel {
    for (int i = 0; i < 4; i++) {
      if (panelOpacity(i) > 0) return i;
    }
    return -1;
  }

  double get scoreOpacity {
    const s = _kArcEnd + 4 * _kPerIng;
    const e = s + 1600 / _kTotalMs;
    return ((_t - s) / (e - s)).clamp(0.0, 1.0);
  }

  double get blinkOpacity =>
      (math.sin(scanCtrl.value * 2 * math.pi) * 0.4 + 0.6).clamp(0.0, 1.0);

  Offset arcPos(double deg, double cx, double cy) {
    final r = deg * math.pi / 180;
    return Offset(cx + _kRadius * math.cos(r), cy + _kRadius * math.sin(r));
  }

  // ── Shared builders ────────────────────────────────────────────────────────

  Widget buildNode(int i, double cx, double cy, String lang) {
    final ing = _kIngredients[i];
    final posT = nodePosT(i);
    final scaleT = nodeScaleT(i);
    if (posT == 0) return const SizedBox.shrink();
    final target = arcPos(ing.angleDeg, cx, cy);
    final pos = Offset.lerp(Offset(cx, cy), target, posT)!;
    return Positioned(
      left: pos.dx - 20,
      top: pos.dy - 20,
      child: IgnorePointer(
        child: Transform.scale(
          scale: scaleT,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ing.color.withOpacity(0.12),
                  border: Border.all(color: ing.color.withOpacity(0.55), width: 1.5),
                ),
                child: Center(
                  child: Text(ing.initial,
                      style: TextStyle(color: ing.color, fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 72,
                child: Text(ing.name(lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600, height: 1.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopBadge(BuildContext context, double safeTop, int activeIdx) {
    final lang = FFLocalizations.of(context).languageCode;

    final showScore = scoreOpacity > 0;
    Widget content;

    if (showScore) {
      content = Opacity(
        opacity: scoreOpacity,
        child: _GlassBadge(
          borderColor: _kArc.withOpacity(0.45),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('87',
                style: TextStyle(color: Color(0xFF7DBBFF), fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_s(lang, 'Общий', 'Overall', 'General'),
                    style: const TextStyle(color: Color(0x55FFFFFF), fontSize: 10)),
                Text(_s(lang, 'рейтинг', 'rating', 'puntuación'),
                    style: const TextStyle(color: Color(0x55FFFFFF), fontSize: 10)),
              ],
            ),
          ]),
        ),
      );
    } else if (activeIdx >= 0 || arcProgress < 1.0) {
      final label = activeIdx >= 0
          ? '${_s(lang, 'Анализирую', 'Analyzing', 'Analizando')}: ${_kIngredients[activeIdx].name(lang)}'
          : _s(lang, 'Сканирование...', 'Scanning...', 'Escaneando...');
      content = _GlassBadge(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Opacity(
            opacity: blinkOpacity,
            child: Container(
                width: 6, height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _kArc)),
          ),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(color: Color(0xBBCCCCCC), fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Positioned(top: safeTop + 14, left: 0, right: 0, child: Center(child: content));
  }

  Widget buildPropertiesPanel(int i, String lang) {
    final ing = _kIngredients[i];
    final opacity = panelOpacity(i);
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned(
      bottom: 218,
      left: 18,
      right: 18,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - opacity)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF030A22).withOpacity(0.93),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kArc.withOpacity(0.28), width: 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(width: 9, height: 9,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: ing.color)),
                    const SizedBox(width: 8),
                    Text(ing.name(lang),
                        style: const TextStyle(color: Color(0x88FFFFFF), fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 13),
                  ...ing.properties.asMap().entries.map((entry) {
                    final propOp = propOpacity(i, entry.key);
                    final prop = entry.value;
                    final valueColor = prop.sentiment == 1
                        ? const Color(0xFF4CD964)
                        : prop.sentiment == -1
                            ? const Color(0xFFFF6B6B)
                            : Colors.white.withOpacity(0.82);
                    return Opacity(
                      opacity: propOp,
                      child: Transform.translate(
                        offset: Offset(8 * (1 - propOp), 0),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(children: [
                            Text(prop.label(lang),
                                style: const TextStyle(color: Color(0x77FFFFFF), fontSize: 12)),
                            const Spacer(),
                            Text(prop.value(lang),
                                style: TextStyle(color: valueColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            if (prop.sentiment != 0) ...[
                              const SizedBox(width: 5),
                              Container(width: 6, height: 6,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: valueColor)),
                            ],
                          ]),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSceneStack(BuildContext context, double cx, double cy,
      double safeTop, List<Widget> extra) {
    final lang = FFLocalizations.of(context).languageCode;
    final activeIdx = activePanel;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
        Positioned(
          left: cx - 150,
          top: cy * 0.65 - 150,
          child: _GlowCircle(size: 300, color: _kPrimary, opacity: 0.13),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _ScenePainter(
              cx: cx, cy: cy,
              arcProgress: arcProgress,
              lineProgressList: List.generate(4, lineProgress),
            ),
          ),
        ),
        _RingWidget(cx: cx, cy: cy, radius: 130, opacity: 0.18),
        _RingWidget(cx: cx, cy: cy, radius: 180,
            opacity: 0.08 + pulseCtrl.value * 0.12),
        _RingWidget(cx: cx, cy: cy, radius: 234,
            opacity: 0.04 + (1 - pulseCtrl.value) * 0.10),
        Positioned(
          left: cx - 68, top: cy - 68,
          child: IgnorePointer(
            child: RotationTransition(
              turns: scanCtrl,
              child: SizedBox(
                  width: 136, height: 136,
                  child: CustomPaint(painter: _SpinArcPainter())),
            ),
          ),
        ),
        Positioned(
          left: cx - 35, top: cy - 47,
          child: SizedBox(
              width: 70, height: 94,
              child: CustomPaint(painter: _BottlePainter())),
        ),
        for (int i = 0; i < 4; i++) buildNode(i, cx, cy, lang),
        buildTopBadge(context, safeTop, activeIdx),
        if (activeIdx >= 0) buildPropertiesPanel(activeIdx, lang),
        ...extra,
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STANDALONE PAGE (with its own route, Scaffold and CTA button)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class OnboardingAnalysisWidget extends StatefulWidget {
  const OnboardingAnalysisWidget({super.key});

  static const routeName = 'OnboardingAnalysis';
  static const routePath = '/onboardingAnalysis';

  @override
  State<OnboardingAnalysisWidget> createState() =>
      _OnboardingAnalysisWidgetState();
}

class _OnboardingAnalysisWidgetState extends State<OnboardingAnalysisWidget>
    with TickerProviderStateMixin, _AnalysisMixin {
  @override
  void initState() {
    super.initState();
    initAnimations();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    final cx = size.width * 0.5;
    final cy = size.height * 0.34;
    final lang = FFLocalizations.of(context).languageCode;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _kBg,
        body: AnimatedBuilder(
          animation: Listenable.merge([scanCtrl, pulseCtrl, mainCtrl]),
          builder: (context, _) => buildSceneStack(
            context, cx, cy, safeTop,
            [_buildBottomUI(context, lang)],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomUI(BuildContext context, String lang) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.36],
            colors: [Colors.transparent, _kBg],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _s(lang, 'Получите полноценный анализ',
                      'Get a full ingredient analysis',
                      'Obtén un análisis completo'),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).headlineSmallFamily,
                        color: Colors.white,
                        fontSize: 21,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        useGoogleFonts: !FlutterFlowTheme.of(context)
                            .headlineSmallIsCustom,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _s(lang, 'всего за 30 секунд', 'in just 30 seconds',
                      'en solo 30 segundos'),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: Colors.white.withAlpha(110),
                        letterSpacing: 0,
                        useGoogleFonts: !FlutterFlowTheme.of(context)
                            .bodyMediumIsCustom,
                      ),
                ),
                const SizedBox(height: 22),
                const _PageDots(current: 1, count: 5),
                const SizedBox(height: 18),
                FFButtonWidget(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    context.goNamed(PaywallpageWidget.routeName);
                  },
                  text: _s(lang, 'Продолжить', 'Continue', 'Continuar'),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 55,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: _kPrimary,
                    textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMBEDDABLE BODY — animation only, no Scaffold / no CTA button.
// Used as slide 0 inside OnboardingCarouselWidget.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class OnboardingAnalysisBody extends StatefulWidget {
  const OnboardingAnalysisBody({super.key});

  @override
  State<OnboardingAnalysisBody> createState() => _OnboardingAnalysisBodyState();
}

class _OnboardingAnalysisBodyState extends State<OnboardingAnalysisBody>
    with TickerProviderStateMixin, _AnalysisMixin {
  @override
  void initState() {
    super.initState();
    initAnimations();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    final cx = size.width * 0.5;
    final cy = size.height * 0.34;

    return AnimatedBuilder(
      animation: Listenable.merge([scanCtrl, pulseCtrl, mainCtrl]),
      builder: (context, _) => ColoredBox(
        color: _kBg,
        child: buildSceneStack(context, cx, cy, safeTop, const []),
      ),
    );
  }
}
