// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StabilityStruct extends FFFirebaseStruct {
  StabilityStruct({
    String? calculationBreakdown,
    int? confidence,
    List<String>? keyFactors,
    int? score,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _calculationBreakdown = calculationBreakdown,
        _confidence = confidence,
        _keyFactors = keyFactors,
        _score = score,
        super(firestoreUtilData);

  // "calculation_breakdown" field.
  String? _calculationBreakdown;
  String get calculationBreakdown => _calculationBreakdown ?? '';
  set calculationBreakdown(String? val) => _calculationBreakdown = val;

  bool hasCalculationBreakdown() => _calculationBreakdown != null;

  // "confidence" field.
  int? _confidence;
  int get confidence => _confidence ?? 0;
  set confidence(int? val) => _confidence = val;

  void incrementConfidence(int amount) => confidence = confidence + amount;

  bool hasConfidence() => _confidence != null;

  // "key_factors" field.
  List<String>? _keyFactors;
  List<String> get keyFactors => _keyFactors ?? const [];
  set keyFactors(List<String>? val) => _keyFactors = val;

  void updateKeyFactors(Function(List<String>) updateFn) {
    updateFn(_keyFactors ??= []);
  }

  bool hasKeyFactors() => _keyFactors != null;

  // "score" field.
  int? _score;
  int get score => _score ?? 0;
  set score(int? val) => _score = val;

  void incrementScore(int amount) => score = score + amount;

  bool hasScore() => _score != null;

  static StabilityStruct fromMap(Map<String, dynamic> data) => StabilityStruct(
        calculationBreakdown: data['calculation_breakdown'] as String?,
        confidence: castToType<int>(data['confidence']),
        keyFactors: getDataList(data['key_factors']),
        score: castToType<int>(data['score']),
      );

  static StabilityStruct? maybeFromMap(dynamic data) => data is Map
      ? StabilityStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'calculation_breakdown': _calculationBreakdown,
        'confidence': _confidence,
        'key_factors': _keyFactors,
        'score': _score,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'calculation_breakdown': serializeParam(
          _calculationBreakdown,
          ParamType.String,
        ),
        'confidence': serializeParam(
          _confidence,
          ParamType.int,
        ),
        'key_factors': serializeParam(
          _keyFactors,
          ParamType.String,
          isList: true,
        ),
        'score': serializeParam(
          _score,
          ParamType.int,
        ),
      }.withoutNulls;

  static StabilityStruct fromSerializableMap(Map<String, dynamic> data) =>
      StabilityStruct(
        calculationBreakdown: deserializeParam(
          data['calculation_breakdown'],
          ParamType.String,
          false,
        ),
        confidence: deserializeParam(
          data['confidence'],
          ParamType.int,
          false,
        ),
        keyFactors: deserializeParam<String>(
          data['key_factors'],
          ParamType.String,
          true,
        ),
        score: deserializeParam(
          data['score'],
          ParamType.int,
          false,
        ),
      );

  static StabilityStruct fromAlgoliaData(Map<String, dynamic> data) =>
      StabilityStruct(
        calculationBreakdown: convertAlgoliaParam(
          data['calculation_breakdown'],
          ParamType.String,
          false,
        ),
        confidence: convertAlgoliaParam(
          data['confidence'],
          ParamType.int,
          false,
        ),
        keyFactors: convertAlgoliaParam<String>(
          data['key_factors'],
          ParamType.String,
          true,
        ),
        score: convertAlgoliaParam(
          data['score'],
          ParamType.int,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'StabilityStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is StabilityStruct &&
        calculationBreakdown == other.calculationBreakdown &&
        confidence == other.confidence &&
        listEquality.equals(keyFactors, other.keyFactors) &&
        score == other.score;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([calculationBreakdown, confidence, keyFactors, score]);
}

StabilityStruct createStabilityStruct({
  String? calculationBreakdown,
  int? confidence,
  int? score,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    StabilityStruct(
      calculationBreakdown: calculationBreakdown,
      confidence: confidence,
      score: score,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

StabilityStruct? updateStabilityStruct(
  StabilityStruct? stability, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    stability
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addStabilityStructData(
  Map<String, dynamic> firestoreData,
  StabilityStruct? stability,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (stability == null) {
    return;
  }
  if (stability.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && stability.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final stabilityData = getStabilityFirestoreData(stability, forFieldValue);
  final nestedData = stabilityData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = stability.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getStabilityFirestoreData(
  StabilityStruct? stability, [
  bool forFieldValue = false,
]) {
  if (stability == null) {
    return {};
  }
  final firestoreData = mapToFirestore(stability.toMap());

  // Add any Firestore field values
  mapToFirestore(stability.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getStabilityListFirestoreData(
  List<StabilityStruct>? stabilitys,
) =>
    stabilitys?.map((e) => getStabilityFirestoreData(e, true)).toList() ?? [];
