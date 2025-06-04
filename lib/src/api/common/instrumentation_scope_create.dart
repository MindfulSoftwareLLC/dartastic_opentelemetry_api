// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'instrumentation_scope.dart';

/// Factory class for creating InstrumentationScope instances.
/// Used internally and not exported to respect factories.
/// This class is not intended to be used directly by users.
/// Instead, use the methods provided by the [OTelAPI].
class InstrumentationScopeCreate {
  /// Creates a new InstrumentationScope instance containing the specified attributes.
  /// [name] is required and represents the instrumentation scope name (e.g. 'io.opentelemetry.contrib.mongodb')
  /// [version] is optional and specifies the version of the instrumentation scope
  /// [schemaUrl] is optional and specifies the Schema URL
  /// [attributes] is optional and specifies instrumentation scope attributes
  /// @return A new InstrumentationScope instance
  static InstrumentationScope create({
    required String name,
    String version = '1.0.0',
    String? schemaUrl,
    Attributes? attributes,
  }) {
    return InstrumentationScope._(name, version, schemaUrl, attributes);
  }
}
