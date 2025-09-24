// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APICounter', () {
    late APIMeter meter;
    late APICounter<int> counter;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      counter = meter.createCounter<int>(
        name: 'test-counter',
        unit: 'ms',
        description: 'A test counter',
      );
    });

    test('has correct properties', () {
      // Assert
      expect(counter.name, equals('test-counter'));
      expect(counter.unit, equals('ms'));
      expect(counter.description, equals('A test counter'));
      expect(counter.meter, equals(meter));
      expect(counter.enabled,
          isFalse); // API implementation is disabled by default
      expect(counter.isCounter, isTrue);
      expect(counter.isUpDownCounter, isFalse);
      expect(counter.isGauge, isFalse);
      expect(counter.isHistogram, isFalse);
    });

    test('accepts valid add value including negative values', () {
      // No exception should be thrown
      counter.add(42);
      counter.add(0);
      // API implementation doesn't validate, so this should work too in the API
      counter.add(-1); // This would throw in SDK implementation
    });

    test('accepts add with attributes', () {
      // No exception should be thrown
      final attributes = {'key1': 'value1', 'key2': 123}.toAttributes();
      counter.add(42, attributes);
    });

    test('addWithMap works correctly', () {
      // Arrange
      final attributeMap = {'key1': 'value1', 'key2': 123};

      // Act & Assert - No exception should be thrown
      counter.addWithMap(42, attributeMap);
    });

    test('addWithMap with empty map is equivalent to add with null attributes',
        () {
      // Act & Assert - No exception should be thrown
      counter.addWithMap(42, {});
    });

    test('generic type constraint is respected', () {
      // Arrange
      final intCounter = meter.createCounter<int>(name: 'int-counter');
      final doubleCounter = meter.createCounter<double>(name: 'double-counter');

      // Act & Assert
      intCounter.add(42);
      doubleCounter.add(42.5);

      // Both should work without exceptions
    });

    test('counter works with different numeric types', () {
      // Act & Assert
      final intCounter = meter.createCounter<int>(name: 'int-counter');
      final doubleCounter = meter.createCounter<double>(name: 'double-counter');

      // These should work without exceptions
      intCounter.add(42);
      doubleCounter.add(42.5);
    });
  });
}
