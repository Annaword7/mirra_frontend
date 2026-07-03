import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/internationalization.dart' show kTranslationsMap;
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'countryselector_model.dart';
export 'countryselector_model.dart';

class CountryselectorWidget extends StatefulWidget {
  const CountryselectorWidget({
    super.key,
    this.languageCode,
    this.fillColor,
    this.textColor,
    this.iconColor,
    this.textSize,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.elevation,
    this.onCountrySelected,
  });

  /// When provided, overrides the app locale for country name labels.
  /// Use this to preview labels in a language not yet applied to the app.
  final String? languageCode;

  /// Optional style overrides (default to the app theme). Used by the
  /// light-themed quick-setup sheet to force a neutral field with black text.
  final Color? fillColor;
  final Color? textColor;
  final Color? iconColor;
  final double? textSize;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final double? elevation;

  /// Called when the user picks a country. When provided and there is no
  /// active auth session, the DB write is skipped — the caller is responsible
  /// for persisting the value after sign-in.
  final void Function(int?)? onCountrySelected;

  @override
  State<CountryselectorWidget> createState() => _CountryselectorWidgetState();
}

class _CountryselectorWidgetState extends State<CountryselectorWidget> {
  late CountryselectorModel _model;
  late Future<(List<CountriesRow>, int?)> _dataFuture;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CountryselectorModel());
    _dataFuture = _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<(List<CountriesRow>, int?)> _loadData() async {
    final uid = currentUserUid;
    final futures = <Future>[
      CountriesTable().queryRows(queryFn: (q) => q),
      if (uid.isNotEmpty)
        UsersTable().queryRows(
          queryFn: (q) => q.eqOrNull('id', uid),
        ),
    ];
    final results = await Future.wait(futures);
    final countries = results[0] as List<CountriesRow>;
    final users = uid.isNotEmpty ? results[1] as List<UsersRow> : <UsersRow>[];
    return (countries, users.firstOrNull?.countryId);
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<CountriesRow>, int?)>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return GestureDetector(
            onTap: () => safeSetState(() => _dataFuture = _loadData()),
            child: Container(
              height: 50.0,
              alignment: Alignment.center,
              child: Text(
                'Tap to retry',
                style: FlutterFlowTheme.of(context)
                    .bodyMedium
                    .override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).error,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        final (dropDownCountriesRowList, userCountryId) = snapshot.data!;

        return FlutterFlowDropDown<int>(
          controller: _model.dropDownValueController ??=
              FormFieldController<int>(
            _model.dropDownValue ??= userCountryId,
          ),
          options: List<int>.from(
              dropDownCountriesRowList.map((e) => e.id).toList()),
          optionLabels: () {
            final lang = widget.languageCode ??
                FFLocalizations.of(context).languageCode;
            if (lang == 'ru') {
              return dropDownCountriesRowList.map((e) => e.nameRu).toList();
            } else if (lang == 'es') {
              return dropDownCountriesRowList.map((e) => e.nameEs).toList();
            } else {
              return dropDownCountriesRowList.map((e) => e.nameEn).toList();
            }
          }(),
          onChanged: (val) async {
            safeSetState(() => _model.dropDownValue = val);
            widget.onCountrySelected?.call(val);
            final uid = currentUserUid;
            if (uid.isEmpty) return;
            await UsersTable().update(
              data: {'country_id': _model.dropDownValue},
              matchingRows: (rows) => rows.eqOrNull('id', uid),
            );
          },
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 50.0,
          searchHintTextStyle:
              FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                    color: widget.textColor,
                    fontSize: widget.textSize,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).labelMediumIsCustom,
                  ),
          searchTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: widget.textColor,
                    fontSize: widget.textSize,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
          textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: widget.textColor,
                    fontSize: widget.textSize,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
          hintText: widget.languageCode == null
              ? FFLocalizations.of(context).getText('ocz602t7')
              : (kTranslationsMap['ocz602t7']?[widget.languageCode] ??
                  kTranslationsMap['ocz602t7']?['en'] ??
                  'Your region'),
          searchHintText: widget.languageCode == null
              ? FFLocalizations.of(context).getText('qsbnew6g')
              : (kTranslationsMap['qsbnew6g']?[widget.languageCode] ??
                  kTranslationsMap['qsbnew6g']?['en'] ??
                  'Search...'),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: widget.iconColor ??
                FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          fillColor: widget.fillColor ?? FlutterFlowTheme.of(context).alternate,
          elevation: widget.elevation ?? 2.0,
          borderColor: widget.borderColor ?? Colors.transparent,
          borderWidth: widget.borderWidth ?? 0.0,
          borderRadius: widget.borderRadius ?? 16.0,
          margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
          hidesUnderline: true,
          isOverButton: false,
          isSearchable: true,
          isMultiSelect: false,
        );
      },
    );
  }
}
