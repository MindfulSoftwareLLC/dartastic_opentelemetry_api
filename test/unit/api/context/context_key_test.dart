// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {

  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize();
  });

  group('ContextKey', () {
    test('regular context keys are unique even with same name', () {
      final key1 = OTelAPI.contextKey<String>('test');
      final key2 = OTelAPI.contextKey<String>('test');
      final key3 = OTelAPI.contextKey<String>('different');

      expect(key1, isNot(equals(key2)));
      expect(key1, isNot(equals(key3)));
      expect(key1.name, equals('test'));
    });

    test('keys with different types but same name are unique', () {
      final stringKey = OTelAPI.contextKey<String>('test');
      final intKey = OTelAPI.contextKey<int>('test');

      expect(stringKey, isNot(equals(intKey)));
      expect(stringKey.hashCode, isNot(equals(intKey.hashCode)));
      expect(stringKey.name, equals('test'));
    });
  });
}
