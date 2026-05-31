import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'navbar_model.dart';
export 'navbar_model.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({
    super.key,
    this.activePage,
    this.analysesused,
  });

  final int? activePage;
  final int? analysesused;

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
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final active = widget.activePage == pageId;
    final color = active
        ? FlutterFlowTheme.of(context).alternate
        : FlutterFlowTheme.of(context).secondaryBackground;

    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(data: IconThemeData(color: color, size: 24), child: icon),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: color,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ]
              .divide(const SizedBox(height: 6.0))
              .addToStart(const SizedBox(height: 12.0))
              .addToEnd(const SizedBox(height: 12.0)),
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
    return SizedBox(
      height: 121.0,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: 1.0,
                    decoration:
                        const BoxDecoration(),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4.0,
                        color: FlutterFlowTheme.of(context).primary,
                        offset: const Offset(0.0, 1.0),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(48.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTab(
                            pageId: 2,
                            icon: const Icon(Icons.home),
                            label: FFLocalizations.of(context)
                                .getText('kndykt66' /* Home */),
                            onTap: () => _goFade(HomeWidget.routeName),
                          ),
                          _buildTab(
                            pageId: 1,
                            icon: const FaIcon(FontAwesomeIcons.search),
                            label: FFLocalizations.of(context)
                                .getText('f0lv5sbb' /* Explore */),
                            onTap: () => _goFade(TopratedWidget.routeName),
                          ),
                          // Center FAB placeholder
                          const Expanded(
                            child: SizedBox(height: 40.0),
                          ),
                          _buildTab(
                            pageId: 3,
                            icon: const Icon(Icons.space_dashboard),
                            label: FFLocalizations.of(context)
                                .getText('5lvcbe4s' /* Boards */),
                            onTap: () => _goFade(BoardsWidget.routeName),
                          ),
                          _buildTab(
                            pageId: 4,
                            icon: const Icon(Icons.person),
                            label: FFLocalizations.of(context)
                                .getText('i0bb253q' /* Profile */),
                            onTap: () => _goFade(ProfileWidget.routeName),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center FAB (scan button)
          Align(
            alignment: const AlignmentDirectional(0.0, -0.67),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4.0,
                    color: FlutterFlowTheme.of(context).primary,
                    offset: const Offset(0.0, -2.0),
                  ),
                ],
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 24.0,
                buttonSize: 65.0,
                fillColor: FlutterFlowTheme.of(context).alternate,
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  color: widget.activePage == 5
                      ? FlutterFlowTheme.of(context).primary
                      : FlutterFlowTheme.of(context).secondaryBackground,
                  size: 35.0,
                ),
                onPressed: () {
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
              ),
            ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
          ),
        ],
      ),
    );
  }
}
