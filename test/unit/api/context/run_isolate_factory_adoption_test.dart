// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// api#94 — the isolate bridge goes through the factory-held error handler.
//
// Ordering subtlety pinned here: in the child isolate the bridged handler
// arrives over the port handshake BEFORE `OTelFactory.deserialize` installs
// the child's factory. The pre-init buffer semantics must carry the
// handler onto the factory once it is installed — the child-side install
// is the same "setErrorHandler before initialize" path a user takes.

@TestOn('vm')
library;

import 'dart:isolate';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group(
      'runIsolate installs the bridged handler onto the child factory '
      '(api#94)', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    tearDown(OTelAPI.reset);

    test('the handshake handler is adopted by the child factory', () async {
      final received = ReceivePort();
      final reportSink = received.sendPort;
      OTelAPI.setErrorHandler((error, stackTrace) {
        reportSink.send(error.toString());
      });

      final childSaw = await Context.current.runIsolate(() async {
        // The handler arrived before the child factory existed; adoption
        // must have moved it onto the factory installed by deserialize.
        final onFactory = OTelFactory.otelFactory!.errorHandler != null;
        final installed = OTelErrorHandling.installedHandler != null;
        OTelErrorHandling.report(StateError('adopted-report'));
        return [onFactory, installed];
      });

      expect(childSaw, equals([true, true]),
          reason: 'the bridged handler must be held by the child factory '
              'and visible as the installed handler');

      final first = await received.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => fail(
          'The child-side report did not route through the bridged handler.',
        ),
      );
      expect(first, contains('adopted-report'));
      received.close();
    });

    test('with no user handler the child factory slot stays empty', () async {
      final childSaw = await Context.current.runIsolate(() async {
        return [
          OTelFactory.otelFactory!.errorHandler == null,
          OTelErrorHandling.installedHandler == null,
        ];
      });
      expect(childSaw, equals([true, true]),
          reason: 'defaults are never forwarded; the child resolves its '
              'own factory default');
    });
  });
}
