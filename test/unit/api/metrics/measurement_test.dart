// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
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

  group('Measurement', () {
    test('creates int measurement with value', () {
      // Act
      final measurement = OTelAPI.createMeasurement<int>(42);

      // Assert
      expect(measurement.value, equals(42));
      expect(measurement.attributes, isNull);
    });

    test('creates double measurement with value', () {
      // Act
      final measurement = OTelAPI.createMeasurement<double>(42.5);

      // Assert
      expect(measurement.value, equals(42.5));
      expect(measurement.attributes, isNull);
    });

    test('creates measurement with attributes', () {
      // Arrange
      final attributes = {'key1': 'value1', 'key2': 123}.toAttributes();

      // Act
      final measurement = OTelAPI.createMeasurement<int>(42, attributes);

      // Assert
      expect(measurement.value, equals(42));
      expect(measurement.attributes, equals(attributes));
    });

    test('supports equality check', () {
      // Arrange
      final measurement1 = OTelAPI.createMeasurement<int>(42);
      final measurement2 = OTelAPI.createMeasurement<int>(42);
      final measurement3 = OTelAPI.createMeasurement<int>(43);

      // Assert
      expect(measurement1 == measurement2, isTrue);
      expect(measurement1 == measurement3, isFalse);
    });

    test('handles measurements with same value but different attributes as not equal', () {
      // Arrange
      final attributes1 = {'key1': 'value1'}.toAttributes();
      final attributes2 = {'key2': 'value2'}.toAttributes();

      final measurement1 = OTelAPI.createMeasurement<int>(42, attributes1);
      final measurement2 = OTelAPI.createMeasurement<int>(42, attributes2);

      // Assert
      expect(measurement1 == measurement2, isFalse);
    });

    test('hasAttributes returns correct value', () {
      // Arrange
      final attributes = {'key1': 'value1'}.toAttributes();

      final measurement1 = OTelAPI.createMeasurement<int>(42);
      final measurement2 = OTelAPI.createMeasurement<int>(42, attributes);

      // Assert
      expect(measurement1.hasAttributes, isFalse);
      expect(measurement2.hasAttributes, isTrue);
    });

    test('toString includes value and attributes if present', () {
      // Arrange
      final attributes = {'key1': 'value1'}.toAttributes();

      final measurement1 = OTelAPI.createMeasurement<int>(42);
      final measurement2 = OTelAPI.createMeasurement<int>(42, attributes);

      // Assert
      expect(measurement1.toString(), contains('42'));
      expect(measurement2.toString(), contains('42'));
      expect(measurement2.toString(), contains('key1'));
      expect(measurement2.toString(), contains('value1'));
    });

    test('hash code is correctly implemented', () {
      // Arrange
      final attributes = {'key1': 'value1'}.toAttributes();
      final measurement1 = OTelAPI.createMeasurement<int>(42, attributes);
      final measurement2 = OTelAPI.createMeasurement<int>(42, attributes);
      final measurement3 = OTelAPI.createMeasurement<int>(43, attributes);
      final measurement4 = OTelAPI.createMeasurement<int>(42, {'key2': 'value2'}.toAttributes());

      // Assert
      expect(measurement1.hashCode, equals(measurement2.hashCode));
      expect(measurement1.hashCode, isNot(equals(measurement3.hashCode)));
      expect(measurement1.hashCode, isNot(equals(measurement4.hashCode)));
    });

    test('different numeric types work correctly', () {
      // Act
      final intMeasurement = OTelAPI.createMeasurement<int>(42);
      final doubleMeasurement = OTelAPI.createMeasurement<double>(42.5);
      
      // Assert
      expect(intMeasurement.value, isA<int>());
      expect(intMeasurement.value, equals(42));
      
      expect(doubleMeasurement.value, isA<double>());
      expect(doubleMeasurement.value, equals(42.5));
    });
  });
}
