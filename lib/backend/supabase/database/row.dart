import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'database.dart';

abstract class SupabaseDataRow {
  SupabaseDataRow(this.data);

  SupabaseTable get table;
  Map<String, dynamic> data;

  String get tableName => table.tableName;

  T? getField<T>(String fieldName, [T? defaultValue]) =>
      _supaDeserialize<T>(data[fieldName]) ?? defaultValue;
  void setField<T>(String fieldName, T? value) =>
      data[fieldName] = supaSerialize<T>(value);
  List<T> getListField<T>(String fieldName) =>
      _supaDeserializeList<T>(data[fieldName]) ?? [];
  void setListField<T>(String fieldName, List<T>? value) =>
      data[fieldName] = supaSerializeList<T>(value);

  @override
  String toString() => '''
Table: $tableName
Row Data: {${data.isNotEmpty ? '\n' : ''}${data.entries.map((e) => '  (${e.value.runtimeType}) "${e.key}": ${e.value},\n').join('')}}''';

  @override
  int get hashCode => Object.hash(
        tableName,
        Object.hashAllUnordered(
          data.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  @override
  bool operator ==(Object other) =>
      other is SupabaseDataRow && mapEquals(other.data, data);
}

dynamic supaSerialize<T>(T? value) {
  if (value == null) {
    return null;
  }

  switch (T) {
    case DateTime:
      return (value as DateTime).toIso8601String();
    case PostgresTime:
      return (value as PostgresTime).toIso8601String();
    case LatLng:
      final latLng = (value as LatLng);
      return {'lat': latLng.latitude, 'lng': latLng.longitude};
    default:
      return value;
  }
}

List? supaSerializeList<T>(List<T>? value) =>
    value?.map((v) => supaSerialize<T>(v)).toList();

T? _supaDeserialize<T>(dynamic value) {
  if (value == null) {
    return null;
  }

  switch (T) {
    case int:
      if (value is num) return value.round() as T?;
      // PostgREST returns DECIMAL/NUMERIC columns as JSON strings ("75.00").
      // int.tryParse fails on those, so fall back to double-then-round.
      if (value is String) {
        return (int.tryParse(value) ?? double.tryParse(value)?.round()) as T?;
      }
      return null;
    case double:
      if (value is num) return value.toDouble() as T?;
      if (value is String) return double.tryParse(value) as T?;
      return null;
    case DateTime:
      return DateTime.tryParse(value as String)?.toLocal() as T?;
    case PostgresTime:
      return PostgresTime.tryParse(value as String) as T?;
    case LatLng:
      final latLng = value is Map ? value : json.decode(value) as Map;
      final lat = latLng['lat'] ?? latLng['latitude'];
      final lng = latLng['lng'] ?? latLng['longitude'];
      return lat is num && lng is num
          ? LatLng(lat.toDouble(), lng.toDouble()) as T?
          : null;
    default:
      return value as T;
  }
}

List<T>? _supaDeserializeList<T>(dynamic value) => value is List
    ? value
        .map((v) => _supaDeserialize<T>(v))
        .where((v) => v != null)
        .map((v) => v as T)
        .toList()
    : null;
