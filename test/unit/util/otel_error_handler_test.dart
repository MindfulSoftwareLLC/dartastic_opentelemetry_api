// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Spec-compliance tests for the global error handler
// (error-handling.md, "Configuring Error Handlers"):
//
// > SDK implementations MUST allow end users to change the library's
// > default error handling behavior for relevant errors.
//
// and for self-diagnostics:
//
// > Whenever the library suppresses an error that would otherwise have
// > been exposed to the user, the library SHOULD log the error using
// > language-specific conventions.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('OTelErrorHandling', () {
    late List<String> loggedMessages;

    setUp(() {
      loggedMessages = [];
      OTelLog.logFunction = (msg) => loggedMessages.add(msg);
      OTelLog.currentLevel = LogLevel.error;
      OTelErrorHandling.resetToDefault();
    });

    tearDown(() {
      OTelLog.logFunction = print;
      OTelLog.currentLevel = LogLevel.info;
      OTelErrorHandling.resetToDefault();
    });

    test('default handler logs the error through OTelLog', () {
      OTelErrorHandling.report(ArgumentError('bad input'));

      expect(loggedMessages.length, equals(1));
      expect(loggedMessages[0], contains('ERROR'));
      expect(loggedMessages[0], contains('bad input'));
    });

    test('default handler logs the stack trace when one is given', () {
      OTelErrorHandling.report(
          StateError('broken'), StackTrace.fromString('fake stack'));

      expect(loggedMessages.length, equals(2));
      expect(loggedMessages[0], contains('broken'));
      expect(loggedMessages[1], contains('Stack trace: fake stack'));
    });

    test('a user-installed handler receives reported errors', () {
      final received = <Object>[];
      final stacks = <StackTrace?>[];
      OTelErrorHandling.handler = (error, stackTrace) {
        received.add(error);
        stacks.add(stackTrace);
      };

      final error = ArgumentError('invalid attribute');
      final stack = StackTrace.current;
      OTelErrorHandling.report(error, stack);

      expect(received, equals([error]));
      expect(stacks, equals([stack]));
      expect(loggedMessages, isEmpty,
          reason: 'a custom handler replaces the default logging');
    });

    test('the default handler never throws, even with logging disabled', () {
      OTelLog.logFunction = null;
      expect(() => OTelErrorHandling.report(ArgumentError('quiet')),
          returnsNormally);
    });

    test('resetToDefault restores the logging handler', () {
      OTelErrorHandling.handler = (error, stackTrace) {};
      OTelErrorHandling.report(ArgumentError('swallowed'));
      expect(loggedMessages, isEmpty);

      OTelErrorHandling.resetToDefault();
      OTelErrorHandling.report(ArgumentError('logged again'));
      expect(loggedMessages.length, equals(1));
      expect(loggedMessages[0], contains('logged again'));
    });

    test('a rethrowing handler makes invalid usage fail fast', () {
      // The staging-environment use case called out by the spec: the one
      // sanctioned exception to "never throw".
      OTelErrorHandling.handler = (error, stackTrace) =>
          Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);

      expect(() => OTelErrorHandling.report(ArgumentError('strict mode')),
          throwsArgumentError);
    });

    test('OTelAPI.setErrorHandler installs and clears the handler', () {
      final received = <Object>[];
      OTelAPI.setErrorHandler((error, stackTrace) => received.add(error));

      OTelErrorHandling.report(ArgumentError('via OTelAPI'));
      expect(received.length, equals(1));
      expect(loggedMessages, isEmpty);

      OTelAPI.setErrorHandler(null);
      OTelErrorHandling.report(ArgumentError('back to default'));
      expect(received.length, equals(1));
      expect(loggedMessages.length, equals(1));
      expect(loggedMessages[0], contains('back to default'));
    });
  });
}
