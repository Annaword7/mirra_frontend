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
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '/flutter_flow/analytics_service.dart';

// ── Localization maps ──────────────────────────────────────────────────────────

const _l10n = {
  'share': {'en': 'Share', 'ru': 'Поделиться', 'es': 'Compartir'},
  'creating': {'en': 'Creating…', 'ru': 'Создаём…', 'es': 'Creando…'},
  'shareText': {
    'en': 'Analyzed with MiRRA',
    'ru': 'Проверено с MiRRA',
    'es': 'Analizado con MiRRA',
  },
  'tagPrompt': {
    'en': 'Tag us when you share!',
    'ru': 'Отметьте нас, когда делитесь!',
    'es': '¡Etiquétanos cuando compartas!',
  },
  'copyTags': {
    'en': 'Copy tags',
    'ru': 'Скопировать теги',
    'es': 'Copiar etiquetas',
  },
  'copied': {
    'en': 'Copied!',
    'ru': 'Скопировано!',
    'es': '¡Copiado!',
  },
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
    this.quickSummary = '',
    this.bestForTags = const [],
    this.expertAnalysis = '',
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
  final String quickSummary;
  final List<String> bestForTags;
  final String expertAnalysis;

  @override
  State<ShareCardWidget> createState() => _ShareCardWidgetState();
}

class _ShareCardWidgetState extends State<ShareCardWidget> {
  final GlobalKey _repaintKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();
  bool _isCapturing = false;

  double get _aspectRatio => widget.isStory ? (9 / 16) : 1.0;

  Future<void> _captureAndShare() async {
    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('[ShareCard] ERROR: RepaintBoundary is null');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      Rect? shareOrigin;
      final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final position = box.localToGlobal(Offset.zero);
        shareOrigin = position & box.size;
      }

      await Share.shareXFiles(
        [XFile.fromData(bytes, name: 'mirra_card.png', mimeType: 'image/png')],
        text:
            '${widget.brandName} ${widget.productName} — ${_t('shareText', widget.lang)}',
        sharePositionOrigin: shareOrigin,
      );
      unawaited(AnalyticsService.instance.trackShareCardCreated(
        imageId: widget.imageId,
        format: widget.isStory ? 'story' : 'square',
      ));
    } catch (e, stack) {
      debugPrint('[ShareCard] EXCEPTION: $e\n$stack');
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
                    lang: widget.lang,
                    expertAnalysis: widget.expertAnalysis,
                  )
                : _SquareCard(
                    productName: widget.productName,
                    brandName: widget.brandName,
                    imageUrl: widget.imageUrl,
                    score: widget.score,
                    lang: widget.lang,
                    expertAnalysis: widget.expertAnalysis,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        _TagsSection(
          brandName: widget.brandName,
          bestForTags: widget.bestForTags,
          lang: widget.lang,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            key: _shareButtonKey,
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
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared right-panel ─────────────────────────────────────────────────────────

Widget _rightPanel({
  required String brandName,
  required String productName,
  required double score,
  required String expertAnalysis,
  required double nameFontSize,
  required double brandFontSize,
  required double badgeSize,
  required double gradeFontSize,
  required double scoreFontSize,
  required EdgeInsets padding,
}) {
  final sColor = _scoreColor(score);
  final grade = _scoreGrade(score);
  const primary = Color(0xFF5C85D9);

  return Padding(
    padding: padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        Text(
          brandName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black.withOpacity(0.4),
            fontSize: brandFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        // Product name
        Text(
          productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontSize: nameFontSize,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        // Score badge
        Row(
          children: [
            Container(
              width: badgeSize,
              height: badgeSize,
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
                  fontSize: gradeFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${score.toStringAsFixed(0)}/100',
              style: TextStyle(
                color: sColor,
                fontSize: scoreFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Expert analysis — fills all remaining space
        if (expertAnalysis.isNotEmpty)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => AutoSizeText(
                expertAnalysis,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.72),
                  fontSize: 22,
                  height: 1.45,
                ),
                minFontSize: 7,
                maxLines: (constraints.maxHeight / (7 * 1.45)).ceil(),
              ),
            ),
          )
        else
          const Spacer(),
        const SizedBox(height: 8),
        // Footer
        Text(
          'M!RRA Cosmetic Checker',
          style: TextStyle(
            color: primary.withOpacity(0.5),
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}

// ── Story Card (9:16) ──────────────────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.score,
    required this.lang,
    required this.expertAnalysis,
  });

  final String productName;
  final String brandName;
  final String imageUrl;
  final double score;
  final String lang;
  final String expertAnalysis;

  static const _primary = Color(0xFF5C85D9);
  static const _bg = Color(0xFFF5F7FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: _bg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: image (38%)
          Expanded(
            flex: 38,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                Positioned(
                  left: 10,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
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
          // Right: info (62%)
          Expanded(
            flex: 62,
            child: _rightPanel(
              brandName: brandName,
              productName: productName,
              score: score,
              expertAnalysis: expertAnalysis,
              nameFontSize: 17,
              brandFontSize: 11,
              badgeSize: 48,
              gradeFontSize: 22,
              scoreFontSize: 16,
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
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
    required this.lang,
    required this.expertAnalysis,
  });

  final String productName;
  final String brandName;
  final String imageUrl;
  final double score;
  final String lang;
  final String expertAnalysis;

  static const _primary = Color(0xFF5C85D9);
  static const _bg = Color(0xFFF5F7FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: _bg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: image (50%)
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
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
          // Right: info (50%)
          Expanded(
            child: _rightPanel(
              brandName: brandName,
              productName: productName,
              score: score,
              expertAnalysis: expertAnalysis,
              nameFontSize: 14,
              brandFontSize: 10,
              badgeSize: 40,
              gradeFontSize: 18,
              scoreFontSize: 14,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tags section ───────────────────────────────────────────────────────────────

String _toHashtag(String raw) {
  final clean = raw
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-zA-Z0-9а-яёА-ЯЁ]'), '');
  return clean.isEmpty ? '' : '#$clean';
}

class _TagsSection extends StatefulWidget {
  const _TagsSection({
    required this.brandName,
    required this.bestForTags,
    required this.lang,
  });

  final String brandName;
  final List<String> bestForTags;
  final String lang;

  @override
  State<_TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<_TagsSection> {
  bool _copied = false;

  static const _primary = Color(0xFF5C85D9);

  List<String> get _tags {
    final result = <String>['#mirra'];
    final brand = _toHashtag(widget.brandName);
    if (brand.isNotEmpty) result.add(brand);
    for (final t in widget.bestForTags) {
      final h = _toHashtag(t);
      if (h.isNotEmpty && !result.contains(h)) result.add(h);
    }
    return result;
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _tags.join(' ')));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final tags = _tags;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _t('tagPrompt', widget.lang),
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _copy,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _copied
                      ? Row(
                          key: const ValueKey('copied'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 14, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text(
                              _t('copied', widget.lang),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('copy'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_rounded,
                                size: 14,
                                color: _primary.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              _t('copyTags', widget.lang),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _primary.withOpacity(0.25)),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
