// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIMeter', () {
    late APIMeter meter;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      
      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
    });

    test('has correct properties', () {
      // Assert
      expect(meter.name, equals('test-meter'));
      expect(meter.version, isNotNull);
      expect(meter.schemaUrl, isNotNull);
    });

    test('creates counter with valid name', () {
      // Act
      final counter = meter.createCounter<int>(name: 'test-counter');

      // Assert
      expect(counter, isNotNull);
      expect(counter.name, equals('test-counter'));
      expect(counter.enabled, isFalse); // API implementation is disabled by default
      expect(counter.isCounter, isTrue);
      expect(counter.isUpDownCounter, isFalse);
      expect(counter.isGauge, isFalse);
      expect(counter.isHistogram, isFalse);
    });

    test('throws when creating counter with empty name', () {
      // Assert
      expect(
        () => meter.createCounter<int>(name: ''),
        throwsArgumentError,
      );
    });

    test('creates up-down counter with valid name', () {
      // Act
      final upDownCounter = meter.createUpDownCounter<int>(name: 'test-up-down-counter');

      // Assert
      expect(upDownCounter, isNotNull);
      expect(upDownCounter.name, equals('test-up-down-counter'));
      expect(upDownCounter.enabled, isFalse); // API implementation is disabled by default
      expect(upDownCounter.isCounter, isFalse);
      expect(upDownCounter.isUpDownCounter, isTrue);
      expect(upDownCounter.isGauge, isFalse);
      expect(upDownCounter.isHistogram, isFalse);
    });

    test('throws when creating up-down counter with empty name', () {
      // Assert
      expect(
        () => meter.createUpDownCounter<int>(name: ''),
        throwsArgumentError,
      );
    });

    test('creates histogram with valid name', () {
      // Act
      final histogram = meter.createHistogram<double>(name: 'test-histogram');

      // Assert
      expect(histogram, isNotNull);
      expect(histogram.name, equals('test-histogram'));
      expect(histogram.enabled, isFalse); // API implementation is disabled by default
      expect(histogram.isCounter, isFalse);
      expect(histogram.isUpDownCounter, isFalse);
      expect(histogram.isGauge, isFalse);
      expect(histogram.isHistogram, isTrue);
    });

    test('throws when creating histogram with empty name', () {
      // Assert
      expect(
        () => meter.createHistogram<double>(name: ''),
        throwsArgumentError,
      );
    });

    test('creates gauge with valid name', () {
      // Act
      final gauge = meter.createGauge<double>(name: 'test-gauge');

      // Assert
      expect(gauge, isNotNull);
      expect(gauge.name, equals('test-gauge'));
      expect(gauge.enabled, isFalse); // API implementation is disabled by default
      expect(gauge.isCounter, isFalse);
      expect(gauge.isUpDownCounter, isFalse);
      expect(gauge.isGauge, isTrue);
      expect(gauge.isHistogram, isFalse);
    });

    test('throws when creating gauge with empty name', () {
      // Assert
      expect(
        () => meter.createGauge<double>(name: ''),
        throwsArgumentError,
      );
    });

    test('creates observable counter with valid name', () {
      // Act
      final observableCounter = meter.createObservableCounter<int>(name: 'test-observable-counter');

      // Assert
      expect(observableCounter, isNotNull);
      expect(observableCounter.name, equals('test-observable-counter'));
      expect(observableCounter.enabled, isFalse); // API implementation is disabled by default
    });

    test('throws when creating observable counter with empty name', () {
      // Assert
      expect(
        () => meter.createObservableCounter<int>(name: ''),
        throwsArgumentError,
      );
    });

    test('creates observable up-down counter with valid name', () {
      // Act
      final observableUpDownCounter = meter.createObservableUpDownCounter<int>(
        name: 'test-observable-up-down-counter',
      );

      // Assert
      expect(observableUpDownCounter, isNotNull);
      expect(observableUpDownCounter.name, equals('test-observable-up-down-counter'));
      expect(observableUpDownCounter.enabled, isFalse); // API implementation is disabled by default
    });

    test('throws when creating observable up-down counter with empty name', () {
      // Assert
      expect(
        () => meter.createObservableUpDownCounter<int>(name: ''),
        throwsArgumentError,
      );
    });

    test('creates observable gauge with valid name', () {
      // Act
      final observableGauge = meter.createObservableGauge<double>(name: 'test-observable-gauge');

      // Assert
      expect(observableGauge, isNotNull);
      expect(observableGauge.name, equals('test-observable-gauge'));
      expect(observableGauge.enabled, isFalse); // API implementation is disabled by default
    });

    test('throws when creating observable gauge with empty name', () {
      // Assert
      expect(
        () => meter.createObservableGauge<double>(name: ''),
        throwsArgumentError,
      );
    });

    test('equals works correctly', () {
      // Arrange
      final meter1 = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      final meter2 = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      final meter3 = OTelAPI.meterProvider().getMeter(name: 'other-meter');

      // Assert
      expect(meter1 == meter2, isTrue);
      expect(meter1 == meter3, isFalse);
    });

    test('hashCode works correctly', () {
      // Arrange
      final meter1 = OTelAPI.meterProvider().getMeter(name: 'test-meter');
      final meter2 = OTelAPI.meterProvider().getMeter(name: 'test-meter');

      // Assert
      expect(meter1.hashCode == meter2.hashCode, isTrue);
    });
  });
}
