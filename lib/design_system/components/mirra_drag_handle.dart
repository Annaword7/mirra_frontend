import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// The single canonical bottom-sheet drag handle (Design Review Initiative 6):
/// a 40×4 neutral-grey (`border`) fully-rounded bar. Replaces the three
/// competing designs (40×4 `border`, 100×5 blue `info`, `info`+redundant border).
class MirraDragHandle extends StatelessWidget {
  const MirraDragHandle({
    super.key,
    this.width = 40.0,
    this.height = 4.0,
    this.color,
  });

  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? FlutterFlowTheme.of(context).border,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
