// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIObservableUpDownCounter', () {
    late APIMeter meter;
    late APIObservableUpDownCounter<int> observableUpDownCounter;

    void observableCallback(APIObservableResult result) {
      result.observe(42, {'key1': 'value1', 'key2': 123}.toAttributes());
      result.observe(-10, {'key1': 'value1', 'key2': 123}.toAttributes());
    }

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      observableUpDownCounter = meter.createObservableUpDownCounter<int>(
        name: 'test-observable-up-down-counter',
        unit: 'connections',
        description: 'A test observable up-down counter',
        callback: observableCallback,
      );
    });

    test('has correct properties', () {
      // Assert
      expect(observableUpDownCounter.name,
          equals('test-observable-up-down-counter'));
      expect(observableUpDownCounter.unit, equals('connections'));
      expect(observableUpDownCounter.description,
          equals('A test observable up-down counter'));
      expect(observableUpDownCounter.meter, equals(meter));
      expect(observableUpDownCounter.enabled,
          isFalse); // API implementation is disabled by default
    });

    test('creates observable up-down counter without callback', () {
      // Act
      final upDownCounter = meter.createObservableUpDownCounter<int>(
        name: 'no-callback-up-down-counter',
      );

      // Assert
      expect(upDownCounter, isNotNull);
      expect(upDownCounter.name, equals('no-callback-up-down-counter'));
    });

    test('observable up-down counter allows callback to be registered later',
        () {
      // Arrange
      final upDownCounter = meter.createObservableUpDownCounter<int>(
          name: 'late-callback-up-down-counter');

      // Act
      upDownCounter.addCallback(observableCallback);

      // Assert
      // Just verifying it doesn't throw; API doesn't actually call the callback
    });

    test('observable up-down counter allows callback to be changed', () {
      // Arrange
      void newCallback(APIObservableResult result) {
        result.observe(100);
        result.observe(-50);
      }

      // Act
      observableUpDownCounter.addCallback(newCallback);

      // Assert
      // Just verifying it doesn't throw; API doesn't actually call the callback
    });

    test(
        'observable up-down counter allows callback to be registered and unregistered',
        () {
      // Arrange
      final upDownCounter = meter.createObservableUpDownCounter<int>(
          name: 'callback-up-down-counter');

      // Act
      final registration = upDownCounter.addCallback(observableCallback);

      // Assert - verify unregistration doesn't throw
      registration.unregister();
    });

    test('generic type constraint is respected', () {
      // Arrange
      final intUpDownCounter = meter.createObservableUpDownCounter<int>(
          name: 'int-observable-up-down-counter');
      final doubleUpDownCounter = meter.createObservableUpDownCounter<double>(
          name: 'double-observable-up-down-counter');

      // Act & Assert - Just verify these don't throw
      intUpDownCounter.addCallback((result) {
        result.observe(42);
        result.observe(-10);
      });

      doubleUpDownCounter.addCallback((result) {
        result.observe(42.5);
        result.observe(-10.5);
      });
    });
  });
}
