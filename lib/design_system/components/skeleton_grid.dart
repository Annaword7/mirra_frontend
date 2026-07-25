import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// One skeleton placeholder tile — a rounded, theme-`alternate`-filled box.
/// Reserved for **loading** grids (an empty screen should use `MirraEmptyState`,
/// not a skeleton — Design Review Initiative 5).
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key, this.radius = 12.0, this.color});

  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A grid of pulsing [SkeletonTile]s — the single loading-skeleton primitive
/// that replaces the ~2,000 lines of hand-unrolled fade-tile loaders
/// (album_list_loading alone declared 32 `AnimationInfo` by hand).
///
/// The staggered loop-reverse fade is generated from the tile index, so callers
/// pass only layout params. Defaults match the common gallery loader (2 columns,
/// square tiles, 8px spacing, `alternate` fill).
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({
    super.key,
    this.count = 8,
    this.columns = 2,
    this.aspectRatio = 1.0,
    this.spacing = 8.0,
    this.tileRadius = 12.0,
    this.tileColor,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
    this.animate = true,
  });

  final int count;
  final int columns;
  final double aspectRatio;
  final double spacing;
  final double tileRadius;
  final Color? tileColor;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: count,
      itemBuilder: (context, i) {
        final tile = SkeletonTile(radius: tileRadius, color: tileColor);
        if (!animate) return tile;
        // Loop-reverse fade (0↔1) with a per-tile stagger, matching the old
        // FlutterFlow loaders. Stagger wraps every 8 tiles to keep delays tight.
        return tile
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(
              begin: 0.0,
              end: 1.0,
              delay: (100 * (i % 8)).ms,
              duration: 600.ms,
              curve: Curves.easeInOut,
            );
      },
    );
  }
}
