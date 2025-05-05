// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:dartastic_opentelemetry_api/src/api/metrics/metric_point.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('MetricPoint', () {
    test('creates metric point with timestamp, value, and attributes', () {
      // Arrange
      final timestamp = DateTime.now();
      const value = 42.5;
      final attributes = {'key1': 'value1', 'key2': 123}.toAttributes();

      // Act
      final metricPoint = MetricPoint(
        timestamp: timestamp,
        value: value,
        attributes: attributes,
      );

      // Assert
      expect(metricPoint.timestamp, equals(timestamp));
      expect(metricPoint.value, equals(value));
      expect(metricPoint.attributes, equals(attributes));
    });

    test('creates metric point with integer value', () {
      // Arrange
      final timestamp = DateTime.now();
      const value = 42;
      final attributes = {'key1': 'value1'}.toAttributes();

      // Act
      final metricPoint = MetricPoint(
        timestamp: timestamp,
        value: value,
        attributes: attributes,
      );

      // Assert
      expect(metricPoint.timestamp, equals(timestamp));
      expect(metricPoint.value, equals(value));
      expect(metricPoint.attributes, equals(attributes));
    });

    test('creates metric point with empty attributes', () {
      // Arrange
      final timestamp = DateTime.now();
      const value = 42.5;
      final emptyAttributes = OTelAPI.attributes(); // Empty attributes

      // Act
      final metricPoint = MetricPoint(
        timestamp: timestamp,
        value: value,
        attributes: emptyAttributes,
      );

      // Assert
      expect(metricPoint.timestamp, equals(timestamp));
      expect(metricPoint.value, equals(value));
      expect(metricPoint.attributes, equals(emptyAttributes));
      expect(metricPoint.attributes.length, equals(0));
    });
  });
}
