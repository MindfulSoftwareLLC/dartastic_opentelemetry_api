// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIMeterProvider defaults handling', () {
    late APIMeterProvider meterProvider;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      meterProvider = OTelAPI.meterProvider();
    });

    test('applies all defaults when no optional parameters are provided', () {
      // Act
      final meter = meterProvider.getMeter(name: 'test-meter');

      // Assert
      expect(meter.name, equals('test-meter'));
      expect(meter.version,
          equals('1.11.0.0')); // Default version should be applied
      expect(
          meter.schemaUrl,
          equals(
              'https://opentelemetry.io/schemas/1.11.0')); // Default schema should be applied
      expect(meter.attributes, isNull);
    });

    test('does not apply defaults when version is provided', () {
      // Act
      final meter =
          meterProvider.getMeter(name: 'test-meter', version: 'custom-version');

      // Assert
      expect(meter.name, equals('test-meter'));
      expect(
          meter.version, equals('custom-version')); // Custom version preserved
      expect(meter.schemaUrl, isNull); // No default schema
      expect(meter.attributes, isNull);
    });

    test('does not apply defaults when schemaUrl is provided', () {
      // Act
      final meter = meterProvider.getMeter(
          name: 'test-meter', schemaUrl: 'https://example.com/schema');

      // Assert
      expect(meter.name, equals('test-meter'));
      expect(meter.version, isNull); // No default version
      expect(meter.schemaUrl,
          equals('https://example.com/schema')); // Custom schema preserved
      expect(meter.attributes, isNull);
    });

    test('does not apply defaults when attributes are provided', () {
      // Act
      final meter = meterProvider.getMeter(
          name: 'test-meter', attributes: {'key': 'value'}.toAttributes());

      // Assert
      expect(meter.name, equals('test-meter'));
      expect(meter.version, isNull); // No default version
      expect(meter.schemaUrl, isNull); // No default schema
      expect(meter.attributes, isNotNull);
      expect(meter.attributes!.getString('key'), equals('value'));
    });

    test(
        'does not apply defaults when any combination of parameters is provided',
        () {
      // Act
      final meter = meterProvider.getMeter(
          name: 'test-meter',
          version: 'custom-version',
          attributes: {'key': 'value'}.toAttributes());

      // Assert
      expect(meter.name, equals('test-meter'));
      expect(
          meter.version, equals('custom-version')); // Custom version preserved
      expect(meter.schemaUrl, isNull); // No default schema
      expect(meter.attributes, isNotNull);
      expect(meter.attributes!.getString('key'), equals('value'));
    });

    test('meterProvider returns existing named provider', () {
      final name = 'test-meter-provider';

      // Create a named provider
      final provider1 = OTelAPI.addMeterProvider(name);

      // Get the same provider by name
      final provider2 = OTelAPI.meterProvider(name);

      expect(provider2, same(provider1));
    });
  });
}
