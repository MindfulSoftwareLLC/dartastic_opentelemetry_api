// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'attribute.dart';

/// Factory class for creating Attribute instances.
/// This class is not intended to be used directly by users.
/// Instead, use the methods provided by the OpenTelemetry API.
@internal
class AttributeCreate {
  /// Creates a new Attribute with the specified name and value.
  ///
  /// @param name The name of the attribute
  /// @param value The value of the attribute
  /// @return A new Attribute instance
  static Attribute create(String name, AnyValue value) {
    return Attribute._(name, value);
  }

  /// Whether [value] is legal as an *attribute* value.
  ///
  /// [AnyValue] is the log body data model, so it admits maps, heterogeneous
  /// arrays, bytes and null, and `LogRecord.body` needs all of them.
  /// common/README.md constrains an attribute value to a primitive (String,
  /// bool, int, double) or a homogeneous array of primitives, so the wider
  /// values are rejected here rather than in [AnyValue].
  ///
  /// Without this an illegal value converts cleanly, is stored, and ships to
  /// the backend, but no branch of `Attributes._getTyped` matches it, so every
  /// typed getter returns null: the attribute is write-only.
  static bool isValidAttributeValue(AnyValue value) {
    // A switch over the sealed hierarchy, not an if-chain, so a new subtype
    // is a compile error here instead of silently becoming legal.
    return switch (value) {
      AnyValueString() ||
      AnyValueBool() ||
      AnyValueInt() ||
      AnyValueDouble() =>
        true,
      AnyValueMap() || AnyValueBytes() || AnyValueNull() => false,
      AnyValueArray(value: final elements) => _isValidAttributeArray(elements),
    };
  }

  static bool _isValidAttributeArray(List<AnyValue> elements) {
    // An empty array has no element type to disagree about.
    if (elements.isEmpty) return true;

    var sawString = false;
    var sawBool = false;
    var sawNumber = false;
    for (final element in elements) {
      switch (element) {
        case AnyValueString():
          sawString = true;
        case AnyValueBool():
          sawBool = true;
        case AnyValueInt():
        case AnyValueDouble():
          sawNumber = true;
        case AnyValueArray():
        case AnyValueMap():
        case AnyValueBytes():
        case AnyValueNull():
          // Nested arrays, maps, bytes and null are never attribute values.
          return false;
      }
    }

    // Exactly one element kind, except that int and double may mix. JSON has
    // a single number type, so [1, 2.5] is routine; attrsFromMap and fromJson
    // promoted such an array to List<double> before AnyValue and
    // Attributes._getTyped still does, so it reads back rather than being the
    // write-only value this check exists to reject.
    final kinds = (sawString ? 1 : 0) + (sawBool ? 1 : 0) + (sawNumber ? 1 : 0);
    return kinds == 1;
  }

  /// Names [value]'s kind for an error message, e.g. `a map`.
  static String describeIllegalValue(AnyValue value) {
    return switch (value) {
      AnyValueMap() => 'a map',
      AnyValueBytes() => 'a byte array',
      AnyValueNull() => 'null',
      AnyValueArray(value: final elements) =>
        elements.any((e) => e is AnyValueNull)
            ? 'an array containing null'
            : 'a nested or heterogeneous array',
      // Unreachable: a scalar is always a legal attribute value, so it never
      // reaches this. Kept so the switch stays exhaustive over the sealed
      // hierarchy and a new subtype is a compile error here.
      AnyValueString() ||
      AnyValueBool() ||
      AnyValueInt() ||
      AnyValueDouble() =>
        'a primitive',
    };
  }
}
