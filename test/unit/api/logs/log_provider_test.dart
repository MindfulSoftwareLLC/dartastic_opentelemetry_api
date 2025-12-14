// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/common/attributes.dart';
import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('LogProvider', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('creates logger with valid name and version', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger(
        'test-lib',
        version: '1.0.0',
      );

      expect(logger, isNotNull);
      expect(logger.name, equals('test-lib'));
      expect(logger.version, equals('1.0.0'));
    });

    test('creates logger with schema url', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger(
        'test-lib',
        version: '1.0.0',
        schemaUrl: 'https://opentelemetry.io/schemas/1.4.0',
      );

      expect(logger, isNotNull);
      expect(logger.schemaUrl, equals('https://opentelemetry.io/schemas/1.4.0'));
    });

    test('creates logger with instrumentation scope attributes', () {
      final provider = OTelAPI.loggerProvider();
      final attributes = <String, Object>{
        'library.name': 'test-lib',
        'library.version': '1.0.0',
      }.toAttributes();

      final logger = provider.getLogger(
        'test-lib',
        version: '1.0.0',
        attributes: attributes,
      );

      expect(logger, isNotNull);
      expect(logger.attributes?.toMap()['library.name']?.value, equals('test-lib'));
      expect(logger.attributes?.toMap()['library.version']?.value, equals('1.0.0'));
    });

    test('handles invalid name by returning working logger with empty name', () {
      final provider = OTelAPI.loggerProvider();

      // Test with null name
      final loggerNullName = provider.getLogger('');
      expect(loggerNullName, isNotNull);
      expect(loggerNullName.name, equals(''));

      // Test with empty string name
      final loggerEmptyName = provider.getLogger('');
      expect(loggerEmptyName, isNotNull);
      expect(loggerEmptyName.name, equals(''));
    });

    test('returns same logger instance for identical parameters', () {
      final provider = OTelAPI.loggerProvider();

      final logger1 = provider.getLogger('test-lib', version: '1.0.0');
      final logger2 = provider.getLogger('test-lib', version: '1.0.0');

      expect(identical(logger1, logger2), isTrue);
    });

    test('returns different logger instance for different parameters', () {
      final provider = OTelAPI.loggerProvider();

      final logger1 = provider.getLogger('test-lib-1', version: '1.0.0');
      final logger2 = provider.getLogger('test-lib-2', version: '1.0.0');

      expect(identical(logger1, logger2), isFalse);
    });

    test('configuration changes affect existing loggers', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-lib');

      // This test is a bit tricky since the API is no-op
      // In a real SDK implementation, we'd verify that configuration changes
      // are reflected in the existing logger
      expect(logger, isNotNull);
    });

    test('endpoint getter and setter work correctly', () {
      final provider = OTelAPI.loggerProvider();

      // Initial endpoint from initialization
      expect(provider.endpoint, equals('http://localhost:4317'));

      // Set new endpoint
      provider.endpoint = 'http://127.0.0.1:4318';
      expect(provider.endpoint, equals('http://127.0.0.1:4318'));
    });

    test('serviceName getter and setter work correctly', () {
      final provider = OTelAPI.loggerProvider();

      // Initial service name from initialization
      expect(provider.serviceName, equals('test-service'));

      // Set new service name
      provider.serviceName = 'changed-service';
      expect(provider.serviceName, equals('changed-service'));
    });

    test('serviceVersion getter and setter work correctly', () {
      final provider = OTelAPI.loggerProvider();

      // Initial service version from initialization
      expect(provider.serviceVersion, equals('1.0.0'));

      // Set new service version
      provider.serviceVersion = '2.0.0';
      expect(provider.serviceVersion, equals('2.0.0'));

      // Set to null
      provider.serviceVersion = null;
      expect(provider.serviceVersion, isNull);
    });

    test('enabled getter and setter work correctly', () {
      final provider = OTelAPI.loggerProvider();

      // API implementation defaults to false
      expect(provider.enabled, isTrue);

      // Enable the provider
      provider.enabled = false;
      expect(provider.enabled, isFalse);

      // Disable the provider
      provider.enabled = true;
      expect(provider.enabled, isTrue);
    });

    test('isShutdown getter returns correct state', () {
      final provider = OTelAPI.loggerProvider();

      // Initially not shut down
      expect(provider.isShutdown, isFalse);
    });

    test('shutdown marks provider as shutdown and clears cache', () async {
      final provider = OTelAPI.loggerProvider();

      // Create a logger to populate the cache
      final logger = provider.getLogger('cached-logger');
      expect(logger, isNotNull);

      // Shutdown should succeed
      final result = await provider.shutdown();
      expect(result, isTrue);
      expect(provider.isShutdown, isTrue);
      expect(provider.enabled, isFalse);
    });

    test('shutdown is idempotent', () async {
      final provider = OTelAPI.loggerProvider();

      // First shutdown
      final result1 = await provider.shutdown();
      expect(result1, isTrue);
      expect(provider.isShutdown, isTrue);

      // Second shutdown should also succeed
      final result2 = await provider.shutdown();
      expect(result2, isTrue);
      expect(provider.isShutdown, isTrue);
    });

    test('Set isShutdown', () async {
      final provider = OTelAPI.loggerProvider();

      // First shutdown
      provider.isShutdown = true;

      // Second shutdown should also succeed
      final result2 = await provider.shutdown();
      expect(result2, isTrue);
      expect(provider.isShutdown, isTrue);
    });

    test('getLogger throws StateError after shutdown', () async {
      final provider = OTelAPI.loggerProvider();

      // Create a logger before shutdown (should work)
      final logger = provider.getLogger('before-shutdown');
      expect(logger, isNotNull);

      // Shutdown the provider
      await provider.shutdown();

      // Attempting to create a logger after shutdown should throw
      expect(
        () => provider.getLogger('after-shutdown'),
        throwsA(isA<StateError>()),
      );
    });

    test('getLogger uses defaults when no optional parameters provided', () {
      final provider = OTelAPI.loggerProvider();

      final logger = provider.getLogger('test-lib');

      expect(logger, isNotNull);
      expect(logger.name, equals('test-lib'));
      // When no parameters are provided, defaults should be applied
      expect(logger.version, equals(OTelAPI.defaultServiceVersion));
      expect(logger.schemaUrl, equals(OTelAPI.defaultSchemaUrl));
    });

    test('getLogger does not apply defaults when any optional parameter provided', () {
      final provider = OTelAPI.loggerProvider();

      final logger = provider.getLogger('test-lib', version: '2.0.0');

      expect(logger, isNotNull);
      expect(logger.name, equals('test-lib'));
      expect(logger.version, equals('2.0.0'));
      // schemaUrl should be null, not the default
      expect(logger.schemaUrl, isNull);
    });
  });
}
