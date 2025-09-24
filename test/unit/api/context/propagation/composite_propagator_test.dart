// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Mock implementation of TextMapGetter
class MockTextMapGetter implements TextMapGetter<String> {
  final Map<String, String> _values;

  MockTextMapGetter(this._values);

  @override
  String? get(String key) => _values[key];

  @override
  Iterable<String> keys() => _values.keys;
}

// Mock implementation of TextMapSetter
class MockTextMapSetter implements TextMapSetter<String> {
  final Map<String, String> _values;

  MockTextMapSetter(this._values);

  @override
  void set(String key, String value) {
    _values[key] = value;
  }
}

// Mock implementation of TextMapPropagator
class MockPropagator implements TextMapPropagator<Map<String, String>, String> {
  final String _prefix;
  final List<String> _fields;

  MockPropagator(this._prefix, this._fields);

  @override
  List<String> fields() => _fields;

  @override
  Context extract(Context context, Map<String, String> carrier,
      TextMapGetter<String> getter) {
    for (final field in _fields) {
      final value = getter.get(field);
      if (value != null) {
        final baggage = context.baggage?.copyWith(field, "$_prefix:$value") ??
            OTelAPI.baggage().copyWith(field, "$_prefix:$value");
        context = context.copyWithBaggage(baggage);
      }
    }
    return context;
  }

  @override
  void inject(Context context, Map<String, String> carrier,
      TextMapSetter<String> setter) {
    for (final field in _fields) {
      final value = context.baggage?.getValue(field);
      if (value != null && value.startsWith("$_prefix:")) {
        setter.set(field, value.substring(_prefix.length + 1));
      }
    }
  }
}

void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('CompositePropagator', () {
    test(
        'fields() returns the combined fields from all propagators without duplicates',
        () {
      final propagator1 = MockPropagator('p1', ['field1', 'field2']);
      final propagator2 = MockPropagator('p2', ['field2', 'field3']);
      final propagator3 = MockPropagator('p3', ['field3', 'field4']);

      final composite =
          CompositePropagator([propagator1, propagator2, propagator3]);

      final fields = composite.fields();
      expect(fields, containsAll(['field1', 'field2', 'field3', 'field4']));
      expect(fields.length, equals(4)); // No duplicates
    });

    test('extract() applies propagators in reverse order', () {
      final propagator1 = MockPropagator('p1', ['field1']);
      final propagator2 = MockPropagator('p2', ['field2']);
      final propagator3 = MockPropagator('p3', ['field3']);

      final composite =
          CompositePropagator([propagator1, propagator2, propagator3]);

      final context = OTelAPI.context();
      final carrier = {
        'field1': 'value1',
        'field2': 'value2',
        'field3': 'value3'
      };
      final getter = MockTextMapGetter(carrier);

      final extractedContext = composite.extract(context, carrier, getter);

      // Propagators should be applied in reverse order (p3, p2, p1)
      expect(extractedContext.baggage?.getValue('field1'), equals('p1:value1'));
      expect(extractedContext.baggage?.getValue('field2'), equals('p2:value2'));
      expect(extractedContext.baggage?.getValue('field3'), equals('p3:value3'));
    });

    test('extract() preserves original context for fields not in carrier', () {
      final propagator1 = MockPropagator('p1', ['field1', 'missing1']);
      final propagator2 = MockPropagator('p2', ['field2', 'missing2']);

      final composite = CompositePropagator([propagator1, propagator2]);

      // Create context with existing baggage
      final baggage = OTelAPI.baggage().copyWith('existing', 'value');
      final context = OTelAPI.context().copyWithBaggage(baggage);

      final carrier = {'field1': 'value1', 'field2': 'value2'};
      final getter = MockTextMapGetter(carrier);

      final extractedContext = composite.extract(context, carrier, getter);

      // Should preserve existing baggage
      expect(extractedContext.baggage?.getValue('existing'), equals('value'));

      // Should add new values from carrier
      expect(extractedContext.baggage?.getValue('field1'), equals('p1:value1'));
      expect(extractedContext.baggage?.getValue('field2'), equals('p2:value2'));

      // Missing fields should not be in the baggage
      expect(extractedContext.baggage?.getValue('missing1'), isNull);
      expect(extractedContext.baggage?.getValue('missing2'), isNull);
    });

    test('inject() applies propagators in order', () {
      final propagator1 = MockPropagator('p1', ['field1']);
      final propagator2 = MockPropagator('p2', ['field2']);
      final propagator3 = MockPropagator('p3', ['field3']);

      final composite =
          CompositePropagator([propagator1, propagator2, propagator3]);

      // Create context with baggage values that match each propagator's prefix
      final baggage = OTelAPI.baggage()
          .copyWith('field1', 'p1:value1')
          .copyWith('field2', 'p2:value2')
          .copyWith('field3', 'p3:value3');
      final context = OTelAPI.context().copyWithBaggage(baggage);

      final carrier = <String, String>{};
      final setter = MockTextMapSetter(carrier);

      composite.inject(context, carrier, setter);

      // Each propagator should inject its own fields
      expect(carrier['field1'], equals('value1'));
      expect(carrier['field2'], equals('value2'));
      expect(carrier['field3'], equals('value3'));
    });

    test('inject() does not inject values that do not match propagator prefix',
        () {
      final propagator1 = MockPropagator('p1', ['field1']);
      final propagator2 = MockPropagator('p2', ['field2']);

      final composite = CompositePropagator([propagator1, propagator2]);

      // Create context with values that don't match propagator prefixes
      final baggage = OTelAPI.baggage()
          .copyWith('field1', 'p2:value1') // Wrong prefix for propagator1
          .copyWith('field2', 'p1:value2') // Wrong prefix for propagator2
          .copyWith('field3', 'value3'); // No prefix
      final context = OTelAPI.context().copyWithBaggage(baggage);

      final carrier = <String, String>{};
      final setter = MockTextMapSetter(carrier);

      composite.inject(context, carrier, setter);

      // No values should be injected since prefixes don't match
      expect(carrier['field1'], isNull);
      expect(carrier['field2'], isNull);
      expect(carrier['field3'], isNull);
    });

    test('works with empty list of propagators', () {
      final composite = CompositePropagator<Map<String, String>, String>([]);

      final context = OTelAPI.context();
      final carrier = <String, String>{};
      final getter = MockTextMapGetter(carrier);
      final setter = MockTextMapSetter(carrier);

      // Should not throw and should return original context
      final extractedContext = composite.extract(context, carrier, getter);
      expect(extractedContext, equals(context));

      // Should not throw and should not modify carrier
      composite.inject(context, carrier, setter);
      expect(carrier, isEmpty);

      // Fields should be empty
      expect(composite.fields(), isEmpty);
    });
  });
}
