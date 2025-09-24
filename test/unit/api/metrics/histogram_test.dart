// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIHistogram', () {
    late APIMeter meter;
    late APIHistogram<double> histogram;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      histogram = meter.createHistogram<double>(
        name: 'test-histogram',
        unit: 'ms',
        description: 'A test histogram',
        boundaries: [
          0.0,
          5.0,
          10.0,
          25.0,
          50.0,
          75.0,
          100.0,
          250.0,
          500.0,
          750.0,
          1000.0
        ],
      );
    });

    test('has correct properties', () {
      // Assert
      expect(histogram.name, equals('test-histogram'));
      expect(histogram.unit, equals('ms'));
      expect(histogram.description, equals('A test histogram'));
      expect(histogram.meter, equals(meter));
      expect(histogram.enabled,
          isFalse); // API implementation is disabled by default
      expect(histogram.isCounter, isFalse);
      expect(histogram.isUpDownCounter, isFalse);
      expect(histogram.isGauge, isFalse);
      expect(histogram.isHistogram, isTrue);
    });

    test('accepts valid record value', () {
      // Act & Assert - No exception should be thrown
      histogram.record(42.5);
      histogram.record(0);
    });

    test('accepts record with attributes', () {
      // Act & Assert - No exception should be thrown
      final attributes = {'key1': 'value1', 'key2': 123}.toAttributes();
      histogram.record(42.5, attributes);
    });

    test('recordWithMap works correctly', () {
      // Arrange
      final attributeMap = {'key1': 'value1', 'key2': 123};

      // Act & Assert - No exception should be thrown
      histogram.recordWithMap(42.5, attributeMap);
    });

    test(
        'recordWithMap with empty map is equivalent to record with null attributes',
        () {
      // Act & Assert - No exception should be thrown
      histogram.recordWithMap(42.5, {});
    });

    test('generic type constraint is respected', () {
      // Arrange
      final intHistogram = meter.createHistogram<int>(name: 'int-histogram');
      final doubleHistogram =
          meter.createHistogram<double>(name: 'double-histogram');

      // Act & Assert
      intHistogram.record(42);
      doubleHistogram.record(42.5);

      // Both should work without exceptions
    });

    test('histogram works with different numeric types', () {
      // Act & Assert
      final intHistogram = meter.createHistogram<int>(name: 'int-histogram');
      final doubleHistogram =
          meter.createHistogram<double>(name: 'double-histogram');

      // These should work without exceptions
      intHistogram.record(42);
      doubleHistogram.record(42.5);
    });

    test('histogram is created with custom boundaries', () {
      // Arrange
      final customBoundaries = [0.0, 10.0, 100.0, 1000.0];

      // Act
      final customHistogram = meter.createHistogram<double>(
          name: 'custom-boundary-histogram', boundaries: customBoundaries);

      // Assert (no real way to verify boundaries are used in the API implementation)
      // Just verify it doesn't throw
      customHistogram.record(50.0);
    });

    test('histogram is created with no boundaries specified', () {
      // Act
      final defaultHistogram =
          meter.createHistogram<double>(name: 'default-boundary-histogram');

      // Assert (just verify it doesn't throw)
      defaultHistogram.record(50.0);
    });
  });
}
