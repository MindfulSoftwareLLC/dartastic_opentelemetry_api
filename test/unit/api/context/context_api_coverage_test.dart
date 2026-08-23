// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Coverage for Context.withSpanContext trace replacement and the
// ContextKey uniqueId/toString surface.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('withSpanContext debug logging', () {
    tearDown(() {
      OTelLog.logFunction = null;
      OTelLog.currentLevel = LogLevel.info;
    });

    test('logs the trace replacement when debug logging is enabled', () {
      final lines = <String>[];
      OTelLog.logFunction = lines.add;
      OTelLog.currentLevel = LogLevel.debug;

      final spanA = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      final spanB = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      final base = OTelAPI.context().withSpanContext(spanA);

      final derived = base.withSpanContext(spanB);

      expect(derived.spanContext, spanB);
      expect(
        lines.join('\n'),
        contains('replacing span context of trace'),
        reason: 'the derive-not-throw path must announce the trace '
            'replacement when debug logging is on (#196)',
      );
    });
  });

  group('Context API surface', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test(
        'withSpanContext returns a derived context when the Context holds '
        'a span of another trace', () {
      // Per the Propagators API spec, extract "MUST NOT throw": a service
      // with an active local span in trace A that receives a valid
      // traceparent for trace B is an ordinary situation. withSpanContext
      // sits on that extraction path, so it must derive, never throw.
      final sc1 = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );
      final sc2 = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(), // different trace
        spanId: OTelAPI.spanId(),
      );
      final span = OTelAPI.nonRecordingSpan(sc1);
      final context = Context.root.withSpan(span);

      final derived = context.withSpanContext(sc2);
      expect(derived.spanContext, equals(sc2));

      // The original context is unchanged.
      expect(context.spanContext, equals(sc1));
    });

    test('ContextKey exposes uniqueId and a descriptive toString', () {
      final key = OTelAPI.contextKey<String>('coverage-key');
      expect(key.uniqueId, isNotEmpty);
      expect(key.toString(), contains('coverage-key'));
    });
  });
}
