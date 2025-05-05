// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library span_id;

import 'dart:typed_data';
import '../id/id_generator.dart';

part 'span_id_create.dart';

/// A span identifier - an 8-byte array with an ID in a base-16 hex format.
/// Follows W3C Trace Context specification.
class SpanId {
  /// The number of bytes in a span ID.
  /// Per the OpenTelemetry specification, span IDs must be 8 bytes (64 bits).
  static const int spanIdLength = 8; // 8 bytes for SpanId
  /// A span ID consisting of all zeros, representing an invalid span ID.
  static final Uint8List invalidSpanIdBytes = Uint8List(spanIdLength);

  /// A SpanId instance representing an invalid span ID (all zeros).
  static final SpanId invalidSpanId = SpanId._(Uint8List(spanIdLength));

  /// The raw bytes of the span ID
  final Uint8List _bytes;

  /// Creates a new [SpanId] from bytes
  SpanId._(this._bytes) {
    if (_bytes.length != spanIdLength) {
      throw ArgumentError('SpanId must be $spanIdLength bytes');
    }
  }

  /// Returns a copy of the raw bytes of this SpanId.
  ///
  /// Returns a new Uint8List to prevent modification of the internal bytes.
  Uint8List get bytes => Uint8List.fromList(_bytes);

  /// Returns the lowercase base16 (hex) representation of the SpanId
  String get hexString => IdGenerator.bytesToHex(_bytes);

  @override
  String toString() => hexString;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanId &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => toString().hashCode;

  /// Returns true if this SpanId is valid (not zero)
  bool get isValid {
    for (var byte in _bytes) {
      if (byte != 0) return true;
    }
    return false;
  }
}
