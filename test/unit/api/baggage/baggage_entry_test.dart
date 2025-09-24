// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('BaggageEntry', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    group('equality', () {
      test('same value and metadata are equal', () {
        final entry1 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry2 = OTelAPI.baggageEntry('value1', 'meta1');
        expect(entry1, equals(entry2));
      });

      test('different values are not equal', () {
        final entry1 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry2 = OTelAPI.baggageEntry('value2', 'meta1');
        expect(entry1, isNot(equals(entry2)));
      });

      test('different metadata are not equal', () {
        final entry1 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry2 = OTelAPI.baggageEntry('value1', 'meta2');
        expect(entry1, isNot(equals(entry2)));
      });

      test('null vs non-null metadata are not equal', () {
        final entry1 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry2 = OTelAPI.baggageEntry('value1', null);
        expect(entry1, isNot(equals(entry2)));
      });

      test('null metadata entries are equal', () {
        final entry1 = OTelAPI.baggageEntry('value1', null);
        final entry2 = OTelAPI.baggageEntry('value1', null);
        expect(entry1, equals(entry2));
      });

      test('reflexive equality', () {
        final entry = OTelAPI.baggageEntry('value1', 'meta1');
        // ignore: prefer_const_literals_to_create_immutables
        expect(entry, equals(entry));
      });

      test('transitive equality', () {
        final entry1 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry2 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry3 = OTelAPI.baggageEntry('value1', 'meta1');
        expect(entry1, equals(entry2));
        expect(entry2, equals(entry3));
        expect(entry1, equals(entry3));
      });
    });

    group('hashCode', () {
      test('equal entries have equal hashCodes', () {
        final entry1 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry2 = OTelAPI.baggageEntry('value1', 'meta1');
        expect(entry1.hashCode, equals(entry2.hashCode));
      });

      test('different entries have different hashCodes', () {
        final entry1 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry2 = OTelAPI.baggageEntry('value2', 'meta1');
        expect(entry1.hashCode, isNot(equals(entry2.hashCode)));
      });

      test('entries with null metadata have consistent hashCodes', () {
        final entry1 = OTelAPI.baggageEntry('value1', null);
        final entry2 = OTelAPI.baggageEntry('value1', null);
        expect(entry1.hashCode, equals(entry2.hashCode));
      });

      test('null vs non-null metadata produce different hashCodes', () {
        final entry1 = OTelAPI.baggageEntry('value1', 'meta1');
        final entry2 = OTelAPI.baggageEntry('value1', null);
        expect(entry1.hashCode, isNot(equals(entry2.hashCode)));
      });

      test('hashCode is consistent across multiple calls', () {
        final entry = OTelAPI.baggageEntry('value1', 'meta1');
        final firstHash = entry.hashCode;
        for (var i = 0; i < 10; i++) {
          expect(entry.hashCode, equals(firstHash));
        }
      });
    });

    group('toString', () {
      test('includes value and metadata', () {
        final entry = OTelAPI.baggageEntry('value1', 'meta1');
        expect(entry.toString(),
            equals('BaggageEntry(value: value1, metadata: meta1)'));
      });

      test('handles null metadata correctly', () {
        final entry = OTelAPI.baggageEntry('value1', null);
        expect(entry.toString(),
            equals('BaggageEntry(value: value1, metadata: null)'));
      });

      test('handles special characters in value', () {
        final entry =
            OTelAPI.baggageEntry('value: with, special\nchars', 'meta1');
        expect(
            entry.toString(),
            equals(
                'BaggageEntry(value: value: with, special\nchars, metadata: meta1)'));
      });

      test('handles special characters in metadata', () {
        final entry =
            OTelAPI.baggageEntry('value1', 'meta: with, special\nchars');
        expect(
            entry.toString(),
            equals(
                'BaggageEntry(value: value1, metadata: meta: with, special\nchars)'));
      });

      test('toString representation can be used to distinguish entries', () {
        final entries = [
          OTelAPI.baggageEntry('value1', 'meta1'),
          OTelAPI.baggageEntry('value1', 'meta2'),
          OTelAPI.baggageEntry('value2', 'meta1'),
          OTelAPI.baggageEntry('value1', null),
        ];

        final strings = entries.map((e) => e.toString()).toSet();
        expect(strings.length, equals(entries.length),
            reason:
                'Each distinct entry should have a unique string representation');
      });
    });

    group('constructor validation', () {
      test('allows empty metadata', () {
        final entry = OTelAPI.baggageEntry('value1', '');
        expect(entry.metadata, equals(''));
      });

      test('identical entries are referentially equal', () {
        final entry = OTelAPI.baggageEntry('value1', 'meta1');
        expect(identical(entry, entry), isTrue);
      });
    });
  });
}
