// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class KeyReferencesStruct extends FFFirebaseStruct {
  KeyReferencesStruct({
    String? finding,
    String? source,
    int? year,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _finding = finding,
        _source = source,
        _year = year,
        super(firestoreUtilData);

  // "finding" field.
  String? _finding;
  String get finding => _finding ?? '';
  set finding(String? val) => _finding = val;

  bool hasFinding() => _finding != null;

  // "source" field.
  String? _source;
  String get source => _source ?? '';
  set source(String? val) => _source = val;

  bool hasSource() => _source != null;

  // "year" field.
  int? _year;
  int get year => _year ?? 0;
  set year(int? val) => _year = val;

  void incrementYear(int amount) => year = year + amount;

  bool hasYear() => _year != null;

  static KeyReferencesStruct fromMap(Map<String, dynamic> data) =>
      KeyReferencesStruct(
        finding: data['finding'] as String?,
        source: data['source'] as String?,
        year: castToType<int>(data['year']),
      );

  static KeyReferencesStruct? maybeFromMap(dynamic data) => data is Map
      ? KeyReferencesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'finding': _finding,
        'source': _source,
        'year': _year,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'finding': serializeParam(
          _finding,
          ParamType.String,
        ),
        'source': serializeParam(
          _source,
          ParamType.String,
        ),
        'year': serializeParam(
          _year,
          ParamType.int,
        ),
      }.withoutNulls;

  static KeyReferencesStruct fromSerializableMap(Map<String, dynamic> data) =>
      KeyReferencesStruct(
        finding: deserializeParam(
          data['finding'],
          ParamType.String,
          false,
        ),
        source: deserializeParam(
          data['source'],
          ParamType.String,
          false,
        ),
        year: deserializeParam(
          data['year'],
          ParamType.int,
          false,
        ),
      );

  static KeyReferencesStruct fromAlgoliaData(Map<String, dynamic> data) =>
      KeyReferencesStruct(
        finding: convertAlgoliaParam(
          data['finding'],
          ParamType.String,
          false,
        ),
        source: convertAlgoliaParam(
          data['source'],
          ParamType.String,
          false,
        ),
        year: convertAlgoliaParam(
          data['year'],
          ParamType.int,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'KeyReferencesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is KeyReferencesStruct &&
        finding == other.finding &&
        source == other.source &&
        year == other.year;
  }

  @override
  int get hashCode => const ListEquality().hash([finding, source, year]);
}

KeyReferencesStruct createKeyReferencesStruct({
  String? finding,
  String? source,
  int? year,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    KeyReferencesStruct(
      finding: finding,
      source: source,
      year: year,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

KeyReferencesStruct? updateKeyReferencesStruct(
  KeyReferencesStruct? keyReferences, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    keyReferences
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addKeyReferencesStructData(
  Map<String, dynamic> firestoreData,
  KeyReferencesStruct? keyReferences,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (keyReferences == null) {
    return;
  }
  if (keyReferences.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && keyReferences.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final keyReferencesData =
      getKeyReferencesFirestoreData(keyReferences, forFieldValue);
  final nestedData =
      keyReferencesData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = keyReferences.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getKeyReferencesFirestoreData(
  KeyReferencesStruct? keyReferences, [
  bool forFieldValue = false,
]) {
  if (keyReferences == null) {
    return {};
  }
  final firestoreData = mapToFirestore(keyReferences.toMap());

  // Add any Firestore field values
  mapToFirestore(keyReferences.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getKeyReferencesListFirestoreData(
  List<KeyReferencesStruct>? keyReferencess,
) =>
    keyReferencess
        ?.map((e) => getKeyReferencesFirestoreData(e, true))
        .toList() ??
    [];
