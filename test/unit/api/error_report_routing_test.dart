// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// api#94 — API log sites that report user misuse, invalid input, or
// dropped/invalid data route through OTelErrorHandling.report() instead
// of OTelLog.warn, so an installed error handler (or a factory default)
// sees them. Per error-handling.md these are exactly the errors the
// library suppresses "that would otherwise have been exposed to the
// user"; a warn-level log line is not a substitute for the handler.
//
// Plain OTelLog.warn remains only for genuine advisories: this file also
// pins the keep-decision for the empty provider-name fallback, which
// coerces '' to the documented global default with nothing dropped.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('API error-class log sites route through the handler (api#94)', () {
    late List<Object> reported;
    late List<String> logged;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4318',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      reported = [];
      logged = [];
      OTelLog.logFunction = (msg) => logged.add(msg);
      OTelLog.currentLevel = LogLevel.warn;
      OTelAPI.setErrorHandler((error, stackTrace) => reported.add(error));
    });

    tearDown(() {
      OTelAPI.reset();
      OTelLog.logFunction = print;
      OTelLog.currentLevel = LogLevel.info;
    });

    test('a dropped attribute (unsupported value type) is reported', () {
      // Attributes.of stringifies unknown scalar types by design; fromJson
      // drops them — the drop must reach the handler.
      final attrs = Attributes.fromJson({'unsupported': () {}});

      expect(attrs.toList(), isEmpty, reason: 'the attribute is dropped');
      expect(reported, hasLength(1));
      expect(reported.single, isArgumentError);
      expect('${reported.single}', contains('unsupported'));
      expect(logged, isEmpty,
          reason: 'the report replaces the warn-level log line');
    });

    test('a dropped attribute (unsupported list element type) is reported', () {
      final attrs = Attributes.of({
        'mixed': [1, () {}]
      });

      expect(attrs.toList(), isEmpty, reason: 'the attribute is dropped');
      expect(reported, hasLength(1));
      expect(reported.single, isArgumentError);
    });

    test('an invalid (empty) tracer name is reported', () {
      OTelAPI.tracerProvider().getTracer('');

      expect(reported, hasLength(1));
      expect(reported.single, isArgumentError);
      expect(logged, isEmpty);
    });

    test('getTracer after shutdown is reported as a StateError', () async {
      final provider = OTelAPI.tracerProvider();
      await provider.shutdown();

      provider.getTracer('post-shutdown');

      expect(reported, hasLength(1));
      expect(reported.single, isStateError);
      expect(logged, isEmpty);
    });

    test('an invalid TraceState entry is reported and dropped', () {
      final traceState = TraceState.empty().put('INVALID KEY', 'value');

      expect(traceState.isEmpty, isTrue, reason: 'the entry is dropped');
      expect(reported, hasLength(1));
      expect(reported.single, isArgumentError);
      expect(logged, isEmpty);
    });

    test('an empty baggage name is reported and the entry dropped', () {
      final baggage = OTelAPI.baggage().copyWith('', 'value');

      expect(baggage.getAllEntries(), isEmpty, reason: 'the entry is dropped');
      expect(reported, hasLength(1));
      expect(reported.single, isArgumentError);
      expect(logged, isEmpty);
    });

    test('with no handler installed, reports log at error level', () {
      OTelAPI.setErrorHandler(null);
      OTelLog.currentLevel = LogLevel.error;

      OTelAPI.tracerProvider().getTracer('');

      expect(reported, isEmpty);
      expect(logged, hasLength(1));
      expect(logged.single, contains('ERROR'));
      expect(logged.single, contains('Invalid tracer name'));
    });

    test('keep-decision: the empty provider-name fallback stays a warn', () {
      // '' coerces to the documented global default; the returned provider
      // is fully functional and nothing is dropped — a genuine advisory.
      final provider = OTelAPI.tracerProvider('');

      expect(provider, same(OTelAPI.tracerProvider()));
      expect(reported, isEmpty,
          reason: 'an informational fallback is not an error report');
      expect(logged, hasLength(1));
      expect(logged.single, contains('WARN'));
      expect(logged.single, contains('global default'));
    });
  });
}
