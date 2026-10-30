// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dartastic_opentelemetry_api/src/api/common/any_value.dart';
import 'package:dartastic_opentelemetry_api/src/api/common/attributes.dart';
import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

AnyValueBytes _bytes(List<int> value) =>
    AnyValue.fromBytes(value) as AnyValueBytes;

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

      test('fromObject stringifies non-String map keys', () {
        final val = AnyValue.fromObject({1: 'val'}) as AnyValueMap;
        expect(val.value.keys.first, equals('1'));
        expect(val.value['1']!.unwrap(), equals('val'));
      });

      test('fromObject reports map key collisions after stringification', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final val = AnyValue.fromObject({1: 'a', '1': 'b'}) as AnyValueMap;
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
        // The second entry overwrites the first.
        expect(val.value['1']!.unwrap(), equals('b'));
        expect(val.value, hasLength(1));
      });

      test('fromObject handles mixed numeric lists as separate types', () {
        final val = AnyValue.fromObject([1, 2.5]) as AnyValueArray;
        expect(val.value, hasLength(2));
        expect(val.value[0], isA<AnyValueInt>());
        expect(val.value[1], isA<AnyValueDouble>());
      });

      test('fromObject handles objects whose toString throws', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final result = AnyValue.fromObject(_ThrowingToString());
        expect(result, isA<AnyValueNull>());
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());

        reported.clear();
        final mapResult =
            AnyValue.fromObject({_ThrowingToString(): 'val'}) as AnyValueMap;
        expect(mapResult.value, isEmpty);
        expect(reported, hasLength(1));

        reported.clear();
        final attrs =
            Attributes.fromJson({'bad': _ThrowingToString(), 'good': 'kept'});
        expect(attrs.getString('good'), equals('kept'));
        expect(attrs.toMap()['bad']?.value, isA<AnyValueNull>());
        expect(reported, hasLength(1));
      });

      test('equality and hashCode', () {
        final nullVal1 = AnyValue.nullValue();
        final nullVal2 = AnyValue.fromObject(null);
        expect(nullVal1, equals(nullVal2));
        expect(nullVal1.hashCode, equals(nullVal2.hashCode));
        expect((nullVal1 as AnyValueNull).value, isNull);

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
          'payload': _bytes([1, 2, 3])
        });
        expect(
            value.toJson(),
            equals({
              'payload': [1, 2, 3],
            }));
      });

      test('unwrap returns raw bytes at every nesting depth', () {
        final map = AnyValueMap({
          'payload': _bytes([1, 2, 3])
        });
        expect(
            map.unwrap(),
            equals({
              'payload': [1, 2, 3],
            }));

        final array = AnyValueArray([
          _bytes([1, 2, 3]),
        ]);
        expect(
            array.unwrap(),
            equals([
              [1, 2, 3],
            ]));

        final nested = AnyValueArray([
          AnyValueMap({
            'payload': _bytes([1, 2, 3])
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

      test(
          'fromBytes rejects out-of-range elements with a report and returns AnyValueNull',
          () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final result256 = AnyValue.fromBytes([256]);
        expect(result256, isA<AnyValueNull>());
        expect(reported, hasLength(1));
        expect(reported.first, isA<ArgumentError>());

        final resultNeg = AnyValue.fromBytes([-1]);
        expect(resultNeg, isA<AnyValueNull>());
        expect(reported, hasLength(2));
        expect(reported.last, isA<ArgumentError>());
      });

      test('fromBytes reports an unreadable list and returns AnyValueNull', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final result = AnyValue.fromBytes(_ThrowingByteList());

        expect(result, isA<AnyValueNull>());
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });

      test('fromBytes copies the same values it validates', () {
        final result = AnyValue.fromBytes(_ChangingByteList());

        expect(result, isA<AnyValueBytes>());
        expect(result.unwrap(), equals([1]));
      });

      test('the boundary values 0 and 255 are accepted', () {
        expect(_bytes([0, 255]).value, equals([0, 255]));
        expect(AnyValue.fromBytes([0, 255]), isA<AnyValueBytes>());
      });

      test('a Uint8List is accepted', () {
        final value = _bytes(Uint8List.fromList([0, 128, 255]));
        expect(value.value, equals([0, 128, 255]));
        final fromBytesVal =
            AnyValue.fromBytes(Uint8List.fromList([0, 128, 255]));
        expect(fromBytesVal, isA<AnyValueBytes>());
      });

      // An out-of-range list cannot reach AnyValueBytes through Attributes.of:
      // a plain List<int> converts via the array branch, and a Uint8List is in
      // range by construction. Explicit byte creation validates through
      // AnyValue.fromBytes.
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
        final value = _bytes(source);
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

      test('fromObject reports at maxDepth + 1 levels of lists', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final result = AnyValue.fromObject(nestedList(maxDepth + 1));

        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
        var curr = result;
        for (var i = 0; i < maxDepth; i++) {
          curr = (curr as AnyValueArray).value.first;
        }
        expect(curr, isA<AnyValueNull>());
      });

      test('fromObject accepts exactly maxDepth levels of maps', () {
        expect(() => AnyValue.fromObject(nestedMap(maxDepth)), returnsNormally);
      });

      test('fromObject reports at maxDepth + 1 levels of maps', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final result = AnyValue.fromObject(nestedMap(maxDepth + 1));

        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
        var curr = result;
        for (var i = 0; i < maxDepth; i++) {
          curr = (curr as AnyValueMap).value['k']!;
        }
        expect(curr, isA<AnyValueNull>());
      });

      test('unwrap accepts exactly maxDepth levels', () {
        expect(nestedArray(maxDepth).unwrap, returnsNormally);
      });

      test('unwrap reports at maxDepth + 1 levels', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, stackTrace) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final unwrapped = nestedArray(maxDepth + 1).unwrap();

        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
        var curr = unwrapped;
        for (var i = 0; i < maxDepth; i++) {
          curr = (curr as List).first;
        }
        expect(curr, isNull);
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
        expect(value.toString(), equals('["a", {k: 1}]'));
      });

      test('toString leaves a top-level String bare', () {
        expect(const AnyValueString('x').toString(), equals('x'));
      });

      test('toString quotes nested Strings so commas are unambiguous', () {
        final oneElement = AnyValueArray([const AnyValueString('a, b')]);
        final twoElements = AnyValueArray([
          const AnyValueString('a'),
          const AnyValueString('b'),
        ]);

        expect(oneElement.toString(), equals('["a, b"]'));
        expect(twoElements.toString(), equals('["a", "b"]'));
        expect(oneElement.toString(), isNot(equals(twoElements.toString())));
      });

      test('toString quotes Strings nested in a map value', () {
        final value = AnyValueMap({'k': const AnyValueString('v')});
        expect(value.toString(), equals('{k: "v"}'));
      });

      test('toString renders bytes as a length, not their contents', () {
        final big = _bytes(List<int>.filled(1000000, 7));
        final rendered = big.toString();

        expect(rendered, equals('<1000000 bytes>'));
        expect(rendered.length, lessThan(40));
        expect(rendered, contains('1000000'));
      });

      test('nested bytes also render as a length', () {
        final value = AnyValueMap({
          'payload': _bytes([1, 2, 3]),
        });
        expect(value.toString(), equals('{payload: <3 bytes>}'));
      });

      test('attrsFromMap reports rather than throws on excessive nesting', () {
        final attrs = Attributes.of({
          'deep': nestedList(maxDepth + 1),
          'good': 'kept',
        });
        expect(attrs.getString('good'), equals('kept'));
        expect(attrs.toMap().containsKey('deep'), isTrue,
            reason: 'attribute is kept but truncated');
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

    group('AnyValue cycle and breadth protection (Item 1)', () {
      test('self-containing list twice finishes without hang and reports twice',
          timeout: const Timeout(Duration(seconds: 5)), () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final l = <Object?>[];
        l
          ..add(l)
          ..add(l);
        expect(() => Attributes.of({'x': l}), returnsNormally);
        expect(reported, hasLength(2));
        expect(reported[0], isA<ArgumentError>());
        expect(reported[1], isA<ArgumentError>());
      });

      test('map containing itself finishes without hang and reports once',
          timeout: const Timeout(Duration(seconds: 5)), () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final m = <String, Object?>{};
        m['self'] = m;
        expect(() => Attributes.of(m), returnsNormally);
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });

      test('mutual cycle a -> b -> a reports once and does not hang',
          timeout: const Timeout(Duration(seconds: 5)), () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final a = <Object?>[];
        final b = <Object?>[];
        a.add(b);
        b.add(a);

        expect(() => Attributes.of({'k': a}), returnsNormally);
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });

      test('shared non-cyclic child [child, child] gives no report', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final child = ['a', 'b'];
        final list = [child, child];

        expect(() => Attributes.of({'k': list}), returnsNormally);
        expect(reported, isEmpty);
      });

      test('depth 33 nesting still gives exactly one report', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        Object current = 'leaf';
        for (var i = 1; i < 33; i++) {
          current = <Object>[current];
        }

        expect(() => Attributes.of({'k': current}), returnsNormally);
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });
    });

    group('AnyValue _unwrap depth guard re-report fix (Item 2)', () {
      test(
          'Attributes.of nested(33) then create + toJson + toString + toJson produces 1 report in total',
          () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        Object current = 'leaf';
        for (var i = 1; i < 33; i++) {
          current = <Object>[current];
        }

        final attrs = Attributes.of({'deep': current});
        expect(reported, hasLength(1));

        attrs.toJson();
        expect(reported, hasLength(1));

        attrs.toString();
        expect(reported, hasLength(1));

        attrs.toJson();
        expect(reported, hasLength(1));
      });
    });

    group('Iterable and Set support (Item 5)', () {
      test('Set becomes AnyValueArray', () {
        final result = AnyValue.fromObject({'a', 'b'});
        expect(result, isA<AnyValueArray>());
        expect((result as AnyValueArray).value.map((e) => e.unwrap()).toSet(),
            equals({'a', 'b'}));
      });

      test('lazy map(...) iterable becomes AnyValueArray', () {
        final result = AnyValue.fromObject([1, 2].map((e) => e * 2));
        expect(result, isA<AnyValueArray>());
        expect((result as AnyValueArray).value.map((e) => e.unwrap()).toList(),
            equals([2, 4]));
      });

      test('nested Set inside a Map becomes AnyValueArray', () {
        final result = AnyValue.fromObject({
          's': {1, 2}
        });
        expect(result, isA<AnyValueMap>());
        final map = result as AnyValueMap;
        expect(map.value['s'], isA<AnyValueArray>());
        expect(
            (map.value['s'] as AnyValueArray)
                .value
                .map((e) => e.unwrap())
                .toSet(),
            equals({1, 2}));
      });

      test('empty Set becomes empty AnyValueArray', () {
        final result = AnyValue.fromObject(<String>{});
        expect(result, isA<AnyValueArray>());
        expect((result as AnyValueArray).value, isEmpty);
      });

      test('Uint8List still gives AnyValueBytes', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        final result = AnyValue.fromObject(bytes);
        expect(result, isA<AnyValueBytes>());
        expect((result as AnyValueBytes).value, equals([1, 2, 3]));
      });

      test('String still gives AnyValueString', () {
        final result = AnyValue.fromObject('hello');
        expect(result, isA<AnyValueString>());
        expect((result as AnyValueString).value, equals('hello'));
      });

      test('Map still gives AnyValueMap', () {
        final result = AnyValue.fromObject({'k': 'v'});
        expect(result, isA<AnyValueMap>());
        expect((result as AnyValueMap).value['k']?.unwrap(), equals('v'));
      });

      test('sync* generator that throws returns AnyValueNull and reports once',
          () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        Iterable<int> throwingGen() sync* {
          yield 1;
          throw StateError('generator failed');
        }

        final result = AnyValue.fromObject(throwingGen());
        expect(result, isA<AnyValueNull>());
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });

      test('throwing sync* generator nested inside a list', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        Iterable<int> throwingGen() sync* {
          yield 1;
          throw StateError('generator failed');
        }

        final result = AnyValue.fromObject([throwingGen()]);
        expect(result, isA<AnyValueArray>());
        expect((result as AnyValueArray).value.single, isA<AnyValueNull>());
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });

      test('throwing sync* generator nested inside a map', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        Iterable<int> throwingGen() sync* {
          yield 1;
          throw StateError('generator failed');
        }

        final result = AnyValue.fromObject({'k': throwingGen()});
        expect(result, isA<AnyValueMap>());
        expect((result as AnyValueMap).value['k'], isA<AnyValueNull>());
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });

      test(
          'an iterable whose own toString throws still reports without breaking',
          () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final result = AnyValue.fromObject(_ThrowingIterable());
        expect(result, isA<AnyValueNull>());
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });

      test('a Map whose iteration throws returns AnyValueNull and reports once',
          () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final result = AnyValue.fromObject(_ThrowingMap());
        expect(result, isA<AnyValueNull>());
        expect(reported, hasLength(1));
        expect(reported.single, isA<ArgumentError>());
      });
    });

    group('Enum string conversion', () {
      test('plain enum preserves its toString representation', () {
        final result = AnyValue.fromObject(_PlainEnum.first);
        expect(result, isA<AnyValueString>());
        expect((result as AnyValueString).value, equals('_PlainEnum.first'));
      });

      test('enhanced enum preserves its toString representation', () {
        final result = AnyValue.fromObject(_EnhancedEnum.alpha);
        expect(result, isA<AnyValueString>());
        expect((result as AnyValueString).value, equals('_EnhancedEnum.alpha'));
      });

      test('enum inside a list converts to AnyValueString', () {
        final result = AnyValue.fromObject([_PlainEnum.second]);
        expect(result, isA<AnyValueArray>());
        final arr = result as AnyValueArray;
        expect(arr.value.first, isA<AnyValueString>());
        expect((arr.value.first as AnyValueString).value,
            equals('_PlainEnum.second'));
      });

      test('enum inside a map converts to AnyValueString', () {
        final result = AnyValue.fromObject({'e': _EnhancedEnum.beta});
        expect(result, isA<AnyValueMap>());
        final map = result as AnyValueMap;
        expect(map.value['e'], isA<AnyValueString>());
        expect((map.value['e'] as AnyValueString).value,
            equals('_EnhancedEnum.beta'));
      });
    });

    group('Typed getters quiet on null attributes (Item 7)', () {
      test('null attribute returns null quietly for all typed getters', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final attrs = Attributes.of({'k': null});

        expect(attrs.getString('k'), isNull);
        expect(attrs.getInt('k'), isNull);
        expect(attrs.getBool('k'), isNull);
        expect(attrs.getDouble('k'), isNull);
        expect(attrs.getStringList('k'), isNull);
        expect(attrs.getBoolList('k'), isNull);
        expect(attrs.getIntList('k'), isNull);
        expect(attrs.getDoubleList('k'), isNull);

        expect(reported, isEmpty);
      });

      test('real type mismatch on a map still reports once', () {
        final reported = <Object>[];
        OTelAPI.setErrorHandler((error, _) => reported.add(error));
        addTearDown(() => OTelAPI.setErrorHandler(null));

        final attrs = Attributes.of({
          'm': {'nested': true}
        });

        expect(attrs.getString('m'), isNull);
        expect(reported, hasLength(1));
        expect(reported.single, isA<StateError>());
      });
    });

    group('Attributes.toString never throws on NaN/Infinity (Item 8)', () {
      test(
          'Attributes.toString renders NaN, Infinity, -Infinity without throwing',
          () {
        final nanAttr = Attributes.of({'a': double.nan});
        expect(nanAttr.toString, returnsNormally);
        expect(nanAttr.toString(), contains('NaN'));

        final posInfAttr = Attributes.of({'b': double.infinity});
        expect(posInfAttr.toString, returnsNormally);
        expect(posInfAttr.toString(), contains('Infinity'));

        final negInfAttr = Attributes.of({'c': double.negativeInfinity});
        expect(negInfAttr.toString, returnsNormally);
        expect(negInfAttr.toString(), contains('-Infinity'));

        final mapWithNan = Attributes.of({
          'm': {'nested': double.nan}
        });
        expect(mapWithNan.toString, returnsNormally);
        expect(mapWithNan.toString(), contains('NaN'));

        final listWithInf = Attributes.of({
          'l': [double.infinity, double.negativeInfinity]
        });
        expect(listWithInf.toString, returnsNormally);
        expect(listWithInf.toString(), contains('Infinity'));
        expect(listWithInf.toString(), contains('-Infinity'));
      });

      test(
          'a normal attribute map still renders as JSON via the non-fallback path',
          () {
        final attrs = Attributes.of({
          'a': 'hello',
          'b': 42,
          'c': true,
        });
        final str = attrs.toString();
        expect(() => jsonDecode(str), returnsNormally);
        final decoded = jsonDecode(str) as Map<String, dynamic>;
        expect(decoded['a'], equals('hello'));
        expect(decoded['b'], equals(42));
        expect(decoded['c'], equals(true));
      });
    });
  });
}

