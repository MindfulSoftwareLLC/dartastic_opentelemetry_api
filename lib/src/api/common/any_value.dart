// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'dart:typed_data';

// UnmodifiableListView comes from dart:collection above; package:collection is
// narrowed so it is not silently supplied by that package's re-export.
import 'package:collection/collection.dart' show DeepCollectionEquality;
import 'package:meta/meta.dart';

import '../../util/otel_error_handler.dart';

/// Represents a value of any type supported by the OpenTelemetry specification.
@immutable
sealed class AnyValue {
  // The spec allows arbitrary nesting; this is a guard against cyclic or
  // runaway structures, not a spec value. A nested map costs three protobuf
  // messages per level (AnyValue, KeyValueList, KeyValue), and the Java and
  // C++ protobuf runtimes reject messages nested past 100, so 32 is about
  // the deepest map such a backend can decode.
  static const int _maxDepth = 32;

  // Stored in the per-conversion identity set to report a depth failure once.
  static final Object _depthReported = Object();

  /// Const constructor for subclasses.
  const AnyValue();

  /// Recursively converts this value back into plain Dart objects.
  ///
  /// Arrays become `List<Object?>` and maps become `Map<String, Object?>`,
  /// with every nested [AnyValue] unwrapped in turn. Bytes are returned as the
  /// raw `List<int>`.
  ///
  /// Reports via [OTelErrorHandling] and returns null if the value nests more
  /// than 32 levels deep.
  Object? unwrap() => _unwrap(0);

