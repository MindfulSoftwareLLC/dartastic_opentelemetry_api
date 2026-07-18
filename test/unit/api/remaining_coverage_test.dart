// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// The last uncovered behaviors: baggage empty-name filtering, the
// OTelFactory.isAPIFactory default, and the no-SDK parent-span
// context pass-through.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

/// A factory that does not override [OTelFactory.isAPIFactory], to lock
/// down the base-class default: a factory is assumed to be a real (SDK)
/// implementation unless it declares otherwise.
class _DefaultingFactory extends OTelFactory {
  _DefaultingFactory()
      : super(
          apiEndpoint: 'http://localhost:4317',
          apiServiceName: 'svc',
          apiServiceVersion: '1.0.0',
          factoryFactory: otelApiFactoryFactoryFunction,
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('Remaining coverage', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('baggage ignores entries with empty names', () {
      final baggage = OTelAPI.baggageForMap({'': 'dropped', 'kept': 'v'});
      expect(baggage.getEntry(''), isNull);
      expect(baggage.getEntry('kept')?.value, equals('v'));
    });

    test(
        'isAPIFactory defaults to false for factories that do not'
        ' declare it', () {
      expect(_DefaultingFactory().isAPIFactory, isFalse);
    });

    test('no-SDK createSpan carries an explicit parent span context through',
        () {
      final sc = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      final parent = OTelAPI.nonRecordingSpan(sc);
      final child = OTelAPI.tracer('no-sdk')
          .createSpan(name: 'child', parentSpan: parent);
      expect(child, isA<NonRecordingSpan>());
      expect(child.spanContext, equals(sc));
    });
  });
}