enum _PlainEnum { first, second }

enum _EnhancedEnum {
  alpha('A'),
  beta('B');

  final String label;
  const _EnhancedEnum(this.label);
}

class _ThrowingToString {
  @override
  String toString() => throw StateError('user toString threw');
}

class _ThrowingIterable extends Iterable<int> {
  @override
  Iterator<int> get iterator => throw StateError('iterator error');

  @override
  String toString() => throw StateError('toString error');
}

class _ThrowingByteList extends ListBase<int> {
  @override
  int get length => throw StateError('length error');

  @override
  set length(int value) => throw UnsupportedError('read only');

  @override
  int operator [](int index) => throw StateError('index error');

  @override
  void operator []=(int index, int value) =>
      throw UnsupportedError('read only');
}

class _ChangingByteList extends ListBase<int> {
  var _reads = 0;

  @override
  int get length => 1;

  @override
  set length(int value) => throw UnsupportedError('read only');

  @override
  int operator [](int index) => _reads++ == 0 ? 1 : 300;

  @override
  void operator []=(int index, int value) =>
      throw UnsupportedError('read only');
}

class _ThrowingMap extends MapBase<String, Object?> {
  @override
  Iterable<String> get keys => throw StateError('map iteration error');
  @override
  Object? operator [](Object? key) => null;
  @override
  void operator []=(String key, Object? value) {}
  @override
  void clear() {}
  @override
  Object? remove(Object? key) => null;
}
