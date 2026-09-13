// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:math';
import 'dart:typed_data';

/// Generates trace and span IDs according to the W3C Trace Context specification.
class IdGenerator {
  static final Random _random = Random.secure();

  /// Generate a 16-byte trace ID.
  /// Returns bytes which can be formatted as a 32-char hex string.
  static Uint8List generateTraceId() {
    final bytes = Uint8List(16);

    // Generate random bytes until we get a non-zero ID
    do {
      for (var i = 0; i < bytes.length; i++) {
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
      for (var i = 0; i < bytes.length; i++) {
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

  /// Value of a lowercase hex digit, or -1 if [codeUnit] is not one.
  static int _hexDigitValue(int codeUnit) {
    // '0'..'9' are 0x30..0x39; 'a'..'f' are 0x61..0x66 and stand for 10..15.
    if (codeUnit >= 0x30 && codeUnit <= 0x39) return codeUnit - 0x30;
    if (codeUnit >= 0x61 && codeUnit <= 0x66) return codeUnit - 0x61 + 10;
    return -1;
  }

  /// Parse a lowercase hex string to bytes.
  /// Returns null for an odd length or any non-lowercase-hex character.
  static Uint8List? hexToBytes(String hex) {
    if (hex.length % 2 != 0) return null;

    final bytes = Uint8List(hex.length ~/ 2);

    for (var i = 0; i < bytes.length; i++) {
      final high = _hexDigitValue(hex.codeUnitAt(i * 2));
      final low = _hexDigitValue(hex.codeUnitAt((i * 2) + 1));
      if (high < 0 || low < 0) return null;
      bytes[i] = (high << 4) | low;
    }

    return bytes;
  }
}
