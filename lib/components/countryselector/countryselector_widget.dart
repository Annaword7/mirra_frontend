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
  const CountryselectorWidget({super.key});

  @override
  State<CountryselectorWidget> createState() => _CountryselectorWidgetState();
}

class _CountryselectorWidgetState extends State<CountryselectorWidget> {
  late CountryselectorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CountryselectorModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CountriesRow>>(
      future: CountriesTable().queryRows(
        queryFn: (q) => q,
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
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
        List<CountriesRow> dropDownCountriesRowList = snapshot.data!;

        return FlutterFlowDropDown<int>(
          controller: _model.dropDownValueController ??=
              FormFieldController<int>(
            _model.dropDownValue ??= 18,
          ),
          options: List<int>.from(
              dropDownCountriesRowList.map((e) => e.id).toList()),
          optionLabels: () {
            if (FFLocalizations.of(context).languageCode == 'ru') {
              return dropDownCountriesRowList.map((e) => e.nameRu).toList();
            } else if (FFLocalizations.of(context).languageCode == 'es') {
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
          hintText: FFLocalizations.of(context).getText(
            'ocz602t7' /* Your region */,
          ),
          searchHintText: FFLocalizations.of(context).getText(
            'qsbnew6g' /* Search... */,
          ),
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
