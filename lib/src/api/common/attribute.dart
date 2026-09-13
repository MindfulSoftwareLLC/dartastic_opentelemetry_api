// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';

import 'any_value.dart';

part 'attribute_create.dart';

/// Represents a value for an attribute, associated with an attribute key.
@immutable
class Attribute {
  /// The key (name) of this attribute.
  final String _key;

  /// The value of this attribute.
  final AnyValue _value;

  /// Creates an attribute.
  ///
  /// The OpenTelemetry specification constrains attribute keys, not attribute
  /// values, so empty Strings and empty lists are valid values but an empty
  /// key is not.
  Attribute._(String key, AnyValue value)
      : _key = key,
        _value = value {
    if (key.isEmpty) {
      throw ArgumentError.value(key, 'key', 'Attribute key must not be empty');
    }
  }

  /// Gets the key (name) of this attribute.
  String get key => _key;

  /// Gets the value of this attribute.
  AnyValue get value => _value;

  @override
  String toString() {
    return 'AttributeValue(${_value.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Attribute) return false;

    return runtimeType == other.runtimeType &&
        key == other.key &&
        value == other.value;
  }

  @override
  int get hashCode {
    return Object.hash(key, value);
  }
}
