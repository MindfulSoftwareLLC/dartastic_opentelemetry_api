// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

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

      test('empty collections throw ArgumentError', () {
        expect(
          () => OTelAPI.attributeStringList('foo', []),
          throwsArgumentError,
        );
        expect(
          () => OTelAPI.attributeIntList('foo', []),
          throwsArgumentError,
        );
        expect(
          () => OTelAPI.attributeBoolList('foo', []),
          throwsArgumentError,
        );
        expect(
          () => OTelAPI.attributeDoubleList('foo', []),
          throwsArgumentError,
        );
      });
    });
  });
}
