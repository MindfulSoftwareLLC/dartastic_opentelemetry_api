// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'span_event.dart';

/// Factory class for creating SpanEvent instances.
///
/// This is a part of the OpenTelemetry API implementation and not meant
/// to be used directly by application code.
class SpanEventCreate {
  /// Creates a new SpanEvent with the given parameters.
  ///
  /// [name] The name of the event (required, must not be empty)
  /// [timestamp] The time at which the event occurred
  /// [attributes] Optional attributes providing additional context
  ///
  /// Throws an ArgumentError if name is empty.
  static SpanEvent create({
    required String name,
    required DateTime timestamp,
    Attributes? attributes,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('name cannot be empty');
    }
    return SpanEvent._(
        name: name, timestamp: timestamp, attributes: attributes);
  }
}
