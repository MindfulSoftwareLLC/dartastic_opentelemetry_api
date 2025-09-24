// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/semantics/semantics.dart';
import 'package:test/test.dart';

// Create a test implementation of OTelSemantic
class TestSemantic implements OTelSemantic {
  @override
  final String key;

  const TestSemantic(this.key);

  @override
  String toString() => key;
}

void main() {
  group('OTelSemantic Tests', () {
    test('OTelSemantic implementation', () {
      const semantic = TestSemantic('test.key');
      expect(semantic.key, equals('test.key'));
      expect(semantic.toString(), equals('test.key'));
    });

    test('OTelSemantic can be used as map key', () {
      const semantic1 = TestSemantic('test.key1');
      const semantic2 = TestSemantic('test.key2');

      final map = <OTelSemantic, String>{
        semantic1: 'value1',
        semantic2: 'value2',
      };

      expect(map[semantic1], equals('value1'));
      expect(map[semantic2], equals('value2'));
    });

    test('OTelSemantic can be used in collection', () {
      const semantic1 = TestSemantic('test.key1');
      const semantic2 = TestSemantic('test.key2');

      final list = [semantic1, semantic2];

      expect(list, contains(semantic1));
      expect(list, contains(semantic2));
      expect(
          list.map((s) => s.key).toList(), equals(['test.key1', 'test.key2']));
    });
  });
}
