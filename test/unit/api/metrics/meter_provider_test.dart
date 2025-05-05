// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIMeterProvider', () {
    late APIMeterProvider meterProvider;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      meterProvider = OTelAPI.meterProvider();
    });

    test('creates meter with valid name', () {
      // Arrange & Act
      final meter = meterProvider.getMeter(name: 'test-meter');

      // Assert
      expect(meter, isNotNull);
      expect(meter.name, equals('test-meter'));
      expect(meter.version, isNotNull);
      expect(meter.schemaUrl, isNotNull);
    });

    test('creates meter with empty name as fallback if name is invalid', () {
      // Arrange & Act
      final meter = meterProvider.getMeter(name: '');

      // Assert
      expect(meter, isNotNull);
      expect(meter.name, equals(''));
    });

    test('caches meters with the same parameters', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter');
      final meter2 = meterProvider.getMeter(name: 'test-meter');

      // Assert
      expect(identical(meter1, meter2), isTrue);
    });

    test('creates separate meters with different names', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter-1');
      final meter2 = meterProvider.getMeter(name: 'test-meter-2');

      // Assert
      expect(identical(meter1, meter2), isFalse);
    });

    test('creates separate meters with different versions', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter', version: '1.0.0');
      final meter2 = meterProvider.getMeter(name: 'test-meter', version: '2.0.0');

      // Assert
      expect(identical(meter1, meter2), isFalse);
    });

    test('creates separate meters with different schema URLs', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter', schemaUrl: 'https://example.com/schema1');
      final meter2 = meterProvider.getMeter(name: 'test-meter', schemaUrl: 'https://example.com/schema2');

      // Assert
      expect(identical(meter1, meter2), isFalse);
    });

    test('creates separate meters with different attributes', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter', attributes: OTelAPI.attributesFromMap({'key1': 'value1'}));
      final meter2 = meterProvider.getMeter(name: 'test-meter', attributes: OTelAPI.attributesFromMap({'key2': 'value2'}));

      // Assert
      expect(identical(meter1, meter2), isFalse);
    });

    test('shutdown disables the provider', () async {
      // Arrange & Act
      final result = await meterProvider.shutdown();

      // Assert
      expect(result, isTrue);
      expect(meterProvider.isShutdown, isTrue);
      expect(meterProvider.enabled, isFalse);

      // Should throw when trying to get a meter after shutdown
      expect(() => meterProvider.getMeter(name: 'test-meter'), throwsStateError);
    });

    test('forceFlush returns true', () async {
      // Act
      final result = await meterProvider.forceFlush();

      // Assert
      expect(result, isTrue);
    });

    test('forceFlush returns false after shutdown', () async {
      // Arrange
      await meterProvider.shutdown();

      // Act
      final result = await meterProvider.forceFlush();

      // Assert
      expect(result, isFalse);
    });

    test('second shutdown attempt still returns true', () async {
      // Arrange
      await meterProvider.shutdown();

      // Act
      final result = await meterProvider.shutdown();

      // Assert
      expect(result, isTrue);
    });

    test('getters and setters work correctly', () {
      // Test endpoint getter/setter
      expect(meterProvider.endpoint, equals('http://localhost:4317'));
      meterProvider.endpoint = 'http://localhost:4318';
      expect(meterProvider.endpoint, equals('http://localhost:4318'));

      // Test serviceName getter/setter
      expect(meterProvider.serviceName, equals('test-service'));
      meterProvider.serviceName = 'new-service';
      expect(meterProvider.serviceName, equals('new-service'));

      // Test serviceVersion getter/setter
      expect(meterProvider.serviceVersion, equals('1.0.0'));
      meterProvider.serviceVersion = '2.0.0';
      expect(meterProvider.serviceVersion, equals('2.0.0'));

      // Test enabled getter/setter
      expect(meterProvider.enabled, isTrue);
      meterProvider.enabled = false;
      expect(meterProvider.enabled, isFalse);

      // Test isShutdown getter/setter
      expect(meterProvider.isShutdown, isFalse);
      meterProvider.isShutdown = true;
      expect(meterProvider.isShutdown, isTrue);
    });

    // Test meter caching behavior indirectly
    test('multiple meters with identical parameters return the same instance', () {
      final attrs1 = OTelAPI.attributesFromMap({'key': 'value'});
      final attrs2 = OTelAPI.attributesFromMap({'key': 'value'});

      final meter1 = meterProvider.getMeter(
        name: 'same-meter',
        version: '1.0',
        schemaUrl: 'https://example.com',
        attributes: attrs1
      );

      final meter2 = meterProvider.getMeter(
        name: 'same-meter',
        version: '1.0',
        schemaUrl: 'https://example.com',
        attributes: attrs2
      );

      // Identical attributes with the same content should result in the same meter
      expect(identical(meter1, meter2), isTrue);
    });
  });
}
