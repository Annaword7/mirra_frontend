import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'startanalys_model.dart';
export 'startanalys_model.dart';

/// New Component Gen
class StartanalysWidget extends StatefulWidget {
  const StartanalysWidget({super.key});

  @override
  State<StartanalysWidget> createState() => _StartanalysWidgetState();
}

class _StartanalysWidgetState extends State<StartanalysWidget> {
  late StartanalysModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StartanalysModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// Returns a short "Resets in X days" / "Resets today" label based on the
  /// window start date stored in FFAppState.weekResetDate.
  String _resetLabel(BuildContext context, DateTime? resetStart) {
    if (resetStart == null) return '';
    final resetAt = resetStart.add(const Duration(days: 7)).toLocal();
    final now = DateTime.now();
    final resetDay = DateTime(resetAt.year, resetAt.month, resetAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final days = (resetDay.difference(today).inHours / 24).round();
    if (days < 0) return '';
    final loc = FFLocalizations.of(context);
    if (days == 0) return '· ${loc.getText('home_resets_today')}';
    if (days == 1) return '· ${loc.getText('home_resets_tomorrow')}';
    return '· ${loc.getText('home_resets_days').replaceAll('{n}', '$days')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();
    final isPro = appState.isprouser;
    final scansUsed = appState.analysesused;
    final scanLimit = appState.freeScanLimit;
    final remaining = (scanLimit - scansUsed).clamp(0, scanLimit);
    final resetLabel = _resetLabel(context, appState.weekResetDate);

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FlutterFlowTheme.of(context).primary, Color(0xFFA7B6CC)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(1.0, 1.0),
              end: AlignmentDirectional(-1.0, -1.0),
            ),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        '16f5sjb6' /* AI Analysis */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                  ].divide(SizedBox(width: 8.0)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText(
                        'bk3jxz77' /* Scan a Product */,
                      ),
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).displaySmallFamily,
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .displaySmallIsCustom,
                          ),
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        'a8lx03m5' /* Instantly analyze ingredients ... */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: Colors.white,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ].divide(SizedBox(height: 8.0)),
                ),
                FFButtonWidget(
                  onPressed: () {
                    print('Button pressed ...');
                  },
                  text: FFLocalizations.of(context).getText(
                    'zyx01ncu' /* Start */,
                  ),
                  icon: Icon(
                    Icons.camera_alt,
                    size: 15.0,
                  ),
                  options: FFButtonOptions(
                    height: 54.0,
                    padding: EdgeInsets.all(15.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconColor: FlutterFlowTheme.of(context).primary,
                    color: Colors.white,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                ),
                // ── Quota status bar ────────────────────────────────────────
                _QuotaStatusBar(
                  isPro: isPro,
                  scansUsed: scansUsed,
                  scanLimit: scanLimit,
                  remaining: remaining,
                  resetLabel: resetLabel,
                ),
              ].divide(SizedBox(height: 16.0)),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuotaStatusBar extends StatelessWidget {
  const _QuotaStatusBar({
    required this.isPro,
    required this.scansUsed,
    required this.scanLimit,
    required this.remaining,
    required this.resetLabel,
  });

  final bool isPro;
  final int scansUsed;
  final int scanLimit;
  final int remaining;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    if (isPro) {
      return Row(
        children: [
          Icon(Icons.all_inclusive, color: Colors.white70, size: 14.0),
          SizedBox(width: 6.0),
          Text(
            FFLocalizations.of(context).getText('ic2_pro_unlimited'),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    final progress = scanLimit > 0 ? scansUsed / scanLimit : 0.0;
    final isExhausted = remaining == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FFLocalizations.of(context)
                  .getText('home_scans_left')
                  .replaceAll('{remaining}', '$remaining')
                  .replaceAll('{limit}', '$scanLimit'),
              style: TextStyle(
                color: isExhausted ? Colors.red[200] : Colors.white70,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (resetLabel.isNotEmpty)
              Text(
                resetLabel,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11.0,
                ),
              ),
          ],
        ),
        SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4.0,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              isExhausted ? Colors.red[300]! : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
