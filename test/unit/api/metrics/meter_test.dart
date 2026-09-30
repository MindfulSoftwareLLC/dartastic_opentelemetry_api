// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  _batchCallbackTests();
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

    test('accepts an empty counter name without throwing or reporting', () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final instrument = meter.createCounter<int>(name: '');

      expect(instrument, isNotNull);
      expect(reported, isEmpty, reason: 'the no-op meter must not report');
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

    test('accepts an empty up-down counter name without throwing or reporting',
        () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final instrument = meter.createUpDownCounter<int>(name: '');

      expect(instrument, isNotNull);
      expect(reported, isEmpty, reason: 'the no-op meter must not report');
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

    test('accepts an empty histogram name without throwing or reporting', () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final instrument = meter.createHistogram<double>(name: '');

      expect(instrument, isNotNull);
      expect(reported, isEmpty, reason: 'the no-op meter must not report');
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

    test('accepts an empty gauge name without throwing or reporting', () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final instrument = meter.createGauge<double>(name: '');

      expect(instrument, isNotNull);
      expect(reported, isEmpty, reason: 'the no-op meter must not report');
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

    test(
        'accepts an empty observable counter name without throwing or reporting',
        () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final instrument = meter.createObservableCounter<int>(name: '');

      expect(instrument, isNotNull);
      expect(reported, isEmpty, reason: 'the no-op meter must not report');
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

    test(
        'accepts an empty observable up-down counter name without throwing or reporting',
        () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final instrument = meter.createObservableUpDownCounter<int>(name: '');

      expect(instrument, isNotNull);
      expect(reported, isEmpty, reason: 'the no-op meter must not report');
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

    test('accepts an empty observable gauge name without throwing or reporting',
        () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final instrument = meter.createObservableGauge<double>(name: '');

      expect(instrument, isNotNull);
      expect(reported, isEmpty, reason: 'the no-op meter must not report');
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

      // A synchronous instrument is a compile-time error now that the set
      // is typed APIObservableInstrument; a foreign meter is covered in the
      // registerBatchCallback group below.
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

void _batchCallbackTests() {
  group('registerBatchCallback', () {
    setUp(() => OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'x',
        serviceVersion: '1'));

    test('an instrument from a different meter is reported, not thrown', () {
      final a = OTelAPI.meterProvider().getMeter(name: 'a');
      final b = OTelAPI.meterProvider().getMeter(name: 'b');
      final foreign = b.createObservableCounter<int>(name: 'c');
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final reg = a.registerBatchCallback((_) {}, {foreign});

      expect(reported, hasLength(1));
      expect(reported.single, isA<ArgumentError>());
      expect(reg, isNotNull);
      expect(reg.unregister, returnsNormally);
    });

    test('instruments from the same meter register without a report', () {
      final a = OTelAPI.meterProvider().getMeter(name: 'a');
      final own = a.createObservableGauge<double>(name: 'g');
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      a.registerBatchCallback((_) {}, {own});

      expect(reported, isEmpty);
    });
  });
}
