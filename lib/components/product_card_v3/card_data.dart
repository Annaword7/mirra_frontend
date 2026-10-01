/// Карточка продукта v3: типизированное чтение `images.sa_card`.
///
/// Объект собирает бэкенд (mirra/card.py, контракт в
/// docs/card_v3_contract.md). Клиент ничего не пересчитывает, кроме двух
/// вещей, которые зависят от профиля человека: окраска при беременности и
/// счётчики «полезные / вредные / внимание». Поля, которых нет в JSON,
/// читаются как пустые, чтобы карточка со старым или урезанным объектом
/// открывалась без ошибок.
class ProductCard {
  ProductCard._({
    required this.version,
    required this.productType,
    required this.usage,
    required this.rinseOff,
    required this.routineMorning,
    required this.routineEvening,
    required this.description,
    required this.howToUse,
    required this.skinScores,
    required this.functions,
    required this.drawbacks,
    required this.spf,
    required this.pregnancy,
    required this.linePosition,
    required this.lineBasis,
    required this.ingredients,
  });

  /// null, если в колонке не объект карточки нужной версии.
  static ProductCard? parse(dynamic raw) {
    if (raw is! Map) return null;
    final version = (raw['version'] as num?)?.toInt() ?? 0;
    if (version < 3) return null;
    final routine = raw['routine'] is Map ? raw['routine'] as Map : const {};
    final line = raw['line'] is Map ? raw['line'] as Map : const {};
    return ProductCard._(
      version: version,
      productType: _str(raw['product_type']) ?? 'other',
      usage: _usage(raw['usage']),
      rinseOff: raw['rinse_off'] == true,
      routineMorning: _ints(routine['morning']),
      routineEvening: _ints(routine['evening']),
      description: _str(raw['description']) ?? '',
      howToUse: _str(raw['how_to_use']) ?? '',
      skinScores: {
        if (raw['skin_scores'] is Map)
          for (final e in (raw['skin_scores'] as Map).entries)
            if (e.value is num) '${e.key}': (e.value as num).round(),
      },
      functions: [
        if (raw['functions'] is List)
          for (final f in raw['functions'] as List)
            if (f is Map && f['key'] is String)
              CardFunction(
                key: f['key'] as String,
                score: (f['score'] as num?)?.round() ?? 0,
                evidence: _strs(f['evidence']),
              ),
      ],
      drawbacks: [
        if (raw['drawbacks'] is List)
          for (final d in raw['drawbacks'] as List)
            if (d is Map && d['key'] is String)
              CardDrawback(
                key: d['key'] as String,
                forWhom: _strs(d['for']),
                ingredients: _strs(d['ingredients']),
              ),
      ],
      spf: raw['spf'] is Map ? CardSpf.parse(raw['spf'] as Map) : null,
      pregnancy: CardPregnancy.parse(raw['pregnancy']),
      linePosition: (line['position'] as num?)?.toInt(),
      lineBasis: _str(line['basis']),
      ingredients: [
        if (raw['ingredients'] is List)
          for (final i in raw['ingredients'] as List)
            if (i is Map && i['name'] is String) CardIngredient.parse(i),
      ],
    );
  }

  final int version;
  final String productType;

  /// day / night / both.
  final String usage;
  final bool rinseOff;

  /// Индексы шагов рутины, которые закрывает продукт (0–4).
  final List<int> routineMorning;
  final List<int> routineEvening;
  final String description;
  final String howToUse;

  /// dry / oily / normal / combination / sensitive / acne_prone → 0–100.
  final Map<String, int> skinScores;
  final List<CardFunction> functions;
  final List<CardDrawback> drawbacks;
  final CardSpf? spf;
  final CardPregnancy pregnancy;

  /// Позиция первого компонента ниже 1 % (1-based); null, если линии нет.
  final int? linePosition;

  /// marker / structure / null.
  final String? lineBasis;
  final List<CardIngredient> ingredients;

  bool get hasSpf => spf != null;
  bool get usedInMorning => usage == 'day' || usage == 'both';
  bool get usedInEvening => usage == 'night' || usage == 'both';

  static String _usage(dynamic v) =>
      v == 'day' || v == 'night' || v == 'both' ? v as String : 'both';

  static String? _str(dynamic v) =>
      v is String && v.trim().isNotEmpty ? v.trim() : null;

