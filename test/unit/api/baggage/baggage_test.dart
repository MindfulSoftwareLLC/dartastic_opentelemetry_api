// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    // Reset state
    OTelAPI.reset();
    
    // Initialize API for tests
    OTelAPI.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('Baggage', () {
    test('creates empty baggage', () {
      final baggage = OTelAPI.baggage();
      expect(baggage.getAllEntries(), isEmpty);
    });

    test('creates baggage with entries', () {
      final entry1 = OTelAPI.baggageEntry('value1', 'metadata1');
      final entry2 = OTelAPI.baggageEntry('value2', 'metadata2');
      
      final baggage = OTelAPI.baggage({
        'key1': entry1,
        'key2': entry2,
      });
      
      expect(baggage.getEntry('key1')?.value, equals('value1'));
      expect(baggage.getEntry('key1')?.metadata, equals('metadata1'));
      expect(baggage.getEntry('key2')?.value, equals('value2'));
      expect(baggage.getEntry('key2')?.metadata, equals('metadata2'));
    });

    test('retrieves values with bracket operator', () {
      final entry = OTelAPI.baggageEntry('value1', 'metadata1');
      final baggage = OTelAPI.baggage({'key1': entry});
      
      expect(baggage['key1'], equals('value1'));
      expect(baggage['nonexistent'], isNull);
    });

    test('gets all values', () {
      final entry1 = OTelAPI.baggageEntry('value1', 'metadata1');
      final entry2 = OTelAPI.baggageEntry('value2', 'metadata2');
      
      final baggage = OTelAPI.baggage({
        'key1': entry1,
        'key2': entry2,
      });
      
      final values = baggage.getAllValues();
      expect(values, containsAll(['value1', 'value2']));
      expect(values.length, equals(2));
    });

    test('adds entry with copyWith', () {
      final baggage1 = OTelAPI.baggage();
      final baggage2 = baggage1.copyWith('key1', 'value1', 'metadata1');
      
      expect(baggage1.getEntry('key1'), isNull); // Original unchanged
      expect(baggage2.getEntry('key1')?.value, equals('value1'));
      expect(baggage2.getEntry('key1')?.metadata, equals('metadata1'));
    });

    test('overwrites existing entry with copyWith', () {
      final entry = OTelAPI.baggageEntry('value1', 'metadata1');
      final baggage1 = OTelAPI.baggage({'key1': entry});
      final baggage2 = baggage1.copyWith('key1', 'value2', 'metadata2');
      
      expect(baggage1.getEntry('key1')?.value, equals('value1')); // Original unchanged
      expect(baggage1.getEntry('key1')?.metadata, equals('metadata1'));
      expect(baggage2.getEntry('key1')?.value, equals('value2'));
      expect(baggage2.getEntry('key1')?.metadata, equals('metadata2'));
    });

    test('removes entry with copyWithout', () {
      final entry = OTelAPI.baggageEntry('value1', 'metadata1');
      final baggage1 = OTelAPI.baggage({'key1': entry});
      final baggage2 = baggage1.copyWithout('key1');
      
      expect(baggage1.getEntry('key1')?.value, equals('value1')); // Original unchanged
      expect(baggage2.getEntry('key1'), isNull);
    });

    test('copying without non-existent key returns same instance', () {
      final entry = OTelAPI.baggageEntry('value1', 'metadata1');
      final baggage1 = OTelAPI.baggage({'key1': entry});
      final baggage2 = baggage1.copyWithout('nonexistent');
      
      // Should be equal (though not necessarily identical due to factory methods)
      expect(baggage2.getAllEntries(), equals(baggage1.getAllEntries()));
    });

    test('merges baggages with copyWithBaggage', () {
      final entry1 = OTelAPI.baggageEntry('value1', 'metadata1');
      final entry2 = OTelAPI.baggageEntry('value2', 'metadata2');
      final entry3 = OTelAPI.baggageEntry('value3', 'metadata3');
      
      final baggage1 = OTelAPI.baggage({
        'key1': entry1,
        'key2': entry2,
      });
      
      final baggage2 = OTelAPI.baggage({
        'key2': entry3, // Will override
        'key3': entry3,
      });
      
      final combined = baggage1.copyWithBaggage(baggage2);
      
      expect(combined.getEntry('key1')?.value, equals('value1'));
      expect(combined.getEntry('key2')?.value, equals('value3')); // Overridden
      expect(combined.getEntry('key3')?.value, equals('value3'));
    });

    test('converts to JSON', () {
      final entry1 = OTelAPI.baggageEntry('value1', 'metadata1');
      final entry2 = OTelAPI.baggageEntry('value2', null);
      
      final baggage = OTelAPI.baggage({
        'key1': entry1,
        'key2': entry2,
      });
      
      final json = baggage.toJson();
      
      expect(json['key1']['value'], equals('value1'));
      expect(json['key1']['metadata'], equals('metadata1'));
      expect(json['key2']['value'], equals('value2'));
      expect(json['key2'].containsKey('metadata'), isFalse);
    });

    test('creates from JSON', () {
      final json = {
        'key1': {'value': 'value1', 'metadata': 'metadata1'},
        'key2': {'value': 'value2'},
        'invalid1': 'not a map',
        'invalid2': {'not-value': 'missing-value-key'},
        'invalid3': {'value': 42}, // Non-string value
        'invalid4': {'value': '', 'metadata': 'metadata'}, // Empty value
        'invalid5': {'value': 'value5', 'metadata': 42}, // Non-string metadata
      };
      
      final baggage = Baggage.fromJson(json);
      
      expect(baggage.getEntry('key1')?.value, equals('value1'));
      expect(baggage.getEntry('key1')?.metadata, equals('metadata1'));
      expect(baggage.getEntry('key2')?.value, equals('value2'));
      expect(baggage.getEntry('key2')?.metadata, isNull);
      
      // Invalid entries should be skipped
      expect(baggage.getEntry('invalid1'), isNull);
      expect(baggage.getEntry('invalid2'), isNull);
      expect(baggage.getEntry('invalid3'), isNull);
      expect(baggage.getEntry('invalid4'), isNull);
      expect(baggage.getEntry('invalid5'), isNull);
    });

    test('equals and hashCode work correctly', () {
      final entry1 = OTelAPI.baggageEntry('value1', 'metadata1');
      final entry2 = OTelAPI.baggageEntry('value2', 'metadata2');
      
      final baggage1 = OTelAPI.baggage({
        'key1': entry1,
        'key2': entry2,
      });
      
      final baggage2 = OTelAPI.baggage({
        'key1': entry1,
        'key2': entry2,
      });
      
      final baggage3 = OTelAPI.baggage({
        'key1': entry1,
      });
      
      expect(baggage1, equals(baggage2));
      expect(baggage1.hashCode, equals(baggage2.hashCode));
      expect(baggage1, isNot(equals(baggage3)));
      expect(baggage1.hashCode, isNot(equals(baggage3.hashCode)));
    });

    test('toString returns readable representation', () {
      final entry = OTelAPI.baggageEntry('value1', 'metadata1');
      final baggage = OTelAPI.baggage({'key1': entry});
      
      expect(baggage.toString(), contains('key1'));
      expect(baggage.toString(), contains('value1'));
    });

    test('throws when creating with empty key', () {
      expect(() {
        final baggage = OTelAPI.baggage();
        baggage.copyWith('', 'value');
      }, throwsArgumentError);
    });

    test('throws when creating with empty value', () {
      expect(() {
        final baggage = OTelAPI.baggage();
        baggage.copyWith('key', '');
      }, throwsArgumentError);
    });

    test('fromJson throws when OTelFactory not initialized', () {
      OTelAPI.reset();
      
      expect(() {
        Baggage.fromJson({'key': {'value': 'value'}});
      }, throwsStateError);
    });

    test('copyWith throws when OTelFactory not initialized', () {
      // Create baggage with initialized factory
      final baggage = OTelAPI.baggage();
      
      // Reset to clear factory
      OTelAPI.reset();
      
      expect(() {
        baggage.copyWith('key', 'value');
      }, throwsStateError);
    });

    test('copyWithout throws when OTelFactory not initialized', () {
      // Create baggage with initialized factory
      final entry = OTelAPI.baggageEntry('value', 'metadata');
      final baggage = OTelAPI.baggage({'key': entry});
      
      // Reset to clear factory
      OTelAPI.reset();
      
      expect(() {
        baggage.copyWithout('key');
      }, throwsStateError);
    });


    test('baggage creation and manipulation', () {
      // Create entries
      final entry1 = OTelAPI.baggageEntry('value1', 'metadata1');
      final entry2 = OTelAPI.baggageEntry('value2', 'metadata2');

      // Create baggage with entries
      final baggage = OTelAPI.baggage({
        'key1': entry1,
        'key2': entry2,
      });

      // Verify entries
      expect(baggage.getEntry('key1')?.value, equals('value1'));
      expect(baggage.getEntry('key1')?.metadata, equals('metadata1'));
      expect(baggage.getEntry('key2')?.value, equals('value2'));
      expect(baggage.getEntry('key2')?.metadata, equals('metadata2'));
    });

    test('baggageForMap creates baggage from key-value pairs', () {
      final map = {
        'key1': 'value1',
        'key2': 'value2',
      };

      final baggage = OTelAPI.baggageForMap(map);

      expect(baggage.getEntry('key1')?.value, equals('value1'));
      expect(baggage.getEntry('key2')?.value, equals('value2'));
      // No metadata provided
      expect(baggage.getEntry('key1')?.metadata, isNull);
      expect(baggage.getEntry('key2')?.metadata, isNull);
    });

    test('baggageFromJson creates baggage from JSON', () {
      final json = {
        'key1': {'value': 'value1', 'metadata': 'metadata1'},
        'key2': {'value': 'value2', 'metadata': 'metadata2'},
        'key3': {'metadata': 'metadata3'}, // Invalid entry, missing value
        'key4': 'not-an-object' // Invalid entry, not an object
      };

      final baggage = OTelAPI.baggageFromJson(json);

      // Valid entries are included
      expect(baggage.getEntry('key1')?.value, equals('value1'));
      expect(baggage.getEntry('key1')?.metadata, equals('metadata1'));
      expect(baggage.getEntry('key2')?.value, equals('value2'));
      expect(baggage.getEntry('key2')?.metadata, equals('metadata2'));

      // Invalid entries are skipped
      expect(baggage.getEntry('key3'), isNull);
      expect(baggage.getEntry('key4'), isNull);
    });
  });
}
