// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Semconv invariants', () {
    final keyFormat = RegExp(r'^[a-z0-9_.]+$');

    test('no duplicate attribute keys across the whole registry', () {
      final owners = <String, List<String>>{};
      for (final values in SemconvRegistry.allAttributeEnums) {
        for (final member in values) {
          owners
              .putIfAbsent(member.key, () => [])
              .add(member.runtimeType.toString());
        }
      }
      final dups =
          Map.fromEntries(owners.entries.where((e) => e.value.length > 1));
      expect(dups, isEmpty,
          reason: 'attribute keys must be defined exactly once');
    });

    test('every attribute key is well-formed and toString() returns it', () {
      for (final values in SemconvRegistry.allAttributeEnums) {
        for (final member in values) {
          expect(member.key, matches(keyFormat));
          expect(member.toString(), equals(member.key));
        }
      }
    });

    test('every value enum member round-trips through toString()', () {
      for (final values in SemconvRegistry.allValueEnums) {
        for (final member in values) {
          expect(member.toString(), equals(member.value));
        }
      }
      for (final values in SemconvRegistry.allIntValueEnums) {
        for (final member in values) {
          expect(member.toString(), equals(member.value.toString()));
        }
      }
    });

    test('every metric has a well-formed name, instrument, and unit', () {
      for (final values in SemconvRegistry.allMetricEnums) {
        for (final metric in values) {
          expect(metric.name, matches(keyFormat));
          expect(metric.toString(), equals(metric.name));
          expect(metric.unit, isNotEmpty);
        }
      }
    });

    test('every event name is well-formed', () {
      for (final values in SemconvRegistry.allEventEnums) {
        for (final event in values) {
          expect(event.name, matches(keyFormat));
          expect(event.toString(), equals(event.name));
        }
      }
    });

    test('entities reference only registered attribute keys', () {
      final allKeys = <String>{
        for (final values in SemconvRegistry.allAttributeEnums)
          for (final member in values) member.key,
      };
      for (final values in SemconvRegistry.allEntityEnums) {
        for (final entity in values) {
          expect(entity.name, matches(keyFormat));
          expect(entity.toString(), equals(entity.name));
          for (final attr in [...entity.identifying, ...entity.descriptive]) {
            expect(allKeys, contains(attr.key),
                reason:
                    'entity ${entity.name} references unregistered ${attr.key}');
          }
        }
      }
    });

    test('registry records its source version', () {
      expect(SemconvRegistry.schemaVersion, isNotEmpty);
      expect(SemconvRegistry.registryCommit, isNot('unknown'));
      expect(SemconvRegistry.allAttributeEnums, isNotEmpty);
    });
  });
}
