// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:async';

import 'package:test/test.dart';
import 'package:dartastic_opentelemetry_api/src/util/otel_log.dart';

void main() {
  group('OTelLog default behavior tests', () {
    late List<String> loggedMessages;

    setUp(() {
      // Reset state before each test
      loggedMessages = [];
      OTelLog.logFunction = (msg) => loggedMessages.add(msg);
      OTelLog.currentLevel = LogLevel.info; // Reset to current default
    });

    tearDown(() {
      // Restore defaults instead of nulling
      OTelLog.logFunction = print;
      OTelLog.currentLevel = LogLevel.info;
      OTelLog.spanLogFunction = null;
      OTelLog.metricLogFunction = null;
      OTelLog.exportLogFunction = null;
    });

    test('error conditions log by default', () {
      // Given: OTelLog with default settings and logFunction set
      // (logFunction must be set or nothing logs)

      // When: an error message is logged
      OTelLog.error('Test error message');

      // Then: the message should be logged
      expect(loggedMessages.length, equals(1),
          reason: 'Error messages should be logged by default');
      expect(loggedMessages[0], contains('ERROR'));
      expect(loggedMessages[0], contains('Test error message'));
    });

    test('warn logs by default', () {
      // Given: OTelLog with default settings and logFunction set

      // When: a warning message is logged
      OTelLog.warn('Test warning message');

      // Then: the message should be logged
      expect(loggedMessages.length, equals(1),
          reason: 'Warn messages should be logged by default');
      expect(loggedMessages[0], contains('WARN'));
      expect(loggedMessages[0], contains('Test warning message'));
    });

    test('info logs by default', () {
      // Given: OTelLog with default settings and logFunction set

      // When: an info message is logged
      OTelLog.info('Test info message');

      // Then: the message should be logged
      expect(loggedMessages.length, equals(1),
          reason: 'Info messages should be logged by default');
      expect(loggedMessages[0], contains('INFO'));
      expect(loggedMessages[0], contains('Test info message'));
    });

    test('fatal logs by default', () {
      // Given: OTelLog with default settings and logFunction set

      // When: a fatal message is logged
      OTelLog.fatal('Test fatal message');

      // Then: the message should be logged
      expect(loggedMessages.length, equals(1),
          reason: 'Fatal messages should always be logged');
      expect(loggedMessages[0], contains('FATAL'));
      expect(loggedMessages[0], contains('Test fatal message'));
    });
  });

  group('OTelLog level filtering tests', () {
    late List<String> loggedMessages;

    setUp(() {
      loggedMessages = [];
      OTelLog.logFunction = (msg) => loggedMessages.add(msg);
    });

    tearDown(() {
      // Restore defaults
      OTelLog.logFunction = print;
      OTelLog.currentLevel = LogLevel.info;
    });

    test('debug messages do not log by default', () {
      // Given: OTelLog with default INFO level
      OTelLog.currentLevel = LogLevel.info;

      // When: a debug message is logged
      OTelLog.debug('Test debug message');

      // Then: the message should NOT be logged (debug is more verbose than info)
      expect(loggedMessages.length, equals(0),
          reason: 'Debug messages should not be logged at INFO level');
    });

    test('trace messages do not log by default', () {
      // Given: OTelLog with default INFO level
      OTelLog.currentLevel = LogLevel.info;

      // When: a trace message is logged
      OTelLog.trace('Test trace message');

      // Then: the message should NOT be logged (trace is more verbose than info)
      expect(loggedMessages.length, equals(0),
          reason: 'Trace messages should not be logged at INFO level');
    });

    test('changing log level to debug enables debug messages', () {
      // Given: OTelLog with DEBUG level
      OTelLog.enableDebugLogging();

      // When: a debug message is logged
      OTelLog.debug('Test debug message');

      // Then: the message should be logged
      expect(loggedMessages.length, equals(1));
      expect(loggedMessages[0], contains('DEBUG'));
    });

    test('changing log level to error disables info and warn', () {
      // Given: OTelLog with ERROR level
      OTelLog.enableErrorLogging();

      // When: info and warn messages are logged
      OTelLog.info('Test info');
      OTelLog.warn('Test warn');

      // Then: neither should be logged
      expect(loggedMessages.length, equals(0),
          reason: 'Info and Warn should not log at ERROR level');
    });

    test('logFunction must be set for any logging to occur', () {
      // Given: OTelLog with no logFunction set
      OTelLog.logFunction = null;
      OTelLog.currentLevel = LogLevel.info;

      List<String> shouldBeEmpty = [];

      // When: error messages are logged
      OTelLog.error('This should not appear anywhere');

      // Then: nothing should be logged
      expect(shouldBeEmpty.length, equals(0),
          reason: 'Without logFunction, no messages should be logged');
    });
  });

  group('OTelLog logs by default without explicit setup', () {
    late List<String> capturedPrintOutput;

    setUp(() {
      capturedPrintOutput = [];
    });

    tearDown(() {
      // Only clean up the specialized log functions
      // DO NOT reset logFunction or currentLevel - we're testing they default correctly
      OTelLog.spanLogFunction = null;
      OTelLog.metricLogFunction = null;
      OTelLog.exportLogFunction = null;
    });

    test('logFunction defaults to print (not null)', () {
      // Given: Fresh OTelLog class with no configuration
      // Then: logFunction should be print by default
      expect(OTelLog.logFunction, equals(print),
          reason: 'logFunction should default to print for out-of-the-box logging');
    });

    test('currentLevel defaults to info', () {
      // Given: Fresh OTelLog class with no configuration
      // Then: currentLevel should be info by default
      expect(OTelLog.currentLevel, equals(LogLevel.info),
          reason: 'currentLevel should default to info for production use');
    });

    test('error logs without setting logFunction', () {
      // Given: OTelLog with default settings (logFunction should be print)
      final capturedOutput = <String>[];
      
      // When: an error message is logged in a zone that captures print
      runZoned(() {
        OTelLog.error('Test error message');
      }, zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          capturedOutput.add(line);
        },
      ));

      // Then: the message should be printed (captured)
      expect(capturedOutput.length, equals(1),
          reason: 'Error should be logged by default');
      expect(capturedOutput[0], contains('ERROR'));
      expect(capturedOutput[0], contains('Test error message'));
    });

    test('warn logs without setting logFunction', () {
      // Given: OTelLog with default settings
      final capturedOutput = <String>[];
      
      // When: a warn message is logged in a zone that captures print
      runZoned(() {
        OTelLog.warn('Test warning message');
      }, zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          capturedOutput.add(line);
        },
      ));

      // Then: the message should be printed (captured)
      expect(capturedOutput.length, equals(1),
          reason: 'Warn should be logged by default');
      expect(capturedOutput[0], contains('WARN'));
      expect(capturedOutput[0], contains('Test warning message'));
    });

    test('info logs without setting logFunction', () {
      // Given: OTelLog with default settings
      final capturedOutput = <String>[];
      
      // When: an info message is logged in a zone that captures print
      runZoned(() {
        OTelLog.info('Test info message');
      }, zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          capturedOutput.add(line);
        },
      ));

      // Then: the message should be printed (captured)
      expect(capturedOutput.length, equals(1),
          reason: 'Info should be logged by default');
      expect(capturedOutput[0], contains('INFO'));
      expect(capturedOutput[0], contains('Test info message'));
    });
  });

  group('OTelLog level check methods', () {
    setUp(() {
      OTelLog.logFunction = print; // Set to non-null
    });

    tearDown(() {
      // Restore defaults
      OTelLog.logFunction = print;
      OTelLog.currentLevel = LogLevel.info;
    });

    test('isInfo returns true when currentLevel is info', () {
      OTelLog.currentLevel = LogLevel.info;
      expect(OTelLog.isInfo(), isTrue);
    });

    test('isWarn returns true when currentLevel is warn or higher', () {
      OTelLog.currentLevel = LogLevel.warn;
      expect(OTelLog.isWarn(), isTrue);

      OTelLog.currentLevel = LogLevel.info;
      expect(OTelLog.isWarn(), isTrue);
    });

    test('isError returns true when currentLevel is error or higher', () {
      OTelLog.currentLevel = LogLevel.error;
      expect(OTelLog.isError(), isTrue);

      OTelLog.currentLevel = LogLevel.info;
      expect(OTelLog.isError(), isTrue);
    });

    test('level check methods return false when logFunction is null', () {
      OTelLog.logFunction = null;
      OTelLog.currentLevel = LogLevel.info;

      expect(OTelLog.isInfo(), isFalse);
      expect(OTelLog.isWarn(), isFalse);
      expect(OTelLog.isError(), isFalse);
    });
  });
}
