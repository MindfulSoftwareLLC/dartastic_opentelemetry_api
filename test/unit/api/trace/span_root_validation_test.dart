// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// Coverage tests for APISpan / APISpanCreate root-vs-child validation
// and SpanContextCreate default fallbacks.
//
// These tests exercise contracts that were previously uncovered:
//
//   APISpanCreate.create + APISpan._ root-span validation:
//     - parentSpan == null AND parentSpanId is null → no throw
//     - parentSpan == null AND parentSpanId is the invalid (all-zeros)
//       SpanId → no throw (the documented "valid root" form)
//     - parentSpan == null AND parentSpanId is a valid non-zero SpanId
//       → MUST throw ArgumentError (a root span cannot reference an
//       arbitrary parent span ID without a parentSpan).
//
//   SpanContextCreate.create defaults:
//     - traceId/spanId omitted → SpanContextCreate falls back to factory
//       generators (these `??` branches are unreachable from
//       OTelAPI.spanContext() because that wrapper substitutes defaults
//       *before* calling the factory; the factory-direct path still
//       needs the fallbacks).

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Root span parentSpanId validation', () {
    late APITracer tracer;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      tracer = OTelAPI.tracer('test-tracer');
    });

    test('tracer.startSpan creates a root span without throwing', () {
      // Sanity: the standard root-span creation path through the tracer
      // sets parentSpanId to the invalid (all-zeros) SpanId, which is
      // the OTel-spec form of "this is a root."
      final span = tracer.startSpan('root');
      expect(span.parentSpan, isNull);
      expect(span.spanContext.parentSpanId, isNotNull);
      expect(span.spanContext.parentSpanId!.isValid, isFalse);
    });

    test(
        'createSpan with omitted parentSpanId and no parentSpan does not throw',
        () {
      // SpanContextCreate.create defaults a null parentSpanId to the
      // invalid SpanId — the OTel-spec form for "no parent." So even
      // when the caller omits parentSpanId, the resulting context's
      // parentSpanId is the invalid (all-zeros) marker, not literally
      // null.
      final ctx = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      expect(ctx.parentSpanId, isNotNull);
      expect(ctx.parentSpanId!.isValid, isFalse);

      expect(
        () => tracer.createSpan(
          name: 'orphan-default',
          spanContext: ctx,
          parentSpan: null,
        ),
        returnsNormally,
      );
    });

    test(
        'createSpan with invalid (all-zeros) parentSpanId and no parentSpan does not throw',
        () {
      // The OTel spec lets a root span carry the invalid SpanId as its
      // parentSpanId — that is the canonical "no parent" marker.
      // OTelAPI.spanContext() normalises invalid → null at the API
      // boundary, so build the SpanContext via the factory directly.
      final ctx = OTelFactory.otelFactory!.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        parentSpanId: OTelAPI.spanIdInvalid(),
      );
      expect(ctx.parentSpanId, isNotNull);
      expect(ctx.parentSpanId!.isValid, isFalse);

      expect(
        () => tracer.createSpan(
          name: 'orphan-invalid',
          spanContext: ctx,
          parentSpan: null,
        ),
        returnsNormally,
      );
    });

    test(
        'createSpan with valid non-zero parentSpanId and no parentSpan throws ArgumentError',
        () {
      // A root span (parentSpan == null) must not carry a non-zero
      // parentSpanId — there is no parent to reference. The error
      // message explicitly states: "Root spans must have invalid
      // (all zeros) parent span ID or no parent span ID".
      final orphanedParent = OTelAPI.spanId(); // valid, non-zero
      expect(orphanedParent.isValid, isTrue);

      final ctx = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        parentSpanId: orphanedParent,
      );

      // Sanity: the API didn't normalise our valid parentSpanId away.
      expect(ctx.parentSpanId, equals(orphanedParent));

      expect(
        () => tracer.createSpan(
          name: 'orphan-with-fake-parent',
          spanContext: ctx,
          parentSpan: null,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('SpanContextCreate factory defaults', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('OTelFactory.spanContext() generates a valid traceId when omitted',
        () {
      // Factory-direct path (no OTelAPI wrapper) — exercises the
      // `traceId ?? factory.traceId()` fallback in SpanContextCreate.
      final ctx = OTelFactory.otelFactory!.spanContext();
      expect(ctx.traceId.isValid, isTrue);
    });

    test('OTelFactory.spanContext() generates a valid spanId when omitted', () {
      // Factory-direct path — exercises the `spanId ?? factory.spanId()`
      // fallback in SpanContextCreate.
      final ctx = OTelFactory.otelFactory!.spanContext();
      expect(ctx.spanId.isValid, isTrue);
    });
  });
}
