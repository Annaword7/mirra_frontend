// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ScoresStruct extends FFFirebaseStruct {
  ScoresStruct({
    ComedogenicityStruct? comedogenicity,
    String? compositeCalculation,
    double? compositeScore,
    EfficacyStruct? efficacy,
    SafetyStruct? safety,
    StabilityStruct? stability,
    UserExperienceStruct? userExperience,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _comedogenicity = comedogenicity,
        _compositeCalculation = compositeCalculation,
        _compositeScore = compositeScore,
        _efficacy = efficacy,
        _safety = safety,
        _stability = stability,
        _userExperience = userExperience,
        super(firestoreUtilData);

  // "comedogenicity" field.
  ComedogenicityStruct? _comedogenicity;
  ComedogenicityStruct get comedogenicity =>
      _comedogenicity ?? ComedogenicityStruct();
  set comedogenicity(ComedogenicityStruct? val) => _comedogenicity = val;

  void updateComedogenicity(Function(ComedogenicityStruct) updateFn) {
    updateFn(_comedogenicity ??= ComedogenicityStruct());
  }

  bool hasComedogenicity() => _comedogenicity != null;

  // "composite_calculation" field.
  String? _compositeCalculation;
  String get compositeCalculation => _compositeCalculation ?? '';
  set compositeCalculation(String? val) => _compositeCalculation = val;

  bool hasCompositeCalculation() => _compositeCalculation != null;

  // "composite_score" field.
  double? _compositeScore;
  double get compositeScore => _compositeScore ?? 0.0;
  set compositeScore(double? val) => _compositeScore = val;

  void incrementCompositeScore(double amount) =>
      compositeScore = compositeScore + amount;

  bool hasCompositeScore() => _compositeScore != null;

  // "efficacy" field.
  EfficacyStruct? _efficacy;
  EfficacyStruct get efficacy => _efficacy ?? EfficacyStruct();
  set efficacy(EfficacyStruct? val) => _efficacy = val;

  void updateEfficacy(Function(EfficacyStruct) updateFn) {
    updateFn(_efficacy ??= EfficacyStruct());
  }

  bool hasEfficacy() => _efficacy != null;

  // "safety" field.
  SafetyStruct? _safety;
  SafetyStruct get safety => _safety ?? SafetyStruct();
  set safety(SafetyStruct? val) => _safety = val;

  void updateSafety(Function(SafetyStruct) updateFn) {
    updateFn(_safety ??= SafetyStruct());
  }

  bool hasSafety() => _safety != null;

  // "stability" field.
  StabilityStruct? _stability;
  StabilityStruct get stability => _stability ?? StabilityStruct();
  set stability(StabilityStruct? val) => _stability = val;

  void updateStability(Function(StabilityStruct) updateFn) {
    updateFn(_stability ??= StabilityStruct());
  }

  bool hasStability() => _stability != null;

  // "user_experience" field.
  UserExperienceStruct? _userExperience;
  UserExperienceStruct get userExperience =>
      _userExperience ?? UserExperienceStruct();
  set userExperience(UserExperienceStruct? val) => _userExperience = val;

  void updateUserExperience(Function(UserExperienceStruct) updateFn) {
    updateFn(_userExperience ??= UserExperienceStruct());
  }

  bool hasUserExperience() => _userExperience != null;

  static ScoresStruct fromMap(Map<String, dynamic> data) => ScoresStruct(
        comedogenicity: data['comedogenicity'] is ComedogenicityStruct
            ? data['comedogenicity']
            : ComedogenicityStruct.maybeFromMap(data['comedogenicity']),
        compositeCalculation: data['composite_calculation'] as String?,
        compositeScore: castToType<double>(data['composite_score']),
        efficacy: data['efficacy'] is EfficacyStruct
            ? data['efficacy']
            : EfficacyStruct.maybeFromMap(data['efficacy']),
        safety: data['safety'] is SafetyStruct
            ? data['safety']
            : SafetyStruct.maybeFromMap(data['safety']),
        stability: data['stability'] is StabilityStruct
            ? data['stability']
            : StabilityStruct.maybeFromMap(data['stability']),
        userExperience: data['user_experience'] is UserExperienceStruct
            ? data['user_experience']
            : UserExperienceStruct.maybeFromMap(data['user_experience']),
      );

  static ScoresStruct? maybeFromMap(dynamic data) =>
      data is Map ? ScoresStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'comedogenicity': _comedogenicity?.toMap(),
        'composite_calculation': _compositeCalculation,
        'composite_score': _compositeScore,
        'efficacy': _efficacy?.toMap(),
        'safety': _safety?.toMap(),
        'stability': _stability?.toMap(),
        'user_experience': _userExperience?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'comedogenicity': serializeParam(
          _comedogenicity,
          ParamType.DataStruct,
        ),
        'composite_calculation': serializeParam(
          _compositeCalculation,
          ParamType.String,
        ),
        'composite_score': serializeParam(
          _compositeScore,
          ParamType.double,
        ),
        'efficacy': serializeParam(
          _efficacy,
          ParamType.DataStruct,
        ),
        'safety': serializeParam(
          _safety,
          ParamType.DataStruct,
        ),
        'stability': serializeParam(
          _stability,
          ParamType.DataStruct,
        ),
        'user_experience': serializeParam(
          _userExperience,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static ScoresStruct fromSerializableMap(Map<String, dynamic> data) =>
      ScoresStruct(
        comedogenicity: deserializeStructParam(
          data['comedogenicity'],
          ParamType.DataStruct,
          false,
          structBuilder: ComedogenicityStruct.fromSerializableMap,
        ),
        compositeCalculation: deserializeParam(
          data['composite_calculation'],
          ParamType.String,
          false,
        ),
        compositeScore: deserializeParam(
          data['composite_score'],
          ParamType.double,
          false,
        ),
        efficacy: deserializeStructParam(
          data['efficacy'],
          ParamType.DataStruct,
          false,
          structBuilder: EfficacyStruct.fromSerializableMap,
        ),
        safety: deserializeStructParam(
          data['safety'],
          ParamType.DataStruct,
          false,
          structBuilder: SafetyStruct.fromSerializableMap,
        ),
        stability: deserializeStructParam(
          data['stability'],
          ParamType.DataStruct,
          false,
          structBuilder: StabilityStruct.fromSerializableMap,
        ),
        userExperience: deserializeStructParam(
          data['user_experience'],
          ParamType.DataStruct,
          false,
          structBuilder: UserExperienceStruct.fromSerializableMap,
        ),
      );

  static ScoresStruct fromAlgoliaData(Map<String, dynamic> data) =>
      ScoresStruct(
        comedogenicity: convertAlgoliaParam(
          data['comedogenicity'],
          ParamType.DataStruct,
          false,
          structBuilder: ComedogenicityStruct.fromAlgoliaData,
        ),
        compositeCalculation: convertAlgoliaParam(
          data['composite_calculation'],
          ParamType.String,
          false,
        ),
        compositeScore: convertAlgoliaParam(
          data['composite_score'],
          ParamType.double,
          false,
        ),
        efficacy: convertAlgoliaParam(
          data['efficacy'],
          ParamType.DataStruct,
          false,
          structBuilder: EfficacyStruct.fromAlgoliaData,
        ),
        safety: convertAlgoliaParam(
          data['safety'],
          ParamType.DataStruct,
          false,
          structBuilder: SafetyStruct.fromAlgoliaData,
        ),
        stability: convertAlgoliaParam(
          data['stability'],
          ParamType.DataStruct,
          false,
          structBuilder: StabilityStruct.fromAlgoliaData,
        ),
        userExperience: convertAlgoliaParam(
          data['user_experience'],
          ParamType.DataStruct,
          false,
          structBuilder: UserExperienceStruct.fromAlgoliaData,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'ScoresStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ScoresStruct &&
        comedogenicity == other.comedogenicity &&
        compositeCalculation == other.compositeCalculation &&
        compositeScore == other.compositeScore &&
        efficacy == other.efficacy &&
        safety == other.safety &&
        stability == other.stability &&
        userExperience == other.userExperience;
  }

  @override
  int get hashCode => const ListEquality().hash([
        comedogenicity,
        compositeCalculation,
        compositeScore,
        efficacy,
        safety,
        stability,
        userExperience
      ]);
}

ScoresStruct createScoresStruct({
  ComedogenicityStruct? comedogenicity,
  String? compositeCalculation,
  double? compositeScore,
  EfficacyStruct? efficacy,
  SafetyStruct? safety,
  StabilityStruct? stability,
  UserExperienceStruct? userExperience,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ScoresStruct(
      comedogenicity:
          comedogenicity ?? (clearUnsetFields ? ComedogenicityStruct() : null),
      compositeCalculation: compositeCalculation,
      compositeScore: compositeScore,
      efficacy: efficacy ?? (clearUnsetFields ? EfficacyStruct() : null),
      safety: safety ?? (clearUnsetFields ? SafetyStruct() : null),
      stability: stability ?? (clearUnsetFields ? StabilityStruct() : null),
      userExperience:
          userExperience ?? (clearUnsetFields ? UserExperienceStruct() : null),
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ScoresStruct? updateScoresStruct(
  ScoresStruct? scores, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    scores
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addScoresStructData(
  Map<String, dynamic> firestoreData,
  ScoresStruct? scores,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (scores == null) {
    return;
  }
  if (scores.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && scores.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final scoresData = getScoresFirestoreData(scores, forFieldValue);
  final nestedData = scoresData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = scores.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getScoresFirestoreData(
  ScoresStruct? scores, [
  bool forFieldValue = false,
]) {
  if (scores == null) {
    return {};
  }
  final firestoreData = mapToFirestore(scores.toMap());

  // Handle nested data for "comedogenicity" field.
  addComedogenicityStructData(
    firestoreData,
    scores.hasComedogenicity() ? scores.comedogenicity : null,
    'comedogenicity',
    forFieldValue,
  );

  // Handle nested data for "efficacy" field.
  addEfficacyStructData(
    firestoreData,
    scores.hasEfficacy() ? scores.efficacy : null,
    'efficacy',
    forFieldValue,
  );

  // Handle nested data for "safety" field.
  addSafetyStructData(
    firestoreData,
    scores.hasSafety() ? scores.safety : null,
    'safety',
    forFieldValue,
  );

  // Handle nested data for "stability" field.
  addStabilityStructData(
    firestoreData,
    scores.hasStability() ? scores.stability : null,
    'stability',
    forFieldValue,
  );

  // Handle nested data for "user_experience" field.
  addUserExperienceStructData(
    firestoreData,
    scores.hasUserExperience() ? scores.userExperience : null,
    'user_experience',
    forFieldValue,
  );

  // Add any Firestore field values
  mapToFirestore(scores.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getScoresListFirestoreData(
  List<ScoresStruct>? scoress,
) =>
    scoress?.map((e) => getScoresFirestoreData(e, true)).toList() ?? [];
