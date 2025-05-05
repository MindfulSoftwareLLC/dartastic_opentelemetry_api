// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIGauge', () {
    late APIMeter meter;
    late APIGauge<double> gauge;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      
      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      gauge = meter.createGauge<double>(
        name: 'test-gauge',
        unit: 'celsius',
        description: 'A test gauge',
      );
    });

    test('has correct properties', () {
      // Assert
      expect(gauge.name, equals('test-gauge'));
      expect(gauge.unit, equals('celsius'));
      expect(gauge.description, equals('A test gauge'));
      expect(gauge.meter, equals(meter));
      expect(gauge.enabled, isFalse); // API implementation is disabled by default
      expect(gauge.isCounter, isFalse);
      expect(gauge.isUpDownCounter, isFalse);
      expect(gauge.isGauge, isTrue);
      expect(gauge.isHistogram, isFalse);
    });

    test('accepts set value', () {
      // Act & Assert - No exception should be thrown
      gauge.record(42.5);
      gauge.record(0.0);
      gauge.record(-10.5); // Gauges can be negative unlike counters
    });

    test('accepts set with attributes', () {
      // Act & Assert - No exception should be thrown
      final attributes = {'key1': 'value1', 'key2': 123}.toAttributes();
      gauge.record(42.5, attributes);
      gauge.record(-10.5, attributes);
    });

    test('setWithMap works correctly', () {
      // Arrange
      final attributeMap = {'key1': 'value1', 'key2': 123};

      // Act & Assert - No exception should be thrown
      gauge.recordWithMap(42.5, attributeMap);
      gauge.recordWithMap(-10.5, attributeMap);
    });

    test('setWithMap with empty map is equivalent to set with null attributes', () {
      // Act & Assert - No exception should be thrown
      gauge.recordWithMap(42.5, {});
      gauge.recordWithMap(-10.5, {});
    });

    test('generic type constraint is respected', () {
      // Arrange
      final intGauge = meter.createGauge<int>(name: 'int-gauge');
      final doubleGauge = meter.createGauge<double>(name: 'double-gauge');

      // Act & Assert
      intGauge.record(42);
      intGauge.record(-10);
      doubleGauge.record(42.5);
      doubleGauge.record(-10.5);

      // Both should work without exceptions
    });

    test('gauge works with different numeric types', () {
      // Act & Assert
      final intGauge = meter.createGauge<int>(name: 'int-gauge');
      final doubleGauge = meter.createGauge<double>(name: 'double-gauge');

      // These should work without exceptions
      intGauge.record(42);
      intGauge.record(-10);
      doubleGauge.record(42.5);
      doubleGauge.record(-10.5);
    });
  });
}
