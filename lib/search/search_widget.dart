import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/database/tables/users.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/item_card/imagedetailed_main/imagedetailed_main_widget.dart';
import 'search_model.dart';
export 'search_model.dart';

import 'package:flutter/material.dart';

// ── Vocabulary (mirrors backend search_facets.py) ────────────────────────────

const List<Map<String, Object>> _kFacetGroups = [
  {
    'name': 'form',
    'values': <String>[
      'serum', 'cream', 'gel_cream', 'toner', 'oil',
      'mask', 'cleanser', 'sunscreen', 'eye_cream', 'exfoliant',
    ],
  },
  {
    'name': 'goal',
    'values': <String>[
      'hydration', 'anti_aging', 'pigmentation', 'acne', 'barrier', 'pores',
    ],
  },
  {
    'name': 'active',
    'values': <String>[
      'retinol', 'niacinamide', 'vitamin_c', 'bakuchiol',
      'hyaluronic_acid', 'ceramide', 'peptide',
      'salicylic_acid', 'glycolic_acid', 'azelaic_acid',
    ],
  },
  {
    'name': 'composition_flags',
    'values': <String>[
      'no_fragrance', 'no_denat_alcohol', 'no_essential_oils', 'vegan',
    ],
  },
  {
    'name': 'time_of_day',
    'values': <String>['am', 'pm'],
  },
  {
    'name': 'price_band',
    'values': <String>['budget', 'mid', 'premium', 'luxury'],
  },
];

const _kSortModes = <String>['fit', 'formula', 'price_asc', 'price_desc'];

// ── Label helpers ─────────────────────────────────────────────────────────────

String _groupLabel(String name, String lang) {
  const m = <String, Map<String, String>>{
    'form':              {'en': 'Form',       'ru': 'Форма',    'es': 'Tipo'},
    'goal':              {'en': 'Goal',       'ru': 'Цель',     'es': 'Objetivo'},
    'active':            {'en': 'Actives',    'ru': 'Активы',   'es': 'Activos'},
    'composition_flags': {'en': 'Free from',  'ru': 'Без',      'es': 'Sin'},
    'time_of_day':       {'en': 'Time of day','ru': 'Время',    'es': 'Momento'},
    'price_band':        {'en': 'Price',      'ru': 'Цена',     'es': 'Precio'},
  };
  return m[name]?[lang] ?? m[name]?['en'] ?? name;
}

String _valueLabel(String value, String lang) {
  const m = <String, Map<String, String>>{
    // form
    'serum':      {'en': 'Serum',       'ru': 'Сыворотка'},
    'cream':      {'en': 'Cream',       'ru': 'Крем'},
    'gel_cream':  {'en': 'Gel-cream',   'ru': 'Гель-крем'},
    'toner':      {'en': 'Toner',       'ru': 'Тоник'},
    'oil':        {'en': 'Oil',         'ru': 'Масло'},
    'mask':       {'en': 'Mask',        'ru': 'Маска'},
    'cleanser':   {'en': 'Cleanser',    'ru': 'Очищение'},
    'sunscreen':  {'en': 'Sunscreen',   'ru': 'Санскрин'},
    'eye_cream':  {'en': 'Eye cream',   'ru': 'Крем для глаз'},
    'exfoliant':  {'en': 'Exfoliant',   'ru': 'Пилинг'},
    // goal
    'hydration':    {'en': 'Hydration',  'ru': 'Увлажнение'},
    'anti_aging':   {'en': 'Anti-aging', 'ru': 'Антивозраст'},
    'pigmentation': {'en': 'Brightening','ru': 'Осветление'},
    'acne':         {'en': 'Acne',       'ru': 'Акне'},
    'barrier':      {'en': 'Barrier',    'ru': 'Барьер'},
    'pores':        {'en': 'Pores',      'ru': 'Поры'},
    // active
    'retinol':        {'en': 'Retinol',    'ru': 'Ретинол'},
    'niacinamide':    {'en': 'Niacinamide','ru': 'Ниацинамид'},
    'vitamin_c':      {'en': 'Vitamin C',  'ru': 'Витамин C'},
    'bakuchiol':      {'en': 'Bakuchiol',  'ru': 'Бакучиол'},
    'hyaluronic_acid':{'en': 'Hyaluronic', 'ru': 'Гиалурон'},
    'ceramide':       {'en': 'Ceramide',   'ru': 'Церамиды'},
    'peptide':        {'en': 'Peptide',    'ru': 'Пептиды'},
    'salicylic_acid': {'en': 'BHA',        'ru': 'BHA'},
    'glycolic_acid':  {'en': 'AHA',        'ru': 'AHA'},
    'azelaic_acid':   {'en': 'Azelaic',    'ru': 'Азелаин'},
    // composition flags
    'no_fragrance':      {'en': 'Fragrance-free', 'ru': 'Без отдушек'},
    'no_denat_alcohol':  {'en': 'Alcohol-free',   'ru': 'Без спирта'},
    'no_essential_oils': {'en': 'No ess. oils',   'ru': 'Без эф. масел'},
    'vegan':             {'en': 'Vegan',           'ru': 'Веган'},
    // time
    'am': {'en': 'Morning', 'ru': 'Утром'},
    'pm': {'en': 'Night',   'ru': 'Ночью'},
    // price
    'budget':  {'en': 'Budget',    'ru': 'Бюджет'},
    'mid':     {'en': 'Mid-range', 'ru': 'Средний'},
    'premium': {'en': 'Premium',   'ru': 'Премиум'},
    'luxury':  {'en': 'Luxury',    'ru': 'Люкс'},
  };
  return m[value]?[lang] ?? m[value]?['en'] ?? value;
}

