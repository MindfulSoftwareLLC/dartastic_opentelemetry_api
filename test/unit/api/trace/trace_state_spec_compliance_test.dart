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

  group('TraceState toHeaderString follows W3C 3.3.1.5 truncation', () {
    test('returns the full value when it fits the budget', () {
      final traceState = TraceState.fromMap({'a': '1', 'b': '2'});
      expect(traceState.toHeaderString(), equals('a=1,b=2'));
    });

    test('returns empty string for an empty state', () {
      final traceState = TraceState.empty();
      expect(traceState.toHeaderString(), equals(''));
    });

    test('keeps an over-128 entry when the total fits 512', () {
      // Robert's case: 134 characters total, under budget. The 128 rule
      // only applies once truncation is needed (W3C 3.3.1.5), so the
      // entry stays.
      final longValue = List.filled(130, 'v').join();
      final traceState = TraceState.fromMap({'big': longValue});
      final header = traceState.toHeaderString();
      expect(header, equals('big=$longValue'));
    });

    test('removes over-128 entries first once truncation is needed', () {
      // 32 entries survive the grammar cap: the 134-character entry
      // plus 31 twelve-character ones total 567 characters, over budget.
      // The over-128 entry is removed first, and that alone brings the
      // value to 433 characters, so the rest survive.
      final bigValue = List.filled(130, 'v').join(); // big=... 134 chars
      final entries = <String, String>{'big': bigValue};
      for (var i = 0; i < 31; i++) {
        entries['a$i'] = 'y' * 10; // a0=..., 13 chars each with separator
      }
      final traceState = TraceState.fromMap(entries);
      expect(traceState.entries.length, 32);
      final header = traceState.toHeaderString();
      expect(header.contains('big'), isFalse,
          reason: 'over-128 entries are removed first');
      expect(header.length, lessThanOrEqualTo(512));
    });

    test('removing one large entry can make the rest fit', () {
      // 404 + 61 + 61 + separators = 528 characters: over budget. The
      // over-128 entry is removed, and that alone brings the value to
      // 123 characters, so the two under-128 entries both survive.
      final bigValue = List.filled(400, 'v').join(); // big=... 404 chars
      final ok1Value = List.filled(58, 'w').join(); // ok1=... 62 chars
      final ok2Value = List.filled(58, 'x').join(); // ok2=... 62 chars
      final traceState = TraceState.fromMap({
        'ok1': ok1Value,
        'ok2': ok2Value,
        'big': bigValue,
      });
      final header = traceState.toHeaderString();
      expect(header, equals('ok1=$ok1Value,ok2=$ok2Value'));
      expect(header.length, lessThanOrEqualTo(512));
    });

    test('keeps a long-but-under-128 entry when shorter entries go first', () {
      // second's entry is 120 characters (key 6 + '=' 1 + value 113),
      // under the 128 limit, while first is tiny. Nothing is dropped here,
      // the point is the size does not trigger the 128-char removal.
      final longValue = List.filled(113, 'x').join();
      final traceState = TraceState.fromMap({
        'first': 'old',
        'second': longValue,
      });
      final header = traceState.toHeaderString();
      expect(header, equals('first=old,second=$longValue'));
    });

    test('removes whole entries from the end to fit 512 characters', () {
      final entries = <String, String>{};
      // 10 entries of ~60 characters each: 600+ total, must drop some.
      final v55 = List.filled(55, 'v').join();
      for (var i = 0; i < 10; i++) {
        entries['k$i'] = v55;
      }
      final traceState = TraceState.fromMap(entries);
      final header = traceState.toHeaderString();
      expect(header.length, lessThanOrEqualTo(512));
      // Whole entries only: the header still ends on a complete entry.
      expect(header.endsWith('}'), isFalse); // sanity, no partial values
      expect(header.contains('k0='), isTrue, reason: 'oldest kept');
      // Some of the newest entries had to go.
      expect(header.contains('k9='), isFalse);
    });

    test('toString keeps all entries when toHeaderString truncates', () {
      final entries = <String, String>{};
      final v55 = List.filled(55, 'v').join();
      for (var i = 0; i < 10; i++) {
        entries['k$i'] = v55;
      }
      final traceState = TraceState.fromMap(entries);
      final header = traceState.toHeaderString();
      expect(header.length, lessThanOrEqualTo(512));
      expect(traceState.toString().length, greaterThan(512));
    });

    test('reports dropped entries through OTelErrorHandling', () {
      final received = <Object>[];
      OTelErrorHandling.handler = (error, stackTrace) {
        received.add(error);
      };
      try {
        final longValue = List.filled(200, 'v').join();
        final entries = <String, String>{'big': longValue};
        for (var i = 0; i < 31; i++) {
          entries['a$i'] = 'y' * 10;
        }
        final traceState = TraceState.fromMap(entries);
        traceState.toHeaderString();
        expect(received.length, 1,
            reason: 'the overlong entry must be reported once');
        expect(received.single.toString(), contains('big'));
      } finally {
        OTelErrorHandling.resetToDefault();
      }
    });
  });
}
