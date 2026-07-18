// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Coverage for the observable-instrument callback surface, the no-op
// histogram record, and meter equality.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Metrics API surface', () {
    late APIMeter meter;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      meter = OTelAPI.meterProvider().getMeter(name: 'coverage-meter');
    });

    void expectCallbackSurface({
      required List<ObservableCallback<double>> Function() callbacks,
      required APICallbackRegistration<double> Function(
              ObservableCallback<double>)
          addCallback,
      required void Function(ObservableCallback<double>) removeCallback,
      required List<Measurement> Function() collect,
      required int initialCallbacks,
    }) {
      void extra(APIObservableResult<double> result) {}

      expect(callbacks().length, equals(initialCallbacks));
      addCallback(extra);
      expect(callbacks(), contains(extra));
      removeCallback(extra);
      expect(callbacks(), isNot(contains(extra)));
      // The API implementation collects nothing; the SDK overrides this.
      expect(collect(), isEmpty);
    }

    test('observable counter callback registration surface', () {
      final counter = meter.createObservableCounter<double>(
        name: 'obs-counter',
        callback: (result) {},
      );
      expectCallbackSurface(
        callbacks: () => counter.callbacks,
        addCallback: counter.addCallback,
        removeCallback: counter.removeCallback,
        collect: counter.collect,
        initialCallbacks: 1,
      );
    });

    test('observable up-down counter callback registration surface', () {
      final counter = meter.createObservableUpDownCounter<double>(
        name: 'obs-updown',
        callback: (result) {},
      );
      expectCallbackSurface(
        callbacks: () => counter.callbacks,
        addCallback: counter.addCallback,
        removeCallback: counter.removeCallback,
        collect: counter.collect,
        initialCallbacks: 1,
      );
    });

    test('observable gauge callback registration surface', () {
      final gauge = meter.createObservableGauge<double>(
        name: 'obs-gauge',
        callback: (result) {},
      );
      expectCallbackSurface(
        callbacks: () => gauge.callbacks,
        addCallback: gauge.addCallback,
        removeCallback: gauge.removeCallback,
        collect: gauge.collect,
        initialCallbacks: 1,
      );
    });

    test('histogram record is a no-op in the API', () {
      final histogram = meter
          .createHistogram<double>(name: 'h', boundaries: [1.0, 5.0, 10.0]);
      histogram.record(0.5);
      histogram.record(1.5, Attributes.of({'k': 'v'}));
      expect(histogram.name, equals('h'));
      expect(histogram.boundaries, equals([1.0, 5.0, 10.0]));
    });

    test('meters with the same identity are equal', () {
      final m1 = OTelAPI.meterProvider('mp-a')
          .getMeter(name: 'm', version: '1.0', schemaUrl: 'https://s');
      final m2 = OTelAPI.meterProvider('mp-b')
          .getMeter(name: 'm', version: '1.0', schemaUrl: 'https://s');
      final other = OTelAPI.meterProvider('mp-a').getMeter(name: 'different');

      expect(identical(m1, m2), isFalse);
      expect(m1, equals(m2));
      expect(m1.hashCode, equals(m2.hashCode));
      expect(m1, isNot(equals(other)));
    });
  });
}
