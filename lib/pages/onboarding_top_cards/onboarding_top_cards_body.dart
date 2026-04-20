import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/internationalization.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _CardData {
  const _CardData({
    required this.name,
    required this.brand,
    required this.score,
    required this.fallbackGradient,
    required this.categoryRu,
    required this.categoryEn,
    required this.categoryEs,
    required this.accentColor,
    required this.ingredients,
    this.imageUrl = '',
  });

  final String name;
  final String brand;
  final int score;
  final List<Color> fallbackGradient;
  final String categoryRu, categoryEn, categoryEs;
  final Color accentColor;
  final String imageUrl; // Supabase Storage public URL; empty → silhouette
  final List<String> ingredients;

  String category(String lang) =>
      lang == 'ru' ? categoryRu : lang == 'es' ? categoryEs : categoryEn;

  factory _CardData.fromJson(Map<String, dynamic> r) => _CardData(
        name: r['name'] as String,
        brand: r['brand'] as String,
        score: r['score'] as int,
        accentColor: _hexColor(r['accent_color'] as String),
        fallbackGradient: [
          _hexColor(r['gradient_start'] as String),
          _hexColor(r['gradient_end'] as String),
        ],
        categoryRu: r['category_ru'] as String,
        categoryEn: r['category_en'] as String,
        categoryEs: r['category_es'] as String,
        imageUrl: (r['image_url'] as String?) ?? '',
        ingredients: [
          r['ingredient_1'] as String,
          if (((r['ingredient_2'] as String?) ?? '').isNotEmpty)
            r['ingredient_2'] as String,
        ],
      );
}

Color _hexColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

// ── Hardcoded defaults shown while remote data loads or on fetch error ────────

const _kDefaultCards = [
  _CardData(
    name: 'Hyaluronic Acid 2% + B5',
    brand: 'The Ordinary',
    score: 94,
    accentColor: Color(0xFF5DBBAA),
    fallbackGradient: [Color(0xFF1A3A44), Color(0xFF0D2230)],
    categoryRu: 'Сыворотка', categoryEn: 'Serum', categoryEs: 'Suero',
    ingredients: ['Hyaluronic Acid', 'Panthenol'],
  ),
  _CardData(
    name: 'Niacinamide 10% + Zinc 1%',
    brand: 'The Ordinary',
    score: 93,
    accentColor: Color(0xFFA882DD),
    fallbackGradient: [Color(0xFF281A44), Color(0xFF180D30)],
    categoryRu: 'Сыворотка', categoryEn: 'Serum', categoryEs: 'Suero',
    ingredients: ['Niacinamide', 'Zinc PCA'],
  ),
  _CardData(
    name: 'C E Ferulic',
    brand: 'SkinCeuticals',
    score: 91,
    accentColor: Color(0xFFFFD166),
    fallbackGradient: [Color(0xFF3A3010), Color(0xFF201A08)],
    categoryRu: 'Антиоксидант', categoryEn: 'Antioxidant', categoryEs: 'Antioxidante',
    ingredients: ['L-Ascorbic Acid', 'Ferulic Acid'],
  ),
  _CardData(
    name: 'Retinol 0.5% in Squalane',
    brand: "Paula's Choice",
    score: 88,
    accentColor: Color(0xFFFF8B5C),
    fallbackGradient: [Color(0xFF3A1A0A), Color(0xFF200E04)],
    categoryRu: 'Ретинол', categoryEn: 'Retinol', categoryEs: 'Retinol',
    ingredients: ['Retinol', 'Squalane'],
  ),
  _CardData(
    name: 'Advanced Snail 96 Mucin Power',
    brand: 'COSRX',
    score: 90,
    accentColor: Color(0xFF5C85D9),
    fallbackGradient: [Color(0xFF0E1E3A), Color(0xFF081222)],
    categoryRu: 'Эссенция', categoryEn: 'Essence', categoryEs: 'Esencia',
    ingredients: ['Snail Secretion Filtrate', 'Betaine'],
  ),
  _CardData(
    name: 'Moisturizing Cream',
    brand: 'CeraVe',
    score: 89,
    accentColor: Color(0xFF4CD964),
    fallbackGradient: [Color(0xFF0E2E18), Color(0xFF081A0C)],
    categoryRu: 'Увлажнение', categoryEn: 'Moisturizer', categoryEs: 'Hidratante',
    ingredients: ['Ceramide NP', 'Hyaluronic Acid'],
  ),
];

// ── Session cache — fetched once per app launch ───────────────────────────────

List<_CardData>? _sessionCards;

Future<List<_CardData>> _fetchOnboardingCards() async {
  if (_sessionCards != null) return _sessionCards!;
  try {
    final rows = await SupaFlow.client
        .from('onboarding_cards')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    final parsed = (rows as List)
        .map((r) => _CardData.fromJson(r as Map<String, dynamic>))
        .toList();
    _sessionCards = parsed.isNotEmpty ? parsed : _kDefaultCards;
  } catch (_) {
    _sessionCards = _kDefaultCards;
  }
  return _sessionCards!;
}

