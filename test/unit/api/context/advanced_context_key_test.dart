// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

class ComplexValue {
  final String data;
  final int number;

  ComplexValue(this.data, this.number);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplexValue &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          number == other.number;

  @override
  int get hashCode => data.hashCode ^ number.hashCode;

  Map<String, dynamic> toJson() => {'data': data, 'number': number};
}

void main() {
  group('Advanced Context Key Tests', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('handles null values explicitly set', () {
      final key = OTelAPI.contextKey<Object?>('nullable-key');
      final context = OTelAPI.context().copyWith(key, null);

      expect(context.get(key), isNull);
    });

    test('maintains type safety with complex objects', () {
      final key = OTelAPI.contextKey<ComplexValue>('complex-key');
      final value = ComplexValue('test', 42);
      final context = OTelAPI.context().copyWith(key, value);

      final retrieved = context.get(key);
      expect(retrieved, isA<ComplexValue>());
      expect(retrieved?.data, equals('test'));
      expect(retrieved?.number, equals(42));
    });

    test('supports key overriding with different types', () {
      final stringKey = OTelAPI.contextKey<String>('shared-key');
      final intKey = OTelAPI.contextKey<int>('shared-key');

      final context = OTelAPI.context()
          .copyWith(stringKey, 'string-value')
          .copyWith(intKey, 42);

      expect(context.get(stringKey), equals('string-value'));
      expect(context.get<int>(intKey), equals(42));
    });

    test('allows duplicate keys', () {
      final stringKey = OTelAPI.contextKey<String>('shared-key');
      final stringKey2 = OTelAPI.contextKey<String>('shared-key');

      final context = OTelAPI.context()
          .copyWith(stringKey, 'string-value')
          .copyWith(stringKey2, 'string-value2');
      expect(context.get(stringKey), equals('string-value'));
      expect(context.get(stringKey2), equals('string-value2'));
    });

    test('allows duplicate keys of different types', () {
      final stringKey = OTelAPI.contextKey<String>('shared-key');
      final intKey = OTelAPI.contextKey<int>('shared-key');

      final context = OTelAPI.context()
          .copyWith(stringKey, 'string-value')
          .copyWith(intKey, 42);
      expect(context.get(stringKey), equals('string-value'));
      expect(context.get<int>(intKey), equals(42));
    });

    test('preserves order of values', () {
      final key1 = OTelAPI.contextKey<String>('key1');
      final key2 = OTelAPI.contextKey<int>('key2');
      final key3 = OTelAPI.contextKey<bool>('key3');

      final context = OTelAPI.context()
          .copyWith(key1, 'value1')
          .copyWith(key2, 2)
          .copyWith(key3, true);

      final values = [
        context.get(key1),
        context.get(key2),
        context.get(key3),
      ];
      expect(values, orderedEquals(['value1', 2, true]));
    });

    test('handles removing values', () {
      final key = OTelAPI.contextKey<String>('removable-key');
      final context = OTelAPI.context().copyWith(key, 'value');
      final modifiedContext = context.copyWith(key, null);

      expect(context.get(key), equals('value'));
      expect(modifiedContext.get(key), isNull);
    });

    test('maintains immutability when removing values', () {
      final key = OTelAPI.contextKey<String>('test-key');
      final originalContext = OTelAPI.context().copyWith(key, 'value');
      final modifiedContext = originalContext.copyWith(key, null);

      expect(originalContext.get(key), equals('value'));
      expect(modifiedContext.get(key), isNull);
    });

    test('handles multiple value operations in chain', () {
      final key1 = OTelAPI.contextKey<String>('key1');
      final key2 = OTelAPI.contextKey<int>('key2');

      final contextA = OTelAPI.context().copyWith(key1, 'value1');
      final contextB = contextA.copyWith(key2, 2);
      final contextC = contextB.copyWith(key1, null);
      final contextD = contextC.copyWith(key1, 'new-value');
      final contextE = contextD.copyWith(key2, null);

      expect(contextE.get(key1), equals('new-value'));
      expect(contextE.get(key2), isNull);
    });

    test('preserves type safety across context chains', () {
      final stringKey = OTelAPI.contextKey<String?>('key');
      final intKey = OTelAPI.contextKey<int>('key');

      final context1 = OTelAPI.context().copyWith(stringKey, 'value');
      final context2 = context1.copyWith(intKey, 42);
      final context3 = context2.copyWith(stringKey, null);

      expect(context1.get(stringKey), equals('value'));
      expect(context1.get(intKey), isNull);

      expect(context2.get(stringKey), equals('value'));
      expect(context2.get(intKey), equals(42));

      expect(context3.get(stringKey), isNull);
      expect(context3.get(intKey), equals(42));
    });
  });
}
