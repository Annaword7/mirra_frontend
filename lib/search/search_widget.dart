import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/database/tables/users.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/design_system/components/app_button.dart';
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
    'form': {'en': 'Form', 'ru': 'Форма', 'es': 'Tipo', 'de': 'Art', 'fr': 'Type', 'it': 'Tipo', 'pt': 'Tipo', 'tr': 'Tür', 'ja': 'タイプ', 'ko': '종류', 'zh': '类型'},
    'goal': {'en': 'Goal', 'ru': 'Цель', 'es': 'Objetivo', 'de': 'Ziel', 'fr': 'Objectif', 'it': 'Obiettivo', 'pt': 'Objetivo', 'tr': 'Hedef', 'ja': '目的', 'ko': '목적', 'zh': '目标'},
    'active': {'en': 'Actives', 'ru': 'Активы', 'es': 'Activos', 'de': 'Wirkstoffe', 'fr': 'Actifs', 'it': 'Attivi', 'pt': 'Ativos', 'tr': 'Aktifler', 'ja': '有効成分', 'ko': '활성 성분', 'zh': '活性成分'},
    'composition_flags': {'en': 'Free from', 'ru': 'Без', 'es': 'Sin', 'de': 'Frei von', 'fr': 'Sans', 'it': 'Senza', 'pt': 'Sem', 'tr': 'İçermez', 'ja': '不使用', 'ko': '무첨가', 'zh': '不含'},
    'time_of_day': {'en': 'Time of day', 'ru': 'Время', 'es': 'Momento', 'de': 'Tageszeit', 'fr': 'Moment', 'it': 'Momento', 'pt': 'Momento', 'tr': 'Zaman', 'ja': '時間帯', 'ko': '시간대', 'zh': '时段'},
    'price_band': {'en': 'Price', 'ru': 'Цена', 'es': 'Precio', 'de': 'Preis', 'fr': 'Prix', 'it': 'Prezzo', 'pt': 'Preço', 'tr': 'Fiyat', 'ja': '価格', 'ko': '가격', 'zh': '价格'},
  };
  return m[name]?[lang] ?? m[name]?['en'] ?? name;
}

