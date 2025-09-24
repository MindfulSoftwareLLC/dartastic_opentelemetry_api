// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('TraceState', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('creates empty trace state', () {
      final traceState = OTelAPI.traceState(null);
      expect(traceState.isEmpty, isTrue);
      expect(traceState.entries, isEmpty);
      expect(traceState.toString(), equals(''));
    });

    test('creates trace state from empty map', () {
      final traceState = TraceState.empty();
      expect(traceState.isEmpty, isTrue);
      expect(traceState.entries, isEmpty);
      expect(traceState.toString(), equals(''));
    });

    test('creates trace state from map', () {
      final entries = {'vendora': 'value1', 'vendorb': 'value2'};
      final traceState = TraceState.fromMap(entries);
      expect(traceState.isEmpty, isFalse);
      expect(traceState.entries, equals(entries));
      expect(traceState.asMap(), equals(entries));
    });

    test('creates trace state from valid header string', () {
      final headerValue = 'vendora=value1,vendorb=value2';
      final traceState = TraceState.fromString(headerValue);
      expect(traceState.isEmpty, isFalse);
      expect(traceState.get('vendora'), equals('value1'));
      expect(traceState.get('vendorb'), equals('value2'));
    });

    test('creates trace state from header string with spaces', () {
      final headerValue = 'vendora=value1, vendorb=value2';
      final traceState = TraceState.fromString(headerValue);
      expect(traceState.isEmpty, isFalse);
      expect(traceState.get('vendora'), equals('value1'));
      expect(traceState.get('vendorb'), equals('value2'));
    });

    test('creates empty trace state from null header', () {
      final traceState = TraceState.fromString(null);
      expect(traceState.isEmpty, isTrue);
    });

    test('creates empty trace state from empty header', () {
      final traceState = TraceState.fromString('');
      expect(traceState.isEmpty, isTrue);
    });

    test('parses header and skips invalid entries', () {
      // Invalid key and value formats, and invalid format entries
      final headerValue =
          'INVALID=value1,vendora=value1,invalid@=value2,vendorb=,vendorc=value3';
      final traceState = TraceState.fromString(headerValue);

      expect(traceState.get('INVALID'), isNull); // Invalid key (uppercase)
      expect(traceState.get('vendora'), equals('value1')); // Valid
      expect(traceState.get('invalid@'), isNull); // Invalid key (special char)
      expect(traceState.get('vendorb'), isNull); // Invalid value (empty)
      expect(traceState.get('vendorc'), equals('value3')); // Valid
    });

    test('limits number of entries to 32', () {
      // Create a header with 40 entries
      final entries = <String, String>{};
      for (var i = 0; i < 40; i++) {
        entries['vendor$i'] = 'value$i';
      }

      final traceState = TraceState.fromMap(entries);
      expect(traceState.entries.length <= 32, isTrue);
    });

    test('gets value for key', () {
      final traceState = OTelAPI.traceState({
        'vendora': 'value1',
        'vendorb': 'value2',
      });

      expect(traceState.get('vendora'), equals('value1'));
      expect(traceState.get('vendorb'), equals('value2'));
      expect(traceState.get('unknown'), isNull);
    });

    test('adds new key/value pair', () {
      final traceState = OTelAPI.traceState({'vendora': 'value1'});
      final updatedState = traceState.put('vendorb', 'value2');

      expect(updatedState.get('vendora'), equals('value1'));
      expect(updatedState.get('vendorb'), equals('value2'));
      expect(identical(traceState, updatedState), isFalse);
    });

    test('rejects invalid key and value', () {
      final traceState = OTelAPI.traceState({'vendora': 'value1'});

      // Invalid key (uppercase)
      expect(() => traceState.put('INVALID', 'value2'), throwsArgumentError);

      // Invalid key (special char)
      expect(() => traceState.put('invalid@', 'value2'), throwsArgumentError);

      // Invalid value (contains invalid characters)
      expect(
          () => traceState.put('vendorb', 'value\u0000'), throwsArgumentError);

      // Invalid value (too long)
      final tooLongValue = 'x' * 257;
      expect(
          () => traceState.put('vendorb', tooLongValue), throwsArgumentError);
    });

    test('updates existing value', () {
      final traceState = OTelAPI.traceState({'vendora': 'value1'});
      final updatedState = traceState.put('vendora', 'newvalue');

      expect(updatedState.get('vendora'), equals('newvalue'));
      expect(identical(traceState, updatedState), isFalse);
    });

    test('deletes key/value pair', () {
      final traceState = OTelAPI.traceState({
        'vendora': 'value1',
        'vendorb': 'value2',
      });
      final updatedState = traceState.remove('vendora');

      expect(updatedState.get('vendora'), isNull);
      expect(updatedState.get('vendorb'), equals('value2'));
      expect(identical(traceState, updatedState), isFalse);
    });

    test('removing non-existent key returns same state', () {
      final traceState = OTelAPI.traceState({'vendora': 'value1'});
      final updatedState = traceState.remove('nonexistent');

      expect(identical(traceState, updatedState), isTrue);
    });

    test('handles OpenTelemetry vendor-specific format', () {
      final traceState = OTelAPI.traceState({'ot': 'p:8;r:62'});

      expect(traceState.get('ot'), equals('p:8;r:62'));
    });

    test('supports tenant format', () {
      final traceState = OTelAPI.traceState({'tenant@vendor': 'value'});
      expect(traceState.get('tenant@vendor'), equals('value'));
    });

    test('maintains immutability', () {
      final traceState = OTelAPI.traceState({'key': 'value'});
      final updatedState = traceState.put('newkey', 'newvalue');

      expect(traceState.get('newkey'), isNull);
      expect(updatedState.get('newkey'), equals('newvalue'));

      // Verify entries map is immutable
      expect(() => traceState.entries['newkey'] = 'newvalue',
          throwsUnsupportedError);
      expect(() => traceState.asMap()['newkey'] = 'newvalue',
          throwsUnsupportedError);
    });

    test('handles empty entries correctly', () {
      final traceState = OTelAPI.traceState({});
      expect(traceState.isEmpty, isTrue);

      final updatedState = traceState.put('key', 'value');
      expect(updatedState.isEmpty, isFalse);
      expect(updatedState.get('key'), equals('value'));
    });

    test('converts to string correctly', () {
      final traceState =
          OTelAPI.traceState({'vendora': 'value1', 'vendorb': 'value2'});

      final str = traceState.toString();
      expect(str.contains('vendora=value1'), isTrue);
      expect(str.contains('vendorb=value2'), isTrue);
      expect(str.contains(','), isTrue);
    });

    test('equals compares TraceState correctly', () {
      final state1 =
          TraceState.fromMap({'vendora': 'value1', 'vendorb': 'value2'});
      final state2 =
          TraceState.fromMap({'vendora': 'value1', 'vendorb': 'value2'});
      final state3 =
          TraceState.fromMap({'vendora': 'value1', 'vendorc': 'value3'});

      expect(state1 == state2, isTrue);
      expect(state1 == state3, isFalse);
      expect(state1 == TraceState.empty(), isFalse);
    });

    test('hashCode is consistent', () {
      final state1 =
          TraceState.fromMap({'vendora': 'value1', 'vendorb': 'value2'});
      final state2 =
          TraceState.fromMap({'vendora': 'value1', 'vendorb': 'value2'});

      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1.hashCode == TraceState.empty().hashCode, isFalse);
    });
  });
}
