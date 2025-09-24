// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/context/context.dart';
import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
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
    });

    test('supports span nesting', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final parentSpan = tracer.startSpan('parent-span');
      final childSpan = tracer.startSpan('child-span', parentSpan: parentSpan);

      final parentContext = Context.current.withSpan(parentSpan);
      final childContext = parentContext.withSpan(childSpan);

      expect(childContext.span, equals(childSpan));
      expect(childSpan.parentSpan, equals(parentSpan));
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

    test('retrieves current span', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      Context.current = Context.current.withSpan(span);
      expect(Context.current.span, equals(span));
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

    test('retrieves current baggage', () {
      final baggage = OTelAPI.baggage({
        'key': OTelAPI.baggageEntry('value', 'metadata'),
      });

      Context.current = Context.current.withBaggage(baggage);
      expect(Context.current.baggage, equals(baggage));
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

    test('handles context restoration', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final originalSpan = tracer.startSpan('original-span');
      final tempSpan = tracer.startSpan('temp-span');

      // Save original context
      final originalContext = Context.current.withSpan(originalSpan);
      Context.current = originalContext;

      // Temporarily use a different context
      Context.current = Context.current.withSpan(tempSpan);
      expect(Context.current.span, equals(tempSpan));

      // Restore original context
      Context.current = originalContext;
      expect(Context.current.span, equals(originalSpan));
    });

    test('supports detached context operations', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Create a context but don't make it current
      final detachedContext = Context.root.withSpan(span);
      expect(detachedContext.span, equals(span));

      // Verify it didn't affect the current context
      expect(Context.current.span, equals(span));
    });

    test('uses root context by default', () {
      final context = Context.current;
      expect(context.span, isNull);
      expect(context.baggage, isNull);
    });

    test('creating span does not affect context', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Verify span creation doesn't affect current context
      expect(Context.current.span, equals(span));

      // Explicitly set span in context
      final newContext = Context.current.withSpan(span);
      expect(newContext.span, equals(span));
      // Verify original context unchanged
      expect(Context.current.span, equals(span));
    });

    test('supports explicit context management', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Create new context with span but don't make it current
      final spanContext = Context.current.withSpan(span);
      expect(spanContext.span, equals(span));
      expect(Context.current.span, equals(span));

      // Explicitly make it current
      Context.current = spanContext;
      expect(Context.current.span, equals(span));
    });

    test('handles span nesting with explicit context', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final parentSpan = tracer.startSpan('parent-span');
      final childSpan = tracer.startSpan('child-span', parentSpan: parentSpan);

      // Create nested contexts
      final parentContext = Context.current.withSpan(parentSpan);
      final childContext = parentContext.withSpan(childSpan);

      expect(childContext.span, equals(childSpan));
      expect(childSpan.parentSpan, equals(parentSpan));

      // Original context remains unchanged
      expect(Context.current.span, equals(childSpan));
    });

    test('maintains context independence', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span1 = tracer.startSpan('span-1');
      final span2 = tracer.startSpan('span-2');

      final context1 = Context.current.withSpan(span1);
      final context2 = Context.current.withSpan(span2);

      expect(context1.span, equals(span1));
      expect(context2.span, equals(span2));
      expect(Context.current.span, equals(span2));
    });

    test('setCurrentSpan modifies current context', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Use convenience method to update current context
      final newContext = Context.current.setCurrentSpan(span);
      expect(Context.current.span, equals(span));
      expect(newContext.span, equals(span));
    });

    test('handles baggage in context', () {
      final baggage = OTelAPI.baggage({
        'key1': OTelAPI.baggageEntry('value1', null),
        'key2': OTelAPI.baggageEntry('value2', 'metadata'),
      });

      final context = Context.current.withBaggage(baggage);
      expect(context.baggage, equals(baggage));
      // Original context unchanged
      expect(Context.current.baggage, isNull);

      // Explicitly make it current
      Context.current = context;
      expect(Context.current.baggage, equals(baggage));
    });

    test('combines span and baggage with explicit context', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final span = tracer.startSpan('test-span');
      final baggage = OTelAPI.baggage({
        'key': OTelAPI.baggageEntry('value', null),
      });

      final context = Context.current.withSpan(span).withBaggage(baggage);

      expect(context.span, equals(span));
      expect(context.baggage, equals(baggage));
      // Original context unchanged until explicitly set
      expect(Context.current.span, equals(span));
      expect(Context.current.baggage, isNull);

      Context.current = context;
      expect(Context.current.span, equals(span));
      expect(Context.current.baggage, equals(baggage));
    });

    test('supports context restoration', () {
      final tracer = OTelAPI.tracerProvider().getTracer('test-tracer');
      final originalSpan = tracer.startSpan('original-span');
      final tempSpan = tracer.startSpan('temp-span');

      // Set up original context
      final originalContext = Context.current.withSpan(originalSpan);
      Context.current = originalContext;

      // Switch to temporary context
      Context.current = Context.current.withSpan(tempSpan);
      expect(Context.current.span, equals(tempSpan));

      // Restore original
      Context.current = originalContext;
      expect(Context.current.span, equals(originalSpan));
    });
  });
}
