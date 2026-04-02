// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '/flutter_flow/analytics_service.dart';

// ── Localization maps ──────────────────────────────────────────────────────────

const _l10n = {
  'safety': {'en': 'Safety', 'ru': 'Безопасность', 'es': 'Seguridad'},
  'efficacy': {'en': 'Efficacy', 'ru': 'Эффективность', 'es': 'Eficacia'},
  'share': {'en': 'Share', 'ru': 'Поделиться', 'es': 'Compartir'},
  'creating': {'en': 'Creating…', 'ru': 'Создаём…', 'es': 'Creando…'},
  'shareText': {
    'en': 'Analyzed with MiRRA',
    'ru': 'Проверено с MiRRA',
    'es': 'Analizado con MiRRA',
  },
  'score': {'en': 'Score', 'ru': 'Оценка', 'es': 'Puntuación'},
};

String _t(String key, String lang) =>
    _l10n[key]?[lang] ?? _l10n[key]?['en'] ?? key;

// ── Score helpers ──────────────────────────────────────────────────────────────

Color _scoreColor(double s) {
  if (s >= 75) return const Color(0xFF1B5E20);
  if (s >= 65) return const Color(0xFF43A047);
  if (s >= 55) return const Color(0xFFC0CA33);
  if (s >= 45) return const Color(0xFFFFB300);
  if (s >= 35) return const Color(0xFFFF7043);
  return const Color(0xFFD32F2F);
}

String _scoreGrade(double s) {
  if (s >= 75) return 'A';
  if (s >= 65) return 'B';
  if (s >= 55) return 'C';
  if (s >= 45) return 'D';
  if (s >= 35) return 'E';
  return 'F';
}

// ── Widget ─────────────────────────────────────────────────────────────────────

class ShareCardWidget extends StatefulWidget {
  const ShareCardWidget({
    super.key,
    required this.width,
    required this.height,
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.score,
    required this.safetyScore,
    required this.efficacyScore,
    required this.tags,
    this.isStory = false,
    this.verdict = '',
    this.lang = 'en',
    this.imageId = 0,
  });

  final double width;
  final double height;
  final String productName;
  final String brandName;
  final String imageUrl;
  final double score;
  final double safetyScore;
  final double efficacyScore;
  final List<String> tags;
  final bool isStory;
  final String verdict;
  final String lang;
  final int imageId;

  @override
  State<ShareCardWidget> createState() => _ShareCardWidgetState();
}

