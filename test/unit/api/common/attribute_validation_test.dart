// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Coverage for Attribute value validation, Attribute.toString, and the
// dynamic-list conversion paths in Attributes.of.

import 'dart:typed_data';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:dartastic_opentelemetry_api/src/api/common/attribute.dart'
    show AttributeCreate;
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

    // Each illegal value is checked through both construction paths.
    void expectDroppedByBothPaths(String label, Object value) {
      final fromMap = Attributes.of({'bad': value, 'good': 'kept'});
      expect(fromMap.keys, equals(['good']),
          reason: '$label via Attributes.of');
      expect(reported, hasLength(1),
          reason: '$label reported by Attributes.of');
      expect(reported.single, isA<ArgumentError>());

      reported.clear();

      final fromJson = Attributes.fromJson({'bad': value, 'good': 'kept'});
      expect(fromJson.keys, equals(['good']), reason: '$label via fromJson');
      expect(reported, hasLength(1), reason: '$label reported by fromJson');
      expect(reported.single, isA<ArgumentError>());
    }

    test('a map value is dropped and reported', () {
      expectDroppedByBothPaths('map', {'a': 1});
    });

    // This is a change, not a long-standing rule. attrsFromMap used to match a
    // Uint8List on its `value is List<int>` branch, so it was stored as an int
    // list and read back through getIntList. Bytes are not an attribute value
    // in the OTel data model, so that reading misrepresented the value; it is
    // now dropped. See the BREAKING note in the CHANGELOG.
    test('a bytes value is dropped and reported', () {
      expectDroppedByBothPaths('bytes', Uint8List.fromList([1, 2, 3]));
    });

    test('a nested array value is dropped and reported', () {
      expectDroppedByBothPaths('nested array', [
        [1, 2],
      ]);
    });

    test('a heterogeneous array value is dropped and reported', () {
      expectDroppedByBothPaths('mixed scalars', [1, 'two']);
      reported.clear();
      expectDroppedByBothPaths('mixed bool/string', [true, 'two']);
    });

    test('an array containing null is dropped and reported', () {
      expectDroppedByBothPaths('array with null', <Object?>[1, null]);
    });

    // Attributes.of takes Map<String, Object>, so a bare null cannot reach it.
    // fromJson takes Map<String, dynamic> and can.
    test('a null value is dropped and reported by fromJson', () {
      final attrs = Attributes.fromJson({'bad': null, 'good': 'kept'});
      expect(attrs.keys, equals(['good']));
      expect(reported, hasLength(1));
      expect(reported.single, isA<ArgumentError>());
    });

    // describeIllegalValue's scalar branch cannot be reached through either
    // construction path, because a scalar is always a legal attribute value.
    // The branch exists so the switch stays exhaustive over the sealed
    // hierarchy, which makes a future AnyValue subtype a compile error there.
    // Calling it directly covers the branch and pins its wording.
    test('describeIllegalValue handles scalars, which callers never reach', () {
      expect(AttributeCreate.describeIllegalValue(const AnyValueString('s')),
          equals('a primitive'));
      expect(AttributeCreate.describeIllegalValue(const AnyValueBool(true)),
          equals('a primitive'));
      expect(AttributeCreate.describeIllegalValue(const AnyValueInt(1)),
          equals('a primitive'));
      expect(AttributeCreate.describeIllegalValue(const AnyValueDouble(1.5)),
          equals('a primitive'));
    });

    test('the report names the offending kind', () {
      Attributes.of({
        'a map': {'a': 1},
      });
      expect('${reported.single}', contains('a map'));

      reported.clear();
      Attributes.of({
        'an array': [1, 'two'],
      });
      expect('${reported.single}', contains('heterogeneous'));
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
