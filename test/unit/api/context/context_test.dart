// Licensed under the Apache License, Version 2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Context', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('uses root context by default', () {
      final context = Context.current;
      expect(context.span, isNull);
      expect(context.baggage, isNull);
    });

    test('handles span in context', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      final context = Context.current.withSpan(span);
      expect(context.span, equals(span));
      // startSpan does not activate
      expect(Context.current.span, isNull);
    });

    test('supports span nesting', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final parentSpan = tracer.startSpan('parent-span');

      final parentContext = Context.current.withSpan(parentSpan);
      expect(parentContext.span, equals(parentSpan),
          reason: 'parentContext should have parentSpan');

      APISpan? childSpan;
      parentContext.runSync(() {
        final current = Context.current;
        expect(current.span, equals(parentSpan),
            reason: 'Context.current.span should be parentSpan inside runSync');
        childSpan = tracer.startSpan('child-span');
      });

      expect(childSpan!.parentSpan, equals(parentSpan));
      expect(childSpan!.spanContext.traceId,
          equals(parentSpan.spanContext.traceId));
    });

    test('maintains context independence', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span1 = tracer.startSpan('span-1');
      final span2 = tracer.startSpan('span-2');

      final context1 = Context.current.withSpan(span1);
      final context2 = Context.current.withSpan(span2);

      expect(context1.span, equals(span1));
      expect(context2.span, equals(span2));
    });

    test('retrieves current span via withSpan', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      tracer.withSpan(span, () {
        expect(Context.current.span, equals(span));
      });
    });

    test('handles baggage in context', () {
      final baggage = OTelAPI.baggage({
        'key1': OTelAPI.baggageEntry('value1', null),
        'key2': OTelAPI.baggageEntry('value2', 'metadata'),
      });

      final context = Context.current.withBaggage(baggage);
      final retrievedBaggage = context.baggage;

      expect(retrievedBaggage, isNotNull);
      expect(retrievedBaggage, equals(baggage));
      expect(retrievedBaggage!.getEntry('key1')?.value, equals('value1'));
      expect(retrievedBaggage.getEntry('key2')?.value, equals('value2'));
      expect(retrievedBaggage.getEntry('key2')?.metadata, equals('metadata'));
    });

    test('retrieves current baggage via runSync', () {
      final baggage = OTelAPI.baggage({
        'key': OTelAPI.baggageEntry('value', 'metadata'),
      });

      final context = Context.current.withBaggage(baggage);
      context.runSync(() {
        expect(Context.current.baggage, equals(baggage));
      });
    });

    test('combines span and baggage', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');
      final baggage = OTelAPI.baggage({
        'key': OTelAPI.baggageEntry('value', null),
      });

      final context = Context.current.withSpan(span).withBaggage(baggage);

      expect(context.span, equals(span));
      expect(context.baggage, equals(baggage));
    });

    test('handles context restoration via runSync', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final originalSpan = tracer.startSpan('original-span');
      final tempSpan = tracer.startSpan('temp-span');

      final originalContext = Context.current.withSpan(originalSpan);
      final tempContext = originalContext.withSpan(tempSpan);

      originalContext.runSync(() {
        expect(Context.current.span, equals(originalSpan));
        tempContext.runSync(() {
          expect(Context.current.span, equals(tempSpan));
        });
        expect(Context.current.span, equals(originalSpan));
      });
    });

    test('supports detached context operations', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Create a context but don't make it current
      final detachedContext = Context.root.withSpan(span);
      expect(detachedContext.span, equals(span));

      // Verify it didn't affect the current context
      expect(Context.current.span, isNull);
    });

    test('creating span does not affect context', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');

      expect(Context.current.span, isNull);
      final span = tracer.startSpan('test-span');

      // Verify span creation doesn't affect current context
      expect(Context.current.span, isNull);

      // Explicitly set span in context
      final newContext = Context.current.withSpan(span);
      expect(newContext.span, equals(span));
      // Verify original context unchanged
      expect(Context.current.span, isNull);
    });

    test('supports explicit context management via deprecated setter', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      final spanContext = Context.current.withSpan(span);

      Context.current = spanContext;
      expect(Context.current.span, equals(span));
    });

    test('setCurrentSpan does NOT modify global static state', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      final newContext = Context.current.setCurrentSpan(span);
      expect(newContext.span, equals(span));
      expect(Context.current.span, isNull);
    });
  });
}
