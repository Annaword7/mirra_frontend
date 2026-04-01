// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class SkinTypeSuitabilityStruct extends FFFirebaseStruct {
  SkinTypeSuitabilityStruct({
    int? acneProne,
    int? combination,
    int? dry,
    int? normal,
    int? oily,
    int? sensitive,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _acneProne = acneProne,
        _combination = combination,
        _dry = dry,
        _normal = normal,
        _oily = oily,
        _sensitive = sensitive,
        super(firestoreUtilData);

  // "acne_prone" field.
  int? _acneProne;
  int get acneProne => _acneProne ?? 0;
  set acneProne(int? val) => _acneProne = val;

  void incrementAcneProne(int amount) => acneProne = acneProne + amount;

  bool hasAcneProne() => _acneProne != null;

  // "combination" field.
  int? _combination;
  int get combination => _combination ?? 0;
  set combination(int? val) => _combination = val;

  void incrementCombination(int amount) => combination = combination + amount;

  bool hasCombination() => _combination != null;

  // "dry" field.
  int? _dry;
  int get dry => _dry ?? 0;
  set dry(int? val) => _dry = val;

  void incrementDry(int amount) => dry = dry + amount;

  bool hasDry() => _dry != null;

  // "normal" field.
  int? _normal;
  int get normal => _normal ?? 0;
  set normal(int? val) => _normal = val;

  void incrementNormal(int amount) => normal = normal + amount;

  bool hasNormal() => _normal != null;

  // "oily" field.
  int? _oily;
  int get oily => _oily ?? 0;
  set oily(int? val) => _oily = val;

  void incrementOily(int amount) => oily = oily + amount;

  bool hasOily() => _oily != null;

  // "sensitive" field.
  int? _sensitive;
  int get sensitive => _sensitive ?? 0;
  set sensitive(int? val) => _sensitive = val;

  void incrementSensitive(int amount) => sensitive = sensitive + amount;

  bool hasSensitive() => _sensitive != null;

  static SkinTypeSuitabilityStruct fromMap(Map<String, dynamic> data) =>
      SkinTypeSuitabilityStruct(
        acneProne: castToType<int>(data['acne_prone']),
        combination: castToType<int>(data['combination']),
        dry: castToType<int>(data['dry']),
        normal: castToType<int>(data['normal']),
        oily: castToType<int>(data['oily']),
        sensitive: castToType<int>(data['sensitive']),
      );

  static SkinTypeSuitabilityStruct? maybeFromMap(dynamic data) => data is Map
      ? SkinTypeSuitabilityStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'acne_prone': _acneProne,
        'combination': _combination,
        'dry': _dry,
        'normal': _normal,
        'oily': _oily,
        'sensitive': _sensitive,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'acne_prone': serializeParam(
          _acneProne,
          ParamType.int,
        ),
        'combination': serializeParam(
          _combination,
          ParamType.int,
        ),
        'dry': serializeParam(
          _dry,
          ParamType.int,
        ),
        'normal': serializeParam(
          _normal,
          ParamType.int,
        ),
        'oily': serializeParam(
          _oily,
          ParamType.int,
        ),
        'sensitive': serializeParam(
          _sensitive,
          ParamType.int,
        ),
      }.withoutNulls;

  static SkinTypeSuitabilityStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      SkinTypeSuitabilityStruct(
        acneProne: deserializeParam(
          data['acne_prone'],
          ParamType.int,
          false,
        ),
        combination: deserializeParam(
          data['combination'],
          ParamType.int,
          false,
        ),
        dry: deserializeParam(
          data['dry'],
          ParamType.int,
          false,
        ),
        normal: deserializeParam(
          data['normal'],
          ParamType.int,
          false,
        ),
        oily: deserializeParam(
          data['oily'],
          ParamType.int,
          false,
        ),
        sensitive: deserializeParam(
          data['sensitive'],
          ParamType.int,
          false,
        ),
      );

  static SkinTypeSuitabilityStruct fromAlgoliaData(Map<String, dynamic> data) =>
      SkinTypeSuitabilityStruct(
        acneProne: convertAlgoliaParam(
          data['acne_prone'],
          ParamType.int,
          false,
        ),
        combination: convertAlgoliaParam(
          data['combination'],
          ParamType.int,
          false,
        ),
        dry: convertAlgoliaParam(
          data['dry'],
          ParamType.int,
          false,
        ),
        normal: convertAlgoliaParam(
          data['normal'],
          ParamType.int,
          false,
        ),
        oily: convertAlgoliaParam(
          data['oily'],
          ParamType.int,
          false,
        ),
        sensitive: convertAlgoliaParam(
          data['sensitive'],
          ParamType.int,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'SkinTypeSuitabilityStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SkinTypeSuitabilityStruct &&
        acneProne == other.acneProne &&
        combination == other.combination &&
        dry == other.dry &&
        normal == other.normal &&
        oily == other.oily &&
        sensitive == other.sensitive;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([acneProne, combination, dry, normal, oily, sensitive]);
}

SkinTypeSuitabilityStruct createSkinTypeSuitabilityStruct({
  int? acneProne,
  int? combination,
  int? dry,
  int? normal,
  int? oily,
  int? sensitive,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SkinTypeSuitabilityStruct(
      acneProne: acneProne,
      combination: combination,
      dry: dry,
      normal: normal,
      oily: oily,
      sensitive: sensitive,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SkinTypeSuitabilityStruct? updateSkinTypeSuitabilityStruct(
  SkinTypeSuitabilityStruct? skinTypeSuitability, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    skinTypeSuitability
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSkinTypeSuitabilityStructData(
  Map<String, dynamic> firestoreData,
  SkinTypeSuitabilityStruct? skinTypeSuitability,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (skinTypeSuitability == null) {
    return;
  }
  if (skinTypeSuitability.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && skinTypeSuitability.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final skinTypeSuitabilityData =
      getSkinTypeSuitabilityFirestoreData(skinTypeSuitability, forFieldValue);
  final nestedData =
      skinTypeSuitabilityData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      skinTypeSuitability.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSkinTypeSuitabilityFirestoreData(
  SkinTypeSuitabilityStruct? skinTypeSuitability, [
  bool forFieldValue = false,
]) {
  if (skinTypeSuitability == null) {
    return {};
  }
  final firestoreData = mapToFirestore(skinTypeSuitability.toMap());

  // Add any Firestore field values
  mapToFirestore(skinTypeSuitability.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSkinTypeSuitabilityListFirestoreData(
  List<SkinTypeSuitabilityStruct>? skinTypeSuitabilitys,
) =>
    skinTypeSuitabilitys
        ?.map((e) => getSkinTypeSuitabilityFirestoreData(e, true))
        .toList() ??
    [];
