// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIObservableGauge', () {
    late APIMeter meter;
    late APIObservableGauge<double> observableGauge;

    void observableCallback(APIObservableResult result) {
      result.observe(42.5, {'key1': 'value1', 'key2': 123}.toAttributes());
      result.observe(-10.5, {'key1': 'value1', 'key2': 123}.toAttributes());
    }

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      observableGauge = meter.createObservableGauge<double>(
        name: 'test-observable-gauge',
        unit: 'celsius',
        description: 'A test observable gauge',
        callback: observableCallback,
      );
    });

    test('has correct properties', () {
      // Assert
      expect(observableGauge.name, equals('test-observable-gauge'));
      expect(observableGauge.unit, equals('celsius'));
      expect(observableGauge.description, equals('A test observable gauge'));
      expect(observableGauge.meter, equals(meter));
      expect(observableGauge.enabled,
          isFalse); // API implementation is disabled by default
    });

    test('creates observable gauge without callback', () {
      // Act
      final gauge = meter.createObservableGauge<double>(
        name: 'no-callback-gauge',
      );

      // Assert
      expect(gauge, isNotNull);
      expect(gauge.name, equals('no-callback-gauge'));
    });

    test('observable gauge allows callback to be registered later', () {
      // Arrange
      final gauge =
          meter.createObservableGauge<double>(name: 'late-callback-gauge');

      // Act
      gauge.addCallback(observableCallback);

      // Assert
      // Just verifying it doesn't throw; API doesn't actually call the callback
    });

    test('observable gauge allows callback to be changed', () {
      // Arrange
      void newCallback(APIObservableResult result) {
        result.observe(100.0);
        result.observe(-50.0);
      }

      // Act
      observableGauge.addCallback(newCallback);

      // Assert
      // Just verifying it doesn't throw; API doesn't actually call the callback
    });

    test('observable gauge allows callback to be registered and unregistered',
        () {
      // Arrange
      final gauge = meter.createObservableGauge<double>(name: 'callback-gauge');

      // Act
      final registration = gauge.addCallback(observableCallback);

      // Assert - verify unregistration doesn't throw
      registration.unregister();
    });

    test('generic type constraint is respected', () {
      // Arrange
      final intGauge =
          meter.createObservableGauge<int>(name: 'int-observable-gauge');
      final doubleGauge =
          meter.createObservableGauge<double>(name: 'double-observable-gauge');

      // Act & Assert - Just verify these don't throw
      intGauge.addCallback((result) {
        result.observe(42);
        result.observe(-10);
      });

      doubleGauge.addCallback((result) {
        result.observe(42.5);
        result.observe(-10.5);
      });
    });
  });
}
