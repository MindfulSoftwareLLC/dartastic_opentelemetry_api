// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Context clearCurrentSpan', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('clearCurrentSpan removes the span from current context', () {
      // Create a tracer and span
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Verify the span is in the current context
      expect(Context.current.span, equals(span));

      // Clear the current span
      final newContext = Context.clearCurrentSpan();

      // Verify the span is removed from the current context
      expect(Context.current.span, isNull);
      expect(newContext.span, isNull);
    });

    test('clearCurrentSpan preserves other context values', () {
      // Create a key and set a value in the context
      final testKey = OTelAPI.contextKey<String>('test-key');
      final testValue = 'test-value';

      // Set a value in the context
      Context.current = Context.current.copyWith(testKey, testValue);

      // Create a tracer and span
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Verify the span and value are in the current context
      expect(Context.current.span, equals(span));
      expect(Context.current.get<String>(testKey), equals(testValue));

      // Clear the current span
      final newContext = Context.clearCurrentSpan();

      // Verify only the span is removed, but other values remain
      expect(Context.current.span, isNull);
      expect(Context.current.get<String>(testKey), equals(testValue));
      expect(newContext.span, isNull);
      expect(newContext.get<String>(testKey), equals(testValue));
    });

    test('clearCurrentSpan works with baggage', () {
      // Create baggage
      final baggage = OTelAPI.baggage({
        'key1': OTelAPI.baggageEntry('value1', null),
        'key2': OTelAPI.baggageEntry('value2', null),
      });

      // Set baggage in the context
      Context.current = Context.current.withBaggage(baggage);

      // Create a tracer and span
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Verify the span and baggage are in the current context
      expect(Context.current.span, equals(span));
      expect(Context.current.baggage, equals(baggage));

      // Clear the current span
      final newContext = Context.clearCurrentSpan();

      // Verify only the span is removed, but baggage remains
      expect(Context.current.span, isNull);
      expect(Context.current.baggage, equals(baggage));
      expect(newContext.span, isNull);
      expect(newContext.baggage, equals(baggage));
    });

    test('clearCurrentSpan handles case where no span is active', () {
      // Ensure no span is in the context
      expect(Context.current.span, isNull);

      // Clear the current span (should be a no-op)
      final newContext = Context.clearCurrentSpan();

      // Verify still no span in context
      expect(Context.current.span, isNull);
      expect(newContext.span, isNull);
    });

    test('clearCurrentSpan interacts correctly with span.end()', () {
      // Create a tracer and span
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.startSpan('test-span');

      // Verify the span is in the current context
      expect(Context.current.span, equals(span));

      // End the span
      span.end();

      // Span should still be in context (per spec)
      expect(Context.current.span, equals(span));
      expect(span.isRecording, isFalse); // But no longer recording

      // Clear the current span
      final newContext = Context.clearCurrentSpan();

      // Verify the span is removed from context
      expect(Context.current.span, isNull);
      expect(newContext.span, isNull);
    });
  });
}
