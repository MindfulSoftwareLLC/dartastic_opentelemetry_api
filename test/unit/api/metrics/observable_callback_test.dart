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

  group('ObservableCallback', () {
    test('callback is properly typed and can be called', () {
      // Arrange
      bool callbackInvoked = false;
      void callback(APIObservableResult<int> result) {
        callbackInvoked = true;
        result.observe(42);
      }

      final result = TestObservableResult<int>();

      // Act
      callback(result);

      // Assert
      expect(callbackInvoked, isTrue);
      expect(result.measurements, hasLength(1));
      expect(result.measurements.first.value, equals(42));
    });

    test('callback with generic double type works correctly', () {
      // Arrange
      void callback(APIObservableResult<double> result) {
        result.observe(42.5);
      }

      final result = TestObservableResult<double>();

      // Act
      callback(result);

      // Assert
      expect(result.measurements, hasLength(1));
      expect(result.measurements.first.value, equals(42.5));
    });

    test('callback can be passed as parameter to instruments', () {
      // Arrange
      // Use num as the generic type to be compatible with instrument callbacks
      void callback(APIObservableResult<num> result) {
        result.observe(42);
      }

      final meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');

      // Act - create instruments with the callback
      final counter = meter.createObservableCounter<int>(
          name: 'test-counter', callback: callback);

      final upDownCounter = meter.createObservableUpDownCounter<int>(
          name: 'test-up-down-counter', callback: callback);

      final gauge = meter.createObservableGauge<int>(
          name: 'test-gauge', callback: callback);

      // Assert - just verify these operations don't throw
      expect(counter, isNotNull);
      expect(upDownCounter, isNotNull);
      expect(gauge, isNotNull);
    });

    test('callback registration returns an APICallbackRegistration', () {
      // Arrange
      // Use num as the generic type
      void callback(APIObservableResult<num> result) {
        result.observe(42);
      }

      final meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      final counter = meter.createObservableCounter<int>(name: 'test-counter');

      // Act
      final registration = counter.addCallback(callback);

      // Assert
      expect(registration, isNotNull);
      expect(registration, isA<APICallbackRegistration>());

      // Act & Assert - unregister should not throw
      registration.unregister();
    });
  });
}

/// Test implementation of ObservableResult for testing purposes
class TestObservableResult<T extends num> implements APIObservableResult<T> {
  final List<Measurement<T>> _measurements = [];

  @override
  List<Measurement<T>> get measurements => List.unmodifiable(_measurements);

  @override
  void observe(T value, [Attributes? attributes]) {
    // Add the measurement to our list
    _measurements.add(OTelAPI.createMeasurement<T>(value, attributes));
  }

  @override
  void observeWithMap(T value, Map<String, Object> attributeMap) {
    final attributes =
        attributeMap.isEmpty ? null : attributeMap.toAttributes();
    observe(value, attributes);
  }
}
