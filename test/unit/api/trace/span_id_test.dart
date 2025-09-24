// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('SpanId', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('generates valid span IDs', () {
      final id = OTelAPI.spanId();
      expect(id.isValid, isTrue);
      expect(id.toString().length, equals(16),
          reason: 'Span ID should be 16 characters (8 bytes) in hex');
      expect(id.toString(), isNot(equals('0000000000000000')),
          reason: 'Generated span ID should not be zero');
    });

    test('creates from valid hex string', () {
      const validHex = 'a1b2c3d4e5f67890';
      final id = OTelAPI.spanIdFrom(validHex);
      expect(id.toString(), equals(validHex));
      expect(id.isValid, isTrue);
    });

    test('creates invalid ID', () {
      final id = OTelAPI.spanIdInvalid();
      expect(id.isValid, isFalse);
      expect(id.toString(), equals('0000000000000000'));
    });

    test('handles invalid hex string', () {
      expect(
        () => OTelAPI.spanIdFrom('invalid'),
        throwsA(isA<FormatException>()),
      );
    });

    test('provides access to raw bytes', () {
      final id = OTelAPI.spanId();
      expect(id.bytes.length, equals(8), reason: 'Span ID should be 8 bytes');
    });

    test('implements value equality', () {
      const hex = 'a1b2c3d4e5f67890';
      final id1 = OTelAPI.spanIdFrom(hex);
      final id2 = OTelAPI.spanIdFrom(hex);

      expect(id1, equals(id2));
      expect(id1.hashCode, equals(id2.hashCode));
    });

    test('generates unique IDs', () {
      final ids = List.generate(1000, (_) => OTelAPI.spanId());
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, equals(ids.length),
          reason: 'All generated span IDs should be unique');
    });
  });
}
