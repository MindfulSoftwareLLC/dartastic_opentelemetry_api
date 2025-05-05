// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Span Links and Status', () {
    late APITracerProvider tracerProvider;
    late APITracer tracer;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      tracerProvider = OTelAPI.tracerProvider();
      // Use proper method signature
      tracer = tracerProvider.getTracer('test-tracer');
    });

    tearDown(() async {
      await tracerProvider.shutdown();
    });

    test('creates span with links at creation time', () {
      // Create two spans to link to
      final span1 = tracer.startSpan('span-1');
      final span2 = tracer.startSpan('span-2');

      final attributes = {'key': 'value'}.toAttributes();

      // Create a span with links to both spans
      final linkedSpan = tracer.startSpan(
        'linked-span',
        links: [
          OTelAPI.spanLink(span1.spanContext, attributes),
          OTelAPI.spanLink(span2.spanContext, attributes),
        ],
      );

      expect(linkedSpan.spanLinks, hasLength(2));
      expect(linkedSpan.spanLinks?.first.spanContext, equals(span1.spanContext));
      expect(linkedSpan.spanLinks?.last.spanContext, equals(span2.spanContext));
      expect(linkedSpan.spanLinks?.first.attributes.getString('key'), equals('value'));
    });

    test('adds links after span creation', () {
      final span1 = tracer.startSpan('span-1');
      final mainSpan = tracer.startSpan('main-span');

      final attributes = {'key': 'value'}.toAttributes();
      mainSpan.addLink(span1.spanContext, attributes);

      expect(mainSpan.spanLinks, hasLength(1));
      expect(mainSpan.spanLinks?.first.spanContext, equals(span1.spanContext));
      expect(mainSpan.spanLinks?.first.attributes.getString('key'), equals('value'));
    });

    test('preserves link order', () {
      final span1 = tracer.startSpan('span-1');
      final span2 = tracer.startSpan('span-2');
      final span3 = tracer.startSpan('span-3');

      final mainSpan = tracer.startSpan('main-span');
      mainSpan.addLink(span1.spanContext);
      mainSpan.addLink(span2.spanContext);
      mainSpan.addLink(span3.spanContext);

      expect(mainSpan.spanLinks, hasLength(3));
      expect(mainSpan.spanLinks?[0].spanContext, equals(span1.spanContext));
      expect(mainSpan.spanLinks?[1].spanContext, equals(span2.spanContext));
      expect(mainSpan.spanLinks?[2].spanContext, equals(span3.spanContext));
    });

    test('handles links with empty trace IDs or span IDs', () {
      final invalidContext = OTelAPI.spanContextInvalid();
      final attributes = {'key': 'value'}.toAttributes();

      // Should still record the link even with invalid context if attributes are present
      final span = tracer.startSpan(
        'test-span',
        links: [OTelAPI.spanLink(invalidContext, attributes)],
      );

      expect(span.spanLinks, hasLength(1));
      expect(span.spanLinks?.first.spanContext, equals(invalidContext));
      expect(span.spanLinks?.first.attributes.getString('key'), equals('value'));
    });

    test('isRecording behavior', () {
      final span = tracer.startSpan('test-span');
      expect(span.isRecording, isTrue);

      // After ending the span, it should become non-recording
      span.end();
      expect(span.isRecording, isFalse);

      // Operations after end should be ignored
      span.addEvent(OTelAPI.spanEvent('test-event'));
      span.setStatus(SpanStatusCode.Error);
      expect(span.spanEvents, isNull);
      expect(span.status, equals(SpanStatusCode.Ok)); // Status should remain unchanged
    });

    test('status setting rules', () {
      final span = tracer.startSpan('test-span');

      // Initial status should be unset
      expect(span.status, equals(SpanStatusCode.Unset));

      // Setting error status with description
      span.setStatus(SpanStatusCode.Error, 'Error occurred');
      expect(span.status, equals(SpanStatusCode.Error));
      expect(span.statusDescription, equals('Error occurred'));

      // Setting OK should override error status
      span.setStatus(SpanStatusCode.Ok);
      expect(span.status, equals(SpanStatusCode.Ok));
      expect(span.statusDescription, isNull);

      // Further attempts to set error should be ignored after OK
      span.setStatus(SpanStatusCode.Error, 'Another error');
      expect(span.status, equals(SpanStatusCode.Ok));
      expect(span.statusDescription, isNull);

      // Attempt to set unset should be ignored
      span.setStatus(SpanStatusCode.Unset);
      expect(span.status, equals(SpanStatusCode.Ok));
    });

    test('description only allowed with error status', () {
      final span = tracer.startSpan('test-span');

      // Description should be ignored for unset status
      span.setStatus(SpanStatusCode.Unset, 'Description');
      expect(span.statusDescription, isNull);

      // Description should be set for error status
      span.setStatus(SpanStatusCode.Error, 'Error Description');
      expect(span.statusDescription, equals('Error Description'));

      // Description should be ignored for OK status
      span.setStatus(SpanStatusCode.Ok, 'Description');
      expect(span.statusDescription, isNull);
    });
  });
}
