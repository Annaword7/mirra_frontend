// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ScientificanalysStruct extends FFFirebaseStruct {
  ScientificanalysStruct({
    AnalysisStruct? analysis,
    String? brand,
    DatabaseCoverageStruct? databaseCoverage,
    String? formattedDisplay,
    String? imageId,
    double? legacyScore,
    String? productName,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _analysis = analysis,
        _brand = brand,
        _databaseCoverage = databaseCoverage,
        _formattedDisplay = formattedDisplay,
        _imageId = imageId,
        _legacyScore = legacyScore,
        _productName = productName,
        super(firestoreUtilData);

  // "analysis" field.
  AnalysisStruct? _analysis;
  AnalysisStruct get analysis => _analysis ?? AnalysisStruct();
  set analysis(AnalysisStruct? val) => _analysis = val;

  void updateAnalysis(Function(AnalysisStruct) updateFn) {
    updateFn(_analysis ??= AnalysisStruct());
  }

  bool hasAnalysis() => _analysis != null;

  // "brand" field.
  String? _brand;
  String get brand => _brand ?? '';
  set brand(String? val) => _brand = val;

  bool hasBrand() => _brand != null;

  // "database_coverage" field.
  DatabaseCoverageStruct? _databaseCoverage;
  DatabaseCoverageStruct get databaseCoverage =>
      _databaseCoverage ?? DatabaseCoverageStruct();
  set databaseCoverage(DatabaseCoverageStruct? val) => _databaseCoverage = val;

  void updateDatabaseCoverage(Function(DatabaseCoverageStruct) updateFn) {
    updateFn(_databaseCoverage ??= DatabaseCoverageStruct());
  }

  bool hasDatabaseCoverage() => _databaseCoverage != null;

  // "formatted_display" field.
  String? _formattedDisplay;
  String get formattedDisplay => _formattedDisplay ?? '';
  set formattedDisplay(String? val) => _formattedDisplay = val;

  bool hasFormattedDisplay() => _formattedDisplay != null;

  // "image_id" field.
  String? _imageId;
  String get imageId => _imageId ?? '';
  set imageId(String? val) => _imageId = val;

  bool hasImageId() => _imageId != null;

  // "legacy_score" field.
  double? _legacyScore;
  double get legacyScore => _legacyScore ?? 0.0;
  set legacyScore(double? val) => _legacyScore = val;

  void incrementLegacyScore(double amount) =>
      legacyScore = legacyScore + amount;

  bool hasLegacyScore() => _legacyScore != null;

  // "product_name" field.
  String? _productName;
  String get productName => _productName ?? '';
  set productName(String? val) => _productName = val;

  bool hasProductName() => _productName != null;

  static ScientificanalysStruct fromMap(Map<String, dynamic> data) =>
      ScientificanalysStruct(
        analysis: data['analysis'] is AnalysisStruct
            ? data['analysis']
            : AnalysisStruct.maybeFromMap(data['analysis']),
        brand: data['brand'] as String?,
        databaseCoverage: data['database_coverage'] is DatabaseCoverageStruct
            ? data['database_coverage']
            : DatabaseCoverageStruct.maybeFromMap(data['database_coverage']),
        formattedDisplay: data['formatted_display'] as String?,
        imageId: data['image_id'] as String?,
        legacyScore: castToType<double>(data['legacy_score']),
        productName: data['product_name'] as String?,
      );

  static ScientificanalysStruct? maybeFromMap(dynamic data) => data is Map
      ? ScientificanalysStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'analysis': _analysis?.toMap(),
        'brand': _brand,
        'database_coverage': _databaseCoverage?.toMap(),
        'formatted_display': _formattedDisplay,
        'image_id': _imageId,
        'legacy_score': _legacyScore,
        'product_name': _productName,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'analysis': serializeParam(
          _analysis,
          ParamType.DataStruct,
        ),
        'brand': serializeParam(
          _brand,
          ParamType.String,
        ),
        'database_coverage': serializeParam(
          _databaseCoverage,
          ParamType.DataStruct,
        ),
        'formatted_display': serializeParam(
          _formattedDisplay,
          ParamType.String,
        ),
        'image_id': serializeParam(
          _imageId,
          ParamType.String,
        ),
        'legacy_score': serializeParam(
          _legacyScore,
          ParamType.double,
        ),
        'product_name': serializeParam(
          _productName,
          ParamType.String,
        ),
      }.withoutNulls;

  static ScientificanalysStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ScientificanalysStruct(
        analysis: deserializeStructParam(
          data['analysis'],
          ParamType.DataStruct,
          false,
          structBuilder: AnalysisStruct.fromSerializableMap,
        ),
        brand: deserializeParam(
          data['brand'],
          ParamType.String,
          false,
        ),
        databaseCoverage: deserializeStructParam(
          data['database_coverage'],
          ParamType.DataStruct,
          false,
          structBuilder: DatabaseCoverageStruct.fromSerializableMap,
        ),
        formattedDisplay: deserializeParam(
          data['formatted_display'],
          ParamType.String,
          false,
        ),
        imageId: deserializeParam(
          data['image_id'],
          ParamType.String,
          false,
        ),
        legacyScore: deserializeParam(
          data['legacy_score'],
          ParamType.double,
          false,
        ),
        productName: deserializeParam(
          data['product_name'],
          ParamType.String,
          false,
        ),
      );

  static ScientificanalysStruct fromAlgoliaData(Map<String, dynamic> data) =>
      ScientificanalysStruct(
        analysis: convertAlgoliaParam(
          data['analysis'],
          ParamType.DataStruct,
          false,
          structBuilder: AnalysisStruct.fromAlgoliaData,
        ),
        brand: convertAlgoliaParam(
          data['brand'],
          ParamType.String,
          false,
        ),
        databaseCoverage: convertAlgoliaParam(
          data['database_coverage'],
          ParamType.DataStruct,
          false,
          structBuilder: DatabaseCoverageStruct.fromAlgoliaData,
        ),
        formattedDisplay: convertAlgoliaParam(
          data['formatted_display'],
          ParamType.String,
          false,
        ),
        imageId: convertAlgoliaParam(
          data['image_id'],
          ParamType.String,
          false,
        ),
        legacyScore: convertAlgoliaParam(
          data['legacy_score'],
          ParamType.double,
          false,
        ),
        productName: convertAlgoliaParam(
          data['product_name'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'ScientificanalysStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ScientificanalysStruct &&
        analysis == other.analysis &&
        brand == other.brand &&
        databaseCoverage == other.databaseCoverage &&
        formattedDisplay == other.formattedDisplay &&
        imageId == other.imageId &&
        legacyScore == other.legacyScore &&
        productName == other.productName;
  }

  @override
  int get hashCode => const ListEquality().hash([
        analysis,
        brand,
        databaseCoverage,
        formattedDisplay,
        imageId,
        legacyScore,
        productName
      ]);
}

ScientificanalysStruct createScientificanalysStruct({
  AnalysisStruct? analysis,
  String? brand,
  DatabaseCoverageStruct? databaseCoverage,
  String? formattedDisplay,
  String? imageId,
  double? legacyScore,
  String? productName,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ScientificanalysStruct(
      analysis: analysis ?? (clearUnsetFields ? AnalysisStruct() : null),
      brand: brand,
      databaseCoverage: databaseCoverage ??
          (clearUnsetFields ? DatabaseCoverageStruct() : null),
      formattedDisplay: formattedDisplay,
      imageId: imageId,
      legacyScore: legacyScore,
      productName: productName,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ScientificanalysStruct? updateScientificanalysStruct(
  ScientificanalysStruct? scientificanalys, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    scientificanalys
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addScientificanalysStructData(
  Map<String, dynamic> firestoreData,
  ScientificanalysStruct? scientificanalys,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (scientificanalys == null) {
    return;
  }
  if (scientificanalys.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && scientificanalys.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final scientificanalysData =
      getScientificanalysFirestoreData(scientificanalys, forFieldValue);
  final nestedData =
      scientificanalysData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = scientificanalys.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getScientificanalysFirestoreData(
  ScientificanalysStruct? scientificanalys, [
  bool forFieldValue = false,
]) {
  if (scientificanalys == null) {
    return {};
  }
  final firestoreData = mapToFirestore(scientificanalys.toMap());

  // Handle nested data for "analysis" field.
  addAnalysisStructData(
    firestoreData,
    scientificanalys.hasAnalysis() ? scientificanalys.analysis : null,
    'analysis',
    forFieldValue,
  );

  // Handle nested data for "database_coverage" field.
  addDatabaseCoverageStructData(
    firestoreData,
    scientificanalys.hasDatabaseCoverage()
        ? scientificanalys.databaseCoverage
        : null,
    'database_coverage',
    forFieldValue,
  );

  // Add any Firestore field values
  mapToFirestore(scientificanalys.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getScientificanalysListFirestoreData(
  List<ScientificanalysStruct>? scientificanalyss,
) =>
    scientificanalyss
        ?.map((e) => getScientificanalysFirestoreData(e, true))
        .toList() ??
    [];
