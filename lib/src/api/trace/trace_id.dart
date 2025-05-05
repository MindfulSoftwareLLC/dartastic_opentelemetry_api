// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library trace_id;

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../id/id_generator.dart';

part 'trace_id_create.dart';

/// A trace identifier - a 16-byte array with an ID in a base-16 hex format.
/// TraceId follows the W3C Trace Context specification.
@immutable
class TraceId {
  /// The number of bytes in a trace ID.
  /// Per the OpenTelemetry specification, trace IDs must be 16 bytes (128 bits).
  static const int traceIdLength = 16;

  /// A trace ID consisting of all zeros, representing an invalid trace ID.
  static final Uint8List invalidTraceIdBytes = Uint8List(traceIdLength);

  /// The raw bytes of the trace ID
  final Uint8List _bytes;

  /// Creates a new [TraceId] from bytes
  TraceId._(this._bytes) {
    if (_bytes.length != traceIdLength) {
      throw ArgumentError('TraceId must be $traceIdLength bytes');
    }
  }

  /// The raw bytes of the trace ID
  Uint8List get bytes => Uint8List.fromList(_bytes);

  /// Returns the lowercase base16 (hex) representation of the TraceId
  String get hexString => IdGenerator.bytesToHex(_bytes);

  @override
  String toString() => hexString;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraceId &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => toString().hashCode;

  /// Returns true if this TraceId is valid (not zero)
  bool get isValid {
    for (var byte in _bytes) {
      if (byte != 0) return true;
    }
    return false;
  }
}
