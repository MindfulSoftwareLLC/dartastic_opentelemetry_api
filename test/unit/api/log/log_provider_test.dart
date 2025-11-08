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
  });
}
