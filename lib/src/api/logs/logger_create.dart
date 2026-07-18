// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'logger.dart';

@internal
class LoggerCreate {
  /// Creates a Logger, only accessible within library
  static APILogger create({
    required String name,
    String? version,
    String? schemaUrl,
    Attributes? attributes,
  }) {
    return APILogger._(
      name: name,
      version: version,
      schemaUrl: schemaUrl,
      attributes: attributes,
    );
  }
}
