import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'shareproduct_model.dart';
export 'shareproduct_model.dart';

class ShareproductWidget extends StatefulWidget {
  const ShareproductWidget({
    super.key,
    required this.imageid,
  });

  final int? imageid;

  static String routeName = 'Shareproduct';
  static String routePath = '/shareproduct';

  @override
  State<ShareproductWidget> createState() => _ShareproductWidgetState();
}

class _ShareproductWidgetState extends State<ShareproductWidget> {
  late ShareproductModel _model;
  late final Future<_ShareData> _dataFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ShareproductModel());
    _dataFuture = _loadShareData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<_ShareData> _loadShareData() async {
    final results = await Future.wait([
      ImagesTable().querySingleRow(
        queryFn: (q) => q.eqOrNull('id', widget.imageid),
      ),
      ImageTopIngredientsTable().queryRows(
        queryFn: (q) => q.eqOrNull('image_id', widget.imageid),
      ),
      ImageIngredientIssuesTable().queryRows(
        queryFn: (q) => q.eqOrNull('image_id', widget.imageid),
      ),
    ]);
    return _ShareData(
      imageRow: (results[0] as List<ImagesRow>).firstOrNull,
      topIngredients: (results[1] as List<ImageTopIngredientsRow>)
          .map((r) => r.ingredientName.toLowerCase().trim())
          .toList(),
      issueIngredients: (results[2] as List<ImageIngredientIssuesRow>)
          .map((r) => r.ingredientName.toLowerCase().trim())
          .toList(),
    );
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
        backgroundColor: FlutterFlowTheme.of(context).alternate,
        body: SafeArea(
          top: true,
          child: FutureBuilder<_ShareData>(
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
              final data = snapshot.data!;
              final containerImagesRow = data.imageRow;

              return Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 1.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.safePop();
                              },
                              child: SizedBox(
                                width: 44.0,
                                height: 44.0,
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color:
                                        FlutterFlowTheme.of(context).primaryText,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: custom_widgets.ShareCardWidget(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 1.0,
                          productName: valueOrDefault<String>(
                            containerImagesRow?.productName,
                            'None',
                          ),
                          brandName: valueOrDefault<String>(
                            containerImagesRow?.brand,
                            'No Brand',
                          ),
                          imageUrl: valueOrDefault<String>(
                            containerImagesRow?.imageUrl,
                            'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
                          ),
                          score: valueOrDefault<double>(
                            containerImagesRow?.saCompositeScore,
                            0.00,
                          ),
                          safetyScore: containerImagesRow?.saSafetyScore ?? 0.0,
                          efficacyScore: containerImagesRow?.saEfficacyScore ?? 0.0,
                          stabilityScore: containerImagesRow?.saStabilityScore,
                          uxScore: containerImagesRow?.saUxScore,
                          comedogenicityScore: containerImagesRow?.saComedogenicityScore,
                          ingredients: containerImagesRow?.ingredients ?? '',
                          topIngredients: data.topIngredients,
                          issueIngredients: data.issueIngredients,
                          isStory: false,
                          tags: containerImagesRow?.skinTypeTags ?? const [],
                          verdict: valueOrDefault<String>(
                            containerImagesRow?.saRatingText,
                            '',
                          ),
                          lang: FFLocalizations.of(context).languageCode,
                          imageId: widget.imageid ?? 0,
                          bestForTags: containerImagesRow?.saBestForTags ?? const [],
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShareData {
  final ImagesRow? imageRow;
  final List<String> topIngredients;
  final List<String> issueIngredients;

  const _ShareData({
    required this.imageRow,
    required this.topIngredients,
    required this.issueIngredients,
  });
}
