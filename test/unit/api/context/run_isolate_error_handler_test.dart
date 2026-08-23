// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

@TestOn('vm')
library;

import 'dart:isolate';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Context.runIsolate error handler propagation (api#94)', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    tearDown(OTelErrorHandling.resetToDefault);

    test('the installed handler crosses into the child isolate', () async {
      // A handler that captures only a SendPort is sendable, so its copy in
      // the child forwards reports back to the parent — the documented
      // pattern for aggregating reports across isolates.
      final received = ReceivePort();
      // Capture the SendPort itself — capturing the ReceivePort (even via
      // `received.sendPort` inside the closure) makes the handler
      // unsendable and triggers the degradation path instead.
      final reportSink = received.sendPort;
      OTelAPI.setErrorHandler((error, stackTrace) {
        reportSink.send(error.toString());
      });

      await Context.current.runIsolate(() async {
        OTelErrorHandling.report(StateError('report-from-child'));
      });

      final first = await received.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => fail(
          'The child isolate ran with the default handler; the '
          'parent-installed handler was not re-installed by runIsolate.',
        ),
      );
      expect(first, contains('report-from-child'));
      received.close();
    });

    test('the default handler is not needlessly forwarded', () async {
      // With no user handler installed, the child must simply keep its own
      // default (logging) handler; runIsolate must not fail attempting to
      // send the default.
      final result = await Context.current.runIsolate(() async {
        OTelErrorHandling.report(StateError('default-ok'));
        return identical(
          OTelErrorHandling.handler,
          OTelErrorHandling.defaultErrorHandler,
        );
      });
      expect(result, isTrue,
          reason: 'child should run the default handler when the parent '
              'has none installed');
    });

    test('an unsendable handler degrades gracefully', () async {
      // A handler closing over a ReceivePort cannot be sent to the child.
      // runIsolate must still run the computation (with the child default
      // handler) rather than throwing at spawn.
      final unsendable = ReceivePort();
      OTelAPI.setErrorHandler((error, stackTrace) {
        unsendable.hashCode; // captures the ReceivePort
      });

      final value = await Context.current.runIsolate(() async => 42);
      expect(value, equals(42));
      unsendable.close();
    });
  });
}