class _ShareCardWidgetState extends State<ShareCardWidget> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isCapturing = false;

  double get _aspectRatio => widget.isStory ? (9 / 16) : 1.0;

  Future<void> _captureAndShare() async {
    setState(() => _isCapturing = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            name: 'mirra_card.png',
            mimeType: 'image/png',
          )
        ],
        text:
            '${widget.brandName} ${widget.productName} — ${_t('shareText', widget.lang)}',
      );
      unawaited(AnalyticsService.instance.trackShareCardCreated(
        imageId: widget.imageId,
        format: widget.isStory ? 'story' : 'square',
      ));
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _aspectRatio,
          child: RepaintBoundary(
            key: _repaintKey,
            child: widget.isStory
                ? _StoryCard(
                    productName: widget.productName,
                    brandName: widget.brandName,
                    imageUrl: widget.imageUrl,
                    score: widget.score,
                    safetyScore: widget.safetyScore,
                    efficacyScore: widget.efficacyScore,
                    tags: widget.tags,
                    verdict: widget.verdict,
                    lang: widget.lang,
                  )
                : _SquareCard(
                    productName: widget.productName,
                    brandName: widget.brandName,
                    imageUrl: widget.imageUrl,
                    score: widget.score,
                    safetyScore: widget.safetyScore,
                    efficacyScore: widget.efficacyScore,
                    tags: widget.tags,
                    verdict: widget.verdict,
                    lang: widget.lang,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isCapturing ? null : _captureAndShare,
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  FlutterFlowTheme.of(context).primary.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            icon: _isCapturing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.ios_share_rounded),
            label: Text(
              _isCapturing
                  ? _t('creating', widget.lang)
                  : _t('share', widget.lang),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Story Card (9:16) ──────────────────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.score,
    required this.safetyScore,
    required this.efficacyScore,
    required this.tags,
    required this.verdict,
    required this.lang,
  });

  final String productName;
  final String brandName;
  final String imageUrl;
  final double score;
  final double safetyScore;
  final double efficacyScore;
  final List<String> tags;
  final String verdict;
  final String lang;

  static const _primary = Color(0xFF5C85D9);
  static const _bg = Color(0xFFF5F7FF);

  @override
  Widget build(BuildContext context) {
    final sColor = _scoreColor(score);
    final grade = _scoreGrade(score);

    return Container(
      decoration: const BoxDecoration(color: _bg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background tinted photo (blurred, decorative)
          Positioned(
            top: 0, left: 0, right: 0,
            height: 420,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
          // Gradient fade to bg
          Positioned(
            top: 0, left: 0, right: 0,
            height: 460,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.55, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.0),
                    _bg,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: MiRRA branding
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MiRRA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Product info
                Text(brandName,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(productName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2)),

                const SizedBox(height: 20),

                // Score + grade badge
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: sColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: sColor, width: 2.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        grade,
                        style: TextStyle(
                          color: sColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${score.toStringAsFixed(0)}/100',
                            style: TextStyle(
                              color: sColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (verdict.isNotEmpty)
                            Text(
                              verdict,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // White card with bars
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _ScoreBar(
                        label: _t('safety', lang),
                        value: safetyScore,
                      ),
                      const SizedBox(height: 10),
                      _ScoreBar(
                        label: _t('efficacy', lang),
                        value: efficacyScore,
                      ),
                    ],
                  ),
                ),

                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tags
                        .take(3)
                        .map((t) => _Tag(label: t, primary: _primary))
                        .toList(),
                  ),
                ],

                const Spacer(),

                Center(
                  child: Text(
                    'mirra.app',
                    style: TextStyle(
                      color: _primary.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Square Card (1:1) ──────────────────────────────────────────────────────────

class _SquareCard extends StatelessWidget {
  const _SquareCard({
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.score,
    required this.safetyScore,
    required this.efficacyScore,
    required this.tags,
    required this.verdict,
    required this.lang,
  });

  final String productName;
  final String brandName;
  final String imageUrl;
  final double score;
  final double safetyScore;
  final double efficacyScore;
  final List<String> tags;
  final String verdict;
  final String lang;

  static const _primary = Color(0xFF5C85D9);
  static const _bg = Color(0xFFF5F7FF);

  @override
  Widget build(BuildContext context) {
    final sColor = _scoreColor(score);
    final grade = _scoreGrade(score);

    return Container(
      decoration: const BoxDecoration(color: _bg),
      child: Row(
        children: [
          // Left: photo with gradient
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl,
                    fit: BoxFit.cover, height: double.infinity),
                // gradient to right
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          _bg.withOpacity(0.15),
                        ],
                      ),
                    ),
                  ),
                ),
                // MiRRA label bottom-left
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MiRRA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right: info panel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand + product name
                  Text(brandName,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2),
                  ),
                  const SizedBox(height: 12),

                  // Grade + score
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: sColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: sColor, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          grade,
                          style: TextStyle(
                            color: sColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${score.toStringAsFixed(0)}/100',
                              style: TextStyle(
                                color: sColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (verdict.isNotEmpty)
                              Text(
                                verdict,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.45),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _ScoreBar(label: _t('safety', lang), value: safetyScore),
                  const SizedBox(height: 6),
                  _ScoreBar(label: _t('efficacy', lang), value: efficacyScore),

                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags
                          .take(2)
                          .map((t) => _Tag(label: t, primary: _primary))
                          .toList(),
                    ),
                  ],

                  const Spacer(),

                  Text(
                    'mirra.app',
                    style: TextStyle(
                      color: _primary.withOpacity(0.5),
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
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

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});
  final String label;
  final double value;

  Color get _color {
    if (value >= 75) return const Color(0xFF43A047);
    if (value >= 50) return const Color(0xFFFFB300);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.5), fontSize: 11)),
            Text('${value.toStringAsFixed(0)}%',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.black.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation(_color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.primary});
  final String label;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: primary,
              fontSize: 10,
              fontWeight: FontWeight.w500)),
    );
  }
}
