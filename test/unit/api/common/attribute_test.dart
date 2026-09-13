// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';

import 'package:dartastic_opentelemetry_api/src/api/common/any_value.dart';
import 'package:dartastic_opentelemetry_api/src/api/common/attributes.dart';
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
        expect(AnyValue.nullValue().unwrap(), isNull);
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
        final nullVal1 = AnyValue.nullValue();
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

    group('AnyValue bytes', () {
      test('fromObject maps Uint8List to AnyValueBytes, not an int array', () {
        final value = AnyValue.fromObject(Uint8List.fromList([1, 2, 3]));
        expect(value, isA<AnyValueBytes>());
        expect(value.unwrap(), equals([1, 2, 3]));
      });

      test('fromObject still maps a plain List<int> to an array', () {
        final value = AnyValue.fromObject([1, 2, 3]);
        expect(value, isA<AnyValueArray>());
        expect(
            (value as AnyValueArray).value, everyElement(isA<AnyValueInt>()));
      });

      test('fromObject maps a nested Uint8List to AnyValueBytes', () {
        final value = AnyValue.fromObject({
          'payload': Uint8List.fromList([255, 0]),
        }) as AnyValueMap;
        expect(value.value['payload'], isA<AnyValueBytes>());
      });

      test('unwrap still returns the raw bytes', () {
        expect(AnyValue.fromBytes([1, 2, 3]).unwrap(), equals([1, 2, 3]));
      });

      test('toJson returns the raw bytes, same as unwrap', () {
        // Not base64: toJson emits plain Dart objects and List<int> is
        // JSON-encodable. The tagged OTLP wire encoding is the exporter's.
        final bytes = [0, 1, 2, 250, 255];
        final value = AnyValue.fromBytes(bytes);
        expect(value.toJson(), equals(bytes));
        expect(value.toJson(), equals(value.unwrap()));
      });

      test('toJson returns raw bytes when nested too', () {
        final value = AnyValueMap({
          'payload': AnyValueBytes([1, 2, 3])
        });
        expect(
            value.toJson(),
            equals({
              'payload': [1, 2, 3],
            }));
      });

      test('unwrap returns raw bytes at every nesting depth', () {
        final map = AnyValueMap({
          'payload': AnyValueBytes([1, 2, 3])
        });
        expect(
            map.unwrap(),
            equals({
              'payload': [1, 2, 3],
            }));

        final array = AnyValueArray([
          AnyValueBytes([1, 2, 3]),
        ]);
        expect(
            array.unwrap(),
            equals([
              [1, 2, 3],
            ]));

        final nested = AnyValueArray([
          AnyValueMap({
            'payload': AnyValueBytes([1, 2, 3])
          }),
        ]);
        expect(
            nested.unwrap(),
            equals([
              {
                'payload': [1, 2, 3],
              },
            ]));
      });

      test('an out-of-range positive element is rejected, not masked', () {
        // Uint8List.fromList would silently store 44 here.
        expect(() => AnyValueBytes([1, 300]), throwsA(isA<ArgumentError>()));
        expect(() => AnyValue.fromBytes([256]), throwsA(isA<ArgumentError>()));
      });

      test('a negative element is rejected', () {
        expect(() => AnyValueBytes([-1]), throwsA(isA<ArgumentError>()));
      });

      test('the boundary values 0 and 255 are accepted', () {
        expect(AnyValueBytes([0, 255]).value, equals([0, 255]));
      });

      test('a Uint8List is accepted without scanning', () {
        final value = AnyValueBytes(Uint8List.fromList([0, 128, 255]));
        expect(value.value, equals([0, 128, 255]));
      });

      test('the fromBytes factory rejects out-of-range elements', () {
        expect(() => AnyValue.fromBytes([999]), throwsA(isA<ArgumentError>()));
      });

      // An out-of-range list cannot reach AnyValueBytes through Attributes.of:
      // a plain List<int> converts via the array branch, and a Uint8List is in
      // range by construction. Bytes only arrive out of range via the explicit
      // bytes constructor or factory, which throw (above).
      test('Attributes.of routes an out-of-range int list to an array', () {
        final attrs = Attributes.of({
          'nums': <int>[999, 1000],
          'good': 'kept',
        });
        expect(attrs.getIntList('nums'), equals([999, 1000]));
        expect(attrs.getString('good'), equals('kept'));
      });

      test('toJson leaves non-bytes values identical to unwrap', () {
        final value = AnyValueMap({
          'a': const AnyValueInt(1),
          'b': AnyValueArray([const AnyValueString('x')]),
        });
        expect(value.toJson(), equals(value.unwrap()));
      });
    });

    group('AnyValue immutability', () {
      test('AnyValueArray copies the caller list and is unmodifiable', () {
        final source = <AnyValue>[const AnyValueInt(1)];
        final value = AnyValueArray(source);
        final hashBefore = value.hashCode;

        source.add(const AnyValueInt(2));

        expect(value.value, hasLength(1));
        expect(value.hashCode, equals(hashBefore));
        expect(() => value.value.add(const AnyValueInt(3)),
            throwsUnsupportedError);
      });

      test('AnyValueMap copies the caller map and is unmodifiable', () {
        final source = <String, AnyValue>{'a': const AnyValueInt(1)};
        final value = AnyValueMap(source);
        final hashBefore = value.hashCode;

        source['b'] = const AnyValueInt(2);

        expect(value.value, hasLength(1));
        expect(value.hashCode, equals(hashBefore));
        expect(() => value.value['c'] = const AnyValueInt(3),
            throwsUnsupportedError);
      });

      test('AnyValueBytes copies the caller list and is unmodifiable', () {
        final source = <int>[1, 2];
        final value = AnyValueBytes(source);
        final hashBefore = value.hashCode;

        source.add(3);

        expect(value.value, equals([1, 2]));
        expect(value.hashCode, equals(hashBefore));
        expect(() => value.value.add(4), throwsUnsupportedError);
      });

      test('a mutated source list does not corrupt Set membership', () {
        final source = <AnyValue>[const AnyValueInt(1)];
        final value = AnyValueArray(source);
        final set = {value};

        source.add(const AnyValueInt(2));

        expect(set.contains(value), isTrue);
        expect(set.contains(AnyValueArray([const AnyValueInt(1)])), isTrue);
      });
    });

    group('AnyValue depth guard', () {
      // Mirrors AnyValue._maxDepth, which is private.
      const maxDepth = 32;

      // Each helper builds a spine of exactly [levels] values: `levels - 1`
      // nested containers wrapped around a leaf, so the boundary can be
      // asserted exactly rather than approximately.
      Object nestedList(int levels) {
        Object current = 'leaf';
        for (var i = 1; i < levels; i++) {
          current = <Object>[current];
        }
        return current;
      }

      Object nestedMap(int levels) {
        Object current = 'leaf';
        for (var i = 1; i < levels; i++) {
          current = <String, Object>{'k': current};
        }
        return current;
      }

      AnyValue nestedArray(int levels) {
        AnyValue current = const AnyValueString('leaf');
        for (var i = 1; i < levels; i++) {
          current = AnyValueArray([current]);
        }
        return current;
      }

      test('fromObject accepts exactly maxDepth levels of lists', () {
        expect(
            () => AnyValue.fromObject(nestedList(maxDepth)), returnsNormally);
      });

      test('fromObject throws at maxDepth + 1 levels of lists', () {
        expect(() => AnyValue.fromObject(nestedList(maxDepth + 1)),
            throwsA(isA<ArgumentError>()));
      });

      test('fromObject accepts exactly maxDepth levels of maps', () {
        expect(() => AnyValue.fromObject(nestedMap(maxDepth)), returnsNormally);
      });

      test('fromObject throws at maxDepth + 1 levels of maps', () {
        expect(() => AnyValue.fromObject(nestedMap(maxDepth + 1)),
            throwsA(isA<ArgumentError>()));
      });

      test('unwrap accepts exactly maxDepth levels', () {
        expect(nestedArray(maxDepth).unwrap, returnsNormally);
      });

      test('unwrap throws at maxDepth + 1 levels', () {
        expect(nestedArray(maxDepth + 1).unwrap, throwsA(isA<ArgumentError>()));
      });

      // toString must never throw: it runs in debuggers and error messages,
      // where an exception is worse than a truncated rendering.
      test('toString truncates instead of throwing on a deep value', () {
        final deep = nestedArray(100);
        expect(deep.toString, returnsNormally);
        expect(deep.toString(), contains('...'));
      });

      test('toString renders a shallow value in full', () {
        final value = AnyValueArray([
          const AnyValueString('a'),
          AnyValueMap({'k': const AnyValueInt(1)}),
        ]);
        expect(value.toString(), equals('[a, {k: 1}]'));
      });

      test('attrsFromMap reports rather than throws on excessive nesting', () {
        final attrs = Attributes.of({
          'deep': nestedList(maxDepth + 1),
          'good': 'kept',
        });
        expect(attrs.getString('good'), equals('kept'));
        expect(attrs.toMap().containsKey('deep'), isFalse);
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

      test('empty collections are stored per OTel spec', () {
        final stringList = OTelAPI.attributeStringList('foo', []);
        expect((stringList.value as AnyValueArray).value, isEmpty);
        expect(stringList.key, equals('foo'));

        final intList = OTelAPI.attributeIntList('foo', []);
        expect((intList.value as AnyValueArray).value, isEmpty);

        final boolList = OTelAPI.attributeBoolList('foo', []);
        expect((boolList.value as AnyValueArray).value, isEmpty);

        final doubleList = OTelAPI.attributeDoubleList('foo', []);
        expect((doubleList.value as AnyValueArray).value, isEmpty);
      });
    });
  });
}