String _valueLabel(String value, String lang) {
  const m = <String, Map<String, String>>{
    'serum': {'en': 'Serum', 'ru': 'Сыворотка', 'es': 'Serum', 'de': 'Serum', 'fr': 'Sérum', 'it': 'Siero', 'pt': 'Sérum', 'tr': 'Serum', 'ja': '美容液', 'ko': '세럼', 'zh': '精华'},
    'cream': {'en': 'Cream', 'ru': 'Крем', 'es': 'Crema', 'de': 'Creme', 'fr': 'Crème', 'it': 'Crema', 'pt': 'Creme', 'tr': 'Krem', 'ja': 'クリーム', 'ko': '크림', 'zh': '面霜'},
    'gel_cream': {'en': 'Gel-cream', 'ru': 'Гель-крем', 'es': 'Gel-crema', 'de': 'Gel-Creme', 'fr': 'Gel-crème', 'it': 'Gel-crema', 'pt': 'Gel-creme', 'tr': 'Jel krem', 'ja': 'ジェルクリーム', 'ko': '젤크림', 'zh': '凝霜'},
    'toner': {'en': 'Toner', 'ru': 'Тоник', 'es': 'Tónico', 'de': 'Toner', 'fr': 'Tonique', 'it': 'Tonico', 'pt': 'Tônico', 'tr': 'Tonik', 'ja': '化粧水', 'ko': '토너', 'zh': '爽肤水'},
    'oil': {'en': 'Oil', 'ru': 'Масло', 'es': 'Aceite', 'de': 'Öl', 'fr': 'Huile', 'it': 'Olio', 'pt': 'Óleo', 'tr': 'Yağ', 'ja': 'オイル', 'ko': '오일', 'zh': '精油'},
    'mask': {'en': 'Mask', 'ru': 'Маска', 'es': 'Mascarilla', 'de': 'Maske', 'fr': 'Masque', 'it': 'Maschera', 'pt': 'Máscara', 'tr': 'Maske', 'ja': 'マスク', 'ko': '마스크', 'zh': '面膜'},
    'cleanser': {'en': 'Cleanser', 'ru': 'Очищение', 'es': 'Limpiador', 'de': 'Reiniger', 'fr': 'Nettoyant', 'it': 'Detergente', 'pt': 'Limpador', 'tr': 'Temizleyici', 'ja': '洗顔料', 'ko': '클렌저', 'zh': '洁面'},
    'sunscreen': {'en': 'Sunscreen', 'ru': 'Санскрин', 'es': 'Protector solar', 'de': 'Sonnenschutz', 'fr': 'Écran solaire', 'it': 'Solare', 'pt': 'Protetor solar', 'tr': 'Güneş kremi', 'ja': '日焼け止め', 'ko': '선크림', 'zh': '防晒'},
    'eye_cream': {'en': 'Eye cream', 'ru': 'Крем для глаз', 'es': 'Contorno de ojos', 'de': 'Augencreme', 'fr': 'Contour des yeux', 'it': 'Contorno occhi', 'pt': 'Creme para olhos', 'tr': 'Göz kremi', 'ja': 'アイクリーム', 'ko': '아이크림', 'zh': '眼霜'},
    'exfoliant': {'en': 'Exfoliant', 'ru': 'Пилинг', 'es': 'Exfoliante', 'de': 'Peeling', 'fr': 'Exfoliant', 'it': 'Esfoliante', 'pt': 'Esfoliante', 'tr': 'Peeling', 'ja': '角質ケア', 'ko': '각질제거', 'zh': '去角质'},
    'hydration': {'en': 'Hydration', 'ru': 'Увлажнение', 'es': 'Hidratación', 'de': 'Feuchtigkeit', 'fr': 'Hydratation', 'it': 'Idratazione', 'pt': 'Hidratação', 'tr': 'Nemlendirme', 'ja': '保湿', 'ko': '수분', 'zh': '保湿'},
    'anti_aging': {'en': 'Anti-aging', 'ru': 'Антивозраст', 'es': 'Antiedad', 'de': 'Anti-Aging', 'fr': 'Anti-âge', 'it': 'Anti-età', 'pt': 'Antienvelhecimento', 'tr': 'Yaşlanma karşıtı', 'ja': 'エイジングケア', 'ko': '안티에이징', 'zh': '抗衰'},
    'pigmentation': {'en': 'Brightening', 'ru': 'Осветление', 'es': 'Iluminación', 'de': 'Aufhellung', 'fr': 'Éclat', 'it': 'Illuminante', 'pt': 'Iluminação', 'tr': 'Aydınlatma', 'ja': '美白', 'ko': '브라이트닝', 'zh': '提亮'},
    'acne': {'en': 'Acne', 'ru': 'Акне', 'es': 'Acné', 'de': 'Akne', 'fr': 'Acné', 'it': 'Acne', 'pt': 'Acne', 'tr': 'Akne', 'ja': 'ニキビ', 'ko': '여드름', 'zh': '痘痘'},
    'barrier': {'en': 'Barrier', 'ru': 'Барьер', 'es': 'Barrera', 'de': 'Barriere', 'fr': 'Barrière', 'it': 'Barriera', 'pt': 'Barreira', 'tr': 'Bariyer', 'ja': 'バリア', 'ko': '장벽', 'zh': '屏障'},
    'pores': {'en': 'Pores', 'ru': 'Поры', 'es': 'Poros', 'de': 'Poren', 'fr': 'Pores', 'it': 'Pori', 'pt': 'Poros', 'tr': 'Gözenekler', 'ja': '毛穴', 'ko': '모공', 'zh': '毛孔'},
    'retinol': {'en': 'Retinol', 'ru': 'Ретинол', 'es': 'Retinol', 'de': 'Retinol', 'fr': 'Rétinol', 'it': 'Retinolo', 'pt': 'Retinol', 'tr': 'Retinol', 'ja': 'レチノール', 'ko': '레티놀', 'zh': '视黄醇'},
    'niacinamide': {'en': 'Niacinamide', 'ru': 'Ниацинамид', 'es': 'Niacinamida', 'de': 'Niacinamid', 'fr': 'Niacinamide', 'it': 'Niacinamide', 'pt': 'Niacinamida', 'tr': 'Niasinamid', 'ja': 'ナイアシンアミド', 'ko': '나이아신아마이드', 'zh': '烟酰胺'},
    'vitamin_c': {'en': 'Vitamin C', 'ru': 'Витамин C', 'es': 'Vitamina C', 'de': 'Vitamin C', 'fr': 'Vitamine C', 'it': 'Vitamina C', 'pt': 'Vitamina C', 'tr': 'C Vitamini', 'ja': 'ビタミンC', 'ko': '비타민C', 'zh': '维生素C'},
    'bakuchiol': {'en': 'Bakuchiol', 'ru': 'Бакучиол', 'es': 'Bakuchiol', 'de': 'Bakuchiol', 'fr': 'Bakuchiol', 'it': 'Bakuchiol', 'pt': 'Bakuchiol', 'tr': 'Bakuchiol', 'ja': 'バクチオール', 'ko': '바쿠치올', 'zh': '补骨脂酚'},
    'hyaluronic_acid': {'en': 'Hyaluronic', 'ru': 'Гиалурон', 'es': 'Hialurónico', 'de': 'Hyaluron', 'fr': 'Hyaluronique', 'it': 'Ialuronico', 'pt': 'Hialurônico', 'tr': 'Hyaluronik', 'ja': 'ヒアルロン酸', 'ko': '히알루론산', 'zh': '玻尿酸'},
    'ceramide': {'en': 'Ceramide', 'ru': 'Церамиды', 'es': 'Ceramidas', 'de': 'Ceramide', 'fr': 'Céramides', 'it': 'Ceramidi', 'pt': 'Ceramidas', 'tr': 'Seramit', 'ja': 'セラミド', 'ko': '세라마이드', 'zh': '神经酰胺'},
    'peptide': {'en': 'Peptide', 'ru': 'Пептиды', 'es': 'Péptidos', 'de': 'Peptide', 'fr': 'Peptides', 'it': 'Peptidi', 'pt': 'Peptídeos', 'tr': 'Peptit', 'ja': 'ペプチド', 'ko': '펩타이드', 'zh': '胜肽'},
    'salicylic_acid': {'en': 'BHA', 'ru': 'BHA', 'es': 'BHA', 'de': 'BHA', 'fr': 'BHA', 'it': 'BHA', 'pt': 'BHA', 'tr': 'BHA', 'ja': 'BHA', 'ko': 'BHA', 'zh': 'BHA'},
    'glycolic_acid': {'en': 'AHA', 'ru': 'AHA', 'es': 'AHA', 'de': 'AHA', 'fr': 'AHA', 'it': 'AHA', 'pt': 'AHA', 'tr': 'AHA', 'ja': 'AHA', 'ko': 'AHA', 'zh': 'AHA'},
    'azelaic_acid': {'en': 'Azelaic', 'ru': 'Азелаин', 'es': 'Azelaico', 'de': 'Azelainsäure', 'fr': 'Acide azélaïque', 'it': 'Azelaico', 'pt': 'Azelaico', 'tr': 'Azelaik', 'ja': 'アゼライン酸', 'ko': '아젤라산', 'zh': '壬二酸'},
    'no_fragrance': {'en': 'Fragrance-free', 'ru': 'Без отдушек', 'es': 'Sin fragancia', 'de': 'Ohne Duft', 'fr': 'Sans parfum', 'it': 'Senza profumo', 'pt': 'Sem fragrância', 'tr': 'Parfümsüz', 'ja': '無香料', 'ko': '무향', 'zh': '无香'},
    'no_denat_alcohol': {'en': 'Alcohol-free', 'ru': 'Без спирта', 'es': 'Sin alcohol', 'de': 'Ohne Alkohol', 'fr': 'Sans alcool', 'it': 'Senza alcol', 'pt': 'Sem álcool', 'tr': 'Alkolsüz', 'ja': 'アルコールフリー', 'ko': '무알코올', 'zh': '无酒精'},
    'no_essential_oils': {'en': 'No ess. oils', 'ru': 'Без эф. масел', 'es': 'Sin aceites es.', 'de': 'Ohne äth. Öle', 'fr': 'Sans huiles ess.', 'it': 'Senza oli ess.', 'pt': 'Sem óleos ess.', 'tr': 'Uçucu yağsız', 'ja': '精油不使用', 'ko': '에센셜오일 무첨가', 'zh': '无精油'},
    'vegan': {'en': 'Vegan', 'ru': 'Веган', 'es': 'Vegano', 'de': 'Vegan', 'fr': 'Végane', 'it': 'Vegano', 'pt': 'Vegano', 'tr': 'Vegan', 'ja': 'ヴィーガン', 'ko': '비건', 'zh': '纯素'},
    'am': {'en': 'Morning', 'ru': 'Утром', 'es': 'Mañana', 'de': 'Morgens', 'fr': 'Matin', 'it': 'Mattina', 'pt': 'Manhã', 'tr': 'Sabah', 'ja': '朝', 'ko': '아침', 'zh': '早晨'},
    'pm': {'en': 'Night', 'ru': 'Ночью', 'es': 'Noche', 'de': 'Nachts', 'fr': 'Soir', 'it': 'Sera', 'pt': 'Noite', 'tr': 'Gece', 'ja': '夜', 'ko': '밤', 'zh': '夜晚'},
    'budget': {'en': 'Budget', 'ru': 'Бюджет', 'es': 'Económico', 'de': 'Günstig', 'fr': 'Budget', 'it': 'Economico', 'pt': 'Econômico', 'tr': 'Uygun', 'ja': 'お手頃', 'ko': '저가', 'zh': '平价'},
    'mid': {'en': 'Mid-range', 'ru': 'Средний', 'es': 'Gama media', 'de': 'Mittelklasse', 'fr': 'Milieu de gamme', 'it': 'Fascia media', 'pt': 'Intermediário', 'tr': 'Orta', 'ja': 'ミドル', 'ko': '중가', 'zh': '中端'},
    'premium': {'en': 'Premium', 'ru': 'Премиум', 'es': 'Premium', 'de': 'Premium', 'fr': 'Premium', 'it': 'Premium', 'pt': 'Premium', 'tr': 'Premium', 'ja': 'プレミアム', 'ko': '프리미엄', 'zh': '高端'},
    'luxury': {'en': 'Luxury', 'ru': 'Люкс', 'es': 'Lujo', 'de': 'Luxus', 'fr': 'Luxe', 'it': 'Lusso', 'pt': 'Luxo', 'tr': 'Lüks', 'ja': 'ラグジュアリー', 'ko': '럭셔리', 'zh': '奢华'},
  };
  return m[value]?[lang] ?? m[value]?['en'] ?? value;
}

