import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'yourrating_model.dart';
export 'yourrating_model.dart';

/// New Component Gen
class YourratingWidget extends StatefulWidget {
  const YourratingWidget({
    super.key,
    int? stars,
    required this.imageid,
  }) : this.stars = stars ?? 0;

  final int stars;
  final int? imageid;

  @override
  State<YourratingWidget> createState() => _YourratingWidgetState();
}

class _YourratingWidgetState extends State<YourratingWidget> {
  late YourratingModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => YourratingModel());

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
      width: MediaQuery.sizeOf(context).width * 1.0,
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
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FFLocalizations.of(context).getText(
                    'yr352ijv' /* Your rating of the product */,
                  ),
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleMediumFamily,
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleMediumIsCustom,
                      ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: RatingBar.builder(
                    onRatingUpdate: (newValue) async {
                      safeSetState(() => _model.ratingBarValue = newValue);
                      await ImagesTable().update(
                        data: {
                          'stars_from_user': _model.ratingBarValue?.round(),
                        },
                        matchingRows: (rows) => rows.eqOrNull(
                          'id',
                          widget.imageid,
                        ),
                      );
                    },
                    itemBuilder: (context, index) => Icon(
                      Icons.star_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    direction: Axis.horizontal,
                    initialRating: _model.ratingBarValue ??=
                        widget.stars.toDouble(),
                    unratedColor: FlutterFlowTheme.of(context).accent1,
                    itemCount: 5,
                    itemSize: 30.0,
                    glowColor: FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ].divide(SizedBox(height: 16.0)),
            ),
          ].divide(SizedBox(height: 16.0)),
        ),
      ),
    );
  }
}
