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

    test('empty string value throws', () {
      expect(() => OTelAPI.attributeString('k', ''), throwsArgumentError);
    });

    test('empty list value throws', () {
      expect(() => OTelAPI.attributeStringList('k', <String>[]),
          throwsArgumentError);
    });

    test('toString includes the value', () {
      expect(OTelAPI.attributeString('k', 'v').toString(),
          equals('AttributeValue(v)'));
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

    test('Attributes.of converts mixed numeric lists to double', () {
      final attrs = Attributes.of({
        'nums': <Object>[1, 2.5]
      });
      expect(attrs.getDoubleList('nums'), equals([1.0, 2.5]));
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
        'nums': <dynamic>[1, 2.5],
      });
      expect(attrs.getStringList('names'), equals(['a', 'b']));
      expect(attrs.getBoolList('flags'), equals([true, false]));
      expect(attrs.getIntList('counts'), equals([1, 2]));
      expect(attrs.getDoubleList('nums'), equals([1.0, 2.5]));
    });
  });
}
