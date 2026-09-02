// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Represents a value of any type supported by the OpenTelemetry specification.
@immutable
sealed class AnyValue {
  const AnyValue();

  /// Returns the underlying Dart object (not recursively unwrapped).
  Object? get value;

  Object? unwrap() {
    return switch (this) {
      AnyValueNull() => null,
      AnyValueString(value: final v) => v,
      AnyValueBool(value: final v) => v,
      AnyValueInt(value: final v) => v,
      AnyValueDouble(value: final v) => v,
      AnyValueArray(value: final v) => v.map((e) => e.unwrap()).toList(),
      AnyValueMap(value: final v) =>
        v.map((k, val) => MapEntry(k, val.unwrap())),
      AnyValueBytes(value: final v) => v,
    };
  }

  /// Implements JSON serialization.
  Object? toJson() => unwrap();

  /// Creates an AnyValue from a String.
  factory AnyValue.fromString(String value) = AnyValueString;

  /// Creates an AnyValue from a boolean.
  factory AnyValue.fromBool(bool value) = AnyValueBool;

  /// Creates an AnyValue from an integer.
  factory AnyValue.fromInt(int value) = AnyValueInt;

  /// Creates an AnyValue from a double.
  factory AnyValue.fromDouble(double value) = AnyValueDouble;

  /// Creates an AnyValue from a List of AnyValues.
  factory AnyValue.fromList(List<AnyValue> value) = AnyValueArray;

  /// Creates an AnyValue from a Map of String to AnyValue.
  factory AnyValue.fromMap(Map<String, AnyValue> value) = AnyValueMap;

  /// Creates an AnyValue from a byte array.
  factory AnyValue.fromBytes(List<int> value) = AnyValueBytes;

  /// Creates an empty or null AnyValue.
  factory AnyValue.empty() = AnyValueNull;

  /// Creates an AnyValue by recursively converting a standard Dart object.
  ///
  /// Throws [ArgumentError] if it encounters an unsupported type.
  factory AnyValue.fromObject(dynamic obj) {
    if (obj == null) {
      return const AnyValueNull();
    } else if (obj is String) {
      return AnyValueString(obj);
    } else if (obj is bool) {
      return AnyValueBool(obj);
    } else if (obj is int) {
      return AnyValueInt(obj);
    } else if (obj is double) {
      return AnyValueDouble(obj);
    } else if (obj is List) {
      return AnyValueArray(obj.map(AnyValue.fromObject).toList());
    } else if (obj is Map) {
      final map = <String, AnyValue>{};
      obj.forEach((key, val) {
        if (key is! String) {
          throw ArgumentError(
              'AnyValue map keys must be Strings, got ${key.runtimeType}');
        }
        map[key] = AnyValue.fromObject(val);
      });
      return AnyValueMap(map);
    } else if (obj is DateTime) {
      return AnyValueString(obj.toUtc().toIso8601String());
    } else {
      throw ArgumentError(
          'Unsupported type in AnyValue conversion: ${obj.runtimeType}');
    }
  }
}

class AnyValueNull extends AnyValue {
  const AnyValueNull();

  @override
  Object? get value => null;

  @override
  int get hashCode => null.hashCode;

  @override
  bool operator ==(Object other) => other is AnyValueNull;
}

class AnyValueString extends AnyValue {
  @override
  final String value;

  const AnyValueString(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueString && value == other.value;
}

class AnyValueBool extends AnyValue {
  @override
  final bool value;

  const AnyValueBool(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueBool && value == other.value;
}

class AnyValueInt extends AnyValue {
  @override
  final int value;

  const AnyValueInt(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueInt && value == other.value;
}

class AnyValueDouble extends AnyValue {
  @override
  final double value;

  const AnyValueDouble(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueDouble && value == other.value;
}

class AnyValueArray extends AnyValue {
  @override
  final List<AnyValue> value;

  const AnyValueArray(this.value);

  @override
  int get hashCode => const DeepCollectionEquality().hash(value);

  @override
  bool operator ==(Object other) =>
      other is AnyValueArray &&
      const DeepCollectionEquality().equals(value, other.value);
}

class AnyValueMap extends AnyValue {
  @override
  final Map<String, AnyValue> value;

  const AnyValueMap(this.value);

  @override
  int get hashCode => const DeepCollectionEquality().hash(value);

  @override
  bool operator ==(Object other) =>
      other is AnyValueMap &&
      const DeepCollectionEquality().equals(value, other.value);
}

class AnyValueBytes extends AnyValue {
  @override
  final List<int> value;

  const AnyValueBytes(this.value);

  @override
  int get hashCode => const DeepCollectionEquality().hash(value);

  @override
  bool operator ==(Object other) =>
      other is AnyValueBytes &&
      const DeepCollectionEquality().equals(value, other.value);
}
