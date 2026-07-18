// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Coverage for the APISpan mutation/getter surface, factory-gone
// StateErrors, ID byte validation, TraceState eviction, and tracer
// equality.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

import '../../../test_util.dart';

/// An exception whose toString throws, to exercise recordException's
/// defensive message fallback.
class _ThrowsOnToString {
  @override
  String toString() => throw StateError('toString exploded');
}

void main() {
  group('APISpan surface (SDK-like factory)', () {
    late OTelFactory originalFactory;
    late APITracer tracer;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      installSdkLikeFactory();
      originalFactory = OTelFactory.otelFactory!;
      tracer = OTelAPI.tracer('coverage-tracer');
    });

    tearDown(() {
      OTelFactory.otelFactory = originalFactory;
    });

    test(
        'span getters: spanId, instrumentationScope, isValid,'
        ' parentSpanContext', () {
      final parent = tracer.createSpan(name: 'parent');
      final child = tracer.createSpan(name: 'child', parentSpan: parent);

      expect(child.spanId, equals(child.spanContext.spanId));
      expect(child.instrumentationScope.name, equals('coverage-tracer'));
      expect(child.isValid, isTrue);
      expect(child.parentSpanContext, equals(parent.spanContext));
      expect(parent.parentSpanContext, isNull);
    });

    test('setDateTimeAsStringAttribute stores the formatted time', () {
      final span = tracer.createSpan(name: 'timed');
      final when = DateTime.utc(2026, 7, 18, 12, 30);
      span.setDateTimeAsStringAttribute('happened.at', when);
      expect(span.attributes.getString('happened.at'), isNotNull);
    });

    test('addEvents adds one event per map entry', () {
      final span = tracer.createSpan(name: 'eventful');
      span.addEvents({
        'first': null,
        'second': Attributes.of({'k': 'v'}),
      });
      expect(span.spanEvents, hasLength(2));
      expect(span.spanEvents!.map((e) => e.name),
          containsAll(['first', 'second']));
    });

    test('addLink and addSpanLink append links', () {
      final span = tracer.createSpan(name: 'linked');
      final other = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      span.addLink(other, Attributes.of({'why': 'related'}));
      span.addSpanLink(OTelAPI.spanLink(other, Attributes.of({'why': 'also'})));
      expect(span.spanLinks, hasLength(2));
    });

    test('recordException survives a throwing toString', () {
      final span = tracer.createSpan(name: 'exceptional');
      span.recordException(_ThrowsOnToString());
      expect(span.spanEvents!.any((e) => e.name == 'exception'), isTrue);
    });

    test('span mutators throw StateError after reset', () {
      final span = tracer.createSpan(name: 'orphaned');
      final linkTarget = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      OTelAPI.reset();
      expect(() => span.addEventNow('late'), throwsStateError);
      expect(() => span.addEvents({'late': null}), throwsStateError);
      expect(() => span.addLink(linkTarget), throwsStateError);
    });
  });

  group('Trace API surface (API factory)', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('NonRecordingSpan requires an installed factory', () {
      final sc = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      OTelAPI.reset();
      expect(() => NonRecordingSpan(sc), throwsStateError);
    });

    test('spanIdFromBytes and traceIdFromBytes validate length', () {
      expect(() => OTelAPI.spanIdFromBytes([1, 2, 3]), throwsArgumentError);
      expect(() => OTelAPI.traceIdFromBytes([1, 2, 3]), throwsArgumentError);
    });

    test('SpanId.invalidSpanId is all zeros', () {
      expect(SpanId.invalidSpanId.toString(),
          equals(OTelAPI.spanIdInvalid().toString()));
    });

    test('TraceState.put evicts the oldest entry at the 32-entry limit', () {
      final full = <String, String>{
        for (var i = 0; i < 32; i++) 'key$i': 'value$i',
      };
      final traceState = OTelAPI.traceState(full);
      final evicted = traceState.put('overflow', 'v');

      expect(evicted.get('overflow'), equals('v'));
      expect(evicted.get('key0'), isNull, reason: 'oldest entry is evicted');
      expect(evicted.entries, hasLength(32));
    });

    test('tracers with the same identity are equal', () {
      final t1 = OTelAPI.tracerProvider('tp-a')
          .getTracer('t', version: '1.0', schemaUrl: 'https://s');
      final t2 = OTelAPI.tracerProvider('tp-b')
          .getTracer('t', version: '1.0', schemaUrl: 'https://s');
      final other = OTelAPI.tracerProvider('tp-a').getTracer('different');

      expect(identical(t1, t2), isFalse);
      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
      expect(t1, isNot(equals(other)));
    });

    test(
        'createSpan with an empty root context returns an invalid'
        ' non-recording span', () {
      final span = OTelAPI.tracer('no-sdk')
          .createSpan(name: 'rootless', context: Context.root);
      expect(span, isA<NonRecordingSpan>());
      expect(span.spanContext.isValid, isFalse);
    });

    test('createSpan carries a context-only SpanContext through unchanged', () {
      final sc = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      final ctx = Context.root.withSpanContext(sc);
      final span =
          OTelAPI.tracer('no-sdk').createSpan(name: 'remote', context: ctx);
      expect(span, isA<NonRecordingSpan>());
      expect(span.spanContext, equals(sc));
    });
  });
}
