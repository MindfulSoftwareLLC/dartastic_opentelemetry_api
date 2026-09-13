// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

library;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import '../../factory/otel_factory.dart';
import '../../util/otel_error_handler.dart';
import 'any_value.dart';
import 'attribute.dart';

part 'attributes_create.dart';

/// A collection of attributes that are immutable and type-safe.
/// Create with the OTelFactory methods.
@immutable
class Attributes {
  final Map<String, Attribute> _entries = {};

  /// Creates an Attributes instance from a map of key-value pairs.
  /// Uses the appropriate factory method (OTelFactory or OTelAPIFactory) based on initialization state.
  ///
  /// @param map The map of key-value pairs to convert to attributes
  /// @return A new Attributes instance containing the converted attributes
  static Attributes of(Map<String, Object> map) {
    return OTelFactory.getOrCreateDefault().attributesFromMap(map);
  }

  /// Creates an Attributes instance from a JSON map.
  /// This is a utility method for deserialization from logs or exports.
  ///
  /// A value that cannot be converted, or that converts to something the
  /// attribute data model does not allow — a map, bytes, null, or a nested or
  /// heterogeneous array — is dropped and reported via [OTelErrorHandling].
  static Attributes fromJson(Map<String, dynamic> json) {
    final attributes = <Attribute>[];

    for (final entry in json.entries) {
      // Only the conversion failure is handled here; whether a converted
      // AnyValue is a legal *attribute* value is Attributes._'s single rule.
      // Reporting outside the catch: a user handler may rethrow (strict mode),
      // and catching that here would report the same value twice.
      final AnyValue anyValue;
      try {
        anyValue = AnyValue.fromObject(entry.value);
      } catch (e) {
        OTelErrorHandling.report(ArgumentError(
            'Ignoring attribute ${entry.key} because it contains unsupported types: $e'));
        continue;
      }

      attributes.add(AttributeCreate.create(entry.key, anyValue));
    }

    return AttributesCreate.create(attributes);
  }

  /// Private constructor to enforce immutability.
  ///
  /// Every Attributes is built here, so this is the one place that enforces
  /// the attribute data model: a non-empty key, and a value that is a
  /// primitive or a homogeneous array of primitives. Enforcing it here rather
  /// than in the conversion helpers covers every route in, including
  /// [attributesFromList], an `Attribute` passed straight through
  /// `attrsFromMap`, and the `copyWith*` methods.
  /// error-handling.md: report it, never throw.
  Attributes._(List<Attribute> entries) {
    for (var attr in entries) {
      // The key check comes first because it identifies the attribute, and
      // the value message names the key, which reads as `attribute ""` for an
      // empty one. Each failure continues, so an attribute that is wrong both
      // ways is dropped once and reported once.
      if (attr.key.isEmpty) {
        OTelErrorHandling.report(ArgumentError(
            'Attribute with an empty key dropped; keys must be non-empty.'));
        continue;
      }
      if (!AttributeCreate.isValidAttributeValue(attr.value)) {
        OTelErrorHandling.report(ArgumentError(
            'Ignoring attribute "${attr.key}" because '
            '${AttributeCreate.describeIllegalValue(attr.value)} is not a '
            'legal attribute value. The OTel specification allows a primitive '
            'or a homogeneous array of primitives.'));
        continue;
      }
      _entries[attr.key] = attr;
    }
  }

  /// Returns a list of all attribute keys.
  /// The returned list is unmodifiable.
  List<String> get keys => List.unmodifiable(_entries.keys);

  /// Returns all attributes as a read-only List.
  List<Attribute> toList() => List.unmodifiable(_entries.values);

  /// Returns all attributes as a read-only map.
  Map<String, Attribute> toMap() => Map.unmodifiable(_entries);

  /// Returns true if this attributes collection is empty.
  bool get isEmpty => _entries.isEmpty;

