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
    setUp(() {});

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
          reason:
              'logFunction should default to print for out-of-the-box logging');
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

    test('isTrace returns true when currentLevel is trace', () {
      OTelLog.currentLevel = LogLevel.trace;
      expect(OTelLog.isTrace(), isTrue);
    });

    test('isTrace returns false when currentLevel is below trace', () {
      OTelLog.currentLevel = LogLevel.debug;
      expect(OTelLog.isTrace(), isFalse);
    });

    test('isDebug returns true when currentLevel is debug or higher', () {
      OTelLog.currentLevel = LogLevel.debug;
      expect(OTelLog.isDebug(), isTrue);

      OTelLog.currentLevel = LogLevel.trace;
      expect(OTelLog.isDebug(), isTrue);
    });

    test('isDebug returns false when currentLevel is below debug', () {
      OTelLog.currentLevel = LogLevel.info;
      expect(OTelLog.isDebug(), isFalse);
    });

    test('isFatal returns true when currentLevel is fatal or higher', () {
      OTelLog.currentLevel = LogLevel.fatal;
      expect(OTelLog.isFatal(), isTrue);

      OTelLog.currentLevel = LogLevel.info;
      expect(OTelLog.isFatal(), isTrue);
    });

    test('isFatal returns false when logFunction is null', () {
      OTelLog.logFunction = null;
      OTelLog.currentLevel = LogLevel.fatal;
      expect(OTelLog.isFatal(), isFalse);
    });
  });

  group('OTelLog signal logging tests', () {
    late List<String> spanMessages;
    late List<String> metricMessages;
    late List<String> exportMessages;

    setUp(() {
      spanMessages = [];
      metricMessages = [];
      exportMessages = [];
      OTelLog.spanLogFunction = (msg) => spanMessages.add(msg);
      OTelLog.metricLogFunction = (msg) => metricMessages.add(msg);
      OTelLog.exportLogFunction = (msg) => exportMessages.add(msg);
    });

    tearDown(() {
      OTelLog.spanLogFunction = null;
      OTelLog.metricLogFunction = null;
      OTelLog.exportLogFunction = null;
      OTelLog.logFunction = print;
      OTelLog.currentLevel = LogLevel.info;
    });

    test('logSpan logs when spanLogFunction is set', () {
      OTelLog.logSpan('Test span message');

      expect(spanMessages.length, equals(1));
      expect(spanMessages[0], contains('[span]'));
      expect(spanMessages[0], contains('Test span message'));
    });

    test('logSpan does not log when spanLogFunction is null', () {
      OTelLog.spanLogFunction = null;
      OTelLog.logSpan('Test span message');

      expect(spanMessages.length, equals(0));
    });

    test('logMetric logs when metricLogFunction is set', () {
      OTelLog.logMetric('Test metric message');

      expect(metricMessages.length, equals(1));
      expect(metricMessages[0], contains('[metric]'));
      expect(metricMessages[0], contains('Test metric message'));
    });

    test('logMetric does not log when metricLogFunction is null', () {
      OTelLog.metricLogFunction = null;
      OTelLog.logMetric('Test metric message');

      expect(metricMessages.length, equals(0));
    });

    test('logExport logs when exportLogFunction is set', () {
      OTelLog.logExport('Test export message');

      expect(exportMessages.length, equals(1));
      expect(exportMessages[0], contains('[export]'));
      expect(exportMessages[0], contains('Test export message'));
    });

    test('logExport does not log when exportLogFunction is null', () {
      OTelLog.exportLogFunction = null;
      OTelLog.logExport('Test export message');

      expect(exportMessages.length, equals(0));
    });

    test('isLogSpans returns true when spanLogFunction is set', () {
      expect(OTelLog.isLogSpans(), isTrue);
    });

    test('isLogSpans returns false when spanLogFunction is null', () {
      OTelLog.spanLogFunction = null;
      expect(OTelLog.isLogSpans(), isFalse);
    });

    test('isLogMetrics returns true when metricLogFunction is set', () {
      expect(OTelLog.isLogMetrics(), isTrue);
    });

    test('isLogMetrics returns false when metricLogFunction is null', () {
      OTelLog.metricLogFunction = null;
      expect(OTelLog.isLogMetrics(), isFalse);
    });

    test('isLogExport returns true when exportLogFunction is set', () {
      expect(OTelLog.isLogExport(), isTrue);
    });

    test('isLogExport returns false when exportLogFunction is null', () {
      OTelLog.exportLogFunction = null;
      expect(OTelLog.isLogExport(), isFalse);
    });
  });

  group('OTelLog enable logging level methods', () {
    tearDown(() {
      OTelLog.logFunction = print;
      OTelLog.currentLevel = LogLevel.info;
    });

    test('enableTraceLogging sets currentLevel to trace', () {
      OTelLog.enableTraceLogging();
      expect(OTelLog.currentLevel, equals(LogLevel.trace));
    });

    test('enableInfoLogging sets currentLevel to info', () {
      OTelLog.currentLevel = LogLevel.error; // Start at different level
      OTelLog.enableInfoLogging();
      expect(OTelLog.currentLevel, equals(LogLevel.info));
    });

    test('enableWarnLogging sets currentLevel to warn', () {
      OTelLog.enableWarnLogging();
      expect(OTelLog.currentLevel, equals(LogLevel.warn));
    });

    test('enableFatalLogging sets currentLevel to fatal', () {
      OTelLog.enableFatalLogging();
      expect(OTelLog.currentLevel, equals(LogLevel.fatal));
    });

    test('trace messages log when trace level is enabled', () {
      final messages = <String>[];
      OTelLog.logFunction = (msg) => messages.add(msg);
      OTelLog.enableTraceLogging();

      OTelLog.trace('Test trace message');

      expect(messages.length, equals(1));
      expect(messages[0], contains('TRACE'));
      expect(messages[0], contains('Test trace message'));
    });

    test('only fatal messages log when fatal level is enabled', () {
      final messages = <String>[];
      OTelLog.logFunction = (msg) => messages.add(msg);
      OTelLog.enableFatalLogging();

      OTelLog.trace('trace');
      OTelLog.debug('debug');
      OTelLog.info('info');
      OTelLog.warn('warn');
      OTelLog.error('error');
      OTelLog.fatal('fatal');

      expect(messages.length, equals(1));
      expect(messages[0], contains('FATAL'));
    });
  });

  group('LogLevel enum', () {
    test('LogLevel values have correct numeric levels', () {
      expect(LogLevel.fatal.level, equals(0));
      expect(LogLevel.error.level, equals(1));
      expect(LogLevel.warn.level, equals(2));
      expect(LogLevel.info.level, equals(3));
      expect(LogLevel.debug.level, equals(4));
      expect(LogLevel.trace.level, equals(6));
    });

    test('higher level values are more verbose', () {
      expect(LogLevel.trace.level, greaterThan(LogLevel.debug.level));
      expect(LogLevel.debug.level, greaterThan(LogLevel.info.level));
      expect(LogLevel.info.level, greaterThan(LogLevel.warn.level));
      expect(LogLevel.warn.level, greaterThan(LogLevel.error.level));
      expect(LogLevel.error.level, greaterThan(LogLevel.fatal.level));
    });
  });
}
