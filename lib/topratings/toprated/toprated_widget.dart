import 'dart:async';

import '/design_system/components/screen_loader.dart';
import '/app_state.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/database/tables/product_prices.dart';
import '/backend/supabase/supabase.dart';
import '/components/navbar/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
import '/design_system/components/product_tile.dart';
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

// Category filter labels are centralized in kTranslationsMap as 'cat_<key>'.

const List<String> _kFilterChips = [
  'all', 'serum', 'toner', 'moisturizer', 'mask',
  'cleanser', 'sunscreen', 'eye_cream', 'lip_balm', 'makeup',
];

// Facet groups for the filter sheet
const _kSheetFacets = [
  ('form',              ['serum','toner','cream','mask','cleanser','sunscreen','eye_cream','exfoliant','balm']),
  ('goal',              ['hydration','anti_aging','pigmentation','acne','pores','barrier']),
  ('active',            ['niacinamide','retinol','vitamin_c','hyaluronic_acid','ceramide','peptide','salicylic_acid','azelaic_acid','centella','squalane']),
  ('composition_flags', ['no_fragrance','no_essential_oils','no_denat_alcohol']),
];

// Всё, что не буква и не цифра, схлопывается в пробел: 'dr. althea' и
// 'dr.althea', 'pdrn 100+' и 'pdrn 100' должны давать один ключ дедупа.
final RegExp _kNonAlnum = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

// Сколько карточек добавляем за один «догруз» при скролле.
const int _kPageSize = 40;

