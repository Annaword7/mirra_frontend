// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FormattedConclusionsStruct extends FFFirebaseStruct {
  FormattedConclusionsStruct({
    String? concentrationNote,
    String? finalVerdict,
    List<String>? idealFor,
    List<String>? notRecommendedFor,
    List<String>? outstandingPoints,
    List<String>? problematicPoints,
    String? synergyHighlight,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _concentrationNote = concentrationNote,
        _finalVerdict = finalVerdict,
        _idealFor = idealFor,
        _notRecommendedFor = notRecommendedFor,
        _outstandingPoints = outstandingPoints,
        _problematicPoints = problematicPoints,
        _synergyHighlight = synergyHighlight,
        super(firestoreUtilData);

  // "concentration_note" field.
  String? _concentrationNote;
  String get concentrationNote => _concentrationNote ?? '';
  set concentrationNote(String? val) => _concentrationNote = val;

  bool hasConcentrationNote() => _concentrationNote != null;

  // "final_verdict" field.
  String? _finalVerdict;
  String get finalVerdict => _finalVerdict ?? '';
  set finalVerdict(String? val) => _finalVerdict = val;

  bool hasFinalVerdict() => _finalVerdict != null;

  // "ideal_for" field.
  List<String>? _idealFor;
  List<String> get idealFor => _idealFor ?? const [];
  set idealFor(List<String>? val) => _idealFor = val;

  void updateIdealFor(Function(List<String>) updateFn) {
    updateFn(_idealFor ??= []);
  }

  bool hasIdealFor() => _idealFor != null;

  // "not_recommended_for" field.
  List<String>? _notRecommendedFor;
  List<String> get notRecommendedFor => _notRecommendedFor ?? const [];
  set notRecommendedFor(List<String>? val) => _notRecommendedFor = val;

  void updateNotRecommendedFor(Function(List<String>) updateFn) {
    updateFn(_notRecommendedFor ??= []);
  }

  bool hasNotRecommendedFor() => _notRecommendedFor != null;

  // "outstanding_points" field.
  List<String>? _outstandingPoints;
  List<String> get outstandingPoints => _outstandingPoints ?? const [];
  set outstandingPoints(List<String>? val) => _outstandingPoints = val;

  void updateOutstandingPoints(Function(List<String>) updateFn) {
    updateFn(_outstandingPoints ??= []);
  }

  bool hasOutstandingPoints() => _outstandingPoints != null;

  // "problematic_points" field.
  List<String>? _problematicPoints;
  List<String> get problematicPoints => _problematicPoints ?? const [];
  set problematicPoints(List<String>? val) => _problematicPoints = val;

  void updateProblematicPoints(Function(List<String>) updateFn) {
    updateFn(_problematicPoints ??= []);
  }

  bool hasProblematicPoints() => _problematicPoints != null;

  // "synergy_highlight" field.
  String? _synergyHighlight;
  String get synergyHighlight => _synergyHighlight ?? '';
  set synergyHighlight(String? val) => _synergyHighlight = val;

  bool hasSynergyHighlight() => _synergyHighlight != null;

  static FormattedConclusionsStruct fromMap(Map<String, dynamic> data) =>
      FormattedConclusionsStruct(
        concentrationNote: data['concentration_note'] as String?,
        finalVerdict: data['final_verdict'] as String?,
        idealFor: getDataList(data['ideal_for']),
        notRecommendedFor: getDataList(data['not_recommended_for']),
        outstandingPoints: getDataList(data['outstanding_points']),
        problematicPoints: getDataList(data['problematic_points']),
        synergyHighlight: data['synergy_highlight'] as String?,
      );

  static FormattedConclusionsStruct? maybeFromMap(dynamic data) => data is Map
      ? FormattedConclusionsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'concentration_note': _concentrationNote,
        'final_verdict': _finalVerdict,
        'ideal_for': _idealFor,
        'not_recommended_for': _notRecommendedFor,
        'outstanding_points': _outstandingPoints,
        'problematic_points': _problematicPoints,
        'synergy_highlight': _synergyHighlight,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'concentration_note': serializeParam(
          _concentrationNote,
          ParamType.String,
        ),
        'final_verdict': serializeParam(
          _finalVerdict,
          ParamType.String,
        ),
        'ideal_for': serializeParam(
          _idealFor,
          ParamType.String,
          isList: true,
        ),
        'not_recommended_for': serializeParam(
          _notRecommendedFor,
          ParamType.String,
          isList: true,
        ),
        'outstanding_points': serializeParam(
          _outstandingPoints,
          ParamType.String,
          isList: true,
        ),
        'problematic_points': serializeParam(
          _problematicPoints,
          ParamType.String,
          isList: true,
        ),
        'synergy_highlight': serializeParam(
          _synergyHighlight,
          ParamType.String,
        ),
      }.withoutNulls;

  static FormattedConclusionsStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      FormattedConclusionsStruct(
        concentrationNote: deserializeParam(
          data['concentration_note'],
          ParamType.String,
          false,
        ),
        finalVerdict: deserializeParam(
          data['final_verdict'],
          ParamType.String,
          false,
        ),
        idealFor: deserializeParam<String>(
          data['ideal_for'],
          ParamType.String,
          true,
        ),
        notRecommendedFor: deserializeParam<String>(
          data['not_recommended_for'],
          ParamType.String,
          true,
        ),
        outstandingPoints: deserializeParam<String>(
          data['outstanding_points'],
          ParamType.String,
          true,
        ),
        problematicPoints: deserializeParam<String>(
          data['problematic_points'],
          ParamType.String,
          true,
        ),
        synergyHighlight: deserializeParam(
          data['synergy_highlight'],
          ParamType.String,
          false,
        ),
      );

  static FormattedConclusionsStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      FormattedConclusionsStruct(
        concentrationNote: convertAlgoliaParam(
          data['concentration_note'],
          ParamType.String,
          false,
        ),
        finalVerdict: convertAlgoliaParam(
          data['final_verdict'],
          ParamType.String,
          false,
        ),
        idealFor: convertAlgoliaParam<String>(
          data['ideal_for'],
          ParamType.String,
          true,
        ),
        notRecommendedFor: convertAlgoliaParam<String>(
          data['not_recommended_for'],
          ParamType.String,
          true,
        ),
        outstandingPoints: convertAlgoliaParam<String>(
          data['outstanding_points'],
          ParamType.String,
          true,
        ),
        problematicPoints: convertAlgoliaParam<String>(
          data['problematic_points'],
          ParamType.String,
          true,
        ),
        synergyHighlight: convertAlgoliaParam(
          data['synergy_highlight'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'FormattedConclusionsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is FormattedConclusionsStruct &&
        concentrationNote == other.concentrationNote &&
        finalVerdict == other.finalVerdict &&
        listEquality.equals(idealFor, other.idealFor) &&
        listEquality.equals(notRecommendedFor, other.notRecommendedFor) &&
        listEquality.equals(outstandingPoints, other.outstandingPoints) &&
        listEquality.equals(problematicPoints, other.problematicPoints) &&
        synergyHighlight == other.synergyHighlight;
  }

  @override
  int get hashCode => const ListEquality().hash([
        concentrationNote,
        finalVerdict,
        idealFor,
        notRecommendedFor,
        outstandingPoints,
        problematicPoints,
        synergyHighlight
      ]);
}

FormattedConclusionsStruct createFormattedConclusionsStruct({
  String? concentrationNote,
  String? finalVerdict,
  String? synergyHighlight,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    FormattedConclusionsStruct(
      concentrationNote: concentrationNote,
      finalVerdict: finalVerdict,
      synergyHighlight: synergyHighlight,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

FormattedConclusionsStruct? updateFormattedConclusionsStruct(
  FormattedConclusionsStruct? formattedConclusions, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    formattedConclusions
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addFormattedConclusionsStructData(
  Map<String, dynamic> firestoreData,
  FormattedConclusionsStruct? formattedConclusions,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (formattedConclusions == null) {
    return;
  }
  if (formattedConclusions.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && formattedConclusions.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final formattedConclusionsData =
      getFormattedConclusionsFirestoreData(formattedConclusions, forFieldValue);
  final nestedData =
      formattedConclusionsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      formattedConclusions.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getFormattedConclusionsFirestoreData(
  FormattedConclusionsStruct? formattedConclusions, [
  bool forFieldValue = false,
]) {
  if (formattedConclusions == null) {
    return {};
  }
  final firestoreData = mapToFirestore(formattedConclusions.toMap());

  // Add any Firestore field values
  mapToFirestore(formattedConclusions.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getFormattedConclusionsListFirestoreData(
  List<FormattedConclusionsStruct>? formattedConclusionss,
) =>
    formattedConclusionss
        ?.map((e) => getFormattedConclusionsFirestoreData(e, true))
        .toList() ??
    [];
