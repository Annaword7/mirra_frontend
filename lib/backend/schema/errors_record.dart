import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ErrorsRecord extends FirestoreRecord {
  ErrorsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "code" field.
  String? _code;
  String get code => _code ?? '';
  bool hasCode() => _code != null;

  // "lang_code" field.
  String? _langCode;
  String get langCode => _langCode ?? '';
  bool hasLangCode() => _langCode != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  void _initializeFields() {
    _code = snapshotData['code'] as String?;
    _langCode = snapshotData['lang_code'] as String?;
    _text = snapshotData['text'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('errors');

  static Stream<ErrorsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ErrorsRecord.fromSnapshot(s));

  static Future<ErrorsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ErrorsRecord.fromSnapshot(s));

  static ErrorsRecord fromSnapshot(DocumentSnapshot snapshot) => ErrorsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ErrorsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ErrorsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ErrorsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ErrorsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createErrorsRecordData({
  String? code,
  String? langCode,
  String? text,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'code': code,
      'lang_code': langCode,
      'text': text,
    }.withoutNulls,
  );

  return firestoreData;
}

class ErrorsRecordDocumentEquality implements Equality<ErrorsRecord> {
  const ErrorsRecordDocumentEquality();

  @override
  bool equals(ErrorsRecord? e1, ErrorsRecord? e2) {
    return e1?.code == e2?.code &&
        e1?.langCode == e2?.langCode &&
        e1?.text == e2?.text;
  }

  @override
  int hash(ErrorsRecord? e) =>
      const ListEquality().hash([e?.code, e?.langCode, e?.text]);

  @override
  bool isValidKey(Object? o) => o is ErrorsRecord;
}
