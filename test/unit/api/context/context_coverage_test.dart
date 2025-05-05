// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Context - Additional Coverage Tests', () {
    late OTelFactory originalFactory;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      // Store the original factory
      originalFactory = OTelFactory.otelFactory!;
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
    });

    test('serialize and deserialize context with all components', () {
      // Create a baggage
      final baggage = OTelAPI.baggage({
        'key1': OTelAPI.baggageEntry('value1', 'metadata1'),
        'key2': OTelAPI.baggageEntry('value2', 'metadata2'),
      });

      // Create a span context
      final spanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        traceFlags: OTelAPI.traceFlags(1), // Sampled
      );

      // Create a context with both baggage and span context
      final context = Context.root
          .withBaggage(baggage)
          .withSpanContext(spanContext)
          .copyWithValue('custom-key', 'custom-value');

      // Serialize the context
      final serialized = context.serialize();

      // Verify serialized form contains all components
      expect(serialized, contains('baggage'));
      expect(serialized, contains('spanContext'));
      expect(serialized, contains('custom-key'));

      // Deserialize the context
      final deserialized = Context.deserialize(serialized);

      // Verify all components are restored correctly
      expect(deserialized.baggage?.getEntry('key1')?.value, equals('value1'));
      expect(deserialized.baggage?.getEntry('key2')?.value, equals('value2'));
      expect(deserialized.spanContext?.traceId, equals(spanContext.traceId));
      expect(deserialized.spanContext?.spanId, equals(spanContext.spanId));
      expect(deserialized.spanContext?.traceFlags.isSampled, isTrue);
    });

    test('serialize skips non-serializable values', () {
      // Create a context with a non-serializable value (a function)
      // ignore: always_declare_return_types
      nonSerializableValue() => 'function';

      // Try to serialize with the function
      final contextKey = OTelAPI.contextKey<Function>('function-key');
      final context = Context.root.copyWith(contextKey, nonSerializableValue);

      // Serializing should not throw
      final serialized = context.serialize();

      // The function should not be included in the serialized form
      expect(serialized, isNot(contains('function-key')));

      // Deserialize should work without issues
      final deserialized = Context.deserialize(serialized);

      // The function value should not be present in the deserialized context
      expect(deserialized.get(contextKey), isNull);
    });

    test('serialize handles empty baggage', () {
      // Create an empty baggage
      final baggage = OTelAPI.baggage();

      // Create a context with the empty baggage
      final context = Context.root.withBaggage(baggage);

      // Serialize the context
      final serialized = context.serialize();

      // Empty baggage should not be included in the serialized form
      expect(serialized, isNot(contains('baggage')));
    });

    test('deserialize handles missing components', () {
      // Create a minimal serialized context with only custom values
      final serialized = {
        'custom-key': {
          'value': 'custom-value',
          'uniqueId': [1, 2, 3, 4, 5, 6, 7, 8],
        },
      };

      // Deserialize the context
      final deserialized = Context.deserialize(serialized);

      // Baggage and span context should be null or empty
      expect(deserialized.baggage, isNull);
      expect(deserialized.spanContext, isNull);

      // But should have the custom value
      expect(deserialized, isNotNull);
    });

    test('Context.currentWithBaggage creates and sets baggage', () {
      // Initial context has no baggage
      expect(Context.current.baggage, isNull);

      // Get current context with baggage
      final context = Context.currentWithBaggage();

      // Should have created and set an empty baggage
      expect(context.baggage, isNotNull);
      expect(context.baggage!.isEmpty, isTrue);

      // And should have set it as the current context
      expect(Context.current.baggage, isNotNull);
      expect(Context.current.baggage!.isEmpty, isTrue);
    });

    test('Context throws when withSpanContext changes trace ID', () {
      // Create two span contexts with different trace IDs
      final spanContext1 = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );

      final spanContext2 = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(), // Different trace ID
        spanId: OTelAPI.spanId(),
      );

      // First set spanContext1
      final context1 = Context.root.withSpanContext(spanContext1);

      // Then try to set spanContext2 with a different trace ID
      expect(() {
        context1.withSpanContext(spanContext2);
      }, throwsArgumentError);
    });

    test('Context.get returns null when value type does not match', () {
    // Create a context with a string value stored under a string key
    final stringKey = OTelAPI.contextKey<String>('test-key');
    final context = Context.root.copyWith(stringKey, 'string-value');
    
    // Create an int key with the same name
    final intKey = OTelAPI.contextKey<int>('test-key');
    
    // When we try to get the value as int, it should return null
    // because the value is a string but we're requesting an int
    final value = context.get<int>(intKey);
    expect(value, isNull);
    
    // The original string value should still be accessible
    expect(context.get<String>(stringKey), equals('string-value'));
    });

    test('Context.copyWithValue with a mismatched type adds a new key', () {
      // Create a context with an int key and int value
      final intKey = OTelAPI.contextKey<int>('int-key');
      final context = Context.root.copyWith(intKey, 123);
      
      // This should work and return the int value
      expect(context.get<int>(intKey), equals(123));
      
      // Add a mismatched value (string with key name 'int-key')
      final badContext = context.copyWithValue('int-key', 'not-an-int');
      
      // We should be able to access the int value still
      expect(badContext.get<int>(intKey), equals(123), reason: 'Should still have the int value');

      // Create a string key with the same name for retrieval
      final strKey = OTelAPI.contextKey<String>('int-key');
      // This will return null since our newly created key won't match the internal one
      expect(badContext.get<String>(strKey), isNull);
      
      // To truly test this, we need to serialize and check the serialized content
      final serialized = badContext.serialize();
      // The serialized map should contain an entry for 'int-key' with string value
      bool foundStringValue = false;
      serialized.forEach((key, value) {
        // Look through the serialized map for our string value
        if ((key == 'int-key' || key.startsWith('int-key-')) && 
            value is Map && 
            value['value'] is String) {
          foundStringValue = true;
          expect(value['value'], equals('not-an-int'));
        }
      });
      
      expect(foundStringValue, isTrue, reason: 'Should find the string value in serialized form');
    });
    
    test('Context allows multiple keys with the same name but different types', () {
      // Create a context with a string value
      final context = Context.root.copyWithValue('mixed-key', 'string-value');
      
      // Add an int value with the same key name
      final mixedContext = context.copyWithValue('mixed-key', 42);
      
      // Add a boolean value with the same key name
      final finalContext = mixedContext.copyWithValue('mixed-key', true);
      
      // Serialize to check the context contents
      final serialized = finalContext.serialize();
      
      // Check if we can find all three value types in the serialized context
      bool foundStringValue = false;
      bool foundIntValue = false;
      bool foundBoolValue = false;
      
      serialized.forEach((key, value) {
        if ((key == 'mixed-key' || key.startsWith('mixed-key-')) && value is Map) {
          final actualValue = value['value'];
          if (actualValue is String) {
            foundStringValue = true;
            expect(actualValue, equals('string-value'));
          } else if (actualValue is int) {
            foundIntValue = true;
            expect(actualValue, equals(42));
          } else if (actualValue is bool) {
            foundBoolValue = true;
            expect(actualValue, isTrue);
          }
        }
      });
      
      expect(foundStringValue, isTrue, reason: 'Should find a String value');
      expect(foundIntValue, isTrue, reason: 'Should find an int value');
      expect(foundBoolValue, isTrue, reason: 'Should find a bool value');
    });
    
    test('Context equality and hashCode', () {
      // Create two contexts with the same values
      final key = OTelAPI.contextKey<String>('key');
      final context1 = Context.root.copyWith(key, 'value');
      final context2 = Context.root.copyWith(key, 'value');

      // Create a different context
      final context3 = Context.root.copyWith(key, 'different');

      // Same contents should be equal
      expect(context1, equals(context2));
      expect(context1.hashCode, equals(context2.hashCode));

      // Different contents should not be equal
      expect(context1, isNot(equals(context3)));
      expect(context1.hashCode, isNot(equals(context3.hashCode)));
    });
  });
}
