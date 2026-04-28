import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item_card/imagedetailed_top_raited/imagedetailed_top_raited_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'toprated_model.dart';
export 'toprated_model.dart';

const Map<String, List<String>> _kCategoryTypes = {
  'serum':       ['serum'],
  'toner':       ['toner'],
  'moisturizer': ['moisturizer', 'treatment'],
  'mask':        ['mask'],
  'cleanser':    ['cleanser', 'exfoliant'],
  'sunscreen':   ['sunscreen'],
  'eye_cream':   ['eye_cream', 'eye_care'],
  'lip_balm':    ['balm', 'lip_balm'],
  'makeup': [
    'foundation', 'bb_cream', 'cc_cream', 'concealer', 'powder',
    'blush', 'mascara', 'eyeliner', 'lipstick', 'lip_gloss',
    'primer', 'highlighter', 'bronzer', 'eyeshadow',
  ],
};

const Map<String, Map<String, String>> _kCategoryLabels = {
  'all':         {'en': 'All',        'ru': 'Все',              'es': 'Todo'},
  'serum':       {'en': 'Serum',      'ru': 'Сыворотки',        'es': 'Sérum'},
  'toner':       {'en': 'Toner',      'ru': 'Тоники',           'es': 'Tónico'},
  'moisturizer': {'en': 'Moisturizer','ru': 'Кремы',            'es': 'Hidratante'},
  'mask':        {'en': 'Mask',       'ru': 'Маски',            'es': 'Mascarilla'},
  'cleanser':    {'en': 'Cleanser',   'ru': 'Очищение',         'es': 'Limpiador'},
  'sunscreen':   {'en': 'Sunscreen',  'ru': 'Санскрин',         'es': 'Protector solar'},
  'eye_cream':   {'en': 'Eye Care',   'ru': 'Уход за глазами',  'es': 'Contorno de ojos'},
  'lip_balm':    {'en': 'Lip & Balm', 'ru': 'Губы и бальзамы', 'es': 'Labios y bálsamos'},
  'makeup':      {'en': 'Makeup',     'ru': 'Макияж',           'es': 'Maquillaje'},
};

const List<String> _kFilterChips = [
  'all', 'serum', 'toner', 'moisturizer', 'mask',
  'cleanser', 'sunscreen', 'eye_cream', 'lip_balm', 'makeup',
];

class TopratedWidget extends StatefulWidget {
  const TopratedWidget({super.key});

  static String routeName = 'Toprated';
  static String routePath = '/Toprated';

  @override
  State<TopratedWidget> createState() => _TopratedWidgetState();
}

class _TopratedWidgetState extends State<TopratedWidget> {
  late TopratedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TopratedModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.userrow = await UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull('id', currentUserUid),
      );
      final profileImg = _model.userrow?.firstOrNull?.profileImage;
      if (profileImg != null && profileImg.isNotEmpty) {
        FFAppState().userProfilePicture = profileImg;
      }

      _model.usersanswer2 = await UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull('id', currentUserUid),
      );
      if (_model.usersanswer2!.length <= 0) {
        context.pushNamed(LogInPageWidget.routeName);
        return;
      }

      // Load top-rated images once — filtered client-side afterwards.
      _model.allImages = await ImagesTable().queryRows(
        columns:
            'id,image_url,product_name,brand,sa_composite_score,user,language_code,product_type,sa_best_for_tags',
        queryFn: (q) => q
            .neqOrNull('user', currentUserUid)
            .gteOrNull('sa_composite_score', 70.0)
            .eqOrNull('language_code', FFLocalizations.of(context).languageCode)
            .order('sa_composite_score', ascending: false),
        limit: 50,
      );

      safeSetState(() {});

      if (_model.listViewController?.hasClients == true) {
        await _model.listViewController?.animateTo(
          0,
          duration: Duration(milliseconds: 100),
          curve: Curves.ease,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<ImagesRow> _filteredImages() {
    if (_model.allImages == null) return [];

    final spamIds = FFAppState().spamlist.toSet();

    final seen = <String>{};
    final deduped = _model.allImages!
        .where((row) => !spamIds.contains(row.id))
        .where((row) => seen.add(
            '${(row.brand ?? '').toLowerCase()}|${(row.productName ?? '').toLowerCase()}'))
        .toList();

    if (_model.selectedCategory == 'all') return deduped;

    final types = _kCategoryTypes[_model.selectedCategory] ?? [];
    return deduped
        .where((row) => types.contains(row.productType ?? ''))
        .toList();
  }

  List<String> _availableChips() {
    if (_model.allImages == null) return [_kFilterChips.first];
    final presentTypes = _model.allImages!.map((r) => r.productType ?? '').toSet();
    return _kFilterChips.where((catKey) {
      if (catKey == 'all') return true;
      final types = _kCategoryTypes[catKey] ?? [];
      return types.any((t) => presentTypes.contains(t));
    }).toList();
  }

  String _chipLabel(String catKey, String langCode) {
    final labels = _kCategoryLabels[catKey] ?? {};
    return labels[langCode] ?? labels['en'] ?? catKey;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final images = _filteredImages();
    final isLoading = _model.allImages == null;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: Stack(
            alignment: AlignmentDirectional(0.0, -1.0),
            children: [
              Padding(
                padding:
                    EdgeInsetsDirectional.fromSTEB(16.0, 64.0, 16.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    controller: _model.listViewController,
                    children: [
                      // ── Title ──────────────────────────────────────────
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText('s0iman0p'),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleLargeFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  useGoogleFonts:
                                      !FlutterFlowTheme.of(context)
                                          .titleLargeIsCustom,
                                ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 12.0, 16.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText('lhz5s19w'),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleLargeFamily,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts:
                                      !FlutterFlowTheme.of(context)
                                          .titleLargeIsCustom,
                                ),
                          ),
                        ),
                      ),
                      // ── Filter chips ───────────────────────────────────
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 16.0, 0.0, 5.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding:
                              EdgeInsetsDirectional.fromSTEB(16.0, 0, 16.0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _availableChips()
                                .map((catKey) {
                                  final isSelected =
                                      _model.selectedCategory == catKey;
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 8.0, 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        _model.selectedCategory = catKey;
                                        safeSetState(() {});
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 150),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          border: Border.all(
                                            color: isSelected
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Text(
                                          _chipLabel(catKey, FFLocalizations.of(context).languageCode),
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                fontSize: 13.0,
                                                color: isSelected
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .alternate
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                      // ── Grid ──────────────────────────────────────────
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        child: isLoading
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 60.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              )
                            : images.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 60.0),
                                      child: Text(
                                        FFLocalizations.of(context)
                                            .getText('xtop_empty'),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ),
                                  )
                                : MasonryGridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    gridDelegate:
                                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    crossAxisSpacing: 10.0,
                                    mainAxisSpacing: 10.0,
                                    itemCount: images.length,
                                    shrinkWrap: true,
                                    controller:
                                        _model.staggeredViewController,
                                    itemBuilder: (context, index) {
                                      final item = images[index];
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                            Itemcard2Widget.routeName,
                                            queryParameters: {
                                              'imageid': serializeParam(
                                                item.id,
                                                ParamType.int,
                                              ),
                                            }.withoutNulls,
                                          );
                                        },
                                        child: ImagedetailedTopRaitedWidget(
                                          key: Key(
                                              'Keyytw_${index}_of_${images.length}'),
                                          imageUrl: item.imageUrl,
                                          brand: item.brand,
                                          name: item.productName,
                                          score: item.saCompositeScore,
                                          imageID: item.id,
                                          tags: item.saBestForTags,
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.navbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NavbarWidget(activePage: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
