// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class DatabaseCoverageStruct extends FFFirebaseStruct {
  DatabaseCoverageStruct({
    int? foundInDb,
    int? queuedForResearch,
    int? totalIngredients,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _foundInDb = foundInDb,
        _queuedForResearch = queuedForResearch,
        _totalIngredients = totalIngredients,
        super(firestoreUtilData);

  // "found_in_db" field.
  int? _foundInDb;
  int get foundInDb => _foundInDb ?? 0;
  set foundInDb(int? val) => _foundInDb = val;

  void incrementFoundInDb(int amount) => foundInDb = foundInDb + amount;

  bool hasFoundInDb() => _foundInDb != null;

  // "queued_for_research" field.
  int? _queuedForResearch;
  int get queuedForResearch => _queuedForResearch ?? 0;
  set queuedForResearch(int? val) => _queuedForResearch = val;

  void incrementQueuedForResearch(int amount) =>
      queuedForResearch = queuedForResearch + amount;

  bool hasQueuedForResearch() => _queuedForResearch != null;

  // "total_ingredients" field.
  int? _totalIngredients;
  int get totalIngredients => _totalIngredients ?? 0;
  set totalIngredients(int? val) => _totalIngredients = val;

  void incrementTotalIngredients(int amount) =>
      totalIngredients = totalIngredients + amount;

  bool hasTotalIngredients() => _totalIngredients != null;

  static DatabaseCoverageStruct fromMap(Map<String, dynamic> data) =>
      DatabaseCoverageStruct(
        foundInDb: castToType<int>(data['found_in_db']),
        queuedForResearch: castToType<int>(data['queued_for_research']),
        totalIngredients: castToType<int>(data['total_ingredients']),
      );

  static DatabaseCoverageStruct? maybeFromMap(dynamic data) => data is Map
      ? DatabaseCoverageStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'found_in_db': _foundInDb,
        'queued_for_research': _queuedForResearch,
        'total_ingredients': _totalIngredients,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'found_in_db': serializeParam(
          _foundInDb,
          ParamType.int,
        ),
        'queued_for_research': serializeParam(
          _queuedForResearch,
          ParamType.int,
        ),
        'total_ingredients': serializeParam(
          _totalIngredients,
          ParamType.int,
        ),
      }.withoutNulls;

  static DatabaseCoverageStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      DatabaseCoverageStruct(
        foundInDb: deserializeParam(
          data['found_in_db'],
          ParamType.int,
          false,
        ),
        queuedForResearch: deserializeParam(
          data['queued_for_research'],
          ParamType.int,
          false,
        ),
        totalIngredients: deserializeParam(
          data['total_ingredients'],
          ParamType.int,
          false,
        ),
      );

  static DatabaseCoverageStruct fromAlgoliaData(Map<String, dynamic> data) =>
      DatabaseCoverageStruct(
        foundInDb: convertAlgoliaParam(
          data['found_in_db'],
          ParamType.int,
          false,
        ),
        queuedForResearch: convertAlgoliaParam(
          data['queued_for_research'],
          ParamType.int,
          false,
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
  String toString() => 'DatabaseCoverageStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DatabaseCoverageStruct &&
        foundInDb == other.foundInDb &&
        queuedForResearch == other.queuedForResearch &&
        totalIngredients == other.totalIngredients;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([foundInDb, queuedForResearch, totalIngredients]);
}

DatabaseCoverageStruct createDatabaseCoverageStruct({
  int? foundInDb,
  int? queuedForResearch,
  int? totalIngredients,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    DatabaseCoverageStruct(
      foundInDb: foundInDb,
      queuedForResearch: queuedForResearch,
      totalIngredients: totalIngredients,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

DatabaseCoverageStruct? updateDatabaseCoverageStruct(
  DatabaseCoverageStruct? databaseCoverage, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    databaseCoverage
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addDatabaseCoverageStructData(
  Map<String, dynamic> firestoreData,
  DatabaseCoverageStruct? databaseCoverage,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (databaseCoverage == null) {
    return;
  }
  if (databaseCoverage.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && databaseCoverage.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final databaseCoverageData =
      getDatabaseCoverageFirestoreData(databaseCoverage, forFieldValue);
  final nestedData =
      databaseCoverageData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = databaseCoverage.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getDatabaseCoverageFirestoreData(
  DatabaseCoverageStruct? databaseCoverage, [
  bool forFieldValue = false,
]) {
  if (databaseCoverage == null) {
    return {};
  }
  final firestoreData = mapToFirestore(databaseCoverage.toMap());

  // Add any Firestore field values
  mapToFirestore(databaseCoverage.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getDatabaseCoverageListFirestoreData(
  List<DatabaseCoverageStruct>? databaseCoverages,
) =>
    databaseCoverages
        ?.map((e) => getDatabaseCoverageFirestoreData(e, true))
        .toList() ??
    [];
