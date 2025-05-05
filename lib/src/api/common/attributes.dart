// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library attributes;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import '../../../dartastic_opentelemetry_api.dart';

part 'attributes_create.dart';

/// A collection of attributes that are immutable and type-safe.
/// Create with the OTelFactory methods.
@immutable
class Attributes {
  final Map<String, Attribute<Object>> _entries = {};

  /// Creates an Attributes instance from a map of key-value pairs.
  /// Uses the appropriate factory method (OTelFactory or OTelAPIFactory) based on initialization state.
  ///
  /// @param map The map of key-value pairs to convert to attributes
  /// @return A new Attributes instance containing the converted attributes
  static Attributes of(Map<String, Object> map) {
    // Directly use the API factory's attrsFromMap if not initialized
    // This is to allow the creation of attributes for initialization and is
    // Overrides would take effect after initialization.
    return OTelFactory.otelFactory != null
        ? OTelFactory.otelFactory!.attributesFromMap(map)
        : OTelAPIFactory.attrsFromMap(map);
  }

  /// Creates an Attributes instance from a JSON map.
  /// This is a utility method for deserialization from logs or exports.
  static Attributes fromJson(Map<String, dynamic> json) {
    final attributes = <Attribute<Object>>[];

    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        attributes.add(AttributeCreate.create<String>(key, value));
      } else if (value is bool) {
        attributes.add(AttributeCreate.create<bool>(key, value));
      } else if (value is int) {
        attributes.add(AttributeCreate.create<int>(key, value));
      } else if (value is double) {
        attributes.add(AttributeCreate.create<double>(key, value));
      } else if (value is List<String>) {
        attributes.add(AttributeCreate.create<List<String>>(key, value));
      } else if (value is List<bool>) {
        attributes.add(AttributeCreate.create<List<bool>>(key, value));
      } else if (value is List<int>) {
        attributes.add(AttributeCreate.create<List<int>>(key, value));
      } else if (value is List<double>) {
        attributes.add(AttributeCreate.create<List<double>>(key, value));
      } else if (value is List) {
        // Try to convert the list to a supported type
        if (value.isNotEmpty) {
          if (value.every((e) => e is String)) {
            attributes.add(AttributeCreate.create<List<String>>(
                key, value.cast<String>()));
          } else if (value.every((e) => e is bool)) {
            attributes.add(
                AttributeCreate.create<List<bool>>(key, value.cast<bool>()));
          } else if (value.every((e) => e is int)) {
            attributes
                .add(AttributeCreate.create<List<int>>(key, value.cast<int>()));
          } else if (value.every((e) => e is double || e is int)) {
            // Convert all to double
            attributes.add(AttributeCreate.create<List<double>>(
                key,
                value
                    .map((e) => e is int ? e.toDouble() : e as double)
                    .toList()));
          } else {
            OTelLog.warn(
                'Ignoring attribute $key because the list contains unsupported types. Only String, bool, int, double lists are allowed by the OTel specification.');
          }
        } else {
          OTelLog.warn(
              'Ignoring attribute $key because empty lists are not allowed by the OTel specification.');
        }
      } else {
        OTelLog.warn(
            'Ignoring attribute $key because the value is not a valid attribute type. Only String, bool, int, double and Lists of those types are allowed by the OTel specification.');
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

    // Ensure the value matches the expected type `T`
    if (attribute.value is T) {
      return attribute.value as T;
    } else {
      throw StateError('Value for key "$key" is not of type $T');
    }
  }

  /// Creates a new Attributes instance with a String attribute added or updated.
  ///
  /// @param name The attribute key
  /// @param value The String value
  /// @return A new Attributes instance with the added/updated attribute
  Attributes copyWithStringAttribute(String name, String value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create<String>(name, value),
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
      AttributeCreate.create<bool>(name, value),
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
      AttributeCreate.create<int>(name, value),
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
      AttributeCreate.create<double>(name, value),
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
      AttributeCreate.create<List<String>>(name, value),
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
      AttributeCreate.create<List<bool>>(name, value),
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
      AttributeCreate.create<List<int>>(name, value),
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
      AttributeCreate.create<List<double>>(name, value),
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
  String toString() => _entries.toString();

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

  /// Converts the attributes to a JSON-serializable map.
  /// This is useful for logging or debugging.
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    for (final entry in _entries.entries) {
      result[entry.key] = entry.value.value;
    }
    return result;
  }
}

/// Extension to create Attributes from a simple Map
extension AttributesExtension on Map<String, Object> {
  /// Convert this map to Attributes
  /// Empty string are not allowed and are skipped
  Attributes toAttributes() {
    if (OTelFactory.otelFactory == null) {
      // Cheating here since Attributes is unlikely to be overriden in a
      // factory and is often called before initialize
      return OTelAPI.attributesFromMap(this);
    }
    return OTelFactory.otelFactory!.attributesFromMap(this);
  }
}