  Object? _unwrap(int depth) {
    if (depth >= _maxDepth && this is! AnyValueNull) {
      OTelErrorHandling.report(ArgumentError(
          'AnyValue nesting exceeds the maximum depth of $_maxDepth'));
      return null;
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

  /// Converts this value to plain Dart objects for debugging and in-process use.
  ///
  /// This delegates to [unwrap].
  Object? toJson() => unwrap();

  /// A readable rendering of this value, for debuggers and error messages.
  ///
  /// Bounded in both directions, because `toString` runs in exactly the places
  /// (a debugger, an error message) where an exception or a megabyte of
  /// output is least welcome. Unlike [unwrap] it never throws: nesting past 32
  /// levels renders as `...`. Bytes render as `<N bytes>` rather than their
  /// contents, since the length is what you want when debugging and the
  /// individual values almost never are.
  ///
  /// A String nested inside an array or a map is quoted, so `["a", "b"]` and
  /// `["a, b"]` are distinguishable. A top-level String renders bare.
  @override
  String toString() => _describe(0);

  // Depth doubles as the nested flag: toString enters at 0, and every
  // recursive call is at 1 or more, so `depth > 0` is exactly "inside a
  // collection". That avoids threading a second parameter through.
  String _describe(int depth) {
    if (depth >= _maxDepth) return '...';
    return switch (this) {
      AnyValueNull() => 'null',
      AnyValueString(value: final v) => depth == 0 ? v : '"$v"',
      AnyValueBool(value: final v) => '$v',
      AnyValueInt(value: final v) => '$v',
      AnyValueDouble(value: final v) => '$v',
      AnyValueBytes(value: final v) => '<${v.length} bytes>',
      AnyValueArray(value: final v) =>
        '[${v.map((e) => e._describe(depth + 1)).join(', ')}]',
      AnyValueMap(value: final v) =>
        '{${v.entries.map((e) => '${e.key}: ${e.value._describe(depth + 1)}').join(', ')}}',
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
  ///
  /// Every element must be in the range 0-255. If an element is out of range,
  /// or the list cannot be read, the error is reported via [OTelErrorHandling]
  /// and [AnyValueNull] is returned.
  factory AnyValue.fromBytes(List<int> value) {
    var hasInvalidElement = false;
    AnyValueBytes? result;
    try {
      if (value is Uint8List) {
        result = AnyValueBytes._(value);
      } else {
        final validated = <int>[];
        for (final byte in value) {
          if (byte < 0 || byte > 255) {
            hasInvalidElement = true;
            break;
          }
          validated.add(byte);
        }
        if (!hasInvalidElement) {
          // Copy from the values that were validated, rather than iterating a
          // caller-defined List twice and allowing it to change between reads.
          result = AnyValueBytes._(validated);
        }
      }
    } catch (_) {
      OTelErrorHandling.report(ArgumentError(
          'AnyValue.fromBytes could not read the byte list; using an empty value.'));
      return const AnyValueNull();
    }
    if (hasInvalidElement) {
      OTelErrorHandling.report(ArgumentError(
          'AnyValue.fromBytes elements must be in the range 0-255; using an empty value.'));
      return const AnyValueNull();
    }
    return result!;
  }

  /// Creates the null AnyValue.
  factory AnyValue.nullValue() = AnyValueNull;

  /// Converts a Dart object to an [AnyValue], recursively, following the
  /// specification's "Mapping Arbitrary Data to OTLP AnyValue"
  /// (common/attribute-type-mapping.md).
  ///
  /// - `null` becomes [AnyValueNull]. String, bool, int and double become the
  ///   matching leaf.
  /// - [Uint8List] becomes [AnyValueBytes] ("Byte Sequences").
  /// - Any other [Iterable] (such as [List] or [Set]) becomes an
  ///   [AnyValueArray] with each element converted by these same rules
  ///   ("Array Values"). Elements need not share a type, and `null` elements
  ///   are kept, per "an array of AnyValue" and the `null` rule in
  ///   common/README.md. Infinite iterables will not terminate, so callers
  ///   must pass finite collections.
  /// - A [Map] becomes an [AnyValueMap] ("Associative Arrays With Unique
  ///   Keys"). A non-String key is converted with `toString()`; if that throws,
  ///   the entry is skipped. Key collisions after stringification are reported.
  /// - [DateTime] becomes an ISO 8601 UTC string via
  ///   `toUtc().toIso8601String()`. The specification has no rule for dates,
  ///   so this is "Other Values" with a fixed format instead of
  ///   [DateTime.toString].
  /// - Enums use `toString()`, preserving custom semantic-convention wire values.
  /// - An [AnyValue] is returned as is.
  /// - Anything else becomes a String via `toString()` ("Other Values"). If
  ///   `toString()` throws, the failure is reported through
  ///   [OTelErrorHandling] and the result is [AnyValueNull].
  ///
  /// Reports failures without throwing under the default error handler. A
  /// user-installed error handler may deliberately throw. Nesting deeper than
  /// 32 levels (reported once per conversion) or cyclic collection
  /// references are reported through [OTelErrorHandling] and that subtree
  /// becomes [AnyValueNull].
  factory AnyValue.fromObject(Object? obj) =>
      _fromObject(obj, 0, HashSet<Object>.identity());

  static AnyValue _cycle() {
    OTelErrorHandling.report(ArgumentError(
        'AnyValue input contains a cycle; using an empty value.'));
    return const AnyValueNull();
  }

  static AnyValue _fromObject(Object? obj, int depth, Set<Object> path,
      {bool preserveDouble = false}) {
    if (depth >= _maxDepth) {
      if (path.add(_depthReported)) {
        OTelErrorHandling.report(ArgumentError(
            'AnyValue nesting exceeds the maximum depth of $_maxDepth'));
      }
      return const AnyValueNull();
    }
    // An AnyValue at any depth passes through; the fallback below would
    // stringify it.
    if (obj is AnyValue) {
      return obj;
    }
    if (obj == null) {
      return const AnyValueNull();
    } else if (obj is String) {
      return AnyValueString(obj);
    } else if (obj is bool) {
      return AnyValueBool(obj);
    } else if (obj is int) {
      // dart2js and DDC share one JS number type for int and double, so there
      // `2.0 is int` is true and a whole-valued double lands here. The VM and
      // dart2wasm keep them distinct. getDouble and getDoubleList promote an
      // int on read, so only `is AnyValueInt` differs between compilers.
      return preserveDouble ? AnyValueDouble(obj.toDouble()) : AnyValueInt(obj);
    } else if (obj is double) {
      return AnyValueDouble(obj);
    } else if (obj is DateTime) {
      return AnyValueString(obj.toUtc().toIso8601String());
    } else if (obj is Uint8List) {
      // Must precede the List check: Uint8List implements List<int>, so it
      // would otherwise become an array of AnyValueInt.
      return AnyValueBytes._(obj);
    } else if (obj is Iterable) {
      if (!path.add(obj)) return _cycle();
      try {
        final List<Object?> elements;
        try {
          elements = obj.toList();
        } catch (_) {
          OTelErrorHandling.report(ArgumentError(
              'Iteration threw while converting an Iterable to an AnyValue; using an empty value.'));
          return const AnyValueNull();
        }
        // A typed double list retains its element type even when a whole-valued
        // double also satisfies `is int` on JavaScript compilers.
        return AnyValueArray([
          for (final element in elements)
            _fromObject(element, depth + 1, path,
                preserveDouble: obj is List<double>),
        ]);
      } finally {
        path.remove(obj);
      }
    } else if (obj is Map) {
      if (!path.add(obj)) return _cycle();
      try {
        final List<MapEntry<Object?, Object?>> entries;
        try {
          entries = obj.entries.toList();
        } catch (_) {
          OTelErrorHandling.report(ArgumentError(
              'Iteration threw while converting a Map to an AnyValue; using an empty value.'));
          return const AnyValueNull();
        }
        final map = <String, AnyValue>{};
        for (final entry in entries) {
          final keyObj = entry.key;
          final String key;
          if (keyObj is! String) {
            final str = OTelErrorHandling.safeToString(keyObj);
            if (str == null) {
              OTelErrorHandling.report(
                  ArgumentError('toString() threw while converting a map '
                      'key to a String; skipping entry.'));
              continue;
            }
            key = str;
          } else {
            key = keyObj;
          }
          if (map.containsKey(key)) {
            OTelErrorHandling.report(ArgumentError(
                'AnyValue map key collision after stringification: $key'));
          }
          map[key] = _fromObject(entry.value, depth + 1, path);
        }
        return AnyValueMap(map);
      } finally {
        path.remove(obj);
      }
    } else {
      // "Mapping Arbitrary Data to OTLP AnyValue", Other Values: anything not
      // listed above SHOULD be converted to a string via toString(), and to an
      // empty AnyValue if that is not possible. Dart offers no general way to
      // serialize an arbitrary object to bytes, so the spec's intermediate
      // bytes_value step has nothing to implement and is skipped.
      final str = OTelErrorHandling.safeToString(obj);
      if (str != null) {
        return AnyValueString(str);
      } else {
        // A user-defined toString() can throw. error-handling.md: report it,
        // never propagate, and fall through to the empty value the mapping
        // doc prescribes as the last resort.
        OTelErrorHandling.report(
            ArgumentError('toString() threw while converting an object to an '
                'AnyValue; using an empty value instead.'));
        return const AnyValueNull();
      }
    }
  }
}

/// An [AnyValue] holding no value, serialized as JSON `null`.
class AnyValueNull extends AnyValue {
  /// Creates the null AnyValue.
  const AnyValueNull();

  Object? get value => null;

  @override
  int get hashCode => null.hashCode;

  @override
  bool operator ==(Object other) => other is AnyValueNull;
}

/// An [AnyValue] holding a String.
class AnyValueString extends AnyValue {
  /// The wrapped String.
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
  final List<AnyValue> value;

  /// Creates an AnyValue holding a defensive, unmodifiable copy of [value].
  ///
  /// The copy is required because [AnyValue] is value-equal and is used as a
  /// key by [Attributes]; sharing the caller's list would let a later mutation
  /// change this value's `hashCode`.
  AnyValueArray(List<AnyValue> value) : value = List.unmodifiable(value);

  // Deep hashing walks the whole structure, and this value is immutable, so
  // compute it once on first use rather than on every lookup.
  late final int _hashCode = const DeepCollectionEquality().hash(value);

  @override
  int get hashCode => _hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueArray &&
      const DeepCollectionEquality().equals(value, other.value);
}

/// An [AnyValue] holding a map of String keys to [AnyValue]s.
class AnyValueMap extends AnyValue {
  /// The wrapped map, which is unmodifiable.
  final Map<String, AnyValue> value;

  /// Creates an AnyValue holding a defensive, unmodifiable copy of [value].
  ///
  /// The copy is required because [AnyValue] is value-equal and is used as a
  /// key by [Attributes]; sharing the caller's map would let a later mutation
  /// change this value's `hashCode`.
  AnyValueMap(Map<String, AnyValue> value) : value = Map.unmodifiable(value);

  // Deep hashing walks the whole structure, and this value is immutable, so
  // compute it once on first use rather than on every lookup.
  late final int _hashCode = const DeepCollectionEquality().hash(value);

  @override
  int get hashCode => _hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueMap &&
      const DeepCollectionEquality().equals(value, other.value);
}

/// An [AnyValue] holding raw bytes.
///
/// [value], [unwrap] and [toJson] all return the raw `List<int>`; encoding it
/// for a wire format is the exporter's job.
///
/// Note that [value] is an unmodifiable view rather than a [Uint8List], so
/// `AnyValue.fromObject(bytes.unwrap())` yields an [AnyValueArray] of
/// [AnyValueInt] rather than an [AnyValueBytes].
class AnyValueBytes extends AnyValue {
  /// The wrapped bytes, which are unmodifiable.
  ///
  /// Every element is in the range 0-255. Backed by a [Uint8List] rather than
  /// `List.unmodifiable`, which
  /// would box every element: bytes carry blobs, so a 1 MB payload would
  /// otherwise become a million boxed ints.
  final List<int> value;

  // Byte construction is routed through AnyValue.fromBytes so invalid input
  // can be reported and degraded without exposing a throwing constructor.
  AnyValueBytes._(List<int> value)
      : value = UnmodifiableListView<int>(Uint8List.fromList(value));

  // Deep hashing walks the whole payload, which for bytes may be large, and
  // this value is immutable, so compute it once on first use.
  late final int _hashCode = const DeepCollectionEquality().hash(value);

  @override
  int get hashCode => _hashCode;

  @override
  bool operator ==(Object other) =>
      other is AnyValueBytes &&
      const DeepCollectionEquality().equals(value, other.value);
}
