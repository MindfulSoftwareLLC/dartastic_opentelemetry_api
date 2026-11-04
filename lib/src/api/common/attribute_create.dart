// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'attribute.dart';

/// Factory class for creating [Attribute] instances.
/// This class is not intended to be used directly by users.
/// Instead, use the methods provided by the OpenTelemetry API.
@internal
class AttributeCreate {
  /// Creates a new [Attribute] with the specified name and value.
  ///
  /// @param name The name of the attribute
  /// @param value The value of the attribute
  /// @return A new [Attribute] instance
  static Attribute<T> create<T extends Object>(String name, T value) {
    return Attribute._(name, value);
  }

  /// Creates an [Attribute] from an untyped list by inspecting its element
  /// types. Only lists of Strings, bools, ints or doubles are valid OTel
  /// attribute values; a list mixing ints and doubles is promoted to a
  /// list of doubles. An empty list is treated as a list of Strings,
  /// since `.every()` is vacuously true for it.
  ///
  /// Returns null, after reporting the error, when no supported element
  /// type fits.
  static Attribute<Object>? createFromUntypedList(
      String key, List<Object?> value) {
    if (value.every((e) => e is String)) {
      return Attribute<List<String>>._(key, value.cast<String>());
    } else if (value.every((e) => e is bool)) {
      return Attribute<List<bool>>._(key, value.cast<bool>());
    } else if (value.every((e) => e is int)) {
      return Attribute<List<int>>._(key, value.cast<int>());
    } else if (value.every((e) => e is double || e is int)) {
      return Attribute<List<double>>._(key,
          value.map((e) => e is int ? e.toDouble() : e as double).toList());
    }
    OTelErrorHandling.report(ArgumentError(
        'Ignoring attribute $key because the list contains unsupported '
        'types. Only lists of Strings, bools, ints and doubles are allowed '
        'by the OTel specification.'));
    return null;
  }
}
