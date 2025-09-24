// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('SpanContextCreate', () {
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

    test('creates SpanContext with default values when parameters are omitted',
        () {
      // Create a span context with minimal parameters
      final context = OTelAPI.spanContext();

      // Should have generated default values
      expect(context.traceId.isValid, isTrue);
      expect(context.spanId.isValid, isTrue);
      expect(context.traceFlags, equals(TraceFlags.none));
      expect(context.isRemote, isFalse);
      expect(context.traceState, isNull);
    });

    test('creates SpanContext with all specified parameters', () {
      final traceId = OTelAPI.traceId();
      final spanId = OTelAPI.spanId();
      final parentSpanId = OTelAPI.spanId();
      final traceFlags = OTelAPI.traceFlags(1); // Sampled
      final traceState = OTelAPI.traceState({'key': 'value'});

      final context = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        parentSpanId: parentSpanId,
        traceFlags: traceFlags,
        traceState: traceState,
        isRemote: true,
      );

      // Should use the specified values
      expect(context.traceId, equals(traceId));
      expect(context.spanId, equals(spanId));
      expect(context.parentSpanId, equals(parentSpanId));
      expect(context.traceFlags, equals(traceFlags));
      expect(context.traceState, equals(traceState));
      expect(context.isRemote, isTrue);
    });

    test('creates invalid SpanContext', () {
      final invalidContext = OTelAPI.spanContextInvalid();

      expect(invalidContext.isValid, isFalse);
      expect(invalidContext.traceId.isValid, isFalse);
      expect(invalidContext.spanId.isValid, isFalse);
    });

    test('creates child SpanContext from parent', () {
      final parentContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        traceFlags: OTelAPI.traceFlags(1), // Sampled
        traceState: OTelAPI.traceState({'key': 'value'}),
      );

      final childContext = OTelAPI.spanContextFromParent(parentContext);

      // Child should inherit trace ID and flags
      expect(childContext.traceId, equals(parentContext.traceId));
      expect(childContext.traceFlags, equals(parentContext.traceFlags));
      expect(childContext.traceState, equals(parentContext.traceState));

      // Child should have new span ID
      expect(childContext.spanId, isNot(equals(parentContext.spanId)));

      // Child should have parent's span ID as parent
      expect(childContext.parentSpanId, equals(parentContext.spanId));

      // Child should not be remote
      expect(childContext.isRemote, isFalse);
    });
  });
}
