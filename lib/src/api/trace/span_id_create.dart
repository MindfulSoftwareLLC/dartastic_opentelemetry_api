// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'span_id.dart';

/// Factory class for creating SpanId instances.
///
/// This is a part of the OpenTelemetry API implementation and not meant
/// to be used directly by application code.
@internal
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
