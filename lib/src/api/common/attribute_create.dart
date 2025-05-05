// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'attribute.dart';

/// Factory class for creating Attribute instances.
/// This class is not intended to be used directly by users.
/// Instead, use the methods provided by the OpenTelemetry API.
class AttributeCreate {
  /// Creates a new Attribute with the specified name and value.
  ///
  /// @param name The name of the attribute
  /// @param value The value of the attribute
  /// @return A new Attribute instance
  static Attribute<T> create<T extends Object>(String name, T value) {
    return Attribute._(name, value);
  }
}