String _sortLabel(String sort, String lang) {
  const m = <String, Map<String, String>>{
    'fit':        {'en': '✦ Best fit',   'ru': '✦ Подбор'},
    'formula':    {'en': 'By score',     'ru': 'По оценке'},
    'price_asc':  {'en': 'Cheapest',     'ru': 'Дешевле'},
    'price_desc': {'en': 'Premium',      'ru': 'Дороже'},
  };
  return m[sort]?[lang] ?? sort;
}

// ── Widget ────────────────────────────────────────────────────────────────────

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  static String routeName = 'Search';
  static String routePath = '/search';

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late SearchModel _model;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Profile ──────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    try {
      final rows = await UsersTable().queryRows(
        queryFn: (q) => q.eq('id', currentUserUid).limit(1),
      );
      if (rows.isNotEmpty && mounted) setState(() => _model.userProfile = rows.first);
    } catch (_) {}
  }

  // ── NL parse ─────────────────────────────────────────────────────────────────

  Future<void> _parsePhrase() async {
    final phrase = _model.phraseController?.text.trim() ?? '';
    if (phrase.isEmpty) return;
    setState(() { _model.isParsing = true; _model.unparsed = ''; });

    try {
      final resp = await ParseSearchPhraseCall.call(
        token: currentJwtToken,
        phrase: phrase,
        lang: FFLocalizations.of(context).languageCode,
      );
      if (!mounted) return;
      if (resp.succeeded) {
        final body = resp.jsonBody as Map<String, dynamic>;
        final newFacets = Map<String, Set<String>>.from(_model.activeFacets);
        for (final f in (body['facets'] as List? ?? [])) {
          final facet = f['facet'] as String?;
          final val   = f['value'] as String?;
          if (facet != null && val != null) {
            newFacets.putIfAbsent(facet, () => {}).add(val);
          }
        }
        setState(() {
          _model.activeFacets = newFacets;
          _model.unparsed     = (body['unparsed'] as String?)?.trim() ?? '';
          _model.sortMode     = (body['sort'] as String?) ?? 'fit';
          _model.isParsing    = false;
        });
        if (mounted) _search();
      } else {
        setState(() => _model.isParsing = false);
      }
    } catch (_) {
      if (mounted) setState(() => _model.isParsing = false);
    }
  }

  // ── Search ───────────────────────────────────────────────────────────────────

  Future<void> _search({bool loadMore = false}) async {
    setState(() {
      _model.isSearching = true;
      if (!loadMore) { _model.results = []; _model.nextCursor = null; _model.narrowestFacet = null; }
    });

    try {
      final resp = await SearchProductsCall.call(
        token: currentJwtToken,
        facets: _model.buildFacetsBody(),
        sort: _model.sortMode,
        profile: _model.buildProfile(),
        cursor: loadMore ? _model.nextCursor : null,
        limit: 20,
      );
      if (!mounted) return;
      if (resp.succeeded) {
        final body = resp.jsonBody as Map<String, dynamic>;
        final newRows = (body['results'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        setState(() {
          if (loadMore) _model.results.addAll(newRows);
          else _model.results = List<Map<String, dynamic>>.from(newRows);
          _model.totalCount     = (body['total']           as int?)    ?? 0;
          _model.nextCursor     = body['cursor']           as String?;
          _model.hasMore        = (body['has_more']        as bool?)   ?? false;
          _model.narrowestFacet = body['narrowest_facet']  as String?;
          _model.hasSearched    = true;
          _model.isSearching    = false;
        });
      } else {
        setState(() => _model.isSearching = false);
      }
    } catch (_) {
      if (mounted) setState(() => _model.isSearching = false);
    }
  }

  void _toggleFacet(String facet, String value) {
    setState(() {
      final s = _model.activeFacets.putIfAbsent(facet, () => {});
      if (s.contains(value)) {
        s.remove(value);
        if (s.isEmpty) _model.activeFacets.remove(facet);
      } else {
        s.add(value);
      }
    });
  }

  void _clearAll() => setState(() {
        _model.activeFacets = {};
        _model.phraseController?.clear();
        _model.unparsed = '';
        _model.results = [];
        _model.hasSearched = false;
        _model.narrowestFacet = null;
      });

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final lang  = FFLocalizations.of(context).languageCode;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryText, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            lang == 'ru' ? 'Поиск продуктов' : lang == 'es' ? 'Buscar productos' : 'Find products',
            style: theme.headlineSmall,
          ),
          actions: [
            if (_model.hasAnyFacet)
              TextButton(
                onPressed: _clearAll,
                child: Text(
                  lang == 'ru' ? 'Сбросить' : 'Clear',
                  style: TextStyle(color: theme.primary, fontSize: 14),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhraseInput(theme, lang),
              const SizedBox(height: 20),
              _buildSortRow(theme, lang),
              const SizedBox(height: 16),
              ..._kFacetGroups.map((g) => _buildFacetGroup(
                    g['name'] as String,
                    (g['values'] as List).cast<String>(),
                    theme,
                    lang,
                  )),
              const SizedBox(height: 24),
              _buildSearchButton(theme, lang),
              const SizedBox(height: 24),
              if (_model.hasSearched) _buildResults(theme, lang),
            ],
          ),
        ),
      ),
    );
  }

  // ── Phrase input ──────────────────────────────────────────────────────────────

  Widget _buildPhraseInput(FlutterFlowTheme theme, String lang) {
    final hint = lang == 'ru'
        ? 'напр. ретинол сыворотка без отдушки...'
        : lang == 'es'
            ? 'ej. sérum con retinol sin fragancia...'
            : 'e.g. retinol serum fragrance-free...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang == 'ru' ? 'Поиск по описанию' : lang == 'es' ? 'Búsqueda por descripción' : 'Describe what you need',
          style: theme.labelMedium.override(
            fontFamily: theme.labelMediumFamily,
            color: theme.secondaryText,
            letterSpacing: 0,
            useGoogleFonts: !theme.labelMediumIsCustom,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _model.phraseController,
                focusNode: _model.phraseFocusNode,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _parsePhrase(),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText.withOpacity(0.5),
                    letterSpacing: 0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: theme.secondaryText, size: 20),
                  suffixIcon: _model.phraseController?.text.isNotEmpty == true
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: theme.secondaryText, size: 18),
                          onPressed: () => setState(() {
                                _model.phraseController?.clear();
                                _model.unparsed = '';
                              }),
                        )
                      : null,
                ),
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  letterSpacing: 0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _model.isParsing
                ? const SizedBox(
                    width: 44, height: 44,
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  )
                : ElevatedButton(
                    onPressed: _parsePhrase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      minimumSize: const Size(0, 44),
                    ),
                    child: Text('AI', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
          ],
        ),
        if (_model.unparsed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: theme.warning),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${lang == 'ru' ? 'Не распознано' : 'Not parsed'}: ${_model.unparsed}',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.warning,
                      fontSize: 12,
                      letterSpacing: 0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Sort row ──────────────────────────────────────────────────────────────────

  Widget _buildSortRow(FlutterFlowTheme theme, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang == 'ru' ? 'Сортировка' : lang == 'es' ? 'Orden' : 'Sort by',
          style: theme.labelMedium.override(
            fontFamily: theme.labelMediumFamily,
            color: theme.secondaryText,
            letterSpacing: 0,
            useGoogleFonts: !theme.labelMediumIsCustom,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _kSortModes.map((sort) {
              final isSelected = _model.sortMode == sort;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _chip(
                  label: _sortLabel(sort, lang),
                  isSelected: isSelected,
                  onTap: () => setState(() => _model.sortMode = sort),
                  theme: theme,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Facet group row ───────────────────────────────────────────────────────────

  Widget _buildFacetGroup(String facetName, List<String> values, FlutterFlowTheme theme, String lang) {
    final selected = _model.activeFacets[facetName] ?? {};
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _groupLabel(facetName, lang),
                style: theme.labelMedium.override(
                  fontFamily: theme.labelMediumFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0,
                  useGoogleFonts: !theme.labelMediumIsCustom,
                ),
              ),
              if (selected.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${selected.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: values.map((v) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _chip(
                  label: _valueLabel(v, lang),
                  isSelected: selected.contains(v),
                  onTap: () => _toggleFacet(facetName, v),
                  theme: theme,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chip helper ───────────────────────────────────────────────────────────────

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required FlutterFlowTheme theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primary : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            fontSize: 13,
            color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: 0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
      ),
    );
  }

  // ── Search button ─────────────────────────────────────────────────────────────

  Widget _buildSearchButton(FlutterFlowTheme theme, String lang) {
    final label = lang == 'ru' ? 'Найти' : lang == 'es' ? 'Buscar' : 'Search';
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _model.isSearching ? null : () => _search(),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          disabledBackgroundColor: theme.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _model.isSearching
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 0,
                  useGoogleFonts: !theme.titleSmallIsCustom,
                ),
              ),
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────────

  Widget _buildResults(FlutterFlowTheme theme, String lang) {
    if (_model.isSearching && _model.results.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: CircularProgressIndicator(),
      ));
    }

    if (_model.results.isEmpty) {
      return _buildEmptyState(theme, lang);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Count header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _countLabel(_model.totalCount, lang),
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              letterSpacing: 0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ),
        // Result cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _model.results.length,
          itemBuilder: (context, i) {
            final r = _model.results[i];
            final fitScore = r['fit_score'];
            final imageId = r['image_id'] as int?;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: imageId == null ? null : () => context.pushNamed(
                  Itemcard2Widget.routeName,
                  queryParameters: {
                    'imageid': serializeParam(imageId, ParamType.int),
                  }.withoutNulls,
                ),
                child: ImagedetailedMainWidget(
                  imageUrl:  r['image_url']    as String?,
                  brand:     r['brand']        as String?,
                  name:      r['product_name'] as String?,
                  score:     fitScore != null ? (fitScore as num).toDouble() : null,
                  imageID:   imageId,
                ),
              ),
            );
          },
        ),
        // Load more
        if (_model.hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _model.isSearching ? null : () => _search(loadMore: true),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _model.isSearching
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary))
                    : Text(
                        lang == 'ru' ? 'Загрузить ещё' : 'Load more',
                        style: TextStyle(color: theme.primary, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState(FlutterFlowTheme theme, String lang) {
    final hint = _model.narrowestFacet;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: theme.secondaryText.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              lang == 'ru' ? 'Ничего не найдено' : 'No results found',
              style: theme.titleSmall.override(
                fontFamily: theme.titleSmallFamily,
                color: theme.primaryText,
                letterSpacing: 0,
                useGoogleFonts: !theme.titleSmallIsCustom,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 8),
              Text(
                lang == 'ru'
                    ? 'Попробуй убрать фильтр «${_groupLabel(hint, lang)}»'
                    : 'Try removing the «${_groupLabel(hint, lang)}» filter',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() {
                      _model.activeFacets.remove(hint);
                      _search();
                    }),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  lang == 'ru' ? 'Убрать фильтр' : 'Remove filter',
                  style: TextStyle(color: theme.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _countLabel(int count, String lang) {
    if (lang == 'ru') return 'Найдено: $count';
    if (lang == 'es') return 'Resultados: $count';
    return '$count result${count == 1 ? '' : 's'}';
  }
}
