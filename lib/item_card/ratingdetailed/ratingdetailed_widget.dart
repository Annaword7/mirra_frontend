import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'ratingdetailed_model.dart';
export 'ratingdetailed_model.dart';

/// New Component Gen
class RatingdetailedWidget extends StatefulWidget {
  const RatingdetailedWidget({
    super.key,
    double? score,
    this.tags,
  }) : this.score = score ?? 0.0;

  final double score;
  final List<String>? tags;

  @override
  State<RatingdetailedWidget> createState() => _RatingdetailedWidgetState();
}

class _RatingdetailedWidgetState extends State<RatingdetailedWidget> {
  late RatingdetailedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RatingdetailedModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FFLocalizations.of(context).getText(
                'bijscz1a' /* Safety Score */,
              ),
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily:
                        FlutterFlowTheme.of(context).headlineMediumFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                  ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: CircularPercentIndicator(
                percent: valueOrDefault<double>(
                  (widget.score ?? 0) / 10,
                  0.1,
                ),
                radius: 60.0,
                lineWidth: 12.0,
                animation: true,
                animateFromLastPercent: true,
                progressColor: valueOrDefault<Color>(
                  () {
                    if (widget.score >= 7.0) {
                      return FlutterFlowTheme.of(context).success;
                    } else if ((widget.score < 7.0) &&
                        (widget.score >= 3.0)) {
                      return Color(0xFFFA8B4B);
                    } else {
                      return FlutterFlowTheme.of(context).error;
                    }
                  }(),
                  FlutterFlowTheme.of(context).primary,
                ),
                backgroundColor: FlutterFlowTheme.of(context).accent4,
                center: Text(
                  '${widget.score.toString()}/10',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).headlineSmallFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).headlineSmallIsCustom,
                      ),
                ),
              ),
            ),
            Divider(
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
            Text(
              FFLocalizations.of(context).getText(
                '2x9pgdry' /* Suitable for: */,
              ),
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleMediumIsCustom,
                  ),
            ),
            if (widget.tags != null && (widget.tags)!.isNotEmpty)
              Builder(
                builder: (context) {
                  final tagsfromlist = widget.tags?.toList() ?? [];

                  return Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.horizontal,
                    runAlignment: WrapAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    clipBehavior: Clip.none,
                    children:
                        List.generate(tagsfromlist.length, (tagsfromlistIndex) {
                      final tagsfromlistItem = tagsfromlist[tagsfromlistIndex];
                      return Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondary,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            tagsfromlistItem,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
          ].divide(SizedBox(height: 16.0)),
        ),
      ),
    );
  }
}