/// Call this early (e.g. on slide 1) to warm the cache and start
/// downloading card images before slide 4 is visible.
Future<void> prefetchOnboardingCards() async {
  final cards = await _fetchOnboardingCards();
  for (final card in cards) {
    if (card.imageUrl.isNotEmpty) {
      CachedNetworkImageProvider(card.imageUrl)
          .resolve(const ImageConfiguration());
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const _kBg = Color(0xFF060D1E);
const _kArc = Color(0xFF5C85D9);
const _kCardWidth = 195.0;
const _kCardHeight = 272.0;
const _kTiltOverflow = 20.0;
const _kSpacing = 16.0;
const _kMaxTiltRad = 0.07;
const _kScrollSpeed = 44.0;
const _kRepeats = 8;

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WIDGET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class OnboardingTopCardsBody extends StatefulWidget {
  const OnboardingTopCardsBody({super.key});

  @override
  State<OnboardingTopCardsBody> createState() => _OnboardingTopCardsBodyState();
}

class _OnboardingTopCardsBodyState extends State<OnboardingTopCardsBody>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late final Ticker _ticker;
  Duration _prev = Duration.zero;
  double _scrollPos = 0;

  List<_CardData> _cards = _kDefaultCards;

  double get _loopWidth => _cards.length * (_kCardWidth + _kSpacing) + _kSpacing;

  @override
  void initState() {
    super.initState();
    _scrollPos = _loopWidth;
    _ticker = createTicker(_onTick)..start();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _fetchOnboardingCards();
    if (!mounted) return;
    // Only rebuild if cards actually changed
    if (cards != _cards) {
      setState(() {
        _cards = cards;
        _scrollPos = _loopWidth; // reset so loop starts clean with new count
      });
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _prev).inMicroseconds / 1e6;
    _prev = elapsed;
    _scrollPos += _kScrollSpeed * dt;
    if (_scrollPos >= _loopWidth * 2) _scrollPos -= _loopWidth;
    if (_scrollCtrl.hasClients &&
        _scrollCtrl.position.hasContentDimensions &&
        _scrollPos <= _scrollCtrl.position.maxScrollExtent) {
      _scrollCtrl.jumpTo(_scrollPos);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final lang = FFLocalizations.of(context).languageCode;
    final viewportCenter = _scrollPos + size.width / 2;

    final contentTop = size.height * 0.14;
    final contentBottom = size.height * 0.60;
    final listHeight = _kCardHeight + _kTiltOverflow * 2;

    return ColoredBox(
      color: _kBg,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

          Positioned(
            left: size.width * 0.5 - 200,
            top: (contentTop + contentBottom) / 2 - 200,
            child: _GlowCircle(size: 400, color: _kArc, opacity: 0.09),
          ),

          Positioned(
            top: contentTop,
            bottom: size.height - contentBottom,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: listHeight,
                child: ListView.builder(
                  controller: _scrollCtrl,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: _kSpacing, vertical: _kTiltOverflow),
                  itemCount: _cards.length * _kRepeats,
                  itemBuilder: (_, index) {
                    final card = _cards[index % _cards.length];
                    final cardLeft =
                        _kSpacing + index * (_kCardWidth + _kSpacing);
                    final cardCenterX = cardLeft + _kCardWidth / 2;
                    final t = ((cardCenterX - viewportCenter) /
                            (size.width * 0.55))
                        .clamp(-1.5, 1.5);
                    final tilt = t * _kMaxTiltRad;
                    final scale = 1.0 - (t.abs() * 0.05).clamp(0.0, 0.08);

                    return Padding(
                      padding: const EdgeInsets.only(right: _kSpacing),
                      child: Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..rotateZ(tilt)
                          ..scale(scale),
                        child: _ProductCard(data: card, lang: lang),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRODUCT CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.data, required this.lang});
  final _CardData data;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kCardWidth,
      height: _kCardHeight,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: data.accentColor.withOpacity(0.20)),
          boxShadow: [
            BoxShadow(
              color: data.accentColor.withOpacity(0.14),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Product photo ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 147,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: data.fallbackGradient,
                            ),
                          ),
                        ),
                        if (data.imageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: data.imageUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: (_, __) =>
                                Center(child: _BottleDecor(color: data.accentColor)),
                            errorWidget: (_, __, ___) =>
                                Center(child: _BottleDecor(color: data.accentColor)),
                          )
                        else
                          Center(child: _BottleDecor(color: data.accentColor)),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _ScoreBadge(
                              score: data.score, color: data.accentColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Text area ─────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final ing in data.ingredients)
                            _IngredientChip(label: ing, color: data.accentColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ingredient chip ───────────────────────────────────────────────────────────

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withOpacity(0.28), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

// ── Score badge ───────────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF060D1E).withOpacity(0.85),
          border: Border.all(color: color.withOpacity(0.55), width: 1.2),
        ),
        child: Center(
          child: Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
}

// ── Bottle silhouette (placeholder) ──────────────────────────────────────────

class _BottleDecor extends StatelessWidget {
  const _BottleDecor({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(50, 84),
        painter: _BottleDecorPainter(color: color),
      );
}

class _BottleDecorPainter extends CustomPainter {
  const _BottleDecorPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(w / 2, 5), 4.5, fill);
    canvas.drawCircle(Offset(w / 2, 5), 4.5, stroke);

    final neck = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.36, 9.5, w * 0.28, 7), const Radius.circular(2));
    canvas.drawRRect(neck, fill);
    canvas.drawRRect(neck, stroke);

    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, 16, w * 0.80, h - 18),
        const Radius.circular(8));
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    final lp = Paint()
      ..color = color.withOpacity(0.28)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final y = 26.0 + i * 8;
      canvas.drawLine(Offset(w * 0.22, y), Offset(w * 0.78, y), lp);
    }
  }

  @override
  bool shouldRepaint(_BottleDecorPainter old) => old.color != color;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAINTERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _kArc.withOpacity(0.07)
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

class _GlowCircle extends StatelessWidget {
  const _GlowCircle(
      {required this.size, required this.color, required this.opacity});
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
