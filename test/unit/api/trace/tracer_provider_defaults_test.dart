// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APITracerProvider defaults handling', () {
    late APITracerProvider tracerProvider;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      tracerProvider = OTelAPI.tracerProvider();
    });

    test('applies all defaults when no optional parameters are provided', () {
      // Act
      final tracer = tracerProvider.getTracer('test-tracer');

      // Assert
      expect(tracer.name, equals('test-tracer'));
      expect(tracer.version,
          equals('1.11.0.0')); // Default version should be applied
      expect(tracer.schemaUrl,
          equals(OTelAPI.defaultSchemaUrl)); // Default schema should be applied
      expect(tracer.attributes, isNull);
    });

    test('does not apply defaults when version is provided', () {
      // Act
      final tracer =
          tracerProvider.getTracer('test-tracer', version: 'custom-version');

      // Assert
      expect(tracer.name, equals('test-tracer'));
      expect(
          tracer.version, equals('custom-version')); // Custom version preserved
      expect(tracer.schemaUrl, isNull); // No default schema
      expect(tracer.attributes, isNull);
    });

    test('does not apply defaults when schemaUrl is provided', () {
      // Act
      final tracer = tracerProvider.getTracer('test-tracer',
          schemaUrl: 'https://example.com/schema');

      // Assert
      expect(tracer.name, equals('test-tracer'));
      expect(tracer.version, isNull); // No default version
      expect(tracer.schemaUrl,
          equals('https://example.com/schema')); // Custom schema preserved
      expect(tracer.attributes, isNull);
    });

    test('does not apply defaults when attributes are provided', () {
      // Act
      final tracer = tracerProvider.getTracer('test-tracer',
          attributes: {'key': 'value'}.toAttributes());

      // Assert
      expect(tracer.name, equals('test-tracer'));
      expect(tracer.version, isNull); // No default version
      expect(tracer.schemaUrl, isNull); // No default schema
      expect(tracer.attributes, isNotNull);
      expect(tracer.attributes!.getString('key'), equals('value'));
    });

    test(
        'does not apply defaults when any combination of parameters is provided',
        () {
      // Act
      final tracer = tracerProvider.getTracer('test-tracer',
          version: 'custom-version',
          attributes: {'key': 'value'}.toAttributes());

      // Assert
      expect(tracer.name, equals('test-tracer'));
      expect(
          tracer.version, equals('custom-version')); // Custom version preserved
      expect(tracer.schemaUrl, isNull); // No default schema
      expect(tracer.attributes, isNotNull);
      expect(tracer.attributes!.getString('key'), equals('value'));
    });
  });
}
