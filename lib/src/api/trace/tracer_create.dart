// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'tracer.dart';

/// Internal constructor access for Tracer
class TracerCreate {
  /// Creates a Tracer, only accessible within library
  static APITracer create({
    required String name,
    String? version,
    String? schemaUrl,
    Attributes? attributes,
  }) {
    return APITracer._(
      name: name,
      version: version,
      schemaUrl: schemaUrl,
      attributes: attributes,
    );
  }
}
