// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

import 'observable_callback_test.dart';

void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize();
  });

  group('APIObservableResult', () {
    test('observe adds measurement to the list', () {
      // Arrange
      final result = TestObservableResult<double>();

      // Act
      result.observe(42.0);

      // Assert
      expect(result.measurements.length, equals(1));
      expect(result.measurements[0].value, equals(42.0));
      expect(result.measurements[0].attributes, isNull);
    });

    test('observe with attributes adds measurement to the list', () {
      // Arrange
      final result = TestObservableResult<int>();
      final attributes = OTelAPI.attributesFromMap({'key': 'value'});

      // Act
      result.observe(100, attributes);

      // Assert
      expect(result.measurements.length, equals(1));
      expect(result.measurements[0].value, equals(100));
      expect(result.measurements[0].attributes, equals(attributes));
    });

    test('observeWithMap converts map to attributes', () {
      // Arrange
      final result = TestObservableResult<double>();
      final map = <String, Object>{'key1': 'value1', 'key2': 42};

      // Act
      result.observeWithMap(99.9, map);

      // Assert
      expect(result.measurements.length, equals(1));
      expect(result.measurements[0].value, equals(99.9));
      expect(result.measurements[0].attributes, isNotNull);
      expect(result.measurements[0].attributes!.getString('key1'), equals('value1'));
      expect(result.measurements[0].attributes!.getInt('key2'), equals(42));
    });

    test('measurements returns unmodifiable list', () {
      // Arrange
      final result = TestObservableResult<int>();

      // Act
      result.observe(1);
      result.observe(2);
      final measurements = result.measurements;

      // Assert
      expect(measurements.length, equals(2));
      expect(() => measurements.add(OTelFactory.otelFactory!.createMeasurement(3, null)),
          throwsUnsupportedError);
    });

    test('measurements returns empty list when no observations', () {
      // Arrange
      final result = TestObservableResult<double>();

      // Assert
      expect(result.measurements, isEmpty);
    });

    test('multiple observations are recorded correctly', () {
      // Arrange
      final result = TestObservableResult<int>();

      // Act
      result.observe(1);
      result.observe(2, OTelAPI.attributesFromMap({'test': true}));
      result.observeWithMap(3, {'name': 'counter'});

      // Assert
      expect(result.measurements.length, equals(3));
      expect(result.measurements[0].value, equals(1));
      expect(result.measurements[1].value, equals(2));
      expect(result.measurements[2].value, equals(3));

      expect(result.measurements[0].attributes, isNull);
      expect(result.measurements[1].attributes!.getBool('test'), isTrue);
      expect(result.measurements[2].attributes!.getString('name'), equals('counter'));
    });
  });
}
