// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

// UnmodifiableListView comes from dart:collection above; package:collection is
// narrowed so it is not silently supplied by that package's re-export.
import 'package:collection/collection.dart' show DeepCollectionEquality;
import 'package:meta/meta.dart';

import 'timestamp.dart';

/// Represents a value of any type supported by the OpenTelemetry specification.
@immutable
sealed class AnyValue {
  // The maximum nesting depth allowed when converting to or from plain Dart
  // objects. Conversion is recursive, so an excessively nested (or
  // caller-constructed cyclic) structure would otherwise overflow the stack.
  // Structures deeper than this are rejected with an ArgumentError, which
  // callers such as attrsFromMap route to OTelErrorHandling like any other
  // unsupported value.
  static const int _maxDepth = 32;

  /// Const constructor for subclasses.
  const AnyValue();

  /// Returns the underlying Dart object (not recursively unwrapped).
  Object? get value;

  /// Recursively converts this value back into plain Dart objects.
  ///
  /// Arrays become `List<Object?>` and maps become `Map<String, Object?>`,
  /// with every nested [AnyValue] unwrapped in turn. Bytes are returned as the
  /// raw `List<int>`.
  ///
  /// Throws an [ArgumentError] if the value nests more than 32 levels deep.
  Object? unwrap() => _unwrap(0);

  Object? _unwrap(int depth) {
    if (depth >= _maxDepth) {
      throw ArgumentError(
          'AnyValue nesting exceeds the maximum depth of $_maxDepth');
    }
    return switch (this) {
      AnyValueNull() => null,
      AnyValueString(value: final v) => v,
      AnyValueBool(value: final v) => v,
      AnyValueInt(value: final v) => v,
      AnyValueDouble(value: final v) => v,
      AnyValueArray(value: final v) =>
        v.map((e) => e._unwrap(depth + 1)).toList(),
      AnyValueMap(value: final v) =>
        v.map((k, val) => MapEntry(k, val._unwrap(depth + 1))),
      AnyValueBytes(value: final v) => v,
    };
  }

  /// Converts this value to its OTLP/JSON representation.
  ///
  /// This differs from [unwrap] in exactly one respect: bytes are encoded as a
  /// base64 String, at any nesting depth, because OTLP/JSON encodes
  /// `bytesValue` that way. [unwrap] returns the raw `List<int>` instead.
  /// Every other type has the same representation in both.
  ///
  /// Throws an [ArgumentError] if the value nests more than 32 levels deep.
  Object? toJson() => _toJson(0);

  Object? _toJson(int depth) {
    if (depth >= _maxDepth) {
      throw ArgumentError(
          'AnyValue nesting exceeds the maximum depth of $_maxDepth');
    }
    // Exhaustive over the sealed hierarchy rather than falling back on a
    // wildcard, so a future composite subtype is a compile error here instead
    // of silently losing byte encoding and depth threading.
    return switch (this) {
      AnyValueNull() => null,
      AnyValueString(value: final v) => v,
      AnyValueBool(value: final v) => v,
      AnyValueInt(value: final v) => v,
      AnyValueDouble(value: final v) => v,
      AnyValueArray(value: final v) =>
        v.map((e) => e._toJson(depth + 1)).toList(),
      AnyValueMap(value: final v) =>
        v.map((k, val) => MapEntry(k, val._toJson(depth + 1))),
      AnyValueBytes(value: final v) => base64Encode(v),
    };
  }

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

  /// Creates the null AnyValue.
  factory AnyValue.nullValue() = AnyValueNull;

  /// Creates an AnyValue by recursively converting a standard Dart object.
  ///
  /// [Uint8List] is converted to [AnyValueBytes]; other lists become an
  /// [AnyValueArray] of converted elements. [DateTime] is converted to a UTC
  /// ISO-8601 string.
  ///
  /// Throws [ArgumentError] if it encounters an unsupported type, a non-String
  /// map key, or a structure nested more than 32 levels deep.
  factory AnyValue.fromObject(Object? obj) => _fromObject(obj, 0);

  static AnyValue _fromObject(Object? obj, int depth) {
    if (depth >= _maxDepth) {
      throw ArgumentError(
          'AnyValue nesting exceeds the maximum depth of $_maxDepth');
    }
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
    } else if (obj is Uint8List) {
      // Must precede the List check: Uint8List implements List<int>, so it
      // would otherwise become an array of AnyValueInt.
      return AnyValueBytes(obj);
    } else if (obj is List) {
      return AnyValueArray(obj.map((e) => _fromObject(e, depth + 1)).toList());
    } else if (obj is Map) {
      final map = <String, AnyValue>{};
      obj.forEach((key, val) {
        if (key is! String) {
          throw ArgumentError(
              'AnyValue map keys must be Strings, got ${key.runtimeType}');
        }
        map[key] = _fromObject(val, depth + 1);
      });
      return AnyValueMap(map);
    } else if (obj is DateTime) {
      // Timestamp.dateTimeToString, not toIso8601String: it is what
      // attrsFromMap and Span.setDateTimeAttribute already emit, and it pins
      // the fractional part to milliseconds instead of widening to
      // microseconds whenever the DateTime happens to carry them.
      return AnyValueString(Timestamp.dateTimeToString(obj));
    } else {
      throw ArgumentError(
          'Unsupported type in AnyValue conversion: ${obj.runtimeType}');
    }
  }
}

