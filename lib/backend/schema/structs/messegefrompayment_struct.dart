// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class MessegefrompaymentStruct extends FFFirebaseStruct {
  MessegefrompaymentStruct({
    bool? ok,
    bool? cancelled,
    String? code,
    String? message,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _ok = ok,
        _cancelled = cancelled,
        _code = code,
        _message = message,
        super(firestoreUtilData);

  // "ok" field.
  bool? _ok;
  bool get ok => _ok ?? false;
  set ok(bool? val) => _ok = val;

  bool hasOk() => _ok != null;

  // "cancelled" field.
  bool? _cancelled;
  bool get cancelled => _cancelled ?? false;
  set cancelled(bool? val) => _cancelled = val;

  bool hasCancelled() => _cancelled != null;

  // "code" field.
  String? _code;
  String get code => _code ?? '';
  set code(String? val) => _code = val;

  bool hasCode() => _code != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  set message(String? val) => _message = val;

  bool hasMessage() => _message != null;

  static MessegefrompaymentStruct fromMap(Map<String, dynamic> data) =>
      MessegefrompaymentStruct(
        ok: data['ok'] as bool?,
        cancelled: data['cancelled'] as bool?,
        code: data['code'] as String?,
        message: data['message'] as String?,
      );

  static MessegefrompaymentStruct? maybeFromMap(dynamic data) => data is Map
      ? MessegefrompaymentStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'ok': _ok,
        'cancelled': _cancelled,
        'code': _code,
        'message': _message,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'ok': serializeParam(
          _ok,
          ParamType.bool,
        ),
        'cancelled': serializeParam(
          _cancelled,
          ParamType.bool,
        ),
        'code': serializeParam(
          _code,
          ParamType.String,
        ),
        'message': serializeParam(
          _message,
          ParamType.String,
        ),
      }.withoutNulls;

  static MessegefrompaymentStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      MessegefrompaymentStruct(
        ok: deserializeParam(
          data['ok'],
          ParamType.bool,
          false,
        ),
        cancelled: deserializeParam(
          data['cancelled'],
          ParamType.bool,
          false,
        ),
        code: deserializeParam(
          data['code'],
          ParamType.String,
          false,
        ),
        message: deserializeParam(
          data['message'],
          ParamType.String,
          false,
        ),
      );

  static MessegefrompaymentStruct fromAlgoliaData(Map<String, dynamic> data) =>
      MessegefrompaymentStruct(
        ok: convertAlgoliaParam(
          data['ok'],
          ParamType.bool,
          false,
        ),
        cancelled: convertAlgoliaParam(
          data['cancelled'],
          ParamType.bool,
          false,
        ),
        code: convertAlgoliaParam(
          data['code'],
          ParamType.String,
          false,
        ),
        message: convertAlgoliaParam(
          data['message'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'MessegefrompaymentStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MessegefrompaymentStruct &&
        ok == other.ok &&
        cancelled == other.cancelled &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode => const ListEquality().hash([ok, cancelled, code, message]);
}

MessegefrompaymentStruct createMessegefrompaymentStruct({
  bool? ok,
  bool? cancelled,
  String? code,
  String? message,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    MessegefrompaymentStruct(
      ok: ok,
      cancelled: cancelled,
      code: code,
      message: message,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

MessegefrompaymentStruct? updateMessegefrompaymentStruct(
  MessegefrompaymentStruct? messegefrompayment, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    messegefrompayment
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addMessegefrompaymentStructData(
  Map<String, dynamic> firestoreData,
  MessegefrompaymentStruct? messegefrompayment,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (messegefrompayment == null) {
    return;
  }
  if (messegefrompayment.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && messegefrompayment.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final messegefrompaymentData =
      getMessegefrompaymentFirestoreData(messegefrompayment, forFieldValue);
  final nestedData =
      messegefrompaymentData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      messegefrompayment.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getMessegefrompaymentFirestoreData(
  MessegefrompaymentStruct? messegefrompayment, [
  bool forFieldValue = false,
]) {
  if (messegefrompayment == null) {
    return {};
  }
  final firestoreData = mapToFirestore(messegefrompayment.toMap());

  // Add any Firestore field values
  mapToFirestore(messegefrompayment.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getMessegefrompaymentListFirestoreData(
  List<MessegefrompaymentStruct>? messegefrompayments,
) =>
    messegefrompayments
        ?.map((e) => getMessegefrompaymentFirestoreData(e, true))
        .toList() ??
    [];
