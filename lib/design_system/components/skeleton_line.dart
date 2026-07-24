import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// A pulsing placeholder bar for a single line of text/content while data loads
/// (Design Review Initiative 5 family). Show it in place of a value that would
/// otherwise flash a stale default and then swap (e.g. "user" → real name,
/// "5 / 5" → "7 / 7"). Honors reduce-motion (static bar).
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width = 80.0,
    this.height = 16.0,
    this.radius = 8.0,
    this.color,
  });

  final double width;
  final double height;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    if (MediaQuery.of(context).disableAnimations) return bar;

    return bar
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(begin: 0.4, end: 0.9, duration: 700.ms, curve: Curves.easeInOut);
  }
}
