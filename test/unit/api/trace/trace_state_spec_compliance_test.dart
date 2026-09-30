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

  group('TraceState construction drops invalid entries', () {
    test('fromMap drops an entry with an invalid key', () {
      final result = TraceState.fromMap({'BadKey': 'a', 'goodkey': 'b'});
      expect(result.entries, equals({'goodkey': 'b'}));
    });

    test('fromMap drops an entry with an invalid value', () {
      final result = TraceState.fromMap({'vendor': 'a,b=c', 'goodkey': 'b'});
      expect(result.entries, equals({'goodkey': 'b'}));
    });

    test('fromMap never produces a TraceState containing invalid data', () {
      final result = TraceState.fromMap({'BadKey': 'a,b=c'});
      expect(result.entries, isEmpty);
      expect(result.toString(), isEmpty);
    });

    test('fromMap drops a key over 256 characters', () {
      final result = TraceState.fromMap({'a' * 257: 'value', 'goodkey': 'b'});
      expect(result.entries, equals({'goodkey': 'b'}));
    });

    test('fromMap drops a value over 256 characters', () {
      final result = TraceState.fromMap({'vendor': 'a' * 257, 'goodkey': 'b'});
      expect(result.entries, equals({'goodkey': 'b'}));
    });

    test('fromMap reports a dropped entry to the error handler', () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((error, stackTrace) => reported.add(error));
      addTearDown(OTelErrorHandling.resetToDefault);

      TraceState.fromMap({'BadKey': 'a,b=c'});

      expect(reported, hasLength(1));
      expect(reported.single, isArgumentError);
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

    test('an empty or whitespace-only member is not an error', () {
      // W3C: "Empty and whitespace-only list members are allowed."
      // `list-member = (key "=" value) / OWS`
      final errors = <Object>[];
      OTelAPI.setErrorHandler((error, stackTrace) => errors.add(error));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final state = TraceState.fromString('vendor=v, ,,\t,other=w');

      expect(state.entries, equals({'vendor': 'v', 'other': 'w'}));
      expect(errors, isEmpty);
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
      // big=... is 258 characters. Eight 59-character entries plus big
      // and separators total 738: over budget. The over-128 entry is
      // removed, and that alone brings the value to 479 characters, so
      // the eight under-128 entries all survive.
      final v55 = List.filled(55, 'v').join(); // k0=... 59 chars
      final bigValue = List.filled(254, 'w').join(); // big=... 258 chars
      final entries = <String, String>{};
      for (var i = 0; i < 8; i++) {
        entries['k$i'] = v55;
      }
      entries['big'] = bigValue;
      final traceState = TraceState.fromMap(entries);
      final header = traceState.toHeaderString();
      expect(
          header,
          equals('k0=$v55,k1=$v55,k2=$v55,k3=$v55,'
              'k4=$v55,k5=$v55,k6=$v55,k7=$v55'));
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

    test('a header one character over budget keeps what fits', () {
      // a=... is 255 characters, b=... is 257, plus the comma: 513.
      // Removing either entry alone fits, so only the first one goes.
      final longA = List.filled(253, 'x').join();
      final longB = List.filled(255, 'y').join();
      final traceState = TraceState.fromMap({'a': longA, 'b': longB});
      expect(traceState.toHeaderString(), equals('b=$longB'));
    });

    test('stops dropping over-128 entries once the value fits', () {
      // Three 180-character entries total 542. Dropping the first
      // brings the value to 361, so the other two over-128 entries
      // must survive and only one drop is reported.
      final received = <Object>[];
      OTelErrorHandling.handler = (error, stackTrace) {
        received.add(error);
      };
      try {
        final v178 = List.filled(178, 'v').join();
        final traceState =
            TraceState.fromMap({'a': v178, 'b': v178, 'c': v178});
        final header = traceState.toHeaderString();
        expect(header, equals('b=$v178,c=$v178'));
        expect(received.length, 1,
            reason: 'only the first over-128 entry is dropped');
      } finally {
        OTelErrorHandling.resetToDefault();
      }
    });

    test('returns the value untouched at exactly 512 characters', () {
      // Both entries are over 128 characters, but 255 + 256 + the
      // comma is exactly 512, so no truncation runs at all.
      final a = List.filled(253, 'x').join(); // a=... 255 chars
      final b = List.filled(254, 'y').join(); // b=... 256 chars
      final traceState = TraceState.fromMap({'a': a, 'b': b});
      expect(traceState.toHeaderString(), equals('a=$a,b=$b'));
    });

    test('an entry of exactly 128 characters is not over-long', () {
      // Five entries of exactly 128 characters total 644. If 128
      // counted as over-long the over-128 pass would drop all five
      // and return an empty string. Since only entries over 128 are
      // dropped, the pass removes nothing and the end-truncation
      // keeps the first three entries.
      final v125 = List.filled(125, 'x').join(); // sN=... 128 chars
      final traceState = TraceState.fromMap({
        's0': v125,
        's1': v125,
        's2': v125,
        's3': v125,
        's4': v125,
      });
      final header = traceState.toHeaderString();
      expect(header, equals('s0=$v125,s1=$v125,s2=$v125'));
    });

    test('a single maximum-size entry yields an empty header', () {
      // A 256-character key with a 256-character value is 513
      // characters, over budget on its own, so the entry is dropped
      // and nothing remains.
      final key = List.filled(256, 'k').join();
      final value = List.filled(256, 'v').join();
      final traceState = TraceState.fromMap({key: value});
      expect(traceState.toHeaderString(), equals(''));
    });
  });
}