  /// Gets a String attribute value by key.
  /// Returns null if the key doesn't exist or if the value is not a String.
  String? getString(String name) => _getTyped<String>(name);

  /// Gets a Boolean attribute value by key.
  /// Returns null if the key doesn't exist or if the value is not a Boolean.
  bool? getBool(String name) => _getTyped<bool>(name);

  /// Gets an Integer attribute value by key.
  /// Returns null if the key doesn't exist or if the value is not an Integer.
  int? getInt(String name) => _getTyped<int>(name);

  /// Gets a Double attribute value by key.
  /// Returns null if the key doesn't exist or if the value is not a Double.
  double? getDouble(String name) => _getTyped<double>(name);

  /// Gets a String List attribute value by key.
  /// Returns null if the key doesn't exist or if the value is not a String List.
  List<String>? getStringList(String name) => _getTyped<List<String>>(name);

  /// Gets a Boolean List attribute value by key.
  /// Returns null if the key doesn't exist or if the value is not a Boolean List.
  List<bool>? getBoolList(String name) => _getTyped<List<bool>>(name);

  /// Gets an Integer List attribute value by key.
  /// Returns null if the key doesn't exist or if the value is not an Integer List.
  List<int>? getIntList(String name) => _getTyped<List<int>>(name);

  /// Gets a Double List attribute value by key.
  /// Returns null if the key doesn't exist or if the value is not a Double List.
  List<double>? getDoubleList(String name) => _getTyped<List<double>>(name);

  /// Returns the number of attributes in this collection.
  int get length => _entries.length;

  /// Returns the value associated with the given [key], or null if the key
  /// is not present or the stored value is not of type [T].
  ///
  /// error-handling.md: API methods MUST NOT throw unhandled exceptions
  /// when used incorrectly by end users. A type mismatch is reported
  /// through [OTelErrorHandling] and null is returned.
  T? _getTyped<T>(String key) {
    final attribute = _entries[key];
    if (attribute == null) return null;

    final anyValue = attribute.value;

    if (T == String && anyValue is AnyValueString) {
      return anyValue.value as T;
    }
    if (T == bool && anyValue is AnyValueBool) {
      return anyValue.value as T;
    }
    if (T == int && anyValue is AnyValueInt) {
      return anyValue.value as T;
    }
    if (T == double && anyValue is AnyValueDouble) {
      return anyValue.value as T;
    }

    if (anyValue is AnyValueArray) {
      final elements = anyValue.value;

      // An empty array carries no element type, so it satisfies whichever
      // list getter was asked for. Without this an empty list would survive
      // storage but read back as null from every typed getter.
      if (elements.isEmpty) {
        if (<String>[] is T) return <String>[] as T;
        if (<bool>[] is T) return <bool>[] as T;
        if (<int>[] is T) return <int>[] as T;
        if (<double>[] is T) return <double>[] as T;
      }

      if (elements.every((e) => e is AnyValueString)) {
        final result = elements.map((e) => e.value as String).toList();
        if (result is T) return result as T;
      }
      if (elements.every((e) => e is AnyValueBool)) {
        final result = elements.map((e) => e.value as bool).toList();
        if (result is T) return result as T;
      }
      if (elements.every((e) => e is AnyValueInt)) {
        final result = elements.map((e) => e.value as int).toList();
        if (result is T) return result as T;
      }
      // Arrays holding any double promote ints to double, which is what
      // attrsFromMap and fromJson did before AnyValue: JSON has a single
      // number type, so [1, 2.5] is routine. An all-int array is matched by
      // the int case above, so it is not promoted here.
      if (elements.any((e) => e is AnyValueDouble) &&
          elements.every((e) => e is AnyValueDouble || e is AnyValueInt)) {
        final result = elements
            .map((e) => e is AnyValueInt
                ? e.value.toDouble()
                : (e as AnyValueDouble).value)
            .toList();
        if (result is T) return result as T;
      }
    }

    // Per #106 a type mismatch is reported and yields null rather than
    // throwing, which is what the getter doc comments promise.
    OTelErrorHandling.report(StateError(
        'Attribute value for key "$key" is a ${anyValue.runtimeType}, '
        'not a $T; returning null.'));
    return null;
  }

