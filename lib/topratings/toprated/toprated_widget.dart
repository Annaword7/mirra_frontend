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

// Maps filter category key → list of product_type values it covers.
const Map<String, List<String>> _kCategoryTypes = {
  'serum': ['serum'],
  'toner': ['toner'],
  'moisturizer': ['moisturizer'],
  'mask': ['mask'],
  'cleanser': ['cleanser'],
  'sunscreen': ['sunscreen'],
  'eye_cream': ['eye_cream'],
  'makeup': [
    'foundation', 'bb_cream', 'cc_cream', 'concealer', 'powder',
    'blush', 'mascara', 'eyeliner', 'lipstick', 'lip_gloss',
    'primer', 'highlighter', 'bronzer', 'eyeshadow',
  ],
};

// Ordered list of (categoryKey, localizationKey) for the chip bar.
const List<(String, String)> _kFilterChips = [
  ('all',          't5l3cspz'),
  ('serum',        '4eemae24'),
  ('toner',        'ty7a9smo'),
  ('moisturizer',  'mubk0pfy'),
  ('mask',         'b652wlj0'),
  ('cleanser',     'pvpxd2wv'),
  ('sunscreen',    'oocbcr3w'),
  ('eye_cream',    '3dfv6cmb'),
  ('makeup',       'pt749ga9'),
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

    // Deduplicate by brand + product name — keep first occurrence (highest score).
    final seen = <String>{};
    final deduped = _model.allImages!
        .where((row) => seen.add(
            '${(row.brand ?? '').toLowerCase()}|${(row.productName ?? '').toLowerCase()}'))
        .toList();

    if (_model.selectedCategory == 'all') return deduped;

    final types = _kCategoryTypes[_model.selectedCategory] ?? [];
    return deduped
        .where((row) => types.contains(row.productType ?? ''))
        .toList();
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
                            0.0, 16.0, 0.0, 0.0),
                        child: SizedBox(
                          height: 36.0,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16.0, 0, 16.0, 0),
                            itemCount: _kFilterChips.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: 8.0),
                            itemBuilder: (context, index) {
                              final (catKey, locKey) = _kFilterChips[index];
                              final isSelected =
                                  _model.selectedCategory == catKey;
                              return GestureDetector(
                                onTap: () {
                                  _model.selectedCategory = catKey;
                                  safeSetState(() {});
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 150),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: isSelected
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context)
                                              .alternate,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    FFLocalizations.of(context).getText(locKey),
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          color: isSelected
                                              ? FlutterFlowTheme.of(context)
                                                  .alternate
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // ── Grid ──────────────────────────────────────────
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 12.0, 0.0, 0.0),
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
