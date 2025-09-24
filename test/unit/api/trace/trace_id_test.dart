// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:typed_data';

import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('TraceId', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('generates valid trace IDs', () {
      final id = OTelAPI.traceId();
      expect(id.isValid, isTrue);
      expect(id.toString().length, equals(32),
          reason: 'Trace ID should be 32 characters (16 bytes) in hex');
      expect(id.toString(), isNot(equals('00000000000000000000000000000000')),
          reason: 'Generated trace ID should not be zero');
    });

    test('creates from valid hex string', () {
      const validHex = 'a1b2c3d4e5f67890a1b2c3d4e5f67890';
      final id = OTelAPI.traceIdFrom(validHex);
      expect(id.toString(), equals(validHex));
      expect(id.isValid, isTrue);
    });

    test('creates invalid ID', () {
      final id = OTelAPI.traceIdInvalid();
      expect(id.isValid, isFalse);
      expect(id.toString(), equals('00000000000000000000000000000000'));
    });

    test('handles invalid hex string', () {
      expect(
        () => OTelAPI.traceIdFrom('invalid'),
        throwsA(isA<FormatException>()),
      );
    });

    test('provides access to raw bytes', () {
      final id = OTelAPI.traceId();
      expect(id.bytes.length, equals(16),
          reason: 'Trace ID should be 16 bytes');
    });

    test('implements value equality', () {
      const hex = 'a1b2c3d4e5f67890a1b2c3d4e5f67890';
      final id1 = OTelAPI.traceIdFrom(hex);
      final id2 = OTelAPI.traceIdFrom(hex);

      expect(id1, equals(id2));
      expect(id1.hashCode, equals(id2.hashCode));
    });

    test('generates unique IDs', () {
      final ids = List.generate(1000, (_) => OTelAPI.traceId());
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, equals(ids.length),
          reason: 'All generated trace IDs should be unique');
    });

    test('traceId and spanId from bytes validation', () {
      // Invalid length for trace ID
      final invalidTraceIdBytes = Uint8List.fromList(List.filled(8, 0));
      expect(() {
        OTelAPI.traceIdOf(invalidTraceIdBytes);
      }, throwsArgumentError);

      // Invalid length for span ID
      final invalidSpanIdBytes = Uint8List.fromList(List.filled(16, 0));
      expect(() {
        OTelAPI.spanIdOf(invalidSpanIdBytes);
      }, throwsArgumentError);
    });

    test('traceIdFrom handles invalid hex strings', () {
      expect(() {
        OTelAPI.traceIdFrom('invalid-hex');
      }, throwsFormatException);
    });

    test('spanIdFrom handles invalid hex strings', () {
      expect(() {
        OTelAPI.spanIdFrom('invalid-hex');
      }, throwsFormatException);
    });
  });
}
