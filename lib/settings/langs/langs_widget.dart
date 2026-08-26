import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/design_system/components/selectable_row.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'langs_model.dart';
export 'langs_model.dart';

/// Create a page to choose interface language
class LangsWidget extends StatefulWidget {
  const LangsWidget({super.key});

  static String routeName = 'Langs';
  static String routePath = '/langs';

  @override
  State<LangsWidget> createState() => _LangsWidgetState();
}

class _LangsWidgetState extends State<LangsWidget> {
  late LangsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LangsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 24.0,
            buttonSize: 48.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Text(
              FFLocalizations.of(context).getText(
                'c7dzaokw' /* App language */,
              ),
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 24.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleLargeIsCustom,
                  ),
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, -1.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 600.0,
              ),
              decoration: BoxDecoration(),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 26.0, 16.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        primary: false,
                        shrinkWrap: false,
                        scrollDirection: Axis.vertical,
                        children: [
                          ...kAppLanguages.map((lang) {
                            final selected =
                                FFLocalizations.of(context).languageCode ==
                                    lang.code;
                            return SelectableRow(
                              label: '${lang.flag} ${lang.nativeName}',
                              selected: selected,
                              onTap: () async {
                                _model.langcode = lang.code;
                                safeSetState(() {});
                                setAppLanguage(context, lang.code);
                                // Экран закрывается сразу: язык уже сохранён
                                // локально (storeLocale), а запись в users
                                // нужна бэкенду и ждать её незачем. Раньше
                                // context использовался после await — к этому
                                // моменту экран мог быть уже снят.
                                context.safePop();
                                if (currentUserUid.isNotEmpty) {
                                  try {
                                    await UsersTable().update(
                                      data: {'language_code': lang.code},
                                      matchingRows: (q) =>
                                          q.eq('id', currentUserUid),
                                    );
                                  } catch (e) {
                                    // Не критично: Главная синхронизирует
                                    // language_code при следующем открытии.
                                    debugPrint('Langs: language_code sync failed: $e');
                                  }
                                }
                              },
                            );
                          }),
                        ].divide(SizedBox(height: 12.0)),
                      ),
                    ),
                  ].divide(SizedBox(height: 24.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