  /// Creates a new Attributes instance with a String attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The String value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithStringAttribute(String name, String value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, AnyValueString(value)),
    ]);
  }

  /// Creates a new Attributes instance with a Boolean attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The Boolean value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithBoolAttribute(String name, bool value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, AnyValueBool(value)),
    ]);
  }

  /// Creates a new Attributes instance with an Integer attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The Integer value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithIntAttribute(String name, int value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, AnyValueInt(value)),
    ]);
  }

  /// Creates a new Attributes instance with a Double attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The Double value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithDoubleAttribute(String name, double value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, AnyValueDouble(value)),
    ]);
  }

  /// Creates a new Attributes instance with a String List attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The String List value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithStringListAttribute(String name, List<String> value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(
          name, AnyValueArray(value.map(AnyValueString.new).toList())),
    ]);
  }

  /// Creates a new Attributes instance with a Boolean List attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The Boolean List value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithBoolListAttribute(String name, List<bool> value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(
          name, AnyValueArray(value.map(AnyValueBool.new).toList())),
    ]);
  }

  /// Creates a new Attributes instance with an Integer List attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The Integer List value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithIntListAttribute(String name, List<int> value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(
          name, AnyValueArray(value.map(AnyValueInt.new).toList())),
    ]);
  }

  /// Creates a new Attributes instance with a Double List attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The Double List value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithDoubleListAttribute(String name, List<double> value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(
          name, AnyValueArray(value.map(AnyValueDouble.new).toList())),
    ]);
  }

  /// Creates a new Attributes instance by adding or updating multiple attributes.
  ///
  /// @param other A list of attributes to add or update
  /// @return A new Attributes instance with the added/updated attributes
  /// If the input list is empty, returns this instance unchanged.
  Attributes copyWith(List<Attribute> other) {
    if (other.isEmpty) {
      return this;
    }
    final newEntries = {
      ..._entries,
    };
    for (var attr in other) {
      newEntries[attr.key] = attr;
    }
    return AttributesCreate.create(newEntries.values.toList());
  }

  /// Creates a new Attributes instance by combining with another Attributes instance.
  /// Attributes from the other instance will overwrite attributes with the same keys in this instance.
  ///
  /// @param other The Attributes instance to combine with
  /// @return A new Attributes instance with the combined attributes
  Attributes copyWithAttributes(Attributes other) {
    return copyWith(other.toList());
  }

  /// Creates a new Attributes instance with the specified attribute removed.
  /// If the key doesn't exist, returns this instance unchanged.
  ///
  /// @param key The key of the attribute to remove
  /// @return A new Attributes instance with the attribute removed
  Attributes copyWithout(String key) {
    if (!_entries.containsKey(key)) return this; // Nothing to remove
    final newEntries = Map<String, Attribute>.from(_entries);
    newEntries.remove(key);
    return AttributesCreate.create(newEntries.values.toList());
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  /// Converts the attributes to a JSON-serializable map.
  /// This is useful for logging or debugging.
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    for (final entry in _entries.entries) {
      result[entry.key] = entry.value.value.unwrap();
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Attributes) return false;

    // Use deep equality for the map
    const equality = MapEquality<String, Attribute>();
    return equality.equals(_entries, other._entries);
  }

  @override
  int get hashCode => const MapEquality<String, Attribute>().hash(_entries);
}

/// Extension to create Attributes from a simple Map
extension AttributesExtension on Map<String, Object> {
  /// Convert this map to Attributes
  /// Empty strings and empty lists are stored per the OTel spec
  Attributes toAttributes() {
    return OTelFactory.getOrCreateDefault().attributesFromMap(this);
  }
}