/// An [AnyValue] holding no value, serialized as JSON `null`.
class AnyValueNull extends AnyValue {
  /// Creates the null AnyValue.
  const AnyValueNull();

  @override
  Object? get value => null;

  @override
  int get hashCode => null.hashCode;

  @override
  bool operator ==(Object other) => other is AnyValueNull;
}

/// An [AnyValue] holding a String.
class AnyValueString extends AnyValue {
  /// The wrapped String.
  @override
  final String value;

  /// Creates an AnyValue holding [value].
  const AnyValueString(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueString && value == other.value;
}

/// An [AnyValue] holding a boolean.
class AnyValueBool extends AnyValue {
  /// The wrapped boolean.
  @override
  final bool value;

  /// Creates an AnyValue holding [value].
  const AnyValueBool(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueBool && value == other.value;
}

/// An [AnyValue] holding an integer.
class AnyValueInt extends AnyValue {
  /// The wrapped integer.
  @override
  final int value;

  /// Creates an AnyValue holding [value].
  const AnyValueInt(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueInt && value == other.value;
}

/// An [AnyValue] holding a double.
class AnyValueDouble extends AnyValue {
  /// The wrapped double.
  @override
  final double value;

  /// Creates an AnyValue holding [value].
  const AnyValueDouble(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueDouble && value == other.value;
}

/// An [AnyValue] holding an ordered list of [AnyValue]s.
class AnyValueArray extends AnyValue {
  /// The wrapped list, which is unmodifiable.
  @override
  final List<AnyValue> value;

  /// Creates an AnyValue holding a defensive, unmodifiable copy of [value].
  ///
  /// The copy is required because [AnyValue] is value-equal and is used as a
  /// key by [Attributes]; sharing the caller's list would let a later mutation
  /// change this value's `hashCode`.
  AnyValueArray(List<AnyValue> value) : value = List.unmodifiable(value);

  @override
  int get hashCode => const DeepCollectionEquality().hash(value);

  @override
  bool operator ==(Object other) =>
      other is AnyValueArray &&
      const DeepCollectionEquality().equals(value, other.value);
}

/// An [AnyValue] holding a map of String keys to [AnyValue]s.
class AnyValueMap extends AnyValue {
  /// The wrapped map, which is unmodifiable.
  @override
  final Map<String, AnyValue> value;

  /// Creates an AnyValue holding a defensive, unmodifiable copy of [value].
  ///
  /// The copy is required because [AnyValue] is value-equal and is used as a
  /// key by [Attributes]; sharing the caller's map would let a later mutation
  /// change this value's `hashCode`.
  AnyValueMap(Map<String, AnyValue> value) : value = Map.unmodifiable(value);

  @override
  int get hashCode => const DeepCollectionEquality().hash(value);

  @override
  bool operator ==(Object other) =>
      other is AnyValueMap &&
      const DeepCollectionEquality().equals(value, other.value);
}

/// An [AnyValue] holding raw bytes.
///
/// Serialized by [toJson] as a base64 String per the OTLP/JSON encoding, while
/// [value] and [unwrap] return the raw bytes.
///
/// Note that [value] is an unmodifiable view rather than a [Uint8List], so
/// `AnyValue.fromObject(bytes.unwrap())` yields an [AnyValueArray] of
/// [AnyValueInt] rather than an [AnyValueBytes].
class AnyValueBytes extends AnyValue {
  /// The wrapped bytes, which are unmodifiable.
  ///
  /// Every element is in the range 0-255; the constructor rejects anything
  /// else. Backed by a [Uint8List] rather than `List.unmodifiable`, which
  /// would box every element: bytes carry blobs, so a 1 MB payload would
  /// otherwise become a million boxed ints.
  @override
  final List<int> value;

  /// Creates an AnyValue holding a defensive, unmodifiable copy of [value].
  ///
  /// The copy is required because [AnyValue] is value-equal and is used as a
  /// key by [Attributes]; sharing the caller's list would let a later mutation
  /// change this value's `hashCode`.
  ///
  /// Throws an [ArgumentError] if any element falls outside the range 0-255.
  AnyValueBytes(List<int> value) : value = _asBytes(value);

  static List<int> _asBytes(List<int> value) {
    // A Uint8List is in range by construction, and Uint8List.fromList is
    // already an O(n) copy, so only an arbitrary List<int> needs scanning.
    // Masking out-of-range values the way Uint8List does would silently
    // corrupt an opaque payload, which is the behavior this package rejects
    // for every other unsupported input.
    if (value is! Uint8List) {
      for (final byte in value) {
        if (byte < 0 || byte > 255) {
          throw ArgumentError.value(byte, 'value',
              'AnyValueBytes elements must be in the range 0-255');
        }
      }
    }
    return UnmodifiableListView<int>(Uint8List.fromList(value));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(value);

  @override
  bool operator ==(Object other) =>
      other is AnyValueBytes &&
      const DeepCollectionEquality().equals(value, other.value);
}
