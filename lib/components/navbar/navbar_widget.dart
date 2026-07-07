import 'dart:ui' show ImageFilter;

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'navbar_model.dart';
export 'navbar_model.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({
    super.key,
    this.activePage,
    this.analysesused,
    this.onScrollToTop,
  });

  final int? activePage;
  final int? analysesused;
  /// Called when the user taps the navbar icon for the page they're already on.
  final VoidCallback? onScrollToTop;

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget>
    with TickerProviderStateMixin {
  late NavbarModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavbarModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 3000.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 0.02,
          ),
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 3600.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: -0.04,
          ),
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 4200.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 0.02,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 3000.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 0.0),
            end: Offset(0.0, -5.0),
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 4200.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 0.0),
            end: Offset(0.0, 5.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Widget _buildTab({
    required int pageId,
    required IconData iconData,
    IconData? activeIconData,
    required String label,
    required String routeName,
  }) {
    final active = widget.activePage == pageId;
    final color =
        active ? FlutterFlowTheme.of(context).primary : const Color(0xFF2C2C2E);

    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          HapticFeedback.lightImpact();
          if (active) {
            widget.onScrollToTop?.call();
          } else {
            _goFade(routeName);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? (activeIconData ?? iconData) : iconData,
                color: color, size: 24),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: color,
                      fontSize: 11.0,
                      letterSpacing: 0.0,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ]
              .divide(const SizedBox(height: 5.0))
              .addToStart(const SizedBox(height: 10.0))
              .addToEnd(const SizedBox(height: 10.0)),
        ),
      ),
    );
  }

  void _goFade(String routeName) {
    context.goNamed(
      routeName,
      extra: <String, dynamic>{
        '__transition_info__': TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = FlutterFlowTheme.of(context).primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Frosted-glass approximation (iOS ultraThinMaterial style).
    final glassFill = dark
        ? Colors.black.withValues(alpha: 0.42)
        : Colors.white.withValues(alpha: 0.72);
    final glassBorder = dark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.75);

    return SizedBox(
      height: 108.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 28.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24.0,
                      offset: const Offset(0.0, 8.0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: glassFill,
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: glassBorder, width: 1.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 0.0, 8.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTab(
                              pageId: 2,
                              iconData: Icons.home_outlined,
                              activeIconData: Icons.home_rounded,
                              label: FFLocalizations.of(context)
                                  .getText('kndykt66' /* Home */),
                              routeName: HomeWidget.routeName,
                            ),
                            _buildTab(
                              pageId: 1,
                              iconData: Icons.search_rounded,
                              label: FFLocalizations.of(context)
                                  .getText('f0lv5sbb' /* Explore */),
                              routeName: TopratedWidget.routeName,
                            ),
                            const Expanded(child: SizedBox(height: 40.0)),
                            _buildTab(
                              pageId: 3,
                              iconData: Icons.spa_outlined,
                              activeIconData: Icons.spa_rounded,
                              label: FFLocalizations.of(context)
                                  .getText('cb_bag_title'),
                              routeName: CosmeticBagWidget.routeName,
                            ),
                            _buildTab(
                              pageId: 4,
                              iconData: Icons.calendar_today_outlined,
                              activeIconData: Icons.calendar_month_rounded,
                              label: FFLocalizations.of(context)
                                  .getText('cb_routine_title'),
                              routeName: RoutineCalendarWidget.routeName,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Center FAB (scan button)
          Align(
            alignment: const AlignmentDirectional(0.0, -0.72),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.40),
                    blurRadius: 16.0,
                    offset: const Offset(0.0, 6.0),
                  ),
                ],
              ),
              child: Material(
                color: primary,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.pushNamed(
                      TakeorUploadPageWidget.routeName,
                      extra: <String, dynamic>{
                        '__transition_info__': TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                  child: const SizedBox(
                    width: 62.0,
                    height: 62.0,
                    child: Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 32.0),
                  ),
                ),
              ),
            ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
          ),
        ],
      ),
    );
  }
}
