// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

import '../../../test_util.dart';

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
      installSdkLikeFactory();

      // Store the original factory
      originalFactory = OTelFactory.otelFactory!;
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
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

    // The trace ID mismatch test was removed because we no longer throw on
    // mismatched trace IDs; instead we use precedence to resolve the parent
    // from the context.
  });
}
