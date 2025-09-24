// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/common/attributes.dart';
import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:dartastic_opentelemetry_api/src/api/trace/span.dart';
import 'package:dartastic_opentelemetry_api/src/api/trace/tracer.dart';
import 'package:dartastic_opentelemetry_api/src/api/trace/tracer_provider.dart';
import 'package:test/test.dart';

void main() {
  group('Span Exception Handling', () {
    late APITracerProvider tracerProvider;
    late APITracer tracer;
    late APISpan span;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      tracerProvider = OTelAPI.tracerProvider();
      tracer = tracerProvider.getTracer('test-tracer');
      span = tracer.startSpan('test-span');
    });

    tearDown(() async {
      await tracerProvider.shutdown();
    });

    test('records exception with minimum attributes', () {
      final exception = Exception('Test error');
      span.recordException(exception);

      final events = span.spanEvents;
      expect(events, hasLength(1));
      expect(events?.first.name, equals('exception'));

      final attrs = events?.first.attributes?.toMap() ?? {};
      expect(attrs['exception.type']?.value, contains('Exception'));
      expect(
          attrs['exception.message']?.value, equals('Exception: Test error'));
    });

    test('records exception with stack trace', () {
      try {
        throw Exception('Test error with stack');
      } catch (e, stackTrace) {
        span.recordException(e, stackTrace: stackTrace);
      }

      final events = span.spanEvents;
      expect(events, hasLength(1));

      final attrs = events?.first.attributes?.toMap() ?? {};
      expect(attrs['exception.stacktrace']?.value, isNotNull);
      expect(attrs['exception.stacktrace']?.value.toString(),
          contains('test/unit/api/trace/span_exception_test.dart'));
    });

    test('records exception with escaped flag', () {
      final exception = Exception('Test error');
      span.recordException(exception, escaped: true);

      final events = span.spanEvents;
      final attrs = events?.first.attributes?.toMap() ?? {};
      expect(attrs['exception.escaped']?.value, true);
    });

    test('records exception with additional attributes', () {
      final exception = Exception('Test error');
      final additionalAttrs = {
        'custom.attribute': 'value',
      }.toAttributes();

      span.recordException(exception, attributes: additionalAttrs);

      final events = span.spanEvents;
      final attrs = events?.first.attributes?.toMap() ?? {};
      expect(attrs['custom.attribute']?.value, equals('value'));
      expect(attrs['exception.type']?.value, contains('Exception'));
      expect(
          attrs['exception.message']?.value, equals('Exception: Test error'));
    });

    test('additional attributes override default exception attributes', () {
      final exception = Exception('Test error');
      final overrideAttrs = {
        'exception.type': 'CustomType',
        'exception.message': 'Custom message',
      }.toAttributes();

      span.recordException(exception, attributes: overrideAttrs);

      final events = span.spanEvents;
      final attrs = events?.first.attributes?.toMap() ?? {};
      expect(attrs['exception.type']?.value, equals('CustomType'));
      expect(attrs['exception.message']?.value, equals('Custom message'));
    });

    test('handles exceptions after span is ended', () {
      span.end();
      final exception = Exception('Test error');
      span.recordException(exception);

      // Should not record the exception since span is ended
      expect(span.spanEvents, isNull);
    });

    test('records multiple exceptions', () {
      span.recordException(Exception('Error 1'));
      span.recordException(Exception('Error 2'));

      final events = span.spanEvents;
      expect(events, hasLength(2));
      expect(events?[0].attributes?.toMap()['exception.message']?.value,
          equals('Exception: Error 1'));
      expect(events?[1].attributes?.toMap()['exception.message']?.value,
          equals('Exception: Error 2'));
    });

    test('handles error status with recordException', () {
      // First verify span starts with unset status
      expect(span.status, equals(SpanStatusCode.Unset));

      final exception = Exception('Test error');
      span.recordException(exception);

      // recordException should not automatically set error status
      // This is left to the specific semantic conventions
      expect(span.status, equals(SpanStatusCode.Unset));
    });
  });
}
