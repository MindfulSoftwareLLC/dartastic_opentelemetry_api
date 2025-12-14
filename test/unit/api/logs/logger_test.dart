// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APILogger', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('creates logger with name', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(logger, isNotNull);
      expect(logger.name, equals('test-logger'));
      expect(logger.version, isNotNull);
      expect(logger.schemaUrl, isNotNull);
      expect(logger.attributes, isNull);
    });

    test('creates logger with name and version', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger(
        'test-logger',
        version: '1.2.3',
      );

      expect(logger, isNotNull);
      expect(logger.name, equals('test-logger'));
      expect(logger.version, equals('1.2.3'));
    });

    test('creates logger with name, version, and schemaUrl', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger(
        'test-logger',
        version: '1.2.3',
        schemaUrl: 'https://opentelemetry.io/schemas/1.4.0',
      );

      expect(logger, isNotNull);
      expect(logger.name, equals('test-logger'));
      expect(logger.version, equals('1.2.3'));
      expect(
          logger.schemaUrl, equals('https://opentelemetry.io/schemas/1.4.0'));
    });

    test('creates logger with attributes', () {
      final provider = OTelAPI.loggerProvider();
      final attributes = Attributes.of({
        'library.name': 'test-logger',
        'library.language': 'dart',
      });

      final logger = provider.getLogger(
        'test-logger',
        version: '1.2.3',
        attributes: attributes,
      );

      expect(logger, isNotNull);
      expect(logger.attributes, isNotNull);
      expect(logger.attributes?.toMap()['library.name']?.value,
          equals('test-logger'));
      expect(logger.attributes?.toMap()['library.language']?.value,
          equals('dart'));
    });

    test('enabled returns false for API logger', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      // API logger is always disabled (no-op)
      expect(logger.enabled, isFalse);
    });

    test('emit does not throw with minimal parameters', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      // Should not throw - it's a no-op
      expect(() => logger.emit(), returnsNormally);
    });

    test('emit does not throw with body', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(() => logger.emit(body: 'test log message'), returnsNormally);
    });

    test('emit does not throw with severity', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(
        () => logger.emit(
          severityNumber: Severity.INFO,
          severityText: 'INFO',
        ),
        returnsNormally,
      );
    });

    test('emit does not throw with timestamp', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final now = DateTime.now();

      expect(
        () => logger.emit(
          timeStamp: now,
          observedTimestamp: now,
        ),
        returnsNormally,
      );
    });

    test('emit does not throw with context', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final context = Context.current;

      expect(
        () => logger.emit(context: context),
        returnsNormally,
      );
    });

    test('emit does not throw with attributes', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final attributes = Attributes.of({
        'key1': 'value1',
        'key2': 123,
      });

      expect(
        () => logger.emit(attributes: attributes),
        returnsNormally,
      );
    });

    test('emit does not throw with event name', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(
        () => logger.emit(eventName: 'test.event'),
        returnsNormally,
      );
    });

    test('emit does not throw with all parameters', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final now = DateTime.now();
      final context = Context.current;
      final attributes = Attributes.of({
        'key1': 'value1',
        'key2': 123,
        'key3': true,
      });

      expect(
        () => logger.emit(
          timeStamp: now,
          observedTimestamp: now,
          context: context,
          severityNumber: Severity.WARN,
          severityText: 'WARN',
          body: 'This is a warning message',
          attributes: attributes,
          eventName: 'test.warning.event',
        ),
        returnsNormally,
      );
    });

    test('emit accepts different body types', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      // String body
      expect(() => logger.emit(body: 'string message'), returnsNormally);

      // Number body
      expect(() => logger.emit(body: 42), returnsNormally);

      // Boolean body
      expect(() => logger.emit(body: true), returnsNormally);

      // Map body
      expect(() => logger.emit(body: {'key': 'value'}), returnsNormally);

      // List body
      expect(() => logger.emit(body: ['item1', 'item2']), returnsNormally);
    });

    test('emit with different severity levels', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(
          () => logger.emit(severityNumber: Severity.TRACE), returnsNormally);
      expect(
          () => logger.emit(severityNumber: Severity.DEBUG), returnsNormally);
      expect(() => logger.emit(severityNumber: Severity.INFO), returnsNormally);
      expect(() => logger.emit(severityNumber: Severity.WARN), returnsNormally);
      expect(
          () => logger.emit(severityNumber: Severity.ERROR), returnsNormally);
      expect(
          () => logger.emit(severityNumber: Severity.FATAL), returnsNormally);
    });

    test('multiple emit calls do not interfere', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(
        () {
          logger.emit(body: 'message 1', severityNumber: Severity.INFO);
          logger.emit(body: 'message 2', severityNumber: Severity.WARN);
          logger.emit(body: 'message 3', severityNumber: Severity.ERROR);
        },
        returnsNormally,
      );
    });
  });
}
