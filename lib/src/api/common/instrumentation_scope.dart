// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../../../dartastic_opentelemetry_api.dart';

/// Represents the instrumentation scope information.
class InstrumentationScope {
  /// The instrumentation scope name (e.g. 'io.opentelemetry.contrib.mongodb').
  final String name;

  /// The version of the instrumentation scope, or null if not specified.
  final String? version;

  /// The Schema URL, or null if not specified.
  final String? schemaUrl;

  /// The instrumentation scope attributes, or null if not specified.
  final Attributes? attributes;

  /// Creates a new InstrumentationScope.
  ///
  /// [name] is required and represents the instrumentation scope name (e.g. 'io.opentelemetry.contrib.mongodb')
  /// [version] is optional and specifies the version of the instrumentation scope
  /// [schemaUrl] is optional and specifies the Schema URL
  /// [attributes] is optional and specifies instrumentation scope attributes
  const InstrumentationScope({
    required this.name,
    this.version,
    this.schemaUrl,
    this.attributes,
  });
}
