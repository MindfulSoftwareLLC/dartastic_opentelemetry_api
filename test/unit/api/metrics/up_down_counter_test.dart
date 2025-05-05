// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIUpDownCounter', () {
    late APIMeter meter;
    late APIUpDownCounter<int> upDownCounter;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      
      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      upDownCounter = meter.createUpDownCounter<int>(
        name: 'test-up-down-counter',
        unit: 'bytes',
        description: 'A test up-down counter',
      );
    });

    test('has correct properties', () {
      // Assert
      expect(upDownCounter.name, equals('test-up-down-counter'));
      expect(upDownCounter.unit, equals('bytes'));
      expect(upDownCounter.description, equals('A test up-down counter'));
      expect(upDownCounter.meter, equals(meter));
      expect(upDownCounter.enabled, isFalse); // API implementation is disabled by default
      expect(upDownCounter.isCounter, isFalse);
      expect(upDownCounter.isUpDownCounter, isTrue);
      expect(upDownCounter.isGauge, isFalse);
      expect(upDownCounter.isHistogram, isFalse);
    });

    test('accepts valid add value including negatives', () {
      // Act & Assert - No exception should be thrown
      upDownCounter.add(42);
      upDownCounter.add(0);
      upDownCounter.add(-10);
    });

    test('accepts add with attributes', () {
      // Act & Assert - No exception should be thrown
      final attributes = {'key1': 'value1', 'key2': 123}.toAttributes();
      upDownCounter.add(42, attributes);
      upDownCounter.add(-10, attributes);
    });

    test('addWithMap works correctly', () {
      // Arrange
      final attributeMap = {'key1': 'value1', 'key2': 123};

      // Act & Assert - No exception should be thrown
      upDownCounter.addWithMap(42, attributeMap);
      upDownCounter.addWithMap(-10, attributeMap);
    });

    test('addWithMap with empty map is equivalent to add with null attributes', () {
      // Act & Assert - No exception should be thrown
      upDownCounter.addWithMap(42, {});
      upDownCounter.addWithMap(-10, {});
    });

    test('generic type constraint is respected', () {
      // Arrange
      final intUpDownCounter = meter.createUpDownCounter<int>(name: 'int-up-down-counter');
      final doubleUpDownCounter = meter.createUpDownCounter<double>(name: 'double-up-down-counter');

      // Act & Assert
      intUpDownCounter.add(42);
      intUpDownCounter.add(-10);
      doubleUpDownCounter.add(42.5);
      doubleUpDownCounter.add(-10.5);

      // Both should work without exceptions
    });

    test('up-down counter works with different numeric types', () {
      // Act & Assert
      final intUpDownCounter = meter.createUpDownCounter<int>(name: 'int-up-down-counter');
      final doubleUpDownCounter = meter.createUpDownCounter<double>(name: 'double-up-down-counter');

      // These should work without exceptions
      intUpDownCounter.add(42);
      intUpDownCounter.add(-10);
      doubleUpDownCounter.add(42.5);
      doubleUpDownCounter.add(-10.5);
    });
  });
}
