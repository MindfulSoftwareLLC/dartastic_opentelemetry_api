// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/id/id_generator.dart';
import 'package:test/test.dart';

void main() {
  group('IdGenerator', () {
    test('generates valid trace ID', () {
      final bytes = IdGenerator.generateTraceId();
      expect(bytes.length, equals(16));
      expect(IdGenerator.bytesToHex(bytes).length, equals(32));

      // Verify not all zeros
      expect(bytes.any((b) => b != 0), isTrue);
    });

    test('generates valid span ID', () {
      final bytes = IdGenerator.generateSpanId();
      expect(bytes.length, equals(8));
      expect(IdGenerator.bytesToHex(bytes).length, equals(16));

      // Verify not all zeros
      expect(bytes.any((b) => b != 0), isTrue);
    });

    test('converts bytes to hex', () {
      final bytes = [0x12, 0x34, 0xAB, 0xCD];
      expect(IdGenerator.bytesToHex(bytes), equals('1234abcd'));
    });

    test('converts hex to bytes', () {
      final hex = '1234abcd';
      final bytes = IdGenerator.hexToBytes(hex);
      expect(bytes, equals([0x12, 0x34, 0xAB, 0xCD]));
    });

    test('returns null for invalid hex string', () {
      expect(IdGenerator.hexToBytes('invalid'), isNull);
      expect(IdGenerator.hexToBytes('123'), isNull);
    });

  });
}
