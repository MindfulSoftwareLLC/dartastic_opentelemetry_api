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
  /// key is not. An empty key is not rejected here: error-handling.md makes it
  /// a MUST NOT for an API method to throw on end-user misuse, so [Attributes]
  /// drops such an attribute and reports it instead.
  Attribute._(String key, AnyValue value)
      : _key = key,
        _value = value;

  /// Gets the key (name) of this attribute.
  String get key => _key;

  /// Gets the value of this attribute.
  AnyValue get value => _value;

  @override
  String toString() {
    // Interpolating _value calls AnyValue.toString, which renders the value
    // recursively: an array of Strings reads as `["a", "b"]`, and bytes as
    // `<3 bytes>`. It is also bounded — it truncates deep nesting rather than
    // throwing, which matters because toString runs inside debuggers and
    // error messages.
    return 'AttributeValue($_value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Attribute) return false;

    // No runtimeType comparison: Attribute is neither generic nor subclassed,
    // so `other is! Attribute` above already settles it.
    return key == other.key && value == other.value;
  }

  @override
  int get hashCode {
    return Object.hash(key, value);
  }
}
