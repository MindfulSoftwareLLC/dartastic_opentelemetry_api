// Licensed under the Apache License, Version 2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Spec-compliance tests for TraceState (specification/trace/api.md):
//
// - "All mutating operations MUST return a new TraceState with the
//   modifications applied."
// - "Every mutating operations MUST validate input parameters. If invalid
//   value is passed the operation MUST NOT return TraceState containing
//   invalid data and MUST follow the general error handling guidelines" —
//   and error-handling.md: "API methods MUST NOT throw unhandled exceptions
//   when used incorrectly by end users." Invalid input is rejected by
//   ignoring it (log a warning), never by throwing.
void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4318',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('TraceState mutating operations never throw', () {
    test('put with an invalid key returns the state unchanged', () {
      final traceState = TraceState.fromMap({'vendor': 'value'});
      final result = traceState.put('INVALID KEY!', 'value');
      expect(result.entries, equals({'vendor': 'value'}));
    });

    test('put with an invalid value returns the state unchanged', () {
      final traceState = TraceState.fromMap({'vendor': 'value'});
      final result = traceState.put('vendor2', 'bad,value');
      expect(result.entries, equals({'vendor': 'value'}));
    });

    test('put never returns TraceState containing invalid data', () {
      final result =
          TraceState.fromMap({'vendor': 'value'}).put('BAD KEY', 'v');
      for (final key in result.entries.keys) {
        expect(TraceState.fromString('$key=${result.get(key)}').get(key),
            isNotNull);
      }
    });
  });

  group('TraceState works without an installed SDK', () {
    test('put works after reset', () {
      final traceState = TraceState.fromMap({'vendor': 'value'});
      OTelAPI.reset();
      final result = traceState.put('vendor2', 'value2');
      expect(result.get('vendor2'), equals('value2'));
    });

    test('remove works after reset', () {
      final traceState = TraceState.fromMap({'vendor': 'value'});
      OTelAPI.reset();
      final result = traceState.remove('vendor');
      expect(result.get('vendor'), isNull);
    });
  });
}
