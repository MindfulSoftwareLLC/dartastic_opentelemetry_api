// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  late APITracerProvider tracerProvider;

  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
    tracerProvider = OTelAPI.tracerProvider();
  });

  test('creates root span correctly', () {
    final tracer = tracerProvider.getTracer('test-tracer');
    final span = tracer.startSpan('root-span');

    expect(span.name, equals('root-span'));
    expect(span.kind, equals(SpanKind.internal));
    expect(
        span.spanContext.isValid, isTrue); // Root spans MUST have valid context
    expect(span.spanContext.parentSpanId, isNotNull);
    expect(span.spanContext.parentSpanId!.hexString,
        equals('0000000000000000')); // Zero SpanId indicates no parent
    expect(span.isRecording, isTrue);

    span.end();
  });

  test('creates child span correctly', () {
    final tracer = tracerProvider.getTracer('test-tracer');

    // Create root span
    final rootSpan = tracer.startSpan('root-span');
    // Create child span
    final childSpan = tracer.startSpan('child-span');

    expect(childSpan.name, equals('child-span'));

    // Verify trace ID inheritance
    expect(childSpan.spanContext.traceId, equals(rootSpan.spanContext.traceId),
        reason: 'Child should inherit trace ID');

    // Verify parent span ID relationship
    expect(
        childSpan.spanContext.parentSpanId, equals(rootSpan.spanContext.spanId),
        reason: 'Child should reference parent span ID');

    // Verify unique span ID
    expect(childSpan.spanContext.spanId,
        isNot(equals(rootSpan.spanContext.spanId)),
        reason: 'Child should have different span ID');

    // Verify flags and state inheritance
    expect(childSpan.spanContext.traceFlags,
        equals(rootSpan.spanContext.traceFlags),
        reason: 'Child should inherit trace flags');
    expect(childSpan.spanContext.traceState,
        equals(rootSpan.spanContext.traceState),
        reason: 'Child should inherit trace state');
  });

  test('span operations work correctly', () {
    final tracer = tracerProvider.getTracer('test-tracer');
    final span = tracer.startSpan('test-span');

    // Add attributes
    span.setStringAttribute<String>('string-key', 'string-value');
    span.setBoolAttribute('bool-key', true);
    span.setIntAttribute('int-key', 123);
    span.setDoubleAttribute('double-key', 123.456);

    span.setStringAttribute<String>('string-key-2', 'string-value-2');
    span.setBoolAttribute('bool-key-2', false);
    span.setIntAttribute('int-key-2', 456);
    span.setDoubleAttribute('double-key-2', 789.1011);

    // Add event
    //span.addEvent('test-event', {'event-key': 'event-value'});

    // Update name
    span.updateName('updated-name');
    expect(span.name, equals('updated-name'));

    // Set status
    span.setStatus(SpanStatusCode.Ok, 'Success');

    span.end();
  });

  test('context operations work correctly', () {
    final tracer = tracerProvider.getTracer('test-tracer');
    final span = tracer.startSpan('test-span');

    // Get span from context
    final retrievedSpan = Context.current.span;

    expect(retrievedSpan, equals(span));

    span.end();
  });
}
