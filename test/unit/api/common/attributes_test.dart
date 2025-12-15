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
        'int.key': -3,
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
      final stringAttribute =
          OTelAPI.attributeString('test.string.key', 'test-value');
      final intAttribute = OTelAPI.attributeInt('test.int.key', 42);
      final boolAttribute = OTelAPI.attributeBool('test.bool.key', true);
      final doubleAttribute = OTelAPI.attributeDouble('test.double.key', 42.0);
      final stringListAttribute =
          OTelAPI.attributeStringList('string.list', ['a', 'b', 'c']);
      final intListAttribute = OTelAPI.attributeIntList('int.list', [1, 2, 3]);
      final doubleListAttribute =
          OTelAPI.attributeDoubleList('double.list', [0.0, 1.1, 22.22]);
      final boolListAttribute =
          OTelAPI.attributeBoolList('bool.list', [true, false, true]);

      final List<Attribute> attributeList = [
        stringAttribute,
        intAttribute,
        boolAttribute,
        doubleAttribute,
        stringListAttribute,
        intListAttribute,
        boolListAttribute,
        doubleListAttribute
      ];
      attributes = attributes
          .copyWithAttributes(OTelAPI.attributesFromList(attributeList));

      expect(attributes.getString(stringAttribute.key),
          equals(stringAttribute.value));
      expect(attributes.getInt(intAttribute.key), equals(intAttribute.value));
      expect(
          attributes.getBool(boolAttribute.key), equals(boolAttribute.value));
      expect(attributes.getDouble(doubleAttribute.key),
          equals(doubleAttribute.value));
      expect(attributes.getStringList(stringListAttribute.key),
          equals(stringListAttribute.value));
      expect(attributes.getBoolList(boolListAttribute.key),
          equals(boolListAttribute.value));
      expect(attributes.getIntList(intListAttribute.key),
          equals(intListAttribute.value));
      expect(attributes.getDoubleList(doubleListAttribute.key),
          equals(doubleListAttribute.value));
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
      expect(attrAsMap['string.list']!.value, equals(['a', 'b', 'c']));
      expect(attrAsMap['int.list']!.value, equals([1, 2, 3]));
    });

    test('should convert from Map<String, Object> with an Attribute value', () {
      final attrs = OTelAPI.attributesFromMap({
        'string.key':
            OTelAPI.attributeString('long-winded', 'long-string-value'),
        'int.key': OTelAPI.attributeInt('long-winded-int', 3333),
      });
      expect(attrs.getString('long-winded'), equals('long-string-value'));
      expect(attrs.getInt('long-winded-int'), equals(3333));
    });

    test(
        'should convert from Map<String, Object> with an Object to string value',
        () {
      final attrs = OTelAPI.attributesFromMap({
        'menu.select': InteractionType
            .menuSelect, //don't put a key as a value, this just tests toString
      });
      expect(attrs.getString('menu.select'), equals('menu_select'));
    });

    test('remove returns new Attributes without given key', () {
      final attrs = OTelAPI.attributes([
        OTelAPI.attributeString('foo', 'bar'),
        OTelAPI.attributeInt(
          'intfoo',
          42,
        ),
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
      final attrs =
          OTelAPI.attributes([OTelAPI.attributeString('key', 'value')]);
      final result = attrs.copyWithout('missing');
      expect(identical(attrs, result), isTrue);
    });

    test('copyWith empty list returns same instance', () {
      final attrs =
          OTelAPI.attributes([OTelAPI.attributeString('key', 'value')]);
      final result = attrs.copyWith([]);
      expect(identical(attrs, result), isTrue);
    });

    test('toJson returns correct map representation', () {
      final attrs = OTelAPI.attributesFromMap({
        'string.key': 'value',
        'int.key': 42,
        'bool.key': true,
        'double.key': 3.14,
      });

      final json = attrs.toJson();

      expect(json['string.key'], equals('value'));
      expect(json['int.key'], equals(42));
      expect(json['bool.key'], equals(true));
      expect(json['double.key'], equals(3.14));
    });

    test('toString returns JSON formatted string', () {
      final attrs = OTelAPI.attributes([
        OTelAPI.attributeString('key', 'value'),
      ]);

      final str = attrs.toString();

      expect(str, contains('key'));
      expect(str, contains('value'));
    });

    test('equality works for identical attributes', () {
      final attrs1 = OTelAPI.attributesFromMap({
        'key1': 'value1',
        'key2': 42,
      });
      final attrs2 = OTelAPI.attributesFromMap({
        'key1': 'value1',
        'key2': 42,
      });

      expect(attrs1 == attrs2, isTrue);
      expect(attrs1.hashCode, equals(attrs2.hashCode));
    });

    test('equality returns false for different attributes', () {
      final attrs1 = OTelAPI.attributesFromMap({'key': 'value1'});
      final attrs2 = OTelAPI.attributesFromMap({'key': 'value2'});

      expect(attrs1 == attrs2, isFalse);
    });

    test('equality returns true for same instance', () {
      final attrs = OTelAPI.attributesFromMap({'key': 'value'});
      expect(attrs == attrs, isTrue);
    });

    test('equality returns false for non-Attributes object', () {
      final attrs = OTelAPI.attributesFromMap({'key': 'value'});
      // Use Object type to avoid analyzer warning about unrelated types
      final Object notAttributes = 'not an Attributes';
      expect(attrs == notAttributes, isFalse);
    });

    test('keys returns list of all attribute keys', () {
      final attrs = OTelAPI.attributesFromMap({
        'key1': 'value1',
        'key2': 42,
        'key3': true,
      });

      final keys = attrs.keys;

      expect(keys, contains('key1'));
      expect(keys, contains('key2'));
      expect(keys, contains('key3'));
      expect(keys.length, equals(3));
    });

    test('toList returns list of all attributes', () {
      final attrs = OTelAPI.attributesFromMap({
        'key1': 'value1',
        'key2': 42,
      });

      final list = attrs.toList();

      expect(list.length, equals(2));
      expect(list.any((a) => a.key == 'key1'), isTrue);
      expect(list.any((a) => a.key == 'key2'), isTrue);
    });

    test('isEmpty returns true for empty attributes', () {
      final attrs = OTelAPI.attributes();
      expect(attrs.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty attributes', () {
      final attrs = OTelAPI.attributes([
        OTelAPI.attributeString('key', 'value'),
      ]);
      expect(attrs.isEmpty, isFalse);
    });

    test('_getTyped throws StateError for wrong type', () {
      final attrs = OTelAPI.attributes([
        OTelAPI.attributeString('key', 'value'),
      ]);

      expect(
        () => attrs.getInt('key'),
        throwsA(isA<StateError>()),
      );
    });

    test('get methods return null for missing key', () {
      final attrs = OTelAPI.attributes();

      expect(attrs.getString('missing'), isNull);
      expect(attrs.getBool('missing'), isNull);
      expect(attrs.getInt('missing'), isNull);
      expect(attrs.getDouble('missing'), isNull);
      expect(attrs.getStringList('missing'), isNull);
      expect(attrs.getBoolList('missing'), isNull);
      expect(attrs.getIntList('missing'), isNull);
      expect(attrs.getDoubleList('missing'), isNull);
    });
  });

  group('Attributes.fromJson', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('fromJson parses string values', () {
      final json = {'key': 'value'};
      final attrs = Attributes.fromJson(json);

      expect(attrs.getString('key'), equals('value'));
    });

    test('fromJson parses bool values', () {
      final json = {'key': true};
      final attrs = Attributes.fromJson(json);

      expect(attrs.getBool('key'), equals(true));
    });

    test('fromJson parses int values', () {
      final json = {'key': 42};
      final attrs = Attributes.fromJson(json);

      expect(attrs.getInt('key'), equals(42));
    });

    test('fromJson parses double values', () {
      final json = {'key': 3.14};
      final attrs = Attributes.fromJson(json);

      expect(attrs.getDouble('key'), equals(3.14));
    });

    test('fromJson parses typed string list', () {
      final json = <String, dynamic>{
        'key': <String>['a', 'b', 'c']
      };
      final attrs = Attributes.fromJson(json);

      expect(attrs.getStringList('key'), equals(['a', 'b', 'c']));
    });

    test('fromJson parses typed bool list', () {
      final json = <String, dynamic>{
        'key': <bool>[true, false, true]
      };
      final attrs = Attributes.fromJson(json);

      expect(attrs.getBoolList('key'), equals([true, false, true]));
    });

    test('fromJson parses typed int list', () {
      final json = <String, dynamic>{
        'key': <int>[1, 2, 3]
      };
      final attrs = Attributes.fromJson(json);

      expect(attrs.getIntList('key'), equals([1, 2, 3]));
    });

    test('fromJson parses typed double list', () {
      final json = <String, dynamic>{
        'key': <double>[1.1, 2.2, 3.3]
      };
      final attrs = Attributes.fromJson(json);

      expect(attrs.getDoubleList('key'), equals([1.1, 2.2, 3.3]));
    });

    test('fromJson converts untyped string list', () {
      final json = <String, dynamic>{
        'key': ['a', 'b', 'c']
      };
      final attrs = Attributes.fromJson(json);

      expect(attrs.getStringList('key'), equals(['a', 'b', 'c']));
    });

    test('fromJson converts untyped bool list', () {
      final json = <String, dynamic>{
        'key': [true, false]
      };
      final attrs = Attributes.fromJson(json);

      expect(attrs.getBoolList('key'), equals([true, false]));
    });

    test('fromJson converts untyped int list', () {
      final json = <String, dynamic>{
        'key': [1, 2, 3]
      };
      final attrs = Attributes.fromJson(json);

      expect(attrs.getIntList('key'), equals([1, 2, 3]));
    });

    test('fromJson converts mixed int/double list to double list', () {
      final json = <String, dynamic>{
        'key': [1, 2.5, 3]
      };
      final attrs = Attributes.fromJson(json);

      expect(attrs.getDoubleList('key'), equals([1.0, 2.5, 3.0]));
    });

    test('fromJson ignores empty list with warning', () {
      final json = <String, dynamic>{'key': <dynamic>[]};
      final attrs = Attributes.fromJson(json);

      // Empty lists are ignored per OTel spec
      expect(attrs.isEmpty, isTrue);
    });

    test('fromJson ignores unsupported list types with warning', () {
      final json = <String, dynamic>{
        'key': [
          {'nested': 'object'}
        ]
      };
      final attrs = Attributes.fromJson(json);

      // Unsupported types are ignored
      expect(attrs.isEmpty, isTrue);
    });

    test('fromJson ignores unsupported value types with warning', () {
      final json = <String, dynamic>{
        'key': {'nested': 'object'}
      };
      final attrs = Attributes.fromJson(json);

      // Unsupported types are ignored
      expect(attrs.isEmpty, isTrue);
    });
  });

  group('Attributes.of', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('Attributes.of creates attributes from map', () {
      final attrs = Attributes.of({'key': 'value', 'num': 42});

      expect(attrs.getString('key'), equals('value'));
      expect(attrs.getInt('num'), equals(42));
    });
  });

  group('AttributesExtension', () {
    test('toAttributes works before OTelAPI initialization', () {
      OTelAPI.reset();
      // Don't initialize - test that toAttributes still works
      final map = <String, Object>{'key': 'value'};
      final attrs = map.toAttributes();

      expect(attrs.getString('key'), equals('value'));
    });

    test('toAttributes works after OTelAPI initialization', () {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      final map = <String, Object>{'key': 'value'};
      final attrs = map.toAttributes();

      expect(attrs.getString('key'), equals('value'));
    });
  });
}