String _sortLabel(String sort, String lang) {
  const m = <String, Map<String, String>>{
    'fit': {'en': '✦ Best fit', 'ru': '✦ Подбор', 'es': '✦ A medida', 'de': '✦ Passt am besten', 'fr': '✦ Meilleur choix', 'it': '✦ Più adatto', 'pt': '✦ Melhor opção', 'tr': '✦ En uygun', 'ja': '✦ おすすめ順', 'ko': '✦ 맞춤순', 'zh': '✦ 最匹配'},
    'formula': {'en': 'By score', 'ru': 'По оценке', 'es': 'Por puntuación', 'de': 'Nach Bewertung', 'fr': 'Par score', 'it': 'Per punteggio', 'pt': 'Por pontuação', 'tr': 'Puana göre', 'ja': 'スコア順', 'ko': '점수순', 'zh': '按评分'},
    'price_asc': {'en': 'Cheapest', 'ru': 'Дешевле', 'es': 'Más barato', 'de': 'Günstigste', 'fr': 'Moins cher', 'it': 'Più economico', 'pt': 'Mais barato', 'tr': 'En ucuz', 'ja': '安い順', 'ko': '저렴한순', 'zh': '最便宜'},
    'price_desc': {'en': 'Premium', 'ru': 'Дороже', 'es': 'Más caro', 'de': 'Teuerste', 'fr': 'Plus cher', 'it': 'Più costoso', 'pt': 'Mais caro', 'tr': 'En pahalı', 'ja': '高い順', 'ko': '비싼순', 'zh': '最贵'},
  };
  return m[sort]?[lang] ?? m[sort]?['en'] ?? sort;
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
            AppButton(
              label: 'AI',
              loading: _model.isParsing,
              size: AppButtonSize.md,
              fullWidth: false,
              onPressed: () => _parsePhrase(),
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
    return AppButton(
      label: label,
      loading: _model.isSearching,
      onPressed: () => _search(),
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
                (() {
                  const t = <String, String>{
                    'en': 'Try removing the «{f}» filter',
                    'ru': 'Попробуй убрать фильтр «{f}»',
                    'es': 'Prueba a quitar el filtro «{f}»',
                    'de': 'Entferne den Filter «{f}»',
                    'fr': 'Essaie de retirer le filtre «{f}»',
                    'it': 'Prova a rimuovere il filtro «{f}»',
                    'pt': 'Tente remover o filtro «{f}»',
                    'tr': '«{f}» filtresini kaldırmayı dene',
                    'ja': '「{f}」フィルターを外してみて',
                    'ko': '«{f}» 필터를 해제해 보세요',
                    'zh': '试试移除「{f}」筛选',
                  };
                  return (t[lang] ?? t['en']!)
                      .replaceAll('{f}', _groupLabel(hint, lang));
                })(),
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
