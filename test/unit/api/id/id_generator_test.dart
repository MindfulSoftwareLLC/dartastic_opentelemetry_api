// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

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

    group('hexToBytes', () {
      test('converts hex to bytes', () {
        final hex = '1234abcd';
        final bytes = IdGenerator.hexToBytes(hex);
        expect(bytes, equals([0x12, 0x34, 0xAB, 0xCD]));
      });

      test('accepts the full lowercase alphabet', () {
        expect(
          IdGenerator.hexToBytes('0123456789abcdef'),
          equals([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF]),
        );
      });

      test('returns null for an odd-length string', () {
        expect(IdGenerator.hexToBytes('invalid'), isNull);
        expect(IdGenerator.hexToBytes('123'), isNull);
      });

      test('rejects non-hex letters', () {
        expect(IdGenerator.hexToBytes('zz'), isNull);
      });

      test('rejects uppercase hex', () {
        expect(IdGenerator.hexToBytes('1234abcd'.toUpperCase()), isNull);
      });

      test('rejects mixed-case hex', () {
        expect(IdGenerator.hexToBytes('1234abcD'), isNull);
        expect(IdGenerator.hexToBytes('Ab'), isNull);
      });

      test('rejects a plus sign', () {
        expect(IdGenerator.hexToBytes('+f'), isNull);
      });

      test('rejects a minus sign rather than wrapping it to 0xff', () {
        expect(IdGenerator.hexToBytes('-1'), isNull);
      });

      test('rejects surrounding whitespace', () {
        expect(IdGenerator.hexToBytes(' f'), isNull);
        expect(IdGenerator.hexToBytes('f '), isNull);
        expect(IdGenerator.hexToBytes('\tf'), isNull);
      });

      test('decodes an empty string to an empty list', () {
        expect(IdGenerator.hexToBytes(''), isEmpty);
      });
    });
  });
}
