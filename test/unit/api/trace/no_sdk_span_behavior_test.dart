// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Spec-compliance tests for trace/api.md, "Behavior of the API in the
// absence of an installed SDK":
//
// - "The API MUST return a non-recording Span with the SpanContext in the
//   parent Context (whether explicitly given or implicit current)."
// - "If the parent Context contains no Span, an empty non-recording Span
//   MUST be returned instead (i.e., having a SpanContext with all-zero
//   Span and Trace IDs, empty Tracestate, and unsampled TraceFlags)."
//
// These run with only the API initialized — no SDK — which is exactly the
// mode the quoted section governs.
void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4318',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('no-SDK span behavior (trace/api.md)', () {
    test('parentless span has all-zero IDs and unsampled flags', () {
      final span = OTelAPI.tracerProvider().getTracer('test').startSpan('root');
      expect(span.spanContext.isValid, isFalse);
      expect(span.spanContext.traceFlags.isSampled, isFalse);
    });

    test('span is non-recording', () {
      final span = OTelAPI.tracerProvider().getTracer('test').startSpan('root');
      expect(span.isRecording, isFalse);
    });

    test('span with a parent carries the parent SpanContext unchanged', () {
      final parent = OTelAPI.spanContext(
        traceId: OTelAPI.traceIdFrom('0123456789abcdef0123456789abcdef'),
        spanId: OTelAPI.spanIdFrom('0123456789abcdef'),
        isRemote: true,
      );
      final context = OTelAPI.context().withSpanContext(parent);
      final span = OTelAPI.tracerProvider()
          .getTracer('test')
          .startSpan('child', context: context);
      expect(span.spanContext.traceId, equals(parent.traceId));
      expect(span.spanContext.spanId, equals(parent.spanId));
    });

    test('all operations on a no-SDK span are no-ops', () {
      final span = OTelAPI.tracerProvider().getTracer('test').startSpan('op');
      span.setStringAttribute<String>('k', 'v');
      span.addEventNow('event');
      span.setStatus(SpanStatusCode.Error, 'boom');
      span.updateName('renamed');
      span.end();
      expect(span.attributes.toList(), isEmpty);
      expect(span.spanEvents, isNull);
      expect(span.status, equals(SpanStatusCode.Unset));
      expect(span.name, equals(''));
      expect(span.isEnded, isFalse);
      expect(span.isRecording, isFalse);
    });
  });

  // trace/api.md, "Wrapping a SpanContext in a Span": "The API MUST provide
  // an operation for wrapping a SpanContext with an object implementing the
  // Span interface [...] SHOULD be named NonRecordingSpan." GetContext
  // returns the wrapped context, IsRecording returns false, everything
  // else is a no-op.
  group('NonRecordingSpan (trace/api.md SpanContext wrapping)', () {
    test('wraps a SpanContext, returning it unchanged', () {
      final wrapped = OTelAPI.spanContext(
        traceId: OTelAPI.traceIdFrom('0123456789abcdef0123456789abcdef'),
        spanId: OTelAPI.spanIdFrom('0123456789abcdef'),
      );
      final span = OTelAPI.nonRecordingSpan(wrapped);
      expect(span, isA<NonRecordingSpan>());
      expect(span.spanContext, same(wrapped));
      expect(span.isRecording, isFalse);
    });

    test('mutating operations are no-ops', () {
      final span = OTelAPI.nonRecordingSpan(OTelAPI.spanContextInvalid());
      span.setBoolAttribute('flag', true);
      span.addEventNow('event');
      span.setStatus(SpanStatusCode.Ok);
      span.end();
      expect(span.attributes.toList(), isEmpty);
      expect(span.spanEvents, isNull);
      expect(span.status, equals(SpanStatusCode.Unset));
      expect(span.isEnded, isFalse);
    });
  });
}