  static List<String> _strs(dynamic v) =>
      v is List ? v.whereType<String>().toList() : const [];

  static List<int> _ints(dynamic v) =>
      v is List ? v.whereType<num>().map((n) => n.toInt()).toList() : const [];
}

class CardFunction {
  const CardFunction({required this.key, required this.score, required this.evidence});
  final String key;
  final int score;
  final List<String> evidence;
}

class CardDrawback {
  const CardDrawback({required this.key, required this.forWhom, required this.ingredients});
  final String key;
  final List<String> forWhom;
  final List<String> ingredients;
}

class CardSpf {
  const CardSpf({
    required this.filterType,
    required this.uvb,
    required this.uva,
    required this.broadSpectrum,
    required this.filters,
  });

  static CardSpf parse(Map raw) => CardSpf(
        filterType: raw['filter_type'] is String ? raw['filter_type'] as String : 'chemical',
        uvb: raw['uvb'] == true,
        uva: raw['uva'] == true,
        broadSpectrum: raw['broad_spectrum'] == true,
        filters: [
          if (raw['filters'] is List)
            for (final f in raw['filters'] as List)
              if (f is Map && f['name'] is String)
                CardUvFilter(
                  name: f['name'] as String,
                  type: f['type'] is String ? f['type'] as String : 'chemical',
                  spectrum: ProductCard._strs(f['spectrum']),
                ),
        ],
      );

  /// mineral / hybrid / chemical.
  final String filterType;
  final bool uvb;
  final bool uva;
  final bool broadSpectrum;
  final List<CardUvFilter> filters;
}

class CardUvFilter {
  const CardUvFilter({required this.name, required this.type, required this.spectrum});
  final String name;
  final String type;
  final List<String> spectrum;
}

class CardPregnancy {
  const CardPregnancy({required this.safe, required this.classes, required this.ingredients});

  static CardPregnancy parse(dynamic raw) {
    if (raw is! Map) return const CardPregnancy(safe: true, classes: [], ingredients: []);
    return CardPregnancy(
      safe: raw['safe'] != false,
      classes: ProductCard._strs(raw['classes']),
      ingredients: ProductCard._strs(raw['ingredients']),
    );
  }

  final bool safe;
  final List<String> classes;
  final List<String> ingredients;
}

class CardIngredient {
  const CardIngredient({
    required this.position,
    required this.name,
    required this.kind,
    required this.reason,
    required this.zone,
    this.status,
    this.mec,
    this.estimated,
    this.forWhom = const [],
    this.pregnancyClass,
    this.tip,
  });

  static CardIngredient parse(Map raw) {
    final est = raw['estimated'];
    return CardIngredient(
      position: (raw['position'] as num?)?.toInt() ?? 0,
      name: raw['name'] as String,
      kind: _kind(raw['kind']),
      reason: raw['reason'] is String ? raw['reason'] as String : 'inactive',
      zone: raw['zone'] is String ? raw['zone'] as String : 'unknown',
      status: raw['status'] is String ? raw['status'] as String : null,
      mec: (raw['mec'] as num?)?.toDouble(),
      estimated: est is List && est.length == 2 && est.every((v) => v is num)
          ? [(est[0] as num).toDouble(), (est[1] as num).toDouble()]
          : null,
      forWhom: ProductCard._strs(raw['for']),
      pregnancyClass: raw['pregnancy_class'] is String ? raw['pregnancy_class'] as String : null,
      tip: ProductCard._str(raw['tip']),
    );
  }

  static String _kind(dynamic v) =>
      v == 'good' || v == 'bad' || v == 'warn' ? v as String : 'plain';

  final int position;
  final String name;

  /// good / bad / warn / plain, как посчитал бэкенд.
  final String kind;
  final String reason;

  /// above_1pct / below_1pct / unknown.
  final String zone;
  final String? status;
  final double? mec;
  final List<double>? estimated;
  final List<String> forWhom;
  final String? pregnancyClass;
  final String? tip;

  bool get belowLine => zone == 'below_1pct';

  /// Вид с учётом профиля: при беременности противопоказанный компонент
  /// считается вредным и в списке, и в счётчиках.
  String kindFor({required bool pregnant}) =>
      pregnant && pregnancyClass != null ? 'bad' : kind;
}
