import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/domain/products/product_photo.dart';
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
    final topRows = results[1] as List<ImageTopIngredientsRow>;
    return _ShareData(
      imageRow: (results[0] as List<ImagesRow>).firstOrNull,
      topRows: topRows,
      topIngredients:
          topRows.map((r) => r.ingredientName.toLowerCase().trim()).toList(),
      issueIngredients: (results[2] as List<ImageIngredientIssuesRow>)
          .map((r) => r.ingredientName.toLowerCase().trim())
          .toList(),
    );
  }

  /// INCI по позициям: массив бэкенда, иначе split без разрыва «1,2-Hexanediol».
  static List<String> _inciOf(ImagesRow? row) {
    if (row == null) return const [];
    if (row.saInciList.isNotEmpty) {
      return row.saInciList
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return (row.ingredients ?? '')
        .split(RegExp(r',(?!\s*\d)|\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Герой share-карточки: актив ниже рабочей дозы (сначала decorative, потом
  /// borderline), иначе первый рабочий. Открытие важнее скора.
  static ImageTopIngredientsRow? _keyActive(List<ImageTopIngredientsRow> rows) {
    for (final status in const ['decorative', 'borderline', 'working']) {
      for (final r in rows) {
        if (r.status == status) return r;
      }
    }
    return null;
  }

  static int? _positionOf(ImageTopIngredientsRow? ing, List<String> inci) {
    if (ing == null) return null;
    if (ing.inciPosition != null) return ing.inciPosition;
    final name = ing.ingredientName.toLowerCase().trim();
    for (var i = 0; i < inci.length; i++) {
      final n = inci[i].toLowerCase();
      if (n == name || n.contains(name) || name.contains(n)) return i + 1;
    }
    return null;
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
              final inci = _inciOf(containerImagesRow);
              final keyActive = _keyActive(data.topRows);
              final withStatus =
                  data.topRows.where((r) => r.status != null).toList();

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
                            containerImagesRow?.displayPhotoUrl,
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
                          // Открытие вместо скора: колба этого продукта и
                          // позиция ключевого актива (раздел 14 документа V).
                          inciList: inci,
                          onePercentLinePos:
                              containerImagesRow?.saOnePercentLinePos,
                          keyActiveName: keyActive?.ingredientName,
                          keyActivePosition: _positionOf(keyActive, inci),
                          keyActiveStatus: keyActive?.status,
                          promisedAllWorking: withStatus.isNotEmpty &&
                              withStatus.every((r) => r.status == 'working'),
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
  final List<ImageTopIngredientsRow> topRows;
  final List<String> topIngredients;
  final List<String> issueIngredients;

  const _ShareData({
    required this.imageRow,
    required this.topRows,
    required this.topIngredients,
    required this.issueIngredients,
  });
}
