// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/src/api/common/any_value.dart';
import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('attribute', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    group('AnyValue tests', () {
      test('unwrap handles all AnyValue types', () {
        expect(AnyValue.empty().unwrap(), isNull);
        expect(AnyValue.fromString('test').unwrap(), equals('test'));
        expect(AnyValue.fromBool(true).unwrap(), equals(true));
        expect(AnyValue.fromInt(42).unwrap(), equals(42));
        expect(AnyValue.fromDouble(3.14).unwrap(), equals(3.14));
        expect(AnyValue.fromList([AnyValue.fromString('x')]).unwrap(),
            equals(['x']));
        expect(AnyValue.fromMap({'k': AnyValue.fromInt(1)}).unwrap(),
            equals({'k': 1}));
        expect(AnyValue.fromBytes([0, 1]).unwrap(), equals([0, 1]));
      });

      test('toJson is implemented', () {
        final anyVal = AnyValue.fromMap({'k': AnyValue.fromInt(1)});
        expect(anyVal.toJson(), equals({'k': 1}));
      });

      test('fromObject throws on invalid map key', () {
        expect(() => AnyValue.fromObject({1: 'val'}),
            throwsA(isA<ArgumentError>()));
      });

      test('equality and hashCode', () {
        final nullVal1 = AnyValue.empty();
        final nullVal2 = AnyValue.fromObject(null);
        expect(nullVal1, equals(nullVal2));
        expect(nullVal1.hashCode, equals(nullVal2.hashCode));
        expect(nullVal1.value, isNull);

        final mapVal1 = AnyValue.fromMap({'a': AnyValue.fromInt(1)});
        final mapVal2 = AnyValue.fromObject({'a': 1});
        expect(mapVal1, equals(mapVal2));
        expect(mapVal1.hashCode, equals(mapVal2.hashCode));

        final bytesVal1 = AnyValue.fromBytes([1, 2]);
        final bytesVal2 = AnyValue.fromBytes([1, 2]);
        expect(bytesVal1, equals(bytesVal2));
        expect(bytesVal1.hashCode, equals(bytesVal2.hashCode));

        final arrayVal1 = AnyValue.fromList([AnyValue.fromInt(1)]);
        final arrayVal2 = AnyValue.fromObject([1]);
        expect(arrayVal1, equals(arrayVal2));
        expect(arrayVal1.hashCode, equals(arrayVal2.hashCode));
      });
    });

    group('equality', () {
      test('identical collections are equal', () {
        final stringList = OTelAPI.attributeStringList(
            'test-string-list', ['foo', 'bar', 'baz']);
        final boolList =
            OTelAPI.attributeBoolList('test-bool-list', [true, false, true]);
        final intList = OTelAPI.attributeIntList('test-int-list', [1, 2, 3]);
        final doubleList =
            OTelAPI.attributeDoubleList('test-double-list', [1.1, 2.2, 3.3]);
        final stringList2 = OTelAPI.attributeStringList(
            'test-string-list', ['foo', 'bar', 'baz']);
        final boolList2 =
            OTelAPI.attributeBoolList('test-bool-list', [true, false, true]);
        final intList2 = OTelAPI.attributeIntList('test-int-list', [1, 2, 3]);
        final doubleList2 =
            OTelAPI.attributeDoubleList('test-double-list', [1.1, 2.2, 3.3]);
        expect(stringList, equals(stringList2));
        expect(stringList.hashCode, equals(stringList2.hashCode));
        expect(intList, equals(intList2));
        expect(intList.hashCode, equals(intList2.hashCode));
        expect(boolList, equals(boolList2));
        expect(boolList.hashCode, equals(boolList2.hashCode));
        expect(doubleList, equals(doubleList2));
        expect(doubleList.hashCode, equals(doubleList2.hashCode));
      });

      test('different collection orders are not equal', () {
        final stringList = OTelAPI.attributeStringList(
            'test-string-list', ['foo', 'bar', 'baz']);
        final boolList =
            OTelAPI.attributeBoolList('test-bool-list', [true, false, true]);
        final intList = OTelAPI.attributeIntList('test-int-list', [1, 2, 3]);
        final doubleList =
            OTelAPI.attributeDoubleList('test-double-list', [1.1, 2.2, 3.3]);
        final stringList2 = OTelAPI.attributeStringList(
            'test-string-list', ['foo2', 'bar2', 'baz2']);
        final boolList2 =
            OTelAPI.attributeBoolList('test-bool-list', [true, false, false]);
        final intList2 = OTelAPI.attributeIntList('test-int-list', [2, 3, 4]);
        final doubleList2 =
            OTelAPI.attributeDoubleList('test-double-list', [1.1, 2.22, 3.33]);
        expect(stringList, isNot(equals(stringList2)));
        expect(stringList.hashCode, isNot(equals(stringList2.hashCode)));
        expect(intList, isNot(equals(intList2)));
        expect(intList.hashCode, isNot(equals(intList2.hashCode)));
        expect(boolList, isNot(equals(boolList2)));
        expect(boolList.hashCode, isNot(equals(boolList2.hashCode)));
        expect(doubleList, isNot(equals(doubleList2)));
        expect(doubleList.hashCode, isNot(equals(doubleList2.hashCode)));
      });

      test('empty collections are valid', () {
        final stringList = OTelAPI.attributeStringList('foo', []);
        final intList = OTelAPI.attributeIntList('foo', []);
        final boolList = OTelAPI.attributeBoolList('foo', []);
        final doubleList = OTelAPI.attributeDoubleList('foo', []);

        expect((stringList.value as AnyValueArray).value, isEmpty);
        expect((intList.value as AnyValueArray).value, isEmpty);
        expect((boolList.value as AnyValueArray).value, isEmpty);
        expect((doubleList.value as AnyValueArray).value, isEmpty);
      });
    });
  });
}
