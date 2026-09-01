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
  static Attributes fromJson(Map<String, dynamic> json) {
    final attributes = <Attribute>[];

    for (final entry in json.entries) {
      try {
        final anyValue = AnyValue.fromObject(entry.value);
        attributes.add(AttributeCreate.create(entry.key, anyValue));
      } catch (e) {
        OTelErrorHandling.report(ArgumentError(
            'Ignoring attribute ${entry.key} because it contains unsupported types: $e'));
      }
    }

    return AttributesCreate.create(attributes);
  }

  /// Private constructor to enforce immutability.
  Attributes._(List<Attribute> entries) {
    for (var attr in entries) {
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

  /// Returns the value associated with the given [key], or null if not present.
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
      if (anyValue.value.every((e) => e is AnyValueString)) {
        final result = anyValue.value.map((e) => e.value as String).toList();
        if (result is T) return result as T;
      }
      if (anyValue.value.every((e) => e is AnyValueBool)) {
        final result = anyValue.value.map((e) => e.value as bool).toList();
        if (result is T) return result as T;
      }
      if (anyValue.value.every((e) => e is AnyValueInt)) {
        final result = anyValue.value.map((e) => e.value as int).toList();
        if (result is T) return result as T;
      }
      if (anyValue.value.every((e) => e is AnyValueDouble)) {
        final result = anyValue.value.map((e) => e.value as double).toList();
        if (result is T) return result as T;
      }
    }

    throw StateError('Value for key "$key" is not of type $T');
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
  Attributes toAttributes() {
    return OTelFactory.getOrCreateDefault().attributesFromMap(this);
  }
}
