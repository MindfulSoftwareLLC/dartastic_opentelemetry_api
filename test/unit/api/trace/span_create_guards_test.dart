// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// APISpanCreate / SpanLinkCreate guard coverage. The public tracer path
// pre-validates (throwing its own trace-mismatch error) and
// auto-corrects parent span IDs, so these internal guards can only fire
// for direct SDK-style calls — which is exactly how they are exercised
// here.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:dartastic_opentelemetry_api/src/api/trace/span.dart';
import 'package:dartastic_opentelemetry_api/src/api/trace/span_link.dart';
import 'package:test/test.dart';

import '../../../test_util.dart';

void main() {
  group('APISpanCreate guards', () {
    late OTelFactory originalFactory;
    late APITracer tracer;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      installSdkLikeFactory();
      originalFactory = OTelFactory.otelFactory!;
      tracer = OTelAPI.tracer('guards-tracer');
    });

    tearDown(() {
      OTelFactory.otelFactory = originalFactory;
    });

    test('child span must inherit the parent trace ID', () {
      final parent = tracer.createSpan(name: 'parent');
      final foreignTrace = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(), // different trace
        spanId: OTelAPI.spanId(),
        parentSpanId: parent.spanContext.spanId,
      );
      expect(
        () => APISpanCreate.create(
          name: 'child',
          spanContext: foreignTrace,
          parentSpan: parent,
          instrumentationScope: parent.instrumentationScope,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('inherit trace ID'),
        )),
      );
    });

    test('child span must reference the parent span ID', () {
      final parent = tracer.createSpan(name: 'parent');
      final wrongParentId = OTelAPI.spanContext(
        traceId: parent.spanContext.traceId,
        spanId: OTelAPI.spanId(),
        parentSpanId: OTelAPI.spanId(), // not the parent's span ID
      );
      expect(
        () => APISpanCreate.create(
          name: 'child',
          spanContext: wrongParentId,
          parentSpan: parent,
          instrumentationScope: parent.instrumentationScope,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('reference parent span ID'),
        )),
      );
    });

    test('create throws StateError once the factory is gone', () {
      final parent = tracer.createSpan(name: 'parent');
      final scope = parent.instrumentationScope;
      final sc = parent.spanContext;
      OTelAPI.reset();

      expect(
        () => APISpanCreate.create(
          name: 'late',
          spanContext: sc,
          parentSpan: null,
          instrumentationScope: scope,
        ),
        throwsStateError,
      );
      expect(
        () => SpanLinkCreate.create(spanContext: sc),
        throwsStateError,
      );
    });
  });
}
