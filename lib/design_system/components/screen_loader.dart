import 'package:flutter/material.dart';

import '/design_system/foundations/layout.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Индикатор загрузки экрана — всегда в центре ЭКРАНА, а не своей области.
///
/// Вкладки устроены по-разному: у одних Scaffold отдаёт часть высоты AppBar и
/// нижнему навбару, у других контент лежит на всю высоту, а навбар наложен
/// сверху. Из-за этого простой `Center` даёт разное положение спиннера на
/// разных вкладках — компонент компенсирует занятые высоты, чтобы точка была
/// одна и та же.
class ScreenLoader extends StatelessWidget {
  const ScreenLoader({
    super.key,
    this.hasAppBar = false,
    this.hasBottomNavBar = false,
  });

  /// У экрана есть `AppBar` (его высота вычитается из области body).
  final bool hasAppBar;

  /// Навбар занимает место как `bottomNavigationBar`, а не наложен поверх.
  final bool hasBottomNavBar;

  @override
  Widget build(BuildContext context) {
    final top = hasAppBar
        ? kToolbarHeight + MediaQuery.viewPaddingOf(context).top
        : 0.0;
    final bottom = hasBottomNavBar ? kNavBarHeight : 0.0;
    return Center(
      child: Transform.translate(
        offset: Offset(0, (bottom - top) / 2),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      ),
    );
  }
}
