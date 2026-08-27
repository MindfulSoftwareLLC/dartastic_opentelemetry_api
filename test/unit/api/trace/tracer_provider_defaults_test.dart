// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

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

    test(
        'does not invent a scope version or schema URL when no optional '
        'parameters are provided', () {
      // Act
      final tracer = tracerProvider.getTracer('test-tracer');

      // Assert
      expect(tracer.name, equals('test-tracer'));
      // The caller stated no version or schema URL, so the API must not
      // report the package's own version constant or a fabricated schema.
      expect(tracer.version, isNull);
      expect(tracer.schemaUrl, isNull);
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

    test(
        'a tracer requested with only attributes is distinct only in '
        'attributes, not in an invented version/schemaUrl', () {
      final bare = tracerProvider.getTracer('same-name');
      final withAttrs = tracerProvider.getTracer('same-name',
          attributes: {'key': 'value'}.toAttributes());

      expect(bare.version, isNull);
      expect(withAttrs.version, isNull);
      expect(bare.schemaUrl, isNull);
      expect(withAttrs.schemaUrl, isNull);
      expect(identical(bare, withAttrs), isFalse);
    });

    test(
        'a span from a tracer with no version does not report an invented '
        'instrumentation scope version', () {
      final tracer = tracerProvider.getTracer('test-tracer');
      final span = tracer.startSpan('test-span');

      expect(span.instrumentationScope.version, isNull);
      expect(span.instrumentationScope.schemaUrl, isNull);
    });
  });
}
