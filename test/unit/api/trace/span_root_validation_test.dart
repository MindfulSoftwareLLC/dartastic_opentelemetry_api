// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// Coverage tests for APISpan / APISpanCreate root-span construction
// and SpanContextCreate default fallbacks.
//
// What "no parentSpan" actually means in OTel:
//
//   parentSpan == null does NOT imply "true root span." It only means
//   there is no in-process parent Span object to reference. The W3C
//   trace-context propagation flow produces spans where parentSpan is
//   null but parentSpanId is set to a valid remote span id (carried in
//   from a `traceparent` header or equivalent). That is a legitimate
//   OTel pattern, not a malformed root.
//
//   Therefore APISpan / APISpanCreate must not reject any specific
//   parentSpanId shape when parentSpan is null. Earlier code in this
//   file *attempted* such a validation but the condition was inverted
//   AND used Uint8List `==` (identity equality on a fresh-copy getter)
//   so it never fired anyway. The dead code has been removed; this
//   suite locks down the legitimate construction shapes so the cleanup
//   doesn't regress.
//
//   SpanContextCreate.create defaults:
//     - traceId/spanId omitted → SpanContextCreate falls back to factory
//       generators. These `??` branches are unreachable from
//       OTelAPI.spanContext() because that wrapper substitutes defaults
//       *before* calling the factory; the factory-direct path still
//       needs the fallbacks.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Root / parent-less span construction', () {
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

    test('tracer.startSpan creates a true root span', () {
      // The standard root-span path through the tracer sets parentSpanId
      // to the invalid (all-zeros) SpanId, which is the OTel-spec form
      // of "this is a root."
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
        'createSpan with explicit invalid (all-zeros) parentSpanId and no parentSpan does not throw',
        () {
      // Build the SpanContext via the factory directly — OTelAPI.spanContext
      // normalises an invalid parentSpanId to null at the API boundary,
      // so the only way to materialise the all-zeros form on the SpanContext
      // is to skip the wrapper.
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
        'createSpan with valid non-zero parentSpanId and no parentSpan succeeds (remote-parent flow)',
        () {
      // This is the W3C trace-context propagation pattern: an incoming
      // request carries a `traceparent` header, the receiver builds a
      // remote SpanContext from it, and starts a new span whose
      // parentSpanId is the upstream span's id. The new span has no
      // in-process parentSpan but is NOT a root.
      final remoteParentSpanId = OTelAPI.spanId();
      expect(remoteParentSpanId.isValid, isTrue);

      final ctx = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        parentSpanId: remoteParentSpanId,
      );
      // Sanity: the API didn't normalise our valid parentSpanId away.
      expect(ctx.parentSpanId, equals(remoteParentSpanId));

      // Must succeed — span_create.dart / span.dart cannot distinguish
      // the remote-parent case from a malformed root, and the OTel spec
      // permits the remote-parent shape, so no throw.
      expect(
        () => tracer.createSpan(
          name: 'remote-parent',
          spanContext: ctx,
          parentSpan: null,
        ),
        returnsNormally,
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
