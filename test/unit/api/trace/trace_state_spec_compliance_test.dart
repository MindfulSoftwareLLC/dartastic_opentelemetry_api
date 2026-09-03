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

  group('TraceState put moves the mutated entry to the front (W3C order)', () {
    test('adding a new key puts it first', () {
      final traceState = TraceState.fromMap({'a': '1', 'b': '2'});
      final result = traceState.put('c', '3');
      expect(result.entries.keys.toList(), equals(['c', 'a', 'b']));
      expect(result.toString(), equals('c=3,a=1,b=2'));
    });

    test('updating an existing key moves it to the front', () {
      final traceState = TraceState.fromMap({'a': '1', 'b': '2', 'c': '3'});
      final result = traceState.put('b', 'new');
      expect(result.entries.keys.toList(), equals(['b', 'a', 'c']));
      expect(result.get('b'), equals('new'));
    });

    test('overflow drops the oldest (rightmost) entry, not the newest', () {
      final entries = <String, String>{};
      for (var i = 0; i < 32; i++) {
        entries['vendor$i'] = 'value$i';
      }
      // Map/header order is left-to-right = newest-to-oldest, so vendor0
      // (first/leftmost) is newest and vendor31 (last/rightmost) is oldest.
      final traceState = TraceState.fromMap(entries);
      final result = traceState.put('vendornew', 'v');

      expect(result.entries.length, equals(32));
      expect(result.get('vendornew'), equals('v'));
      expect(result.get('vendor31'), isNull); // oldest entry evicted
      expect(result.get('vendor0'), equals('value0')); // newest retained
      expect(result.entries.keys.first, equals('vendornew'));
    });

    test('updating a key at the 32-entry limit does not drop any entry', () {
      final entries = <String, String>{};
      for (var i = 0; i < 32; i++) {
        entries['vendor$i'] = 'value$i';
      }
      final traceState = TraceState.fromMap(entries);
      final result = traceState.put('vendor31', 'updated');

      expect(result.entries.length, equals(32));
      expect(result.get('vendor31'), equals('updated'));
      expect(result.entries.keys.first, equals('vendor31'));
      for (var i = 0; i < 31; i++) {
        expect(result.get('vendor$i'), equals('value$i'));
      }
    });

    test('updating the already-frontmost key leaves it in front', () {
      final traceState = TraceState.fromMap({'a': '1', 'b': '2', 'c': '3'});
      final first = traceState.put('a', '1');
      final result = first.put('a', 'updated');
      expect(result.entries.keys.toList(), equals(['a', 'b', 'c']));
      expect(result.get('a'), equals('updated'));
    });

    test('W3C example header: update then add', () {
      final traceState =
          TraceState.fromString('congo=t61rcWkgMzE,rojo=00f067aa0ba902b7');
      final updated = traceState.put('rojo', 'newIntValue');
      expect(updated.entries.keys.toList(), equals(['rojo', 'congo']));
      expect(updated.toString(), equals('rojo=newIntValue,congo=t61rcWkgMzE'));

      final result = updated.put('lumber', '3');
      expect(result.entries.keys.toList(), equals(['lumber', 'rojo', 'congo']));
      expect(result.toString(),
          equals('lumber=3,rojo=newIntValue,congo=t61rcWkgMzE'));
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
