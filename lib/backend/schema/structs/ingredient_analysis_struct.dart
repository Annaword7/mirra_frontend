// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class IngredientAnalysisStruct extends FFFirebaseStruct {
  IngredientAnalysisStruct({
    String? category,
    int? comedogenicityRating,
    int? efficacyContribution,
    int? efficacyTier,
    String? estimatedConcentration,
    String? evidenceLevel,
    String? inciName,
    bool? isActive,
    bool? isProblematic,
    String? mechanism,
    int? position,
    int? safetyContribution,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _category = category,
        _comedogenicityRating = comedogenicityRating,
        _efficacyContribution = efficacyContribution,
        _efficacyTier = efficacyTier,
        _estimatedConcentration = estimatedConcentration,
        _evidenceLevel = evidenceLevel,
        _inciName = inciName,
        _isActive = isActive,
        _isProblematic = isProblematic,
        _mechanism = mechanism,
        _position = position,
        _safetyContribution = safetyContribution,
        super(firestoreUtilData);

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  set category(String? val) => _category = val;

  bool hasCategory() => _category != null;

  // "comedogenicity_rating" field.
  int? _comedogenicityRating;
  int get comedogenicityRating => _comedogenicityRating ?? 0;
  set comedogenicityRating(int? val) => _comedogenicityRating = val;

  void incrementComedogenicityRating(int amount) =>
      comedogenicityRating = comedogenicityRating + amount;

  bool hasComedogenicityRating() => _comedogenicityRating != null;

  // "efficacy_contribution" field.
  int? _efficacyContribution;
  int get efficacyContribution => _efficacyContribution ?? 0;
  set efficacyContribution(int? val) => _efficacyContribution = val;

  void incrementEfficacyContribution(int amount) =>
      efficacyContribution = efficacyContribution + amount;

  bool hasEfficacyContribution() => _efficacyContribution != null;

  // "efficacy_tier" field.
  int? _efficacyTier;
  int get efficacyTier => _efficacyTier ?? 0;
  set efficacyTier(int? val) => _efficacyTier = val;

  void incrementEfficacyTier(int amount) =>
      efficacyTier = efficacyTier + amount;

  bool hasEfficacyTier() => _efficacyTier != null;

  // "estimated_concentration" field.
  String? _estimatedConcentration;
  String get estimatedConcentration => _estimatedConcentration ?? '';
  set estimatedConcentration(String? val) => _estimatedConcentration = val;

  bool hasEstimatedConcentration() => _estimatedConcentration != null;

  // "evidence_level" field.
  String? _evidenceLevel;
  String get evidenceLevel => _evidenceLevel ?? '';
  set evidenceLevel(String? val) => _evidenceLevel = val;

  bool hasEvidenceLevel() => _evidenceLevel != null;

  // "inci_name" field.
  String? _inciName;
  String get inciName => _inciName ?? '';
  set inciName(String? val) => _inciName = val;

  bool hasInciName() => _inciName != null;

  // "is_active" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  set isActive(bool? val) => _isActive = val;

  bool hasIsActive() => _isActive != null;

  // "is_problematic" field.
  bool? _isProblematic;
  bool get isProblematic => _isProblematic ?? false;
  set isProblematic(bool? val) => _isProblematic = val;

  bool hasIsProblematic() => _isProblematic != null;

  // "mechanism" field.
  String? _mechanism;
  String get mechanism => _mechanism ?? '';
  set mechanism(String? val) => _mechanism = val;

  bool hasMechanism() => _mechanism != null;

  // "position" field.
  int? _position;
  int get position => _position ?? 0;
  set position(int? val) => _position = val;

  void incrementPosition(int amount) => position = position + amount;

  bool hasPosition() => _position != null;

  // "safety_contribution" field.
  int? _safetyContribution;
  int get safetyContribution => _safetyContribution ?? 0;
  set safetyContribution(int? val) => _safetyContribution = val;

  void incrementSafetyContribution(int amount) =>
      safetyContribution = safetyContribution + amount;

  bool hasSafetyContribution() => _safetyContribution != null;

  static IngredientAnalysisStruct fromMap(Map<String, dynamic> data) =>
      IngredientAnalysisStruct(
        category: data['category'] as String?,
        comedogenicityRating: castToType<int>(data['comedogenicity_rating']),
        efficacyContribution: castToType<int>(data['efficacy_contribution']),
        efficacyTier: castToType<int>(data['efficacy_tier']),
        estimatedConcentration: data['estimated_concentration'] as String?,
        evidenceLevel: data['evidence_level'] as String?,
        inciName: data['inci_name'] as String?,
        isActive: data['is_active'] as bool?,
        isProblematic: data['is_problematic'] as bool?,
        mechanism: data['mechanism'] as String?,
        position: castToType<int>(data['position']),
        safetyContribution: castToType<int>(data['safety_contribution']),
      );

  static IngredientAnalysisStruct? maybeFromMap(dynamic data) => data is Map
      ? IngredientAnalysisStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'category': _category,
        'comedogenicity_rating': _comedogenicityRating,
        'efficacy_contribution': _efficacyContribution,
        'efficacy_tier': _efficacyTier,
        'estimated_concentration': _estimatedConcentration,
        'evidence_level': _evidenceLevel,
        'inci_name': _inciName,
        'is_active': _isActive,
        'is_problematic': _isProblematic,
        'mechanism': _mechanism,
        'position': _position,
        'safety_contribution': _safetyContribution,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'category': serializeParam(
          _category,
          ParamType.String,
        ),
        'comedogenicity_rating': serializeParam(
          _comedogenicityRating,
          ParamType.int,
        ),
        'efficacy_contribution': serializeParam(
          _efficacyContribution,
          ParamType.int,
        ),
        'efficacy_tier': serializeParam(
          _efficacyTier,
          ParamType.int,
        ),
        'estimated_concentration': serializeParam(
          _estimatedConcentration,
          ParamType.String,
        ),
        'evidence_level': serializeParam(
          _evidenceLevel,
          ParamType.String,
        ),
        'inci_name': serializeParam(
          _inciName,
          ParamType.String,
        ),
        'is_active': serializeParam(
          _isActive,
          ParamType.bool,
        ),
        'is_problematic': serializeParam(
          _isProblematic,
          ParamType.bool,
        ),
        'mechanism': serializeParam(
          _mechanism,
          ParamType.String,
        ),
        'position': serializeParam(
          _position,
          ParamType.int,
        ),
        'safety_contribution': serializeParam(
          _safetyContribution,
          ParamType.int,
        ),
      }.withoutNulls;

  static IngredientAnalysisStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      IngredientAnalysisStruct(
        category: deserializeParam(
          data['category'],
          ParamType.String,
          false,
        ),
        comedogenicityRating: deserializeParam(
          data['comedogenicity_rating'],
          ParamType.int,
          false,
        ),
        efficacyContribution: deserializeParam(
          data['efficacy_contribution'],
          ParamType.int,
          false,
        ),
        efficacyTier: deserializeParam(
          data['efficacy_tier'],
          ParamType.int,
          false,
        ),
        estimatedConcentration: deserializeParam(
          data['estimated_concentration'],
          ParamType.String,
          false,
        ),
        evidenceLevel: deserializeParam(
          data['evidence_level'],
          ParamType.String,
          false,
        ),
        inciName: deserializeParam(
          data['inci_name'],
          ParamType.String,
          false,
        ),
        isActive: deserializeParam(
          data['is_active'],
          ParamType.bool,
          false,
        ),
        isProblematic: deserializeParam(
          data['is_problematic'],
          ParamType.bool,
          false,
        ),
        mechanism: deserializeParam(
          data['mechanism'],
          ParamType.String,
          false,
        ),
        position: deserializeParam(
          data['position'],
          ParamType.int,
          false,
        ),
        safetyContribution: deserializeParam(
          data['safety_contribution'],
          ParamType.int,
          false,
        ),
      );

  static IngredientAnalysisStruct fromAlgoliaData(Map<String, dynamic> data) =>
      IngredientAnalysisStruct(
        category: convertAlgoliaParam(
          data['category'],
          ParamType.String,
          false,
        ),
        comedogenicityRating: convertAlgoliaParam(
          data['comedogenicity_rating'],
          ParamType.int,
          false,
        ),
        efficacyContribution: convertAlgoliaParam(
          data['efficacy_contribution'],
          ParamType.int,
          false,
        ),
        efficacyTier: convertAlgoliaParam(
          data['efficacy_tier'],
          ParamType.int,
          false,
        ),
        estimatedConcentration: convertAlgoliaParam(
          data['estimated_concentration'],
          ParamType.String,
          false,
        ),
        evidenceLevel: convertAlgoliaParam(
          data['evidence_level'],
          ParamType.String,
          false,
        ),
        inciName: convertAlgoliaParam(
          data['inci_name'],
          ParamType.String,
          false,
        ),
        isActive: convertAlgoliaParam(
          data['is_active'],
          ParamType.bool,
          false,
        ),
        isProblematic: convertAlgoliaParam(
          data['is_problematic'],
          ParamType.bool,
          false,
        ),
        mechanism: convertAlgoliaParam(
          data['mechanism'],
          ParamType.String,
          false,
        ),
        position: convertAlgoliaParam(
          data['position'],
          ParamType.int,
          false,
        ),
        safetyContribution: convertAlgoliaParam(
          data['safety_contribution'],
          ParamType.int,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'IngredientAnalysisStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is IngredientAnalysisStruct &&
        category == other.category &&
        comedogenicityRating == other.comedogenicityRating &&
        efficacyContribution == other.efficacyContribution &&
        efficacyTier == other.efficacyTier &&
        estimatedConcentration == other.estimatedConcentration &&
        evidenceLevel == other.evidenceLevel &&
        inciName == other.inciName &&
        isActive == other.isActive &&
        isProblematic == other.isProblematic &&
        mechanism == other.mechanism &&
        position == other.position &&
        safetyContribution == other.safetyContribution;
  }

  @override
  int get hashCode => const ListEquality().hash([
        category,
        comedogenicityRating,
        efficacyContribution,
        efficacyTier,
        estimatedConcentration,
        evidenceLevel,
        inciName,
        isActive,
        isProblematic,
        mechanism,
        position,
        safetyContribution
      ]);
}

IngredientAnalysisStruct createIngredientAnalysisStruct({
  String? category,
  int? comedogenicityRating,
  int? efficacyContribution,
  int? efficacyTier,
  String? estimatedConcentration,
  String? evidenceLevel,
  String? inciName,
  bool? isActive,
  bool? isProblematic,
  String? mechanism,
  int? position,
  int? safetyContribution,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    IngredientAnalysisStruct(
      category: category,
      comedogenicityRating: comedogenicityRating,
      efficacyContribution: efficacyContribution,
      efficacyTier: efficacyTier,
      estimatedConcentration: estimatedConcentration,
      evidenceLevel: evidenceLevel,
      inciName: inciName,
      isActive: isActive,
      isProblematic: isProblematic,
      mechanism: mechanism,
      position: position,
      safetyContribution: safetyContribution,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

IngredientAnalysisStruct? updateIngredientAnalysisStruct(
  IngredientAnalysisStruct? ingredientAnalysis, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    ingredientAnalysis
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addIngredientAnalysisStructData(
  Map<String, dynamic> firestoreData,
  IngredientAnalysisStruct? ingredientAnalysis,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (ingredientAnalysis == null) {
    return;
  }
  if (ingredientAnalysis.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && ingredientAnalysis.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final ingredientAnalysisData =
      getIngredientAnalysisFirestoreData(ingredientAnalysis, forFieldValue);
  final nestedData =
      ingredientAnalysisData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      ingredientAnalysis.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getIngredientAnalysisFirestoreData(
  IngredientAnalysisStruct? ingredientAnalysis, [
  bool forFieldValue = false,
]) {
  if (ingredientAnalysis == null) {
    return {};
  }
  final firestoreData = mapToFirestore(ingredientAnalysis.toMap());

  // Add any Firestore field values
  mapToFirestore(ingredientAnalysis.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getIngredientAnalysisListFirestoreData(
  List<IngredientAnalysisStruct>? ingredientAnalysiss,
) =>
    ingredientAnalysiss
        ?.map((e) => getIngredientAnalysisFirestoreData(e, true))
        .toList() ??
    [];
