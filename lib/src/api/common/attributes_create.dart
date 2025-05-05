// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'attributes.dart';

/// Factory class for creating Attributes instances.
/// Used internally and not exported to respect factories.
/// This class is not intended to be used directly by users.
/// Instead, use the methods provided by the OpenTelemetry API.
class AttributesCreate {
  /// Creates a new Attributes instance containing the specified attributes.
  ///
  /// @param entries The list of attributes to include
  /// @return A new Attributes instance
  static Attributes create(List<Attribute> entries) {
    return Attributes._(entries);
  }
}
