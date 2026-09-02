// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

import '../../../test_util.dart';

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
      installSdkLikeFactory();

      // Store the original factory
      originalFactory = OTelFactory.otelFactory!;
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
    });

    test('does not invent a version or schemaUrl when none are given', () {
      final tracer = OTelAPI.tracer('test-tracer');

      expect(tracer.name, equals('test-tracer'));
      expect(tracer.version, isNull);
      expect(tracer.schemaUrl, isNull);
      expect(tracer.isEnabled(), isFalse);
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
        context: Context.current.withSpan(parentSpan),
      );

      expect(span, isNotNull);
      expect(span.name, equals('test-span'));
      expect(span.kind, equals(SpanKind.client));
    });

    test('startSpan accepts and respects startTime', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final startTime = DateTime.now().subtract(const Duration(minutes: 5));
      final span = tracer.startSpan('test-span', startTime: startTime);

      expect(span.startTime, equals(startTime));
    });

    test('startSpan with root: true creates root even with active parent', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final parent = tracer.startSpan('parent');

      tracer.withSpan(parent, () {
        final child = tracer.startSpan('child', root: true);
        expect(child.spanContext.parentSpanId?.isValid, isFalse);
        expect(child.spanContext.traceId,
            isNot(equals(parent.spanContext.traceId)));
      });
    });

    test(
        'startSpan with root: true and custom startTime produces span with that exact startTime',
        () {
      final tracer = OTelAPI.tracer('test-tracer');
      final parent = tracer.startSpan('parent');
      final startTime = DateTime.now().subtract(const Duration(hours: 1));

      tracer.withSpan(parent, () {
        final child =
            tracer.startSpan('child', root: true, startTime: startTime);
        expect(child.spanContext.parentSpanId?.isValid, isFalse);
        expect(child.startTime, equals(startTime));
      });
    });

    test(
        'remote SpanContext wrapped in NonRecordingSpan and placed in Context '
        'preserves isRemote through createSpan', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Simulate extracting a remote SpanContext from e.g. a traceparent header
      final remoteSpanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        isRemote: true,
      );
      expect(remoteSpanContext.isRemote, isTrue);

      // Wrap in NonRecordingSpan and put into Context — this is the
      // spec-required pattern for propagating a remote parent
      final remoteSpan = OTelAPI.nonRecordingSpan(remoteSpanContext);
      final ctx = Context.current.withSpan(remoteSpan);

      // Create a child span using the context
      final childSpan = tracer.createSpan(name: 'server-handler', context: ctx);

      // The child must inherit the remote parent's trace ID
      expect(childSpan.spanContext.traceId, equals(remoteSpanContext.traceId));

      // The child must have a new span ID (not the remote's)
      expect(childSpan.spanContext.spanId,
          isNot(equals(remoteSpanContext.spanId)));

      // The child's parent span ID must be the remote span's ID
      expect(
          childSpan.spanContext.parentSpanId, equals(remoteSpanContext.spanId));
    });

    test(
        'remote SpanContext in Context (without NonRecordingSpan wrap) '
        'also preserves isRemote and creates correct child', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Remote context placed directly on Context via copyWithSpanContext
      // (the propagator extract path)
      final remoteSpanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        isRemote: true,
      );
      final ctx = Context.current.copyWithSpanContext(remoteSpanContext);

      final childSpan = tracer.createSpan(name: 'server-handler', context: ctx);

      expect(childSpan.spanContext.traceId, equals(remoteSpanContext.traceId));
      expect(
          childSpan.spanContext.parentSpanId, equals(remoteSpanContext.spanId));
    });

    test(
        'createSpan with context that has both a local span and a different-trace '
        'remote SpanContext uses the remote SpanContext as parent (propagator extract flow)',
        () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Local span on trace A
      final localSpan = tracer.createSpan(name: 'local');
      var ctx = Context.current.withSpan(localSpan);

      // Propagator extracts remote context from trace B
      final remoteCtx = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(), // different trace
        spanId: OTelAPI.spanId(),
        isRemote: true,
      );
      ctx = ctx.withSpanContext(remoteCtx);

      // Sanity: context now has conflicting trace IDs
      expect(ctx.span!.spanContext.traceId, isNot(equals(remoteCtx.traceId)));
      expect(ctx.spanContext!.traceId, equals(remoteCtx.traceId));

      // createSpan must NOT throw — it should use the remote SpanContext
      final child = tracer.createSpan(name: 'handler', context: ctx);
      expect(child.spanContext.traceId, equals(remoteCtx.traceId));
      expect(child.spanContext.parentSpanId, equals(remoteCtx.spanId));
    });

    test('creates span with parent context from current context', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Create a parent span
      final parentSpan = tracer.createSpan(name: 'parent-span');

      // Create a child span in the context with the parent span
      final testContext = Context.current.withSpan(parentSpan);
      final childSpan =
          tracer.createSpan(name: 'child-span', context: testContext);
      expect(childSpan, isNotNull);
      expect(childSpan.spanContext.traceId,
          equals(parentSpan.spanContext.traceId));
    });

    test('span with default context takes current context', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Create a parent span
      final parentSpan = tracer.createSpan(name: 'parent-span');
      final parentContext = parentSpan.spanContext;

      // Use withSpan to make it current
      tracer.withSpan(parentSpan, () {
        // Create a child span without explicitly passing a context
        final childSpan = tracer.createSpan(name: 'child-span');

        // The child span should have the parent context
        expect(
            childSpan.spanContext.parentSpanId, equals(parentContext.spanId));
        expect(childSpan.spanContext.traceId, equals(parentContext.traceId));
      });

      // Outside withSpan, should be root
      final rootSpan = tracer.createSpan(name: 'child-span');
      expect(rootSpan.spanContext.parentSpanId?.isValid, isFalse);
    });

    test('gets active span from context', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.createSpan(name: 'test-span');

      expect(Context.current.span, isNot(equals(span))); // Not active yet

      // Use withSpan to make it current
      tracer.withSpan(span, () {
        expect(Context.current.span, equals(span)); // Now it should be active
      });
    });

    test('currentSpan returns current span in context', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final span = tracer.createSpan(name: 'test-span');

      expect(tracer.currentSpan, isNot(equals(span))); // Not active yet

      // Use withSpan to make it current
      tracer.withSpan(span, () {
        expect(tracer.currentSpan, equals(span)); // Now it should be active
      });
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

    test('startSpan does NOT activate a span by default', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Start a new span
      final span = tracer.startSpan('test-span');

      expect(span, isNotNull);
      expect(
          Context.current.span, isNull); // Should NOT be active automatically

      // Activate it manually via withSpan
      tracer.withSpan(span, () {
        expect(Context.current.span, equals(span)); // Now it should be active
      });
    });

    test('startSpan uses existing active span from context', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Create a parent span
      final parentSpan = tracer.startSpan('parent-span');

      // Make it active
      tracer.withSpan(parentSpan, () {
        final parentTraceId = parentSpan.spanContext.traceId;

        // Start a child span (should automatically use the parent from context)
        final childSpan = tracer.startSpan('child-span');

        // Check the child span has the parent's context
        expect(childSpan.spanContext.traceId, equals(parentTraceId));
        expect(childSpan.spanContext.parentSpanId,
            equals(parentSpan.spanContext.spanId));

        // End child span
        childSpan.end();
      });

      // End parent span
      parentSpan.end();
    });
  });
}
