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

    test('isEnabled does not throw when no factory is installed', () {
      // error-handling.md: an API method MUST NOT throw when used
      // incorrectly. isEnabled reads the global factory, which reset()
      // clears, so it has to tolerate a null one.
      final tracer = OTelAPI.tracer('test-tracer');
      OTelFactory.otelFactory = null;

      expect(tracer.isEnabled, returnsNormally);
      expect(tracer.isEnabled(), isFalse);
    });

    test('does not invent a version or schemaUrl when none are given', () {
      final tracer = OTelAPI.tracer('test-tracer');

      expect(tracer.name, equals('test-tracer'));
      expect(tracer.version, isNull);
      expect(tracer.schemaUrl, isNull);
      // The test harness installs SdkLikeFactory, which sets isAPIFactory = false.
      // APITracer natively checks !isAPIFactory to determine if it is enabled.
      // Therefore, in this test environment, the tracer is correctly enabled.
      expect(tracer.isEnabled(), isTrue);
    });

    test('creates scope with tracer attributes, ignoring span attributes', () {
      final tracerAttrs = Attributes.of({'tracer-key': 'tracer-value'});
      final tracer = OTelAPI.tracerProvider()
          .getTracer('test-tracer', attributes: tracerAttrs);

      final spanAttrs = Attributes.of({'span-key': 'span-value'});
      final span = tracer.createSpan(name: 'test-span', attributes: spanAttrs);

      expect(span.instrumentationScope.attributes, equals(tracerAttrs));
    });

    test(
        'reusing a tracer shares the exact same InstrumentationScope instance across spans',
        () {
      final tracer = OTelAPI.tracer('test-tracer');

      final span1 = tracer.createSpan(name: 'span1');
      final span2 = tracer.createSpan(name: 'span2');

      expect(identical(span1.instrumentationScope, span2.instrumentationScope),
          isTrue);
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

      // The wrapping span is the span the remote SpanContext identifies, so
      // it is preserved as the parent span object.
      expect(childSpan.parentSpan, same(remoteSpan));
      expect(childSpan.parentSpanContext, equals(remoteSpanContext));
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

      // There is no span object behind the SpanContext, so no parent span.
      expect(childSpan.parentSpan, isNull);
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

      // The local span belongs to a different trace, so it is not kept as
      // the parent span object.
      expect(child.parentSpan, isNull);
      expect(child.parentSpanContext, isNull);
    });

    test(
        'valid non-remote SpanContext on Context with no span is honored as parent',
        () {
      final tracer = OTelAPI.tracer('test-tracer');

      // A valid, local (non-remote) SpanContext placed on the Context with
      // no span object behind it — e.g. a parent recorded by an in-process
      // framework that does not keep the Span around.
      final parentSpanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      expect(parentSpanContext.isRemote, isFalse);

      final ctx = Context.current.copyWithSpanContext(parentSpanContext);
      expect(ctx.span, isNull);

      final childSpan = tracer.createSpan(name: 'child', context: ctx);

      // Not a fresh root: the child joins the parent's trace and points at it.
      expect(childSpan.spanContext.traceId, equals(parentSpanContext.traceId));
      expect(
          childSpan.spanContext.parentSpanId, equals(parentSpanContext.spanId));
      expect(childSpan.spanContext.parentSpanId?.isValid, isTrue);
      expect(childSpan.spanContext.spanId,
          isNot(equals(parentSpanContext.spanId)));

      // No span object behind the SpanContext, so no parent span.
      expect(childSpan.parentSpan, isNull);
    });

    test('root: true wins over a remote SpanContext in the context', () {
      final tracer = OTelAPI.tracer('test-tracer');

      final remoteSpanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        isRemote: true,
      );
      final ctx =
          Context.current.withSpan(OTelAPI.nonRecordingSpan(remoteSpanContext));

      final child = tracer.createSpan(name: 'child', context: ctx, root: true);

      expect(
          child.spanContext.traceId, isNot(equals(remoteSpanContext.traceId)));
      expect(child.spanContext.parentSpanId?.isValid, isFalse);
      expect(child.parentSpan, isNull);
    });

    test(
        'root: true with only the API factory installed returns a non-recording '
        'span with an invalid span context', () {
      // No SDK: restore the plain API factory installed by OTelAPI.initialize.
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);

      final tracer = OTelAPI.tracer('test-tracer');
      final parentSpanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      final ctx = Context.current.copyWithSpanContext(parentSpanContext);

      final span = tracer.createSpan(name: 'child', context: ctx, root: true);

      expect(span, isA<NonRecordingSpan>());
      expect(span.isRecording, isFalse);
      expect(span.spanContext.isValid, isFalse);
      expect(span.spanContext.traceId.isValid, isFalse);
      expect(span.spanContext.spanId.isValid, isFalse);
    });

    test(
        'a span with an invalid SpanContext in the Context produces a root span, '
        'not an error', () {
      final tracer = OTelAPI.tracer('test-tracer');

      // Context does not validate what is put into it, so an invalid span
      // can sit in one — this is exactly what the no-SDK path returns for
      // root: true.
      final invalidSpanContext = OTelAPI.spanContextInvalid();
      final ctx = Context.current
          .withSpan(OTelAPI.nonRecordingSpan(invalidSpanContext));

      final child = tracer.createSpan(name: 'child', context: ctx);

      // An invalid parent means a root span, per trace/api.md — not an
      // ArgumentError out of APISpanCreate.create.
      expect(child.spanContext.isValid, isTrue);
      expect(child.spanContext.traceId.isValid, isTrue);
      expect(
          child.spanContext.traceId, isNot(equals(invalidSpanContext.traceId)));
      expect(child.spanContext.parentSpanId?.isValid, isFalse);
      expect(child.parentSpan, isNull);
    });

    test(
        'a span with an invalid SpanContext in the Context returns a '
        'non-recording invalid span with only the API factory installed', () {
      // No SDK: restore the plain API factory installed by OTelAPI.initialize.
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);

      final tracer = OTelAPI.tracer('test-tracer');
      final invalidSpanContext = OTelAPI.spanContextInvalid();
      final ctx = Context.current
          .withSpan(OTelAPI.nonRecordingSpan(invalidSpanContext));

      final span = tracer.createSpan(name: 'child', context: ctx);

      // Same Context, same resolution: no parent either way. With an SDK it
      // becomes a root span; without one, the spec-mandated non-recording
      // span with an invalid span context.
      expect(span, isA<NonRecordingSpan>());
      expect(span.isRecording, isFalse);
      expect(span.spanContext.isValid, isFalse);
      expect(span.spanContext.traceId.isValid, isFalse);
      expect(span.spanContext.spanId.isValid, isFalse);
    });

    test('createSpan applies an explicit startTime', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final startTime = DateTime.now().subtract(const Duration(minutes: 42));

      final span = tracer.createSpan(name: 'test-span', startTime: startTime);

      expect(span.startTime, equals(startTime));
    });

    test('startSpan forwards root and startTime through to createSpan', () {
      final tracer = OTelAPI.tracer('test-tracer');
      final parent = tracer.startSpan('parent');
      final startTime = DateTime.now().subtract(const Duration(hours: 2));

      tracer.withSpan(parent, () {
        final viaStartSpan =
            tracer.startSpan('child', root: true, startTime: startTime);
        final viaCreateSpan =
            tracer.createSpan(name: 'child', root: true, startTime: startTime);

        // startSpan is a thin forwarder: both parameters must reach
        // createSpan, so the two spans agree on start time and on both being
        // roots of their own new traces despite the active parent.
        expect(viaStartSpan.startTime, equals(startTime));
        expect(viaStartSpan.startTime, equals(viaCreateSpan.startTime));

        expect(viaStartSpan.spanContext.parentSpanId?.isValid, isFalse);
        expect(viaCreateSpan.spanContext.parentSpanId?.isValid, isFalse);
        expect(viaStartSpan.parentSpan, isNull);

        expect(viaStartSpan.spanContext.traceId,
            isNot(equals(parent.spanContext.traceId)));
        expect(viaStartSpan.spanContext.traceId,
            isNot(equals(viaCreateSpan.spanContext.traceId)));
      });
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
