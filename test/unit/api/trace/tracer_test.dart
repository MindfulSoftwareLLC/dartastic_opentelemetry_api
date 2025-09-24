// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APITracer', () {
    late OTelFactory originalFactory;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      // Store the original factory
      originalFactory = OTelFactory.otelFactory!;
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
    });

    test('creates with name, version, and schemaUrl', () {
      final tracer = OTelAPI.tracer('test-tracer');

      expect(tracer.name, equals('test-tracer'));
      expect(tracer.version, equals('1.11.0.0'));
      expect(
          tracer.schemaUrl, equals('https://opentelemetry.io/schemas/1.11.0'));
    });

    test('creates span with name only', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.createSpan(name: 'test-span');

      expect(span, isNotNull);
      expect(span.name, equals('test-span'));
      expect(span.isRecording, isTrue);
    });

    test('creates span with all options', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Create a parent span to get a valid SpanContext
      final parentSpan = tracer.startSpan('parent-span');
      final parentContext = parentSpan.spanContext;

      final attributes = Attributes.of({'key': 'value'});
      final links = [OTelAPI.spanLink(parentContext, attributes)];
      final startTime = DateTime.now();

      final span = tracer.createSpan(
        name: 'test-span',
        kind: SpanKind.client,
        attributes: attributes,
        links: links,
        startTime: startTime,
        spanContext: parentContext, // Using spanContext parameter correctly
      );

      expect(span, isNotNull);
      expect(span.name, equals('test-span'));
      expect(span.kind, equals(SpanKind.client));
    });

    test('creates span with parent context from current context', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Create a parent span and make it current
      final parentSpan = tracer.createSpan(name: 'parent-span');

      final testContext = Context.current.setCurrentSpan(parentSpan);

      // Create a child span in the context with the parent span
      Context.current = testContext;
      final childSpan = tracer.createSpan(name: 'child-span');
      expect(childSpan, isNotNull);

      // Reset context
      Context.current = Context.root;
    });

    test('span with default context takes current context', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Create a parent span and make it current
      final parentSpan = tracer.createSpan(name: 'parent-span');
      final parentContext = parentSpan.spanContext;

      // Set the parent span as current
      final testContext = Context.current.withSpan(parentSpan);

      // Use the context
      Context.current = testContext;

      // Create a child span without explicitly passing a context
      final childSpan = tracer.createSpan(name: 'child-span');

      // The child span should have the parent context
      expect(childSpan.spanContext.parentSpanId, equals(parentContext.spanId));
      expect(childSpan.spanContext.traceId, equals(parentContext.traceId));

      // Reset context
      Context.current = Context.root;

      // Create a root span
      final rootSpan = tracer.createSpan(name: 'child-span');

      // Check if it has a parent span ID set at all
      expect(rootSpan.spanContext.parentSpanId?.isValid, isFalse);
    });

    test('gets active span from context', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.createSpan(name: 'test-span');

      expect(Context.current.span, isNot(equals(span))); // Not active yet

      // Set the span as current
      final testContext = Context.current.setCurrentSpan(span);
      Context.current = testContext;

      expect(Context.current.span, equals(span)); // Now it should be active

      // Reset context
      Context.current = Context.root;
    });

    test('currentSpan returns current span in context', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.createSpan(name: 'test-span');

      expect(tracer.currentSpan, isNot(equals(span))); // Not active yet

      // Set the span as current
      final testContext = Context.current.setCurrentSpan(span);
      Context.current = testContext;

      expect(tracer.currentSpan, equals(span)); // Now it should be active

      // Reset context
      Context.current = Context.root;
    });

    test('executing code with span in context', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.createSpan(name: 'test-span');

      var executed = false;

      tracer.withSpan(span, () {
        executed = true;
        expect(Context.current.span,
            equals(span)); // Should be active inside the callback
      });

      expect(executed, isTrue);
      expect(Context.current.span,
          isNot(equals(span))); // Should no longer be active after the callback
    });

    test('executing async code with span in context', () async {
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.createSpan(name: 'test-span');

      var executed = false;

      await tracer.withSpanAsync(span, () async {
        executed = true;
        expect(Context.current.span,
            equals(span)); // Should be active inside the callback

        // Make sure it stays active during an await
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(Context.current.span, equals(span)); // Should still be active
      });

      expect(executed, isTrue);
      expect(Context.current.span,
          isNot(equals(span))); // Should no longer be active after the callback
    });

    test('startSpan starts and activates a span', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Start a new span and activate it
      final span = tracer.startSpan('test-span');

      expect(span, isNotNull);
      expect(Context.current.span, equals(span)); // Should be active

      // End the span
      span.end();

      // Clear the span from context (since ending a span doesn't deactivate it per spec)
      Context.clearCurrentSpan();

      // Now check if it's still the current span
      expect(Context.current.span,
          isNot(equals(span))); // Should no longer be active
    });

    test('startSpan attaches to existing active span', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Create and activate a parent span
      final parentSpan = tracer.startSpan('parent-span');

      // The parent span should be active now
      expect(Context.current.span, equals(parentSpan));
      final parentTraceId = parentSpan.spanContext.traceId;

      // Start a child span (should automatically use the parent)
      final childSpan = tracer.startSpan('child-span');

      // Check the child span has the parent's context
      expect(childSpan.spanContext.traceId, equals(parentTraceId));
      expect(childSpan.spanContext.parentSpanId,
          equals(parentSpan.spanContext.spanId));

      // End both spans
      childSpan.end();
      parentSpan.end();
    });
  });
}
