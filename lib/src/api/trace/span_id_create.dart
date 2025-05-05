// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'span_id.dart';

/// Factory class for creating SpanId instances.
///
/// This is a part of the OpenTelemetry API implementation and not meant
/// to be used directly by application code.
class SpanIdCreate {
  /// Creates a new SpanId from the provided bytes.
  ///
  /// [bytes] An 8-byte array representing the span ID
  ///
  /// Throws an ArgumentError if bytes is not exactly 8 bytes long.
  static SpanId create(Uint8List bytes) {
    return SpanId._(bytes);
  }
}
