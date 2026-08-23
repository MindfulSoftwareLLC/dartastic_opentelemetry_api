// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// api#94 — the global error handler is factory-held state, like every
// other global in this library:
//
// - [OTelFactory] holds the user-installed handler (an instance slot) and
//   an overridable [OTelFactory.defaultErrorHandler] so SDK factories can
//   supply their own default reporting behavior.
// - [OTelErrorHandling.report] remains the single call-site API and
//   resolves through [OTelFactory.otelFactory] when one is installed.
// - Before any factory exists, [OTelAPI.setErrorHandler] buffers the
//   handler and factory installation adopts it: never throw, never lose.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

/// A stand-in for an SDK factory that supplies its own default error
/// handling behavior by overriding [defaultErrorHandler].
class _OverridingDefaultFactory extends OTelAPIFactory {
  _OverridingDefaultFactory()
      : super(
          apiEndpoint: 'http://localhost:4318',
          apiServiceName: 'error-handler-test',
          apiServiceVersion: '1.0.0',
        );

  final List<Object> defaultReports = <Object>[];

  @override
  OTelErrorHandler get defaultErrorHandler =>
      (error, stackTrace) => defaultReports.add(error);
}

void main() {
  group('factory-held error handler (api#94)', () {
    late List<String> loggedMessages;

    void initializeAPI() {
      OTelAPI.initialize(
        endpoint: 'http://localhost:4318',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    }

    setUp(() {
      OTelAPI.reset();
      loggedMessages = [];
      OTelLog.logFunction = (msg) => loggedMessages.add(msg);
      OTelLog.currentLevel = LogLevel.error;
    });

    tearDown(() {
      OTelAPI.reset();
      OTelLog.logFunction = print;
      OTelLog.currentLevel = LogLevel.info;
    });

    group('pre-init semantics — never throw, never lose', () {
      test('setErrorHandler works before any factory is installed', () {
        expect(OTelFactory.otelFactory, isNull);
        expect(() => OTelAPI.setErrorHandler((error, stackTrace) {}),
            returnsNormally);
        expect(OTelFactory.otelFactory, isNull,
            reason: 'setErrorHandler must not install a factory '
                'as a side effect');
      });

      test('report() before any factory uses the buffered handler', () {
        final received = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => received.add(error));

        OTelErrorHandling.report(ArgumentError('pre-init'));

        expect(received, hasLength(1));
        expect(loggedMessages, isEmpty,
            reason: 'the buffered handler replaces the default logging');
        expect(OTelFactory.otelFactory, isNull,
            reason: 'report() must not install a factory as a side effect');
      });

      test('report() before any factory or handler logs via the default', () {
        OTelErrorHandling.report(ArgumentError('pre-init default'));

        expect(loggedMessages, hasLength(1));
        expect(loggedMessages[0], contains('pre-init default'));
        expect(OTelFactory.otelFactory, isNull,
            reason: 'report() must not install a factory as a side effect');
      });

      test('factory installation adopts the buffered handler', () {
        final received = <Object>[];
        void bufferedHandler(Object error, StackTrace? stackTrace) =>
            received.add(error);

        OTelAPI.setErrorHandler(bufferedHandler);
        initializeAPI();

        expect(OTelErrorHandling.installedHandler, same(bufferedHandler));
        expect(OTelFactory.otelFactory!.errorHandler, same(bufferedHandler),
            reason: 'the installed factory holds the buffered handler');

        OTelErrorHandling.report(StateError('post-install'));
        expect(received, hasLength(1));
        expect(loggedMessages, isEmpty);
      });

      test(
          'a handler on the auto-installed no-op factory survives '
          'explicit initialization', () {
        // API use before initialize() lazily installs the no-op factory.
        OTelFactory.getOrCreateDefault();
        expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);

        final received = <Object>[];
        void handler(Object error, StackTrace? stackTrace) =>
            received.add(error);
        OTelAPI.setErrorHandler(handler);

        // Explicit initialization replaces the auto-installed factory;
        // the user's handler must not be lost in the exchange.
        initializeAPI();

        expect(OTelErrorHandling.installedHandler, same(handler));
        OTelErrorHandling.report(ArgumentError('after upgrade'));
        expect(received, hasLength(1));
      });
    });

    group('factory-held storage', () {
      test('setErrorHandler stores the handler on the installed factory', () {
        initializeAPI();
        expect(OTelFactory.otelFactory!.errorHandler, isNull,
            reason: 'no user handler is installed by default');

        void handler(Object error, StackTrace? stackTrace) {}
        OTelAPI.setErrorHandler(handler);

        expect(OTelFactory.otelFactory!.errorHandler, same(handler));
        expect(OTelErrorHandling.installedHandler, same(handler));
      });

      test('report() resolves through the factory-held handler', () {
        initializeAPI();
        final received = <Object>[];
        OTelFactory.otelFactory!.errorHandler =
            (error, stackTrace) => received.add(error);

        OTelErrorHandling.report(ArgumentError('via the factory'));

        expect(received, hasLength(1));
        expect(loggedMessages, isEmpty);
      });

      test('setErrorHandler(null) clears the factory-held handler', () {
        initializeAPI();
        OTelAPI.setErrorHandler((error, stackTrace) {});

        OTelAPI.setErrorHandler(null);

        expect(OTelFactory.otelFactory!.errorHandler, isNull);
        expect(OTelErrorHandling.installedHandler, isNull);
        OTelErrorHandling.report(ArgumentError('back to default'));
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages[0], contains('back to default'));
      });

      test('OTelAPI.reset() restores defaults', () {
        initializeAPI();
        final received = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => received.add(error));

        OTelAPI.reset();

        expect(OTelErrorHandling.installedHandler, isNull);
        OTelErrorHandling.report(ArgumentError('reset to default'));
        expect(received, isEmpty);
        expect(loggedMessages, hasLength(1));
        expect(loggedMessages[0], contains('reset to default'));
      });

      test('OTelAPI.reset() clears a buffered pre-init handler', () {
        final received = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => received.add(error));

        OTelAPI.reset();

        expect(OTelErrorHandling.installedHandler, isNull);
        OTelErrorHandling.report(ArgumentError('nothing buffered'));
        expect(received, isEmpty);
      });
    });

    group('factory subclass default (extensibility contract)', () {
      test('a subclass default is used when no user handler is installed', () {
        final factory = _OverridingDefaultFactory();
        OTelFactory.otelFactory = factory;

        OTelErrorHandling.report(ArgumentError('to the subclass default'));

        expect(factory.defaultReports, hasLength(1));
        expect(loggedMessages, isEmpty,
            reason: 'the subclass default replaces the logging default');
      });

      test('a user-installed handler wins over the subclass default', () {
        final factory = _OverridingDefaultFactory();
        OTelFactory.otelFactory = factory;
        final received = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => received.add(error));

        OTelErrorHandling.report(ArgumentError('to the user handler'));

        expect(received, hasLength(1));
        expect(factory.defaultReports, isEmpty);
      });

      test('setErrorHandler(null) returns to the subclass default', () {
        final factory = _OverridingDefaultFactory();
        OTelFactory.otelFactory = factory;
        OTelAPI.setErrorHandler((error, stackTrace) {});

        OTelAPI.setErrorHandler(null);
        OTelErrorHandling.report(ArgumentError('back to the subclass'));

        expect(factory.defaultReports, hasLength(1));
        expect(loggedMessages, isEmpty);
      });

      test('the base default remains the logging handler', () {
        initializeAPI();
        expect(
          OTelFactory.otelFactory!.defaultErrorHandler,
          same(OTelErrorHandling.defaultErrorHandler),
          reason: 'OTelAPIFactory does not override defaultErrorHandler',
        );
      });
    });
  });
}
