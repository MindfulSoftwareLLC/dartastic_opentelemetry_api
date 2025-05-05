// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:math';
import 'dart:typed_data';

/// Generates trace and span IDs according to the W3C Trace Context specification.
class IdGenerator {
  static final Random _random = Random.secure();

  /// Generate a 16-byte trace ID.
  /// Returns bytes which can be formatted as a 32-char hex string.
  static Uint8List generateTraceId() {
    final Uint8List bytes = Uint8List(16);

    // Generate random bytes until we get a non-zero ID
    do {
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = _random.nextInt(256);
      }
    } while (_isZero(bytes));

    return bytes;
  }

  /// Generate an 8-byte span ID.
  /// Returns bytes which can be formatted as a 16-char hex string.
  static Uint8List generateSpanId() {
    final bytes = Uint8List(8);

    // Generate random bytes until we get a non-zero ID
    do {
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = _random.nextInt(256);
      }
    } while (_isZero(bytes));

    return bytes;
  }

  /// Convert bytes to lowercase hex string.
  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Check if all bytes are zero.
  static bool _isZero(List<int> bytes) {
    for (var byte in bytes) {
      if (byte != 0) return false;
    }
    return true;
  }

  /// Parse hex string to bytes.
  static Uint8List? hexToBytes(String hex) {
    if (hex.length % 2 != 0) return null;

    final bytes = Uint8List(hex.length ~/ 2);

    for (var i = 0; i < bytes.length; i++) {
      final hexByte = hex.substring(i * 2, (i * 2) + 2);
      final byte = int.tryParse(hexByte, radix: 16);
      if (byte == null) return null;
      bytes[i] = byte;
    }

    return bytes;
  }
}
