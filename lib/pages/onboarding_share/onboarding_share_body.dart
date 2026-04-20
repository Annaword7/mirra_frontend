import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WIDGET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const _kBg = Color(0xFF060D1E);
const _kArc = Color(0xFF5C85D9);

class OnboardingShareBody extends StatefulWidget {
  const OnboardingShareBody({super.key});

  @override
  State<OnboardingShareBody> createState() => _OnboardingShareBodyState();
}

class _OnboardingShareBodyState extends State<OnboardingShareBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: -7, end: 7).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardWidth = (size.width * 0.84).clamp(0.0, 360.0);

    return ColoredBox(
      color: _kBg,
      child: Stack(
        children: [
          // Dot grid
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

          // Radial glow behind the card
          Positioned(
            left: size.width * 0.5 - 180,
            top: size.height * 0.20,
            child: _GlowCircle(radius: 180, color: _kArc, opacity: 0.10),
          ),
          Positioned(
            left: size.width * 0.5 - 120,
            top: size.height * 0.25,
            child: _GlowCircle(radius: 120, color: const Color(0xFFA882DD), opacity: 0.08),
          ),

          // Main content
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.04),

                  // ── Floating share card ──────────────────────────────────
                  AnimatedBuilder(
                    animation: _floatY,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _floatY.value),
                      child: child,
                    ),
                    child: _ShareCardMock(width: cardWidth),
                  ),

                  SizedBox(height: size.height * 0.038),

                  // ── "Share anywhere" label ───────────────────────────────
                  Text(
                    'Share to any app',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Social icons row ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ShareIcon(
                        icon: Icons.photo_library_rounded,
                        isMaterial: true,
                        color: const Color(0xFF8EAADB),
                        label: 'Photos',
                      ),
                      const SizedBox(width: 18),
                      _ShareIcon(
                        icon: FontAwesomeIcons.instagram,
                        color: const Color(0xFFE1306C),
                        label: 'Instagram',
                      ),
                      const SizedBox(width: 18),
                      _ShareIcon(
                        icon: FontAwesomeIcons.whatsapp,
                        color: const Color(0xFF25D366),
                        label: 'WhatsApp',
                      ),
                      const SizedBox(width: 18),
                      _ShareIcon(
                        icon: FontAwesomeIcons.pinterest,
                        color: const Color(0xFFE60023),
                        label: 'Pinterest',
                      ),
                      const SizedBox(width: 18),
                      _ShareIcon(
                        icon: FontAwesomeIcons.xTwitter,
                        color: Colors.white,
                        label: 'X',
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.06),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHARE CARD MOCK  (recreates the MiRRA share card from the screenshot)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ShareCardMock extends StatelessWidget {
  const _ShareCardMock({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 0.58; // landscape, same ratio as real share card
    const radius = Radius.circular(18);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C85D9).withOpacity(0.22),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // ── Left: photo panel (dark gradient) ───────────────────────────
            Expanded(
              flex: 43,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1B2B4A), Color(0xFF0A1628)],
                      ),
                    ),
                  ),
                  // Subtle gloss
                  Positioned(
                    top: -30,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Product bottle silhouette
                  Center(
                    child: CustomPaint(
                      size: Size(width * 0.10, width * 0.22),
                      painter: _BottlePainter(),
                    ),
                  ),
                  // MiRRA badge bottom-left
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A6FD8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MiRRA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Right: info panel (white) ───────────────────────────────────
            Expanded(
              flex: 57,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    const Text(
                      'numbuzin',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Product name
                    const Text(
                      'NAD+ PDRN Glow\nFasting Toner',
                      maxLines: 2,
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Score row
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF2E7D32), width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '85/100',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Exceptional',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    // Safety bar
                    _InfoBar(label: 'Safety', value: 0.97, valueText: '97%'),
                    const SizedBox(height: 5),
                    // Efficacy bar
                    _InfoBar(label: 'Efficacy', value: 1.0, valueText: '100%'),
                    const Spacer(),
                    // Tags
                    Wrap(
                      spacing: 4,
                      children: const [
                        _Tag('Hydration'),
                        _Tag('Brightening'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Footer
                    const Text(
                      'MiRRA Cosmetic Checker',
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar(
      {required this.label, required this.value, required this.valueText});
  final String label;
  final double value;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 8,
                    fontWeight: FontWeight.w500)),
            Text(valueText,
                style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 8,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 7.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHARE ICON
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ShareIcon extends StatelessWidget {
  const _ShareIcon({
    required this.icon,
    required this.color,
    required this.label,
    this.isMaterial = false,
  });
  final IconData icon;
  final Color color;
  final String label;
  final bool isMaterial;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.22), width: 1),
            ),
            child: Center(
              child: isMaterial
                  ? Icon(icon, color: color, size: 20)
                  : FaIcon(icon, color: color, size: 18),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.40),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAINTERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final accent = const Color(0xFF5C85D9);
    final fill = Paint()
      ..color = accent.withOpacity(0.22)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = accent.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(w / 2, 5), w * 0.18, fill);
    canvas.drawCircle(Offset(w / 2, 5), w * 0.18, stroke);

    final neck = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.12, w * 0.36, h * 0.10),
        const Radius.circular(2));
    canvas.drawRRect(neck, fill);
    canvas.drawRRect(neck, stroke);

    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.21, w, h * 0.77), const Radius.circular(6));
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    final lp = Paint()
      ..color = accent.withOpacity(0.30)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = h * 0.32 + i * h * 0.12;
      canvas.drawLine(Offset(w * 0.18, y), Offset(w * 0.82, y), lp);
    }
  }

  @override
  bool shouldRepaint(_BottlePainter _) => false;
}

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
      {required this.radius, required this.color, required this.opacity});
  final double radius;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), Colors.transparent],
          ),
        ),
      );
}
