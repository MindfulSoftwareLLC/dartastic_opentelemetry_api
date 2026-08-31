// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'span_event.dart';

/// Factory class for creating SpanEvent instances.
///
/// This is a part of the OpenTelemetry API implementation and not meant
/// to be used directly by application code.
@internal
class SpanEventCreate {
  /// Creates a new SpanEvent with the given parameters.
  ///
  /// [name] The name of the event
  /// [timestamp] The time at which the event occurred
  /// [attributes] Optional attributes providing additional context
  ///
  /// This method does not throw. error-handling.md forbids a throw for
  /// incorrect user input. A span drops an event that has an empty name.
  /// See https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
  static SpanEvent create({
    required String name,
    required DateTime timestamp,
    Attributes? attributes,
  }) {
    return SpanEvent._(
        name: name, timestamp: timestamp, attributes: attributes);
  }
}
