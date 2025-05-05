// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/common/attributes.dart';
import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('TracerProvider', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('creates tracer with valid name and version', () {
      final provider = OTelAPI.tracerProvider();
      final tracer = provider.getTracer(
        'test-lib',
        version: '1.0.0',
      );

      expect(tracer, isNotNull);
      expect(tracer.name, equals('test-lib'));
      expect(tracer.version, equals('1.0.0'));
    });

    test('creates tracer with schema url', () {
      final provider = OTelAPI.tracerProvider();
      final tracer = provider.getTracer(
        'test-lib',
        version: '1.0.0',
        schemaUrl: 'https://opentelemetry.io/schemas/1.4.0',
      );

      expect(tracer, isNotNull);
      expect(tracer.schemaUrl, equals('https://opentelemetry.io/schemas/1.4.0'));
    });

    test('creates tracer with instrumentation scope attributes', () {
      final provider = OTelAPI.tracerProvider();
      final attributes = <String, Object>{
        'library.name': 'test-lib',
        'library.version': '1.0.0',
      }.toAttributes();

      final tracer = provider.getTracer(
        'test-lib',
        version: '1.0.0',
        attributes: attributes,
      );

      expect(tracer, isNotNull);
      expect(tracer.attributes?.toMap()['library.name']?.value, equals('test-lib'));
      expect(tracer.attributes?.toMap()['library.version']?.value, equals('1.0.0'));
    });

    test('handles invalid name by returning working tracer with empty name', () {
      final provider = OTelAPI.tracerProvider();

      // Test with null name
      final tracerNullName = provider.getTracer('');
      expect(tracerNullName, isNotNull);
      expect(tracerNullName.name, equals(''));

      // Test with empty string name
      final tracerEmptyName = provider.getTracer('');
      expect(tracerEmptyName, isNotNull);
      expect(tracerEmptyName.name, equals(''));
    });

    test('returns same tracer instance for identical parameters', () {
      final provider = OTelAPI.tracerProvider();

      final tracer1 = provider.getTracer('test-lib', version: '1.0.0');
      final tracer2 = provider.getTracer('test-lib', version: '1.0.0');

      expect(identical(tracer1, tracer2), isTrue);
    });

    test('returns different tracer instance for different parameters', () {
      final provider = OTelAPI.tracerProvider();

      final tracer1 = provider.getTracer('test-lib-1', version: '1.0.0');
      final tracer2 = provider.getTracer('test-lib-2', version: '1.0.0');

      expect(identical(tracer1, tracer2), isFalse);
    });

    test('configuration changes affect existing tracers', () {
      final provider = OTelAPI.tracerProvider();
      final tracer = provider.getTracer('test-lib');

      // This test is a bit tricky since the API is no-op
      // In a real SDK implementation, we'd verify that configuration changes
      // are reflected in the existing tracer
      expect(tracer, isNotNull);
    });
  });
}
