// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:async';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APITracer - Additional Coverage Tests', () {
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

    test('recordSpan handles exceptions correctly', () {
      final tracer = OTelAPI.tracer('test-tracer');
      
      // Test with a function that throws
      expect(() {
        tracer.recordSpan(
          name: 'error-span',
          fn: () {
            throw Exception('Test error');
          },
        );
      }, throwsException);
    });
    
    test('recordSpanAsync handles exceptions correctly', () async {
      final tracer = OTelAPI.tracer('test-tracer');
      
      // Test with a function that throws
      expect(() async {
        await tracer.recordSpanAsync(
          name: 'error-span',
          fn: () async {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            throw Exception('Test error');
          },
        );
      }, throwsException);
    });
    
    test('remote context is handled correctly in createSpan', () {
      final tracer = OTelAPI.tracer('test-tracer');
      
      // Create a remote span context
      final traceId = OTelAPI.traceId();
      final spanId = OTelAPI.spanId();
      final remoteContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        isRemote: true,
      );
      
      // Create a context with the remote span context
      final context = Context.current.copyWithSpanContext(remoteContext);
      
      // Create a span with the context
      final span = tracer.createSpan(
        name: 'remote-span',
        context: context,
      );
      
      // Should inherit the trace ID from the remote context
      expect(span.spanContext.traceId, equals(traceId));
      
      // Should have a new span ID
      expect(span.spanContext.spanId, isNot(equals(spanId)));
      
      // Should have the remote span ID as parent
      expect(span.spanContext.parentSpanId, equals(spanId));
    });
    
    test('tracer equals and hashCode work correctly', () {
      final tracer1 = OTelAPI.tracer('test-tracer');
      final tracer2 = OTelAPI.tracer('test-tracer');
      final tracer3 = OTelAPI.tracer('other-tracer');
      
      // Same name should be equal
      expect(tracer1, equals(tracer2));
      expect(tracer1.hashCode, equals(tracer2.hashCode));
      
      // Different name should not be equal
      expect(tracer1, isNot(equals(tracer3)));
      expect(tracer1.hashCode, isNot(equals(tracer3.hashCode)));
    });
    
    test('tracer with parent span and incompatible trace ID throws', () {
      final tracer = OTelAPI.tracer('test-tracer');
      
      // Create two spans with different trace IDs
      final span1 = tracer.createSpan(
        name: 'span1',
        spanContext: OTelAPI.spanContext(
          traceId: OTelAPI.traceId(),
          spanId: OTelAPI.spanId(),
        ),
      );
      
      final span2 = tracer.createSpan(
        name: 'span2',
        spanContext: OTelAPI.spanContext(
          traceId: OTelAPI.traceId(), // Different trace ID
          spanId: OTelAPI.spanId(),
        ),
      );
      
      // Trying to create a span with incompatible parent should throw
      expect(() {
        tracer.createSpan(
          name: 'child-span',
          spanContext: OTelAPI.spanContext(
            traceId: span1.spanContext.traceId,
            spanId: OTelAPI.spanId(),
          ),
          parentSpan: span2, // Different trace ID from spanContext
        );
      }, throwsArgumentError);
    });
  });
}
