import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'limit_out_model.dart';
export 'limit_out_model.dart';

const _ink = Color(0xFF1A1A1A);

class LimitOutWidget extends StatefulWidget {
  const LimitOutWidget({
    super.key,
    required this.limit,
    required this.date,
    required this.isPro,
  });

  final int? limit;
  final String? date;
  final bool? isPro;

  @override
  State<LimitOutWidget> createState() => _LimitOutWidgetState();
}

class _LimitOutWidgetState extends State<LimitOutWidget> {
  late LimitOutModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LimitOutModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final loc = FFLocalizations.of(context);

    return Container(
      color: Colors.transparent,
      child: Align(
        alignment: AlignmentDirectional.center,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12.0,
                  color: Color(0x33000000),
                  offset: Offset(0.0, 4.0),
                )
              ],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.getText('fvjg2ei8' /* Limit reached */),
                    style: theme.headlineSmall.override(
                      fontFamily: theme.headlineSmallFamily,
                      color: _ink,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.headlineSmallIsCustom,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: _ink,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                      children: [
                        TextSpan(text: loc.getText('5vf31bag' /* You've used  */)),
                        TextSpan(
                          text: widget.limit!.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: loc.getText('9iwfkse3')),
                        TextSpan(
                          text: widget.date!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  if (widget.isPro ?? false)
                    FFButtonWidget(
                      onPressed: () async {
                        Navigator.pop(context);
                        context.pushNamed(HomeWidget.routeName);
                      },
                      text: loc.getText('e12wjrgi' /* Got it */),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 52.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 14.0),
                        iconPadding: EdgeInsetsDirectional.zero,
                        color: theme.primary,
                        textStyle: theme.titleSmall.override(
                          fontFamily: theme.titleSmallFamily,
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.titleSmallIsCustom,
                        ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                  if (!(widget.isPro ?? false))
                    FFButtonWidget(
                      onPressed: () async {
                        Navigator.pop(context);
                        context.pushNamed(PaywallpageWidget.routeName);
                      },
                      text: loc.getText('cscoyn8e' /* Upgrade to Pro */),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 52.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 14.0),
                        iconPadding: EdgeInsetsDirectional.zero,
                        color: theme.primary,
                        textStyle: theme.titleSmall.override(
                          fontFamily: theme.titleSmallFamily,
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.titleSmallIsCustom,
                        ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
