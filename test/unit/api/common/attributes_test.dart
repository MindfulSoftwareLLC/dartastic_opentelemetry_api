// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Attributes', () {
    late Attributes attributes;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      attributes = OTelAPI.attributes();
    });

    test('should store and retrieve string attributes', () {
      final name = 'test.key';
      final value = 'test-value';
      attributes = attributes.copyWithStringAttribute(name, value);

      expect(attributes.getString(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });

    test('should store and retrieve bool attributes', () {
      final value = true;
      final name = 'test.bool.key';
      attributes = attributes.copyWithBoolAttribute(name, value);

      expect(attributes.getBool(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });

    test('should store and retrieve int attributes', () {
      final name = 'test.int.key';
      final value = 42;
      attributes = attributes.copyWithIntAttribute(name, value);

      expect(attributes.getInt(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });

    test('should store and retrieve double attributes', () {
      final value = 42.1;
      final name = 'test-int-key';
      attributes = attributes.copyWithDoubleAttribute(name, value);

      expect(attributes.getDouble(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });


    test('should store and retrieve string list attributes', () {
      final name = 'test.key';
      final value = ['test-value', 'foo', 'bar'];
      attributes = attributes.copyWithStringListAttribute(name, value);

      expect(attributes.getStringList(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });

    test('should store and retrieve bool list attributes', () {
      final name = 'test.bool.key';
      final value = [true, false, true];
      attributes = attributes.copyWithBoolListAttribute(name, value);

      expect(attributes.getBoolList(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });

    test('should store and retrieve int list attributes', () {
      final name = 'test.int.key';
      final value = [42, 0, -1];
      attributes = attributes.copyWithIntListAttribute(name, value);

      expect(attributes.getIntList(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });

    test('should store and retrieve double list attributes', () {
      final value = [42.1, 43.2, 0.1];
      final name = 'test-int-key';
      attributes = attributes.copyWithDoubleListAttribute(name, value);

      expect(attributes.getDoubleList(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });

    test('should store and retrieve string list attributes', () {
      final name = 'test.key';
      final value = ['test-value', 'foo', 'bar'];
      attributes = attributes.copyWithStringListAttribute(name, value);

      expect(attributes.getStringList(name), equals(value));
      expect(attributes.toMap()[name]!.value, equals(value));
    });

    test('should store and retrieve attributes', () {
      attributes = OTelAPI.attributesFromMap({
        'string.key': 'a',
        'bool.key': false,
        'int.key':  -3,
        'double-key': 1.12233,
        'string.list': ['a', 'b', 'c'],
        'bool.list': [true, false],
        'int.list': [1, 2, 3],
        'double.list': [1.1, 2.2, -3.3]
      });

      expect(attributes.getString('string.key'), equals('a'));
      expect(attributes.getBool('bool.key'), equals(false));
      expect(attributes.getInt('int.key'), equals(-3));
      expect(attributes.getDouble('double-key'), equals(1.12233));
      expect(attributes.getStringList('string.list'), equals(['a', 'b', 'c']));
      expect(attributes.getBoolList('bool.list'), equals([true, false]));
      expect(attributes.getIntList('int.list'), equals([1, 2, 3]));
      expect(attributes.getDoubleList('double.list'), equals([1.1, 2.2, -3.3]));
    });

    test('addAll should merge multiple attributes', () {
      final stringAttribute = OTelAPI.attributeString('test.string.key', 'test-value');
      final intAttribute = OTelAPI.attributeInt('test.int.key', 42);
      final boolAttribute = OTelAPI.attributeBool('test.bool.key', true);
      final doubleAttribute = OTelAPI.attributeDouble('test.double.key', 42.0);
      final stringListAttribute = OTelAPI.attributeStringList('string.list', ['a', 'b', 'c']);
      final intListAttribute = OTelAPI.attributeIntList('int.list', [1, 2, 3]);
      final doubleListAttribute = OTelAPI.attributeDoubleList('double.list', [0.0, 1.1, 22.22]);
      final boolListAttribute = OTelAPI.attributeBoolList('bool.list', [true, false, true]);

      final List<Attribute> attributeList = [stringAttribute, intAttribute,boolAttribute,doubleAttribute, stringListAttribute, intListAttribute, boolListAttribute, doubleListAttribute];
      attributes = attributes.copyWithAttributes( OTelAPI.attributesFromList(attributeList));

      expect(attributes.getString(stringAttribute.key), equals(stringAttribute.value));
      expect(attributes.getInt(intAttribute.key), equals(intAttribute.value));
      expect(attributes.getBool(boolAttribute.key), equals(boolAttribute.value));
      expect(attributes.getDouble(doubleAttribute.key), equals(doubleAttribute.value));
      expect(attributes.getStringList(stringListAttribute.key), equals(stringListAttribute.value));
      expect(attributes.getBoolList(boolListAttribute.key), equals(boolListAttribute.value));
      expect(attributes.getIntList(intListAttribute.key), equals(intListAttribute.value));
      expect(attributes.getDoubleList(doubleListAttribute.key), equals(doubleListAttribute.value));
    });

    test('should convert from Map<String, Object>', () {
      final map = {
        'string.key': 'string-value',
        'int.key': 42,
        'bool.key': true,
        'double.key': 42.5,
        'string.list': ['a', 'b', 'c'],
        'int.list': [1, 2, 3],
      };

      final attrs = map.toAttributes();
      final attrAsMap = attrs.toMap();
      expect(attrAsMap['string.key']!.value, equals('string-value'));
      expect(attrAsMap['int.key']!.value, equals(42));
      expect(attrAsMap['bool.key']!.value, equals(true));
      expect(attrAsMap['double.key']!.value, equals(42.5));
      expect(attrAsMap['string.list']!.value,equals(['a', 'b', 'c']));
      expect(attrAsMap['int.list']!.value,equals([1, 2, 3]));
    });

    test('should convert from Map<String, Object> with an Attribute value', () {
       final attrs =  OTelAPI.attributesFromMap({
          'string.key': OTelAPI.attributeString('long-winded', 'long-string-value'),
          'int.key': OTelAPI.attributeInt('long-winded-int', 3333),
        });
       expect(attrs.getString('long-winded'), equals('long-string-value'));
       expect(attrs.getInt('long-winded-int'), equals(3333));
    });

    test('should convert from Map<String, Object> with an Object to string value', () {
      final attrs =  OTelAPI.attributesFromMap({
        'menu.select': InteractionType.menuSelect,//don't put a key as a value, this just tests toString
      });
      expect(attrs.getString('menu.select'), equals('menu_select'));
    });

    test('remove returns new Attributes without given key', () {
      final attrs = OTelAPI.attributes([
        OTelAPI.attributeString('foo', 'bar'),
        OTelAPI.attributeInt('intfoo', 42, ),
        OTelAPI.attributeBool('boolfoo', true),
        OTelAPI.attributeDouble('doublefoo', 1.01)
      ]);

      final updated = attrs.copyWithout('intfoo');

      // Original unchanged
      expect(attrs.getString('foo'), equals('bar'));
      expect(attrs.length, equals(4));
      expect(attrs.getInt('intfoo'), equals(42));
      expect(attrs.length, equals(4));

      // New attributes has key removed
      expect(updated.getInt('intfoo'), isNull);
      expect(updated.length, equals(3));
      expect(updated.getString('foo'), equals('bar'));
      expect(updated.getBool('boolfoo'), equals(true));
      expect(updated.getDouble('doublefoo'), equals(1.01));
    });

    test('remove non-existent key returns same instance', () {
      final attrs = OTelAPI.attributes([OTelAPI.attributeString('key', 'value')]);
      final result = attrs.copyWithout('missing');
      expect(identical(attrs, result), isTrue);
    });
  });
}
