// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Coverage for Context.withSpanContext trace-change rejection and the
// ContextKey uniqueId/toString surface.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Context API surface', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('withSpanContext rejects changing the trace ID', () {
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

      expect(
        () => context.withSpanContext(sc2),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Cannot change trace ID'),
        )),
      );
    });

    test('ContextKey exposes uniqueId and a descriptive toString', () {
      final key = OTelAPI.contextKey<String>('coverage-key');
      expect(key.uniqueId, isNotEmpty);
      expect(key.toString(), contains('coverage-key'));
    });
  });
}
