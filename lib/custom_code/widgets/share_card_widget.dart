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

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

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
            '${widget.brandName} ${widget.productName} — MiRRA Score: ${widget.score.toStringAsFixed(0)}/100',
      );
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
                  )
                : _SquareCard(
                    productName: widget.productName,
                    brandName: widget.brandName,
                    imageUrl: widget.imageUrl,
                    score: widget.score,
                    safetyScore: widget.safetyScore,
                    efficacyScore: widget.efficacyScore,
                    tags: widget.tags,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isCapturing ? null : _captureAndShare,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isCapturing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.share),
            label: Text(_isCapturing ? 'Создаём...' : 'Поделиться'),
          ),
        ),
      ],
    );
  }
}

// ─── Story Card (9:16) ────────────────────────────────────────────────────────
class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.score,
    required this.safetyScore,
    required this.efficacyScore,
    required this.tags,
  });

  final String productName;
  final String brandName;
  final String imageUrl;
  final double score;
  final double safetyScore;
  final double efficacyScore;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0D0D0D)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.25,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MiRRA',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 13, letterSpacing: 5)),
                const Spacer(),
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 40)
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(brandName,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 14)),
                Text(productName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _ScoreBadge(score: score),
                const SizedBox(height: 16),
                _ScoreBar(label: 'Safety', value: safetyScore),
                const SizedBox(height: 8),
                _ScoreBar(label: 'Efficacy', value: efficacyScore),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: tags.take(3).map((t) => _Tag(label: t)).toList(),
                ),
                const Spacer(),
                const Center(
                  child: Text('mirra.app',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Square Card (1:1) ────────────────────────────────────────────────────────
class _SquareCard extends StatelessWidget {
  const _SquareCard({
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.score,
    required this.safetyScore,
    required this.efficacyScore,
    required this.tags,
  });

  final String productName;
  final String brandName;
  final String imageUrl;
  final double score;
  final double safetyScore;
  final double efficacyScore;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1A1A1D)),
      child: Row(
        children: [
          Expanded(
            child: Image.network(imageUrl,
                fit: BoxFit.cover, height: double.infinity),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('MiRRA',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 4)),
                  const SizedBox(height: 8),
                  Text(brandName,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11)),
                  Text(productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  _ScoreBadge(score: score, compact: true),
                  const SizedBox(height: 12),
                  _ScoreBar(label: 'Safety', value: safetyScore),
                  const SizedBox(height: 6),
                  _ScoreBar(label: 'Efficacy', value: efficacyScore),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags.take(2).map((t) => _Tag(label: t)).toList(),
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

// ─── Shared sub-widgets ───────────────────────────────────────────────────────
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, this.compact = false});
  final double score;
  final bool compact;

  Color get _color {
    if (score >= 75) return const Color(0xFF4CAF50);
    if (score >= 50) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14, vertical: compact ? 6 : 10),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color, width: 1.5),
      ),
      child: Text(
        '${score.toStringAsFixed(0)}/100',
        style: TextStyle(
            color: _color,
            fontSize: compact ? 18 : 28,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});
  final String label;
  final double value;

  Color get _color {
    if (value >= 75) return const Color(0xFF4CAF50);
    if (value >= 50) return const Color(0xFFFFC107);
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
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            Text('${value.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(_color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
