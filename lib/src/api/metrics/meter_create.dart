// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'meter.dart';

/// Factory methods for creating [APIMeter] instances.
/// This is part of the meter.dart file to keep related code together.
/// Factory class for creating APIMeter instances.
/// This class is internal and should not be used directly by application code.
class APIMeterCreate {
  /// Creates a new [APIMeter] instance with the specified parameters.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeterProvider.getMeter()] instead.
  ///
  /// @param name The name of the meter, typically the package name or fully qualified class name
  /// @param version Optional version of the instrumentation, e.g. "1.0.0"
  /// @param schemaUrl Optional URL pointing to the schema for this meter
  /// @param attributes Optional attributes to associate with this meter
  static APIMeter create({
    required String name,
    String? version,
    String? schemaUrl,
    Attributes? attributes,
  }) {
    // Only apply all defaults if none of version, schemaUrl, or attributes are provided
    final bool setDefaults =
        version == null && schemaUrl == null && attributes == null;

    return APIMeter._(
      name: name,
      version: setDefaults
          ? OTelAPI.defaultServiceVersion
          : version, // Only set default if no parameters were provided
      schemaUrl: setDefaults
          ? OTelAPI.defaultSchemaUrl
          : schemaUrl, // Only set default if no parameters were provided
      attributes: attributes,
    );
  }
}