const _kSortOptions = [
  ('fit',        'По совместимости', 'Best match'),
  ('formula',    'По формуле',       'By formula'),
  ('price_asc',  'Дешевле',          'Price ↑'),
  ('price_desc', 'Дороже',           'Price ↓'),
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

  /// Подборка, загруженная в этой сессии: экран пересоздаётся при каждом
  /// переключении вкладки, а модель вместе с ним — без этого кэша выдача
  /// перезагружается с нуля каждый раз. Ключ — язык: выборка отфильтрована
  /// по нему на сервере.
  static List<ImagesRow>? _sessionImages;
  static String _sessionImagesLang = '';

  // ── Filter state ──────────────────────────────────────────────────────────
  Map<String, Set<String>> _activeFacets = {};
  String _filterSort = 'fit';
  List<Map<String, dynamic>>? _searchResults;
  bool _isSearching = false;

  // Список отдаётся целиком, но рендерим порциями по мере скролла.
  int _visibleCount = _kPageSize;
  int _totalCount = 0;

  bool get _hasFilters => _activeFacets.values.any((s) => s.isNotEmpty);

  Future<void> _applyFilters(Map<String, Set<String>> facets, String sort) async {
    setState(() {
      _activeFacets = facets;
      _filterSort   = sort;
    });

    if (!_hasFilters) {
      setState(() {
        _searchResults = null;
        _isSearching = false;
        _visibleCount = _kPageSize;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = null;
      _visibleCount = _kPageSize;
    });
    try {
      final facetsBody = {
        for (final e in facets.entries)
          if (e.value.isNotEmpty) e.key: e.value.toList()
      };
      final resp = await SearchProductsCall.call(
        token: currentJwtToken,
        facets: facetsBody,
        sort: sort,
        // Потолок поискового индекса — берём выдачу целиком, одной страницей;
        // на экран она выдаётся порциями по мере скролла.
        limit: 1000,
      );
      if (!mounted) return;
      if (resp.succeeded) {
        // Порядок сортировки задан бэкендом — из дублей остаётся первый,
        // то есть лучший по выбранной сортировке.
        final seen = <String>{};
        final rows = ((resp.jsonBody as Map)['results'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            // Каталожное фото отсекает бэкенд; страховка на случай старой версии.
            .where((r) => (r['image_url'] as String? ?? '').isNotEmpty)
            .where((r) => seen.add(
                _dedupKey(r['brand'] as String?, r['product_name'] as String?)))
            .toList();
        setState(() { _searchResults = rows; _isSearching = false; });
      } else {
        setState(() => _isSearching = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showFilterSheet() {
    var tempFacets = Map<String, Set<String>>.from(
      _activeFacets.map((k, v) => MapEntry(k, Set<String>.from(v))),
    );
    var tempSort = _filterSort;
    final theme = FlutterFlowTheme.of(context);
    final lang  = FFLocalizations.of(context).languageCode;

    String _facetLabel(String facet) => switch (facet) {
      'form'              => lang == 'ru' ? 'Тип' : 'Form',
      'goal'              => lang == 'ru' ? 'Цель' : 'Goal',
      'active'            => lang == 'ru' ? 'Активные' : 'Actives',
      'composition_flags' => lang == 'ru' ? 'Состав' : 'Formula',
      _                   => facet,
    };

    String _valueLabel(String v) => switch (v) {
      'serum'             => lang == 'ru' ? 'Сыворотка' : 'Serum',
      'toner'             => lang == 'ru' ? 'Тоник' : 'Toner',
      'cream'             => lang == 'ru' ? 'Крем' : 'Cream',
      'mask'              => lang == 'ru' ? 'Маска' : 'Mask',
      'cleanser'          => lang == 'ru' ? 'Очищение' : 'Cleanser',
      'sunscreen'         => lang == 'ru' ? 'Санскрин' : 'Sunscreen',
      'eye_cream'         => lang == 'ru' ? 'Для глаз' : 'Eye cream',
      'exfoliant'         => lang == 'ru' ? 'Эксфолиант' : 'Exfoliant',
      'balm'              => lang == 'ru' ? 'Бальзам' : 'Balm',
      'hydration'         => lang == 'ru' ? 'Увлажнение' : 'Hydration',
      'anti_aging'        => lang == 'ru' ? 'Антивозраст' : 'Anti-aging',
      'pigmentation'      => lang == 'ru' ? 'Пигментация' : 'Pigmentation',
      'acne'              => lang == 'ru' ? 'Акне' : 'Acne',
      'pores'             => lang == 'ru' ? 'Поры' : 'Pores',
      'barrier'           => lang == 'ru' ? 'Барьер' : 'Barrier',
      'niacinamide'       => 'Niacinamide',
      'retinol'           => 'Retinol',
      'vitamin_c'         => 'Vitamin C',
      'hyaluronic_acid'   => lang == 'ru' ? 'Гиалуронка' : 'Hyaluronic',
      'ceramide'          => lang == 'ru' ? 'Керамиды' : 'Ceramide',
      'peptide'           => lang == 'ru' ? 'Пептиды' : 'Peptide',
      'salicylic_acid'    => lang == 'ru' ? 'Салицилка' : 'Salicylic',
      'azelaic_acid'      => lang == 'ru' ? 'Азелаинка' : 'Azelaic',
      'centella'          => 'Centella',
      'squalane'          => 'Squalane',
      'no_fragrance'      => lang == 'ru' ? 'Без отдушек' : 'Fragrance-free',
      'no_essential_oils' => lang == 'ru' ? 'Без эф. масел' : 'No ess. oils',
      'no_denat_alcohol'  => lang == 'ru' ? 'Без спирта' : 'No alcohol',
      _                   => v,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: theme.secondaryText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(lang == 'ru' ? 'Фильтры' : 'Filters',
                          style: theme.titleMedium.override(
                            fontFamily: theme.titleMediumFamily,
                            fontWeight: FontWeight.w700, letterSpacing: 0,
                            useGoogleFonts: !theme.titleMediumIsCustom,
                          )),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheet(() => tempFacets.clear());
                          Navigator.of(ctx).pop();
                          _applyFilters({}, tempSort);
                        },
                        child: Text(lang == 'ru' ? 'Сбросить' : 'Reset',
                            style: TextStyle(color: theme.primary)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    children: [
                      // Facet groups
                      for (final (facetKey, values) in _kSheetFacets) ...[
                        Text(_facetLabel(facetKey),
                            style: theme.bodyMedium.override(
                              fontFamily: theme.bodyMediumFamily,
                              fontWeight: FontWeight.w600, letterSpacing: 0,
                              useGoogleFonts: !theme.bodyMediumIsCustom,
                            )),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: values.map((v) {
                            final sel = tempFacets[facetKey]?.contains(v) ?? false;
                            return GestureDetector(
                              onTap: () => setSheet(() {
                                final s = tempFacets.putIfAbsent(facetKey, () => {});
                                if (sel) { s.remove(v); if (s.isEmpty) tempFacets.remove(facetKey); }
                                else s.add(v);
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? theme.primary : theme.surfaceMuted,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_valueLabel(v),
                                    style: theme.bodySmall.override(
                                      fontFamily: theme.bodySmallFamily,
                                      color: sel ? Colors.white : theme.primaryText,
                                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                                      letterSpacing: 0,
                                      useGoogleFonts: !theme.bodySmallIsCustom,
                                    )),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Sort
                      Text(lang == 'ru' ? 'Сортировка' : 'Sort',
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w600, letterSpacing: 0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          )),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _kSortOptions.map((opt) {
                          final (key, labelRu, labelEn) = opt;
                          final sel = tempSort == key;
                          return GestureDetector(
                            onTap: () => setSheet(() => tempSort = key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel ? theme.primary : theme.surfaceMuted,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(lang == 'ru' ? labelRu : labelEn,
                                  style: theme.bodySmall.override(
                                    fontFamily: theme.bodySmallFamily,
                                    color: sel ? Colors.white : theme.primaryText,
                                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                                    letterSpacing: 0,
                                    useGoogleFonts: !theme.bodySmallIsCustom,
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // Apply button
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
                  child: SizedBox(
                    width: double.infinity, height: 52,
                    child: AppButton(
                      label: lang == 'ru' ? 'Применить' : 'Apply',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _applyFilters(tempFacets, tempSort);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TopratedModel());
    _model.listViewController?.addListener(_onScroll);

    // Прошлая выдача показывается сразу, обновление идёт фоном: подборка
    // меняется медленно, а спиннер на каждый вход по ней — самое заметное
    // ожидание на вкладке. Язык здесь ещё не прочитать (нет доступа к
    // InheritedWidget), поэтому несовпадение отсекается кадром позже.
    _model.allImages = _sessionImages;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (_sessionImagesLang != FFLocalizations.of(context).languageCode) {
        _model.allImages = null;
        safeSetState(() {});
      }
      // Один запрос профиля на оба использования: раньше строка юзера
      // читалась дважды подряд одним и тем же запросом.
      _model.userrow = await UsersTable().queryRows(
        queryFn: (q) => q.eqOrNull('id', currentUserUid),
      );
      final profileImg = _model.userrow?.firstOrNull?.profileImage;
      if (profileImg != null && profileImg.isNotEmpty) {
        FFAppState().userProfilePicture = profileImg;
      }

      _model.usersanswer2 = _model.userrow;
      if (!mounted) return;
      if (_model.usersanswer2!.length <= 0) {
        context.pushNamed(LogInPageWidget.routeName);
        return;
      }

      // Load top-rated images once — filtered client-side afterwards.
      if (!mounted) return;
      _model.allImages = await ImagesTable().queryRows(
        // Чужие продукты: показываем каталожное фото (публичное), а не
        // приватный скан владельца (image_url). Без каталожного фото продукт
        // в Top Rated не попадает — заплатки не показываем.
        columns:
            'id,catalog_image_url,product_name,brand,sa_composite_score,product_type',
        queryFn: (q) => q
            .neqOrNull('user', currentUserUid)
            .not('catalog_image_url', 'is', null)
            .neq('catalog_image_url', '')
            .gteOrNull('sa_composite_score', 70.0)
            .eqOrNull('language_code', FFLocalizations.of(context).languageCode)
            .order('sa_composite_score', ascending: false),
      );

      _sessionImages = _model.allImages;
      _sessionImagesLang = FFLocalizations.of(context).languageCode;

      safeSetState(() {});

      // Цены не держат выдачу: карточки уже видны, цена появляется следом.
      unawaited(_loadPricesForVisible());

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
    _model.listViewController?.removeListener(_onScroll);
    _model.dispose();
    super.dispose();
  }

  void _onScroll() {
    final ctrl = _model.listViewController;
    if (ctrl == null || !ctrl.hasClients || _visibleCount >= _totalCount) return;
    final pos = ctrl.position;
    if (pos.pixels < pos.maxScrollExtent - 600) return;
    safeSetState(() {
      _visibleCount = (_visibleCount + _kPageSize).clamp(0, _totalCount);
    });
    unawaited(_loadPricesForVisible());
  }

  /// Цены для показанной порции выдачи. Раньше запрашивались сразу для всей
  /// подборки (сотни товаров, несколько запросов подряд) и держали экран, хотя
  /// на первом экране видно два десятка карточек.
  Future<void> _loadPricesForVisible() async {
    if (_model.allImages == null) return;
    // Именно показанные карточки: выдача проходит дедуп и фильтр по категории.
    await _loadPriceMap(_filteredImages().take(_visibleCount).toList());
    if (mounted) safeSetState(() {});
  }

  final Set<String> _pricedKeys = {};

  Future<void> _loadPriceMap(List<ImagesRow> images) async {
    final countryCode = FFAppState().countrycodeiso;
    if (countryCode.isEmpty || !mounted) return;

    final nameKeys = images
        .map((r) => (r.productName ?? '').toLowerCase().trim())
        .where((s) => s.isNotEmpty && !_pricedKeys.contains(s))
        .toSet()
        .toList();

    if (nameKeys.isEmpty) return;
    _pricedKeys.addAll(nameKeys);

    // Ключей могут быть сотни — режем на пачки, иначе in-фильтр не влезает в URL.
    const chunkSize = 100;
    final prices = <ProductPricesRow>[];
    for (var i = 0; i < nameKeys.length; i += chunkSize) {
      final chunk = nameKeys.sublist(
          i, (i + chunkSize).clamp(0, nameKeys.length));
      prices.addAll(await ProductPricesTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('country_code', countryCode)
            .inFilterOrNull('product_name_key', chunk),
      ));
      if (!mounted) return;
    }

    _model.priceMap = {
      ..._model.priceMap,
      for (final p in prices) '${p.productNameKey}|${p.brandKey}': p,
    };
  }

  static String _normalized(String? s) =>
      (s ?? '').toLowerCase().replaceAll(_kNonAlnum, ' ').trim();

  // Ключ дедупа: нормализованный бренд + название без дублирующего
  // бренд-префикса ('celimax | celimax pore cream' == 'celimax | pore cream').
  static String _dedupKey(String? rawBrand, String? rawName) {
    final brand = _normalized(rawBrand);
    var name = _normalized(rawName);
    if (brand.isNotEmpty && name.startsWith('$brand ')) {
      name = name.substring(brand.length + 1);
    }
    return '$brand|$name';
  }

  List<ImagesRow> _filteredImages() {
    if (_model.allImages == null) return [];

    final spamIds = FFAppState().spamlist.toSet();

    final seen = <String>{};
    final deduped = _model.allImages!
        .where((row) => !spamIds.contains(row.id))
        .where((row) => seen.add(_dedupKey(row.brand, row.productName)))
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
    final label = FFLocalizations.of(context).getText('cat_$catKey');
    return label.isEmpty ? catKey : label;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final images = _filteredImages();
    final isLoading = _model.allImages == null;

    // Порционный рендер общий для обоих списков — какой показан, тот и считаем.
    final showingSearch = _hasFilters && _searchResults != null;
    _totalCount = showingSearch ? _searchResults!.length : images.length;
    final visible = _visibleCount < _totalCount ? _visibleCount : _totalCount;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: Stack(
            alignment: AlignmentDirectional(0.0, -1.0),
            children: [
              Padding(
                padding:
                    EdgeInsetsDirectional.fromSTEB(0.0, 64.0, 0.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    controller: _model.listViewController,
                    children: [
                      // ── Title + filter icon ────────────────────────────
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FFLocalizations.of(context).getText('s0iman0p'),
                                    style: FlutterFlowTheme.of(context).titleLarge.override(
                                      fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                                      letterSpacing: 0, fontWeight: FontWeight.w700,
                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleLargeIsCustom,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    FFLocalizations.of(context).getText('lhz5s19w'),
                                    style: FlutterFlowTheme.of(context).titleLarge.override(
                                      fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                                      fontSize: 16, letterSpacing: 0, fontWeight: FontWeight.normal,
                                      useGoogleFonts: !FlutterFlowTheme.of(context).titleLargeIsCustom,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _showFilterSheet,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: _hasFilters
                                          ? FlutterFlowTheme.of(context).primary.withOpacity(0.12)
                                          : FlutterFlowTheme.of(context).surfaceMuted,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      size: 22,
                                      color: _hasFilters
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context).primaryText,
                                    ),
                                  ),
                                  if (_hasFilters)
                                    Positioned(
                                      top: 0, right: 0,
                                      child: Container(
                                        width: 10, height: 10,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: FlutterFlowTheme.of(context).primaryBackground, width: 1.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Grid / Search results ─────────────────────────
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        // Спиннер поиска рисуется поверх экрана (см. Stack ниже),
                        // а не в потоке списка — иначе его положение зависело бы
                        // от высоты шапки и фильтров.
                        child: _isSearching
                            ? const SizedBox.shrink()
                            : _hasFilters && _searchResults != null
                                ? _searchResults!.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 60),
                                          child: Text(
                                            FFLocalizations.of(context).languageCode == 'ru'
                                                ? 'Ничего не найдено'
                                                : 'No results found',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              letterSpacing: 0,
                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                            ),
                                          ),
                                        ),
                                      )
                                    : MasonryGridView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                        itemCount: visible,
                                        itemBuilder: (context, i) {
                                          final r = _searchResults![i];
                                          final imageId = r['image_id'] as int?;
                                          return GestureDetector(
                                            onTap: imageId == null ? null : () => context.pushNamed(
                                              Itemcard2Widget.routeName,
                                              queryParameters: {
                                                'imageid': serializeParam(imageId, ParamType.int),
                                              }.withoutNulls,
                                            ),
                                            child: ProductTile(
                                              imageUrl:  r['image_url']    as String?,
                                              brand:     r['brand']        as String?,
                                              name:      r['product_name'] as String?,
                                              score:     ((r['composite_score'] ?? r['fit_score']) as num?)?.toDouble(),
                                              variant: ProductTileVariant.plain,
                                            ),
                                          );
                                        },
                                      )
                                : isLoading
                            ? const SizedBox.shrink()
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
                                    itemCount: visible,
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
                                        child: ProductTile(
                                          key: Key(
                                              'Keyytw_${index}_of_${images.length}'),
                                          imageUrl: item.catalogImageUrl,
                                          brand: item.brand,
                                          name: item.productName,
                                          score: item.saCompositeScore,
                                          variant: ProductTileVariant.plain,
                                          avgPrice: _model.priceMap['${(item.productName ?? '').toLowerCase().trim()}|${(item.brand ?? '').toLowerCase().trim()}']?.avgPrice,
                                          priceCurrencyCode: _model.priceMap['${(item.productName ?? '').toLowerCase().trim()}|${(item.brand ?? '').toLowerCase().trim()}']?.priceCurrencyCode,
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isSearching || isLoading)
                const Positioned.fill(child: ScreenLoader()),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.navbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NavbarWidget(
                    activePage: 1,
                    onScrollToTop: () => _model.listViewController?.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
