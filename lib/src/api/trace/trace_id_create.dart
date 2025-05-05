// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'trace_id.dart';

/// Factory class for creating TraceId instances.
///
/// This is a part of the OpenTelemetry API implementation and not meant
/// to be used directly by application code.
class TraceIdCreate {
  /// Creates a new TraceId from the provided bytes.
  ///
  /// [bytes] A 16-byte array representing the trace ID
  ///
  /// Throws an ArgumentError if bytes is not exactly 16 bytes long.
  /// Returns a new TraceId initialized with the provided bytes.
  static TraceId create(Uint8List bytes) {
    return TraceId._(bytes);
  }
}
