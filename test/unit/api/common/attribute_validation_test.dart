// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Coverage for Attribute value validation, Attribute.toString, and the
// dynamic-list conversion paths in Attributes.of.

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
}
