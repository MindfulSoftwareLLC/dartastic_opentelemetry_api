// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

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
      expect(meter.version, isNull);
      expect(meter.isEnabled(), isFalse);
      expect(meter.schemaUrl, isNull);
    });

    test('creates counter with valid name', () {
      // Act
      final counter = meter.createCounter<int>(name: 'test-counter');

      // Assert
      expect(counter, isNotNull);
      expect(counter.name, equals('test-counter'));
      expect(counter.isEnabled(),
          isFalse); // API implementation is disabled by default
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
      final upDownCounter =
          meter.createUpDownCounter<int>(name: 'test-up-down-counter');

      // Assert
      expect(upDownCounter, isNotNull);
      expect(upDownCounter.name, equals('test-up-down-counter'));
      expect(upDownCounter.isEnabled(),
          isFalse); // API implementation is disabled by default
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
      expect(histogram.isEnabled(),
          isFalse); // API implementation is disabled by default
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
      expect(gauge.isEnabled(),
          isFalse); // API implementation is disabled by default
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
      final observableCounter =
          meter.createObservableCounter<int>(name: 'test-observable-counter');

      // Assert
      expect(observableCounter, isNotNull);
      expect(observableCounter.name, equals('test-observable-counter'));
      expect(observableCounter.isEnabled(),
          isFalse); // API implementation is disabled by default
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
      expect(observableUpDownCounter.name,
          equals('test-observable-up-down-counter'));
      expect(observableUpDownCounter.isEnabled(),
          isFalse); // API implementation is disabled by default
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
      final observableGauge =
          meter.createObservableGauge<double>(name: 'test-observable-gauge');

      // Assert
      expect(observableGauge, isNotNull);
      expect(observableGauge.name, equals('test-observable-gauge'));
      expect(observableGauge.isEnabled(),
          isFalse); // API implementation is disabled by default
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
      // Without cache, they are different instances, but == is overridden based on properties
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

    test('observable counter double-removal works safely', () {
      final observableCounter =
          meter.createObservableCounter<int>(name: 'test-double-remove');

      void myCallback(APIObservableResult<int> result) {}

      final handle = observableCounter.addCallback(myCallback);
      expect(observableCounter.callbacks.length, equals(1));

      // Remove via direct path
      observableCounter.removeCallback(myCallback);
      expect(observableCounter.callbacks.length, equals(0));

      // Remove via handle path should not throw
      expect(handle.unregister, returnsNormally);
      expect(observableCounter.callbacks.length, equals(0));

      // And reverse order
      final handle2 = observableCounter.addCallback(myCallback);
      expect(observableCounter.callbacks.length, equals(1));

      handle2.unregister();
      expect(observableCounter.callbacks.length, equals(0));

      expect(
          () => observableCounter.removeCallback(myCallback), returnsNormally);
      expect(observableCounter.callbacks.length, equals(0));
    });

    test('registerBatchCallback surface', () {
      final handle = meter.registerBatchCallback(
        (result) {},
        {
          meter.createObservableCounter<int>(name: 'c'),
          meter.createObservableUpDownCounter<int>(name: 'uc'),
          meter.createObservableGauge<double>(name: 'g'),
        },
      );
      expect(handle, isNotNull);
      expect(handle.unregister, returnsNormally);

      // Invalid instrument type
      expect(
        () => meter.registerBatchCallback(
          (result) {},
          {meter.createCounter<int>(name: 'sync-counter')},
        ),
        throwsArgumentError,
      );

      // Instrument from different meter
      final otherMeter = OTelAPI.meterProvider().getMeter(name: 'other');
      expect(
        () => meter.registerBatchCallback(
          (result) {},
          {otherMeter.createObservableCounter<int>(name: 'other-c')},
        ),
        throwsArgumentError,
      );
    });

    test('create methods accept InstrumentAdvisory', () {
      const advisory =
          InstrumentAdvisory(explicitBucketBoundaries: [1.0, 2.0, 3.0]);

      final c = meter.createCounter<int>(name: 'c', advisory: advisory);
      expect(c.advisory, equals(advisory));

      final uc = meter.createUpDownCounter<int>(name: 'uc', advisory: advisory);
      expect(uc.advisory, equals(advisory));

      final h = meter.createHistogram<double>(name: 'h', advisory: advisory);
      expect(h.boundaries, equals([1.0, 2.0, 3.0]));
      expect(h.advisory, equals(advisory));

      // precedence check: explicit boundaries parameter takes precedence over advisory
      final h2 = meter.createHistogram<double>(
          name: 'h2', boundaries: [4.0, 5.0], advisory: advisory);
      expect(h2.boundaries, equals([4.0, 5.0]));

      final g = meter.createGauge<double>(name: 'g', advisory: advisory);
      expect(g.advisory, equals(advisory));

      final oc =
          meter.createObservableCounter<int>(name: 'oc', advisory: advisory);
      expect(oc.advisory, equals(advisory));

      final ouc = meter.createObservableUpDownCounter<int>(
          name: 'ouc', advisory: advisory);
      expect(ouc.advisory, equals(advisory));

      final og =
          meter.createObservableGauge<double>(name: 'og', advisory: advisory);
      expect(og.advisory, equals(advisory));
    });
  });
}
