// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AnalysisStruct extends FFFirebaseStruct {
  AnalysisStruct({
    List<String>? avoidIf,
    List<String>? bestFor,
    String? consumerSummary,
    double? coveragePercent,
    String? expertSummary,
    FormattedConclusionsStruct? formattedConclusions,
    List<String>? incompatibilities,
    List<IngredientAnalysisStruct>? ingredientAnalysis,
    List<KeyReferencesStruct>? keyReferences,
    bool? patchTestAdvised,
    List<String>? problematicIngredients,
    String? productType,
    int? recognizedIngredients,
    String? recommendedTime,
    bool? requiresSpf,
    ScoresStruct? scores,
    SkinTypeSuitabilityStruct? skinTypeSuitability,
    List<String>? synergies,
    List<String>? topActives,
    int? totalIngredients,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _avoidIf = avoidIf,
        _bestFor = bestFor,
        _consumerSummary = consumerSummary,
        _coveragePercent = coveragePercent,
        _expertSummary = expertSummary,
        _formattedConclusions = formattedConclusions,
        _incompatibilities = incompatibilities,
        _ingredientAnalysis = ingredientAnalysis,
        _keyReferences = keyReferences,
        _patchTestAdvised = patchTestAdvised,
        _problematicIngredients = problematicIngredients,
        _productType = productType,
        _recognizedIngredients = recognizedIngredients,
        _recommendedTime = recommendedTime,
        _requiresSpf = requiresSpf,
        _scores = scores,
        _skinTypeSuitability = skinTypeSuitability,
        _synergies = synergies,
        _topActives = topActives,
        _totalIngredients = totalIngredients,
        super(firestoreUtilData);

  // "avoid_if" field.
  List<String>? _avoidIf;
  List<String> get avoidIf => _avoidIf ?? const [];
  set avoidIf(List<String>? val) => _avoidIf = val;

  void updateAvoidIf(Function(List<String>) updateFn) {
    updateFn(_avoidIf ??= []);
  }

  bool hasAvoidIf() => _avoidIf != null;

  // "best_for" field.
  List<String>? _bestFor;
  List<String> get bestFor => _bestFor ?? const [];
  set bestFor(List<String>? val) => _bestFor = val;

  void updateBestFor(Function(List<String>) updateFn) {
    updateFn(_bestFor ??= []);
  }

  bool hasBestFor() => _bestFor != null;

  // "consumer_summary" field.
  String? _consumerSummary;
  String get consumerSummary => _consumerSummary ?? '';
  set consumerSummary(String? val) => _consumerSummary = val;

  bool hasConsumerSummary() => _consumerSummary != null;

  // "coverage_percent" field.
  double? _coveragePercent;
  double get coveragePercent => _coveragePercent ?? 0.0;
  set coveragePercent(double? val) => _coveragePercent = val;

  void incrementCoveragePercent(double amount) =>
      coveragePercent = coveragePercent + amount;

  bool hasCoveragePercent() => _coveragePercent != null;

  // "expert_summary" field.
  String? _expertSummary;
  String get expertSummary => _expertSummary ?? '';
  set expertSummary(String? val) => _expertSummary = val;

  bool hasExpertSummary() => _expertSummary != null;

  // "formatted_conclusions" field.
  FormattedConclusionsStruct? _formattedConclusions;
  FormattedConclusionsStruct get formattedConclusions =>
      _formattedConclusions ?? FormattedConclusionsStruct();
  set formattedConclusions(FormattedConclusionsStruct? val) =>
      _formattedConclusions = val;

  void updateFormattedConclusions(
      Function(FormattedConclusionsStruct) updateFn) {
    updateFn(_formattedConclusions ??= FormattedConclusionsStruct());
  }

  bool hasFormattedConclusions() => _formattedConclusions != null;

  // "incompatibilities" field.
  List<String>? _incompatibilities;
  List<String> get incompatibilities => _incompatibilities ?? const [];
  set incompatibilities(List<String>? val) => _incompatibilities = val;

  void updateIncompatibilities(Function(List<String>) updateFn) {
    updateFn(_incompatibilities ??= []);
  }

  bool hasIncompatibilities() => _incompatibilities != null;

  // "ingredient_analysis" field.
  List<IngredientAnalysisStruct>? _ingredientAnalysis;
  List<IngredientAnalysisStruct> get ingredientAnalysis =>
      _ingredientAnalysis ?? const [];
  set ingredientAnalysis(List<IngredientAnalysisStruct>? val) =>
      _ingredientAnalysis = val;

  void updateIngredientAnalysis(
      Function(List<IngredientAnalysisStruct>) updateFn) {
    updateFn(_ingredientAnalysis ??= []);
  }

  bool hasIngredientAnalysis() => _ingredientAnalysis != null;

  // "key_references" field.
  List<KeyReferencesStruct>? _keyReferences;
  List<KeyReferencesStruct> get keyReferences => _keyReferences ?? const [];
  set keyReferences(List<KeyReferencesStruct>? val) => _keyReferences = val;

  void updateKeyReferences(Function(List<KeyReferencesStruct>) updateFn) {
    updateFn(_keyReferences ??= []);
  }

  bool hasKeyReferences() => _keyReferences != null;

  // "patch_test_advised" field.
  bool? _patchTestAdvised;
  bool get patchTestAdvised => _patchTestAdvised ?? false;
  set patchTestAdvised(bool? val) => _patchTestAdvised = val;

  bool hasPatchTestAdvised() => _patchTestAdvised != null;

  // "problematic_ingredients" field.
  List<String>? _problematicIngredients;
  List<String> get problematicIngredients =>
      _problematicIngredients ?? const [];
  set problematicIngredients(List<String>? val) =>
      _problematicIngredients = val;

  void updateProblematicIngredients(Function(List<String>) updateFn) {
    updateFn(_problematicIngredients ??= []);
  }

  bool hasProblematicIngredients() => _problematicIngredients != null;

  // "product_type" field.
  String? _productType;
  String get productType => _productType ?? '';
  set productType(String? val) => _productType = val;

  bool hasProductType() => _productType != null;

  // "recognized_ingredients" field.
  int? _recognizedIngredients;
  int get recognizedIngredients => _recognizedIngredients ?? 0;
  set recognizedIngredients(int? val) => _recognizedIngredients = val;

  void incrementRecognizedIngredients(int amount) =>
      recognizedIngredients = recognizedIngredients + amount;

  bool hasRecognizedIngredients() => _recognizedIngredients != null;

  // "recommended_time" field.
  String? _recommendedTime;
  String get recommendedTime => _recommendedTime ?? '';
  set recommendedTime(String? val) => _recommendedTime = val;

  bool hasRecommendedTime() => _recommendedTime != null;

  // "requires_spf" field.
  bool? _requiresSpf;
  bool get requiresSpf => _requiresSpf ?? false;
  set requiresSpf(bool? val) => _requiresSpf = val;

  bool hasRequiresSpf() => _requiresSpf != null;

  // "scores" field.
  ScoresStruct? _scores;
  ScoresStruct get scores => _scores ?? ScoresStruct();
  set scores(ScoresStruct? val) => _scores = val;

  void updateScores(Function(ScoresStruct) updateFn) {
    updateFn(_scores ??= ScoresStruct());
  }

  bool hasScores() => _scores != null;

  // "skin_type_suitability" field.
  SkinTypeSuitabilityStruct? _skinTypeSuitability;
  SkinTypeSuitabilityStruct get skinTypeSuitability =>
      _skinTypeSuitability ?? SkinTypeSuitabilityStruct();
  set skinTypeSuitability(SkinTypeSuitabilityStruct? val) =>
      _skinTypeSuitability = val;

  void updateSkinTypeSuitability(Function(SkinTypeSuitabilityStruct) updateFn) {
    updateFn(_skinTypeSuitability ??= SkinTypeSuitabilityStruct());
  }

  bool hasSkinTypeSuitability() => _skinTypeSuitability != null;

  // "synergies" field.
  List<String>? _synergies;
  List<String> get synergies => _synergies ?? const [];
  set synergies(List<String>? val) => _synergies = val;

  void updateSynergies(Function(List<String>) updateFn) {
    updateFn(_synergies ??= []);
  }

  bool hasSynergies() => _synergies != null;

  // "top_actives" field.
  List<String>? _topActives;
  List<String> get topActives => _topActives ?? const [];
  set topActives(List<String>? val) => _topActives = val;

  void updateTopActives(Function(List<String>) updateFn) {
    updateFn(_topActives ??= []);
  }

  bool hasTopActives() => _topActives != null;

  // "total_ingredients" field.
  int? _totalIngredients;
  int get totalIngredients => _totalIngredients ?? 0;
  set totalIngredients(int? val) => _totalIngredients = val;

  void incrementTotalIngredients(int amount) =>
      totalIngredients = totalIngredients + amount;

  bool hasTotalIngredients() => _totalIngredients != null;

  static AnalysisStruct fromMap(Map<String, dynamic> data) => AnalysisStruct(
        avoidIf: getDataList(data['avoid_if']),
        bestFor: getDataList(data['best_for']),
        consumerSummary: data['consumer_summary'] as String?,
        coveragePercent: castToType<double>(data['coverage_percent']),
        expertSummary: data['expert_summary'] as String?,
        formattedConclusions:
            data['formatted_conclusions'] is FormattedConclusionsStruct
                ? data['formatted_conclusions']
                : FormattedConclusionsStruct.maybeFromMap(
                    data['formatted_conclusions']),
        incompatibilities: getDataList(data['incompatibilities']),
        ingredientAnalysis: getStructList(
          data['ingredient_analysis'],
          IngredientAnalysisStruct.fromMap,
        ),
        keyReferences: getStructList(
          data['key_references'],
          KeyReferencesStruct.fromMap,
        ),
        patchTestAdvised: data['patch_test_advised'] as bool?,
        problematicIngredients: getDataList(data['problematic_ingredients']),
        productType: data['product_type'] as String?,
        recognizedIngredients: castToType<int>(data['recognized_ingredients']),
        recommendedTime: data['recommended_time'] as String?,
        requiresSpf: data['requires_spf'] as bool?,
        scores: data['scores'] is ScoresStruct
            ? data['scores']
            : ScoresStruct.maybeFromMap(data['scores']),
        skinTypeSuitability:
            data['skin_type_suitability'] is SkinTypeSuitabilityStruct
                ? data['skin_type_suitability']
                : SkinTypeSuitabilityStruct.maybeFromMap(
                    data['skin_type_suitability']),
        synergies: getDataList(data['synergies']),
        topActives: getDataList(data['top_actives']),
        totalIngredients: castToType<int>(data['total_ingredients']),
      );

  static AnalysisStruct? maybeFromMap(dynamic data) =>
      data is Map ? AnalysisStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'avoid_if': _avoidIf,
        'best_for': _bestFor,
        'consumer_summary': _consumerSummary,
        'coverage_percent': _coveragePercent,
        'expert_summary': _expertSummary,
        'formatted_conclusions': _formattedConclusions?.toMap(),
        'incompatibilities': _incompatibilities,
        'ingredient_analysis':
            _ingredientAnalysis?.map((e) => e.toMap()).toList(),
        'key_references': _keyReferences?.map((e) => e.toMap()).toList(),
        'patch_test_advised': _patchTestAdvised,
        'problematic_ingredients': _problematicIngredients,
        'product_type': _productType,
        'recognized_ingredients': _recognizedIngredients,
        'recommended_time': _recommendedTime,
        'requires_spf': _requiresSpf,
        'scores': _scores?.toMap(),
        'skin_type_suitability': _skinTypeSuitability?.toMap(),
        'synergies': _synergies,
        'top_actives': _topActives,
        'total_ingredients': _totalIngredients,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'avoid_if': serializeParam(
          _avoidIf,
          ParamType.String,
          isList: true,
        ),
        'best_for': serializeParam(
          _bestFor,
          ParamType.String,
          isList: true,
        ),
        'consumer_summary': serializeParam(
          _consumerSummary,
          ParamType.String,
        ),
        'coverage_percent': serializeParam(
          _coveragePercent,
          ParamType.double,
        ),
        'expert_summary': serializeParam(
          _expertSummary,
          ParamType.String,
        ),
        'formatted_conclusions': serializeParam(
          _formattedConclusions,
          ParamType.DataStruct,
        ),
        'incompatibilities': serializeParam(
          _incompatibilities,
          ParamType.String,
          isList: true,
        ),
        'ingredient_analysis': serializeParam(
          _ingredientAnalysis,
          ParamType.DataStruct,
          isList: true,
        ),
        'key_references': serializeParam(
          _keyReferences,
          ParamType.DataStruct,
          isList: true,
        ),
        'patch_test_advised': serializeParam(
          _patchTestAdvised,
          ParamType.bool,
        ),
        'problematic_ingredients': serializeParam(
          _problematicIngredients,
          ParamType.String,
          isList: true,
        ),
        'product_type': serializeParam(
          _productType,
          ParamType.String,
        ),
        'recognized_ingredients': serializeParam(
          _recognizedIngredients,
          ParamType.int,
        ),
        'recommended_time': serializeParam(
          _recommendedTime,
          ParamType.String,
        ),
        'requires_spf': serializeParam(
          _requiresSpf,
          ParamType.bool,
        ),
        'scores': serializeParam(
          _scores,
          ParamType.DataStruct,
        ),
        'skin_type_suitability': serializeParam(
          _skinTypeSuitability,
          ParamType.DataStruct,
        ),
        'synergies': serializeParam(
          _synergies,
          ParamType.String,
          isList: true,
        ),
        'top_actives': serializeParam(
          _topActives,
          ParamType.String,
          isList: true,
        ),
        'total_ingredients': serializeParam(
          _totalIngredients,
          ParamType.int,
        ),
      }.withoutNulls;

  static AnalysisStruct fromSerializableMap(Map<String, dynamic> data) =>
      AnalysisStruct(
        avoidIf: deserializeParam<String>(
          data['avoid_if'],
          ParamType.String,
          true,
        ),
        bestFor: deserializeParam<String>(
          data['best_for'],
          ParamType.String,
          true,
        ),
        consumerSummary: deserializeParam(
          data['consumer_summary'],
          ParamType.String,
          false,
        ),
        coveragePercent: deserializeParam(
          data['coverage_percent'],
          ParamType.double,
          false,
        ),
        expertSummary: deserializeParam(
          data['expert_summary'],
          ParamType.String,
          false,
        ),
        formattedConclusions: deserializeStructParam(
          data['formatted_conclusions'],
          ParamType.DataStruct,
          false,
          structBuilder: FormattedConclusionsStruct.fromSerializableMap,
        ),
        incompatibilities: deserializeParam<String>(
          data['incompatibilities'],
          ParamType.String,
          true,
        ),
        ingredientAnalysis: deserializeStructParam<IngredientAnalysisStruct>(
          data['ingredient_analysis'],
          ParamType.DataStruct,
          true,
          structBuilder: IngredientAnalysisStruct.fromSerializableMap,
        ),
        keyReferences: deserializeStructParam<KeyReferencesStruct>(
          data['key_references'],
          ParamType.DataStruct,
          true,
          structBuilder: KeyReferencesStruct.fromSerializableMap,
        ),
        patchTestAdvised: deserializeParam(
          data['patch_test_advised'],
          ParamType.bool,
          false,
        ),
        problematicIngredients: deserializeParam<String>(
          data['problematic_ingredients'],
          ParamType.String,
          true,
        ),
        productType: deserializeParam(
          data['product_type'],
          ParamType.String,
          false,
        ),
        recognizedIngredients: deserializeParam(
          data['recognized_ingredients'],
          ParamType.int,
          false,
        ),
        recommendedTime: deserializeParam(
          data['recommended_time'],
          ParamType.String,
          false,
        ),
        requiresSpf: deserializeParam(
          data['requires_spf'],
          ParamType.bool,
          false,
        ),
        scores: deserializeStructParam(
          data['scores'],
          ParamType.DataStruct,
          false,
          structBuilder: ScoresStruct.fromSerializableMap,
        ),
        skinTypeSuitability: deserializeStructParam(
          data['skin_type_suitability'],
          ParamType.DataStruct,
          false,
          structBuilder: SkinTypeSuitabilityStruct.fromSerializableMap,
        ),
        synergies: deserializeParam<String>(
          data['synergies'],
          ParamType.String,
          true,
        ),
        topActives: deserializeParam<String>(
          data['top_actives'],
          ParamType.String,
          true,
        ),
        totalIngredients: deserializeParam(
          data['total_ingredients'],
          ParamType.int,
          false,
        ),
      );

  static AnalysisStruct fromAlgoliaData(Map<String, dynamic> data) =>
      AnalysisStruct(
        avoidIf: convertAlgoliaParam<String>(
          data['avoid_if'],
          ParamType.String,
          true,
        ),
        bestFor: convertAlgoliaParam<String>(
          data['best_for'],
          ParamType.String,
          true,
        ),
        consumerSummary: convertAlgoliaParam(
          data['consumer_summary'],
          ParamType.String,
          false,
        ),
        coveragePercent: convertAlgoliaParam(
          data['coverage_percent'],
          ParamType.double,
          false,
        ),
        expertSummary: convertAlgoliaParam(
          data['expert_summary'],
          ParamType.String,
          false,
        ),
        formattedConclusions: convertAlgoliaParam(
          data['formatted_conclusions'],
          ParamType.DataStruct,
          false,
          structBuilder: FormattedConclusionsStruct.fromAlgoliaData,
        ),
        incompatibilities: convertAlgoliaParam<String>(
          data['incompatibilities'],
          ParamType.String,
          true,
        ),
        ingredientAnalysis: convertAlgoliaParam<IngredientAnalysisStruct>(
          data['ingredient_analysis'],
          ParamType.DataStruct,
          true,
          structBuilder: IngredientAnalysisStruct.fromAlgoliaData,
        ),
        keyReferences: convertAlgoliaParam<KeyReferencesStruct>(
          data['key_references'],
          ParamType.DataStruct,
          true,
          structBuilder: KeyReferencesStruct.fromAlgoliaData,
        ),
        patchTestAdvised: convertAlgoliaParam(
          data['patch_test_advised'],
          ParamType.bool,
          false,
        ),
        problematicIngredients: convertAlgoliaParam<String>(
          data['problematic_ingredients'],
          ParamType.String,
          true,
        ),
        productType: convertAlgoliaParam(
          data['product_type'],
          ParamType.String,
          false,
        ),
        recognizedIngredients: convertAlgoliaParam(
          data['recognized_ingredients'],
          ParamType.int,
          false,
        ),
        recommendedTime: convertAlgoliaParam(
          data['recommended_time'],
          ParamType.String,
          false,
        ),
        requiresSpf: convertAlgoliaParam(
          data['requires_spf'],
          ParamType.bool,
          false,
        ),
        scores: convertAlgoliaParam(
          data['scores'],
          ParamType.DataStruct,
          false,
          structBuilder: ScoresStruct.fromAlgoliaData,
        ),
        skinTypeSuitability: convertAlgoliaParam(
          data['skin_type_suitability'],
          ParamType.DataStruct,
          false,
          structBuilder: SkinTypeSuitabilityStruct.fromAlgoliaData,
        ),
        synergies: convertAlgoliaParam<String>(
          data['synergies'],
          ParamType.String,
          true,
        ),
        topActives: convertAlgoliaParam<String>(
          data['top_actives'],
          ParamType.String,
          true,
        ),
        totalIngredients: convertAlgoliaParam(
          data['total_ingredients'],
          ParamType.int,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'AnalysisStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is AnalysisStruct &&
        listEquality.equals(avoidIf, other.avoidIf) &&
        listEquality.equals(bestFor, other.bestFor) &&
        consumerSummary == other.consumerSummary &&
        coveragePercent == other.coveragePercent &&
        expertSummary == other.expertSummary &&
        formattedConclusions == other.formattedConclusions &&
        listEquality.equals(incompatibilities, other.incompatibilities) &&
        listEquality.equals(ingredientAnalysis, other.ingredientAnalysis) &&
        listEquality.equals(keyReferences, other.keyReferences) &&
        patchTestAdvised == other.patchTestAdvised &&
        listEquality.equals(
            problematicIngredients, other.problematicIngredients) &&
        productType == other.productType &&
        recognizedIngredients == other.recognizedIngredients &&
        recommendedTime == other.recommendedTime &&
        requiresSpf == other.requiresSpf &&
        scores == other.scores &&
        skinTypeSuitability == other.skinTypeSuitability &&
        listEquality.equals(synergies, other.synergies) &&
        listEquality.equals(topActives, other.topActives) &&
        totalIngredients == other.totalIngredients;
  }

  @override
  int get hashCode => const ListEquality().hash([
        avoidIf,
        bestFor,
        consumerSummary,
        coveragePercent,
        expertSummary,
        formattedConclusions,
        incompatibilities,
        ingredientAnalysis,
        keyReferences,
        patchTestAdvised,
        problematicIngredients,
        productType,
        recognizedIngredients,
        recommendedTime,
        requiresSpf,
        scores,
        skinTypeSuitability,
        synergies,
        topActives,
        totalIngredients
      ]);
}

AnalysisStruct createAnalysisStruct({
  String? consumerSummary,
  double? coveragePercent,
  String? expertSummary,
  FormattedConclusionsStruct? formattedConclusions,
  bool? patchTestAdvised,
  String? productType,
  int? recognizedIngredients,
  String? recommendedTime,
  bool? requiresSpf,
  ScoresStruct? scores,
  SkinTypeSuitabilityStruct? skinTypeSuitability,
  int? totalIngredients,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    AnalysisStruct(
      consumerSummary: consumerSummary,
      coveragePercent: coveragePercent,
      expertSummary: expertSummary,
      formattedConclusions: formattedConclusions ??
          (clearUnsetFields ? FormattedConclusionsStruct() : null),
      patchTestAdvised: patchTestAdvised,
      productType: productType,
      recognizedIngredients: recognizedIngredients,
      recommendedTime: recommendedTime,
      requiresSpf: requiresSpf,
      scores: scores ?? (clearUnsetFields ? ScoresStruct() : null),
      skinTypeSuitability: skinTypeSuitability ??
          (clearUnsetFields ? SkinTypeSuitabilityStruct() : null),
      totalIngredients: totalIngredients,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

AnalysisStruct? updateAnalysisStruct(
  AnalysisStruct? analysis, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    analysis
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addAnalysisStructData(
  Map<String, dynamic> firestoreData,
  AnalysisStruct? analysis,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (analysis == null) {
    return;
  }
  if (analysis.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && analysis.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final analysisData = getAnalysisFirestoreData(analysis, forFieldValue);
  final nestedData = analysisData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = analysis.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getAnalysisFirestoreData(
  AnalysisStruct? analysis, [
  bool forFieldValue = false,
]) {
  if (analysis == null) {
    return {};
  }
  final firestoreData = mapToFirestore(analysis.toMap());

  // Handle nested data for "formatted_conclusions" field.
  addFormattedConclusionsStructData(
    firestoreData,
    analysis.hasFormattedConclusions() ? analysis.formattedConclusions : null,
    'formatted_conclusions',
    forFieldValue,
  );

  // Handle nested data for "scores" field.
  addScoresStructData(
    firestoreData,
    analysis.hasScores() ? analysis.scores : null,
    'scores',
    forFieldValue,
  );

  // Handle nested data for "skin_type_suitability" field.
  addSkinTypeSuitabilityStructData(
    firestoreData,
    analysis.hasSkinTypeSuitability() ? analysis.skinTypeSuitability : null,
    'skin_type_suitability',
    forFieldValue,
  );

  // Add any Firestore field values
  mapToFirestore(analysis.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getAnalysisListFirestoreData(
  List<AnalysisStruct>? analysiss,
) =>
    analysiss?.map((e) => getAnalysisFirestoreData(e, true)).toList() ?? [];
