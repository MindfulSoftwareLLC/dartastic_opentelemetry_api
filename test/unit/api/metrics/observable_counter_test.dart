// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIObservableCounter', () {
    late APIMeter meter;
    late APIObservableCounter<int> observableCounter;

    void observableCallback(APIObservableResult result) {
      result.observe(42, {'key1': 'value1', 'key2': 123}.toAttributes());
    }

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      
      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      observableCounter = meter.createObservableCounter<int>(
        name: 'test-observable-counter',
        unit: 'requests',
        description: 'A test observable counter',
        callback: observableCallback,
      );
    });

    test('has correct properties', () {
      // Assert
      expect(observableCounter.name, equals('test-observable-counter'));
      expect(observableCounter.unit, equals('requests'));
      expect(observableCounter.description, equals('A test observable counter'));
      expect(observableCounter.meter, equals(meter));
      expect(observableCounter.enabled, isFalse); // API implementation is disabled by default
    });

    test('creates observable counter without callback', () {
      // Act
      final counter = meter.createObservableCounter<int>(
        name: 'no-callback-counter',
      );

      // Assert
      expect(counter, isNotNull);
      expect(counter.name, equals('no-callback-counter'));
    });

    test('observable counter allows callback to be registered later', () {
      // Arrange
      final counter = meter.createObservableCounter<int>(name: 'late-callback-counter');

      // Act
      counter.addCallback(observableCallback);

      // Assert
      // Just verifying it doesn't throw; API doesn't actually call the callback
    });

    test('observable counter allows callback to be changed', () {
      // Arrange
      void newCallback(APIObservableResult result) {
        result.observe(100);
      }

      // Act
      observableCounter.addCallback(newCallback);

      // Assert
      // Just verifying it doesn't throw; API doesn't actually call the callback
    });

    test('observable counter allows callback to be registered and unregistered', () {
      // Arrange
      final counter = meter.createObservableCounter<int>(name: 'callback-counter');

      // Act
      final registration = counter.addCallback(observableCallback);

      // Assert - verify unregistration doesn't throw
      registration.unregister();
    });

    test('generic type constraint is respected', () {
      // Arrange
      final intCounter = meter.createObservableCounter<int>(name: 'int-observable-counter');
      final doubleCounter = meter.createObservableCounter<double>(name: 'double-observable-counter');

      // Act & Assert - Just verify these don't throw
      intCounter.addCallback((result) => result.observe(42));
      doubleCounter.addCallback((result) => result.observe(42.5));
    });
  });
}
