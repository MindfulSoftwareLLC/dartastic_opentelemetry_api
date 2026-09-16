// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Coverage for Attribute value validation, Attribute.toString, and the
// dynamic-list conversion paths in Attributes.of.

import 'dart:typed_data';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Attribute validation', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('toString includes the value', () {
      expect(OTelAPI.attributeString('k', 'v').toString(),
          equals('AttributeValue(v)'));
    });

    // error-handling.md makes it a MUST NOT for an API method to throw on
    // end-user misuse, so the factories accept an empty key and Attributes
    // drops it; see the "empty attribute keys" group in attributes_test.dart.
    test('an empty key does not throw at the factory', () {
      expect(() => OTelAPI.attributeString('', 'v'), returnsNormally);
      expect(() => OTelAPI.attributeInt('', 1), returnsNormally);
      expect(() => OTelAPI.attributeStringList('', ['v']), returnsNormally);
    });

    test('Attributes.of drops an empty key rather than throwing', () {
      final attrs = Attributes.of({'': 'dropped', 'good': 'kept'});
      expect(attrs.getString('good'), equals('kept'));
      expect(attrs.toMap().containsKey(''), isFalse);
    });

    // The OpenTelemetry specification constrains attribute keys, not attribute
    // values. Empty values are stored per #103; these pin that the AnyValue
    // representation did not reintroduce a rejection.
    test('an empty String value is stored', () {
      final attr = OTelAPI.attributeString('k', '');
      expect((attr.value as AnyValueString).value, isEmpty);
      expect(attr.key, equals('k'));
      expect(Attributes.of({'k': ''}).getString('k'), isEmpty);
    });

    test('empty list values are stored', () {
      expect(OTelAPI.attributeStringList('k', []).key, equals('k'));
      expect(
          (OTelAPI.attributeStringList('k', []).value as AnyValueArray).value,
          isEmpty);
      expect((OTelAPI.attributeIntList('k', []).value as AnyValueArray).value,
          isEmpty);
      expect((OTelAPI.attributeBoolList('k', []).value as AnyValueArray).value,
          isEmpty);
      expect(
          (OTelAPI.attributeDoubleList('k', []).value as AnyValueArray).value,
          isEmpty);
    });

    test('a list containing empty Strings is allowed', () {
      final attrs = Attributes.of({
        'names': <String>['', 'b'],
      });
      expect(attrs.getStringList('names'), equals(['', 'b']));
    });

    test('Attributes.of converts untyped bool lists', () {
      final attrs = Attributes.of({
        'flags': <Object>[true, false]
      });
      expect(attrs.getBoolList('flags'), equals([true, false]));
    });

    test('Attributes.of converts untyped int lists', () {
      final attrs = Attributes.of({
        'counts': <Object>[1, 2, 3]
      });
      expect(attrs.getIntList('counts'), equals([1, 2, 3]));
    });

    // Promotion is one way: an int reads as a double, never the reverse.
    // It also absorbs the web's single number type, where a whole-valued
    // double is stored as an AnyValueInt.
    test('getDouble promotes a stored int', () {
      final attrs = Attributes.of({'n': 2});
      expect(attrs.getDouble('n'), equals(2.0));
      expect(attrs.getInt('n'), equals(2));
    });

    test('getDoubleList promotes an all-int array', () {
      final attrs = Attributes.of({
        'nums': <int>[1, 2, 3],
      });
      expect(attrs.getDoubleList('nums'), equals([1.0, 2.0, 3.0]));
      expect(attrs.getIntList('nums'), equals([1, 2, 3]));
    });

    test('getInt does not demote a stored double', () {
      final attrs = Attributes.of({'d': 2.5});
      expect(attrs.getInt('d'), isNull);
      expect(attrs.getDouble('d'), equals(2.5));
    });

    test('getIntList does not demote a double array', () {
      final attrs = Attributes.of({
        'nums': <double>[1.5, 2.5],
      });
      expect(attrs.getIntList('nums'), isNull);
      expect(attrs.getDoubleList('nums'), equals([1.5, 2.5]));
    });

    test('Attributes.of promotes mixed numeric lists to double', () {
      final attrs = Attributes.of({
        'nums': <Object>[1, 2.5]
      });
      // Mixed int/double lists read back as List<double>, as they did before
      // AnyValue (#103). The stored array keeps each element's own type, so
      // the promotion happens in the getter rather than at storage.
      expect(attrs.getDoubleList('nums'), equals([1.0, 2.5]));
      expect(attrs.getIntList('nums'), isNull);
    });

    test('Attributes.of ignores lists of unsupported types', () {
      final attrs = Attributes.of({
        'bad': <Object>[Duration.zero],
        'good': 'kept',
      });
      expect(attrs.getString('good'), equals('kept'));
      expect(attrs.getStringList('bad'), isNull);
    });

    test(
        'fromJson converts untyped string, bool, int, and mixed numeric'
        ' lists', () {
      final attrs = Attributes.fromJson({
        'names': <dynamic>['a', 'b'],
        'flags': <dynamic>[true, false],
        'counts': <dynamic>[1, 2],
      });
      expect(attrs.getStringList('names'), equals(['a', 'b']));
      expect(attrs.getBoolList('flags'), equals([true, false]));
      expect(attrs.getIntList('counts'), equals([1, 2]));
    });

    test('Attributes.of preserves empty string', () {
      final attrs = Attributes.of({'key': ''});
      expect(attrs.getString('key'), equals(''));
    });

    test('Attributes.of preserves the element type of typed empty lists', () {
      expect(Attributes.of({'k': <String>[]}).getStringList('k'),
          equals(<String>[]));
      expect(Attributes.of({'k': <bool>[]}).getBoolList('k'), equals(<bool>[]));
      expect(Attributes.of({'k': <int>[]}).getIntList('k'), equals(<int>[]));
      expect(Attributes.of({'k': <double>[]}).getDoubleList('k'),
          equals(<double>[]));
    });

    test('Attributes.of preserves untyped empty list as List<String>', () {
      final attrs = Attributes.of({'key': <Object>[]});
      expect(attrs.getStringList('key'), equals(<String>[]));
    });

    test('empty list attribute equality', () {
      final a = OTelAPI.attributeStringList('k', []);
      final b = OTelAPI.attributeStringList('k', []);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('empty string attribute equality', () {
      final a = OTelAPI.attributeString('k', '');
      final b = OTelAPI.attributeString('k', '');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  _attributeValueDataModelTests();
}

/// common/README.md constrains an attribute value to a primitive or a
/// homogeneous array of primitives. `AnyValue` is wider than that because it
/// is the log body model, so both attribute construction paths check the
/// converted value and drop what the attribute model does not allow. Without
/// the check such a value stores fine but no typed getter can read it back.
void _attributeValueDataModelTests() {
  group('attribute value data model', () {
    late List<Object> reported;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
    });

    tearDown(() => OTelAPI.setErrorHandler(null));

    // common.md, Attribute: "The attribute value MUST be one of types defined
    // in AnyValue", which covers a map, a nested array, a byte array and null.
    // Issue #95 was filed because this package supported only a primitive and
    // a homogeneous list of primitives, so each of these must now survive
    // storage and be readable back.
    void expectStoredByBothPaths(
      String label,
      Object? value,
      Matcher anyValueMatcher,
    ) {
      final fromMap = Attributes.of({'v': value, 'other': 'kept'});
      expect(fromMap.keys, containsAll(['v', 'other']),
          reason: '$label via Attributes.of');
      expect(fromMap.toMap()['v']!.value, anyValueMatcher,
          reason: '$label round-trips via Attributes.of');

      final fromJson = Attributes.fromJson({'v': value, 'other': 'kept'});
      expect(fromJson.keys, containsAll(['v', 'other']),
          reason: '$label via fromJson');
      expect(fromJson.toMap()['v']!.value, anyValueMatcher,
          reason: '$label round-trips via fromJson');

      expect(reported, isEmpty, reason: '$label is legal, nothing to report');
    }

    test('a map value is stored and readable', () {
      expectStoredByBothPaths('map', {'nested': true}, isA<AnyValueMap>());

      final attrs = Attributes.of({
        'context': {'nested': true},
      });
      final value = attrs.toMap()['context']!.value as AnyValueMap;
      expect(value.value['nested'], equals(const AnyValueBool(true)));
      expect(value.unwrap(), equals({'nested': true}));
    });

    test('a bytes value is stored and readable', () {
      expectStoredByBothPaths(
          'bytes', Uint8List.fromList([1, 2, 3]), isA<AnyValueBytes>());

      final attrs = Attributes.of({
        'b': Uint8List.fromList([1, 2, 3])
      });
      expect(attrs.toMap()['b']!.value.unwrap(), equals([1, 2, 3]));
    });

    test('a nested array value is stored and readable', () {
      expectStoredByBothPaths(
          'nested array',
          [
            [1, 2],
          ],
          isA<AnyValueArray>());

      final attrs = Attributes.of({
        'matrix': [
          [1, 2],
          [3],
        ],
      });
      expect(
          attrs.toMap()['matrix']!.value.unwrap(),
          equals([
            [1, 2],
            [3],
          ]));
    });

    test('a heterogeneous array value is stored and readable', () {
      expectStoredByBothPaths(
          'mixed scalars', [1, 'two'], isA<AnyValueArray>());

      final attrs = Attributes.of({
        'mixed': [1, 'two', true],
      });
      expect(attrs.toMap()['mixed']!.value.unwrap(), equals([1, 'two', true]));
    });

    test('an array containing null is stored, preserving the null', () {
      // common/README.md: a null within an array MUST be preserved where it
      // cannot be prevented at compile time.
      expectStoredByBothPaths(
          'array with null', <Object?>[1, null], isA<AnyValueArray>());

      final attrs = Attributes.of({
        'sparse': <Object?>['a', null, 'c'],
      });
      expect(attrs.toMap()['sparse']!.value.unwrap(), equals(['a', null, 'c']));
    });

    test('a null value is stored as AnyValueNull by both paths', () {
      expectStoredByBothPaths('null', null, isA<AnyValueNull>());

      expect(Attributes.of({'n': null}).toMap()['n']!.value.unwrap(), isNull);
      expect(Attributes.fromJson({'n': null}).toMap()['n']!.value.unwrap(),
          isNull);
    });

    test('a complex value is still dropped if it cannot be converted', () {
      // Removing the data-model restriction does not resurrect the
      // `.toString()` fallback: a closure has no AnyValue representation.
      final attrs = Attributes.of({'bad': () {}, 'good': 'kept'});
      expect(attrs.keys, equals(['good']));
      expect(reported, hasLength(1));
      expect(reported.single, isA<ArgumentError>());
    });

    test('a complex value nested inside a map is dropped with the attribute',
        () {
      final attrs = Attributes.of({
        'bad': {'inner': () {}},
        'good': 'kept',
      });
      expect(attrs.keys, equals(['good']));
      expect(reported, hasLength(1));
    });

    test('legal scalars are stored by both paths', () {
      const values = <String, Object>{
        'str': 'v',
        'bool': true,
        'int': 1,
        'double': 1.5,
      };

      final fromMap = Attributes.of(values);
      expect(fromMap.getString('str'), equals('v'));
      expect(fromMap.getBool('bool'), isTrue);
      expect(fromMap.getInt('int'), equals(1));
      expect(fromMap.getDouble('double'), equals(1.5));

      final fromJson = Attributes.fromJson(values);
      expect(fromJson.getString('str'), equals('v'));
      expect(fromJson.getBool('bool'), isTrue);
      expect(fromJson.getInt('int'), equals(1));
      expect(fromJson.getDouble('double'), equals(1.5));

      expect(reported, isEmpty);
    });

    test('legal homogeneous arrays are stored by both paths', () {
      const values = <String, Object>{
        'strs': ['a', 'b'],
        'bools': [true, false],
        'ints': [1, 2],
        'doubles': [1.5, 2.5],
      };

      final fromMap = Attributes.of(values);
      expect(fromMap.getStringList('strs'), equals(['a', 'b']));
      expect(fromMap.getBoolList('bools'), equals([true, false]));
      expect(fromMap.getIntList('ints'), equals([1, 2]));
      expect(fromMap.getDoubleList('doubles'), equals([1.5, 2.5]));

      final fromJson = Attributes.fromJson(values);
      expect(fromJson.getStringList('strs'), equals(['a', 'b']));
      expect(fromJson.getBoolList('bools'), equals([true, false]));
      expect(fromJson.getIntList('ints'), equals([1, 2]));
      expect(fromJson.getDoubleList('doubles'), equals([1.5, 2.5]));

      expect(reported, isEmpty);
    });

    test('an empty array is legal on both paths', () {
      expect(Attributes.of({'k': <Object>[]}).keys, equals(['k']));
      expect(Attributes.fromJson({'k': <dynamic>[]}).keys, equals(['k']));
      expect(reported, isEmpty);
    });

    // A mixed int/double array stays legal: JSON has one number type, so
    // [1, 2.5] is routine, and _getTyped promotes it to List<double>, so it
    // reads back rather than being the write-only value the check rejects.
    test('a mixed int/double array stays legal and reads back as doubles', () {
      final fromMap = Attributes.of({
        'nums': [1, 2.5, 3],
      });
      expect(fromMap.getDoubleList('nums'), equals([1.0, 2.5, 3.0]));

      final fromJson = Attributes.fromJson({
        'nums': [1, 2.5, 3],
      });
      expect(fromJson.getDoubleList('nums'), equals([1.0, 2.5, 3.0]));

      expect(reported, isEmpty);
    });
  });
}
