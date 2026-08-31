// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

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

  group('TraceState.fromString parses per W3C Trace Context', () {
    test('a repeated key is invalid; the first entry is kept', () {
      final state = TraceState.fromString('vendor=first,vendor=second');
      expect(state.entries, equals({'vendor': 'first'}));
    });

    test('an invalid member is dropped and the valid members survive', () {
      final state = TraceState.fromString('INVALID=v1,vendora=v2,vendorb=');
      expect(state.entries, equals({'vendora': 'v2'}));
    });

    test('a leading space inside a value is preserved', () {
      final state = TraceState.fromString('vendora=v1, vendorb= v2');
      expect(state.get('vendorb'), equals(' v2'));
    });

    test('an empty list member is ignored', () {
      final state = TraceState.fromString('vendora=v1,,=v2,vendorb=v3');
      expect(state.entries, equals({'vendora': 'v1', 'vendorb': 'v3'}));
    });

    test('parsing stops at 32 members', () {
      final header = List.generate(40, (i) => 'vendor$i=value$i').join(',');
      expect(TraceState.fromString(header).entries.length, equals(32));
    });

    test('a parsed state round-trips to a header this package accepts', () {
      const header = 'congo=t61rcWkgMzE,rojo=00f067aa0ba902b7';
      final state = TraceState.fromString(header);
      expect(state.toString(), equals(header));
      expect(TraceState.fromString(state.toString()).entries,
          equals(state.entries));
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
