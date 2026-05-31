import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'countryselector_model.dart';
export 'countryselector_model.dart';

class CountryselectorWidget extends StatefulWidget {
  const CountryselectorWidget({super.key, this.languageCode});

  /// When provided, overrides the app locale for country name labels.
  /// Use this to preview labels in a language not yet applied to the app.
  final String? languageCode;

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
    final results = await Future.wait([
      CountriesTable().queryRows(queryFn: (q) => q),
      UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull('id', currentUserUid),
      ),
    ]);
    final countries = results[0] as List<CountriesRow>;
    final users = results[1] as List<UsersRow>;
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
            await UsersTable().update(
              data: {
                'country_id': _model.dropDownValue,
              },
              matchingRows: (rows) => rows.eqOrNull(
                'id',
                currentUserUid,
              ),
            );
          },
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 50.0,
          searchHintTextStyle:
              FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).labelMediumIsCustom,
                  ),
          searchTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
          textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
          hintText: widget.languageCode == null
              ? FFLocalizations.of(context).getText('ocz602t7')
              : const {'ru': 'Ваш регион', 'es': 'Tu región'}[widget.languageCode] ?? 'Your region',
          searchHintText: widget.languageCode == null
              ? FFLocalizations.of(context).getText('qsbnew6g')
              : const {'ru': 'Поиск...', 'es': 'Buscar...'}[widget.languageCode] ?? 'Search...',
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          fillColor: FlutterFlowTheme.of(context).alternate,
          elevation: 2.0,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          borderRadius: 16.0,
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
