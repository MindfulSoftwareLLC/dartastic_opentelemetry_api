// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

library;

import '../otel_api.dart';
import 'attributes.dart';

part 'instrumentation_scope_create.dart';

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
  const InstrumentationScope._(
    this.name,
    this.version,
    this.schemaUrl,
    this.attributes,
  );

  @override
  String toString() {
    return 'InstrumentationScope{name: $name, version: $version, schemaUrl: $schemaUrl, attributes: $attributes}';
  }
}
