// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

part 'attribute_create.dart';

/// Represents a value for an attribute, associated with an attribute key.
@immutable
class Attribute<T extends Object> {
  /// The DeepCollectionEquality object used for comparing list values.
  /// This enables proper element-by-element comparisons for lists.
  static final DeepCollectionEquality _listEquality =
      const DeepCollectionEquality();

  /// The key (name) of this attribute.
  final String _key;

  /// The value of this attribute.
  final T _value;

  Attribute._(String key, T value)
      : _key = key,
        _value = value {
    if (_value is String && (_value as String).isEmpty) {
      throw ArgumentError('Attribute _value must not be an empty string');
    }
    if (_value is List) {
      final valueList = _value as List;
      if (valueList.isEmpty) {
        throw ArgumentError('Attribute _value list must not be empty');
      }
      // No null-element guard: attributes are only created with
      // non-nullable element types (List<String>, List<bool>, List<int>,
      // List<double>), so sound null safety already rules nulls out.
    }
  }

  /// Gets the key (name) of this attribute.
  String get key => _key;

  /// Gets the value of this attribute.
  T get value => _value;

  @override
  String toString() {
    return 'AttributeValue($_value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Attribute<T>) return false;

    // Use deep equality for lists, otherwise default equality
    final valuesAreEqual = value is List
        ? _listEquality.equals(value, other.value)
        : value == other.value;

    return runtimeType == other.runtimeType &&
        key == other.key &&
        valuesAreEqual;
  }

  @override
  int get hashCode {
    // Use deep hash for lists, otherwise default hash
    final valueHash =
        value is List ? _listEquality.hash(value) : value.hashCode;
    return Object.hash(key, valueHash);
  }
}
