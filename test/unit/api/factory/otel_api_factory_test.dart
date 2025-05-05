// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// ignore_for_file: always_declare_return_types

import 'dart:typed_data';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  late OTelAPIFactory factory;

  setUp(() {
    // First reset any previous state
    OTelAPI.reset();

    // Initialize with test parameters
    OTelAPI.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );

    // Get the factory for use in tests
    factory = OTelFactory.otelFactory as OTelAPIFactory;
  });

  group('OTelAPIFactory', () {
    test('factory function creates an OTelAPIFactory instance', () {
      final factory = otelApiFactoryFactoryFunction(
        apiEndpoint: 'http://localhost:4317',
        apiServiceName: 'test-service',
        apiServiceVersion: '1.0.0',
      );
      expect(factory, isA<OTelAPIFactory>());
    });

    test('creates baggage entry', () {
      final entry = factory.baggageEntry('test-value', 'test-metadata');
      expect(entry.value, equals('test-value'));
      expect(entry.metadata, equals('test-metadata'));
    });

    test('creates baggage with entries', () {
      final entry = factory.baggageEntry('test-value', 'test-metadata');
      final baggage = factory.baggage({'test-key': entry});

      expect(baggage.getEntry('test-key')?.value, equals('test-value'));
      expect(baggage.getEntry('test-key')?.metadata, equals('test-metadata'));
    });

    test('creates baggage from map', () {
      final baggage = factory.baggageForMap({'test-key': 'test-value'});

      expect(baggage.getEntry('test-key')?.value, equals('test-value'));
      expect(baggage.getEntry('test-key')?.metadata, isNull);
    });

    test('creates context', () {
      final context = factory.context();
      expect(context, isA<Context>());
    });

    test('creates context with baggage', () {
      final baggage = factory.baggage();
      final context = factory.context(baggage: baggage);
      expect(context, isA<Context>());
      expect(context.baggage, equals(baggage));
    });

    test('creates context key', () {
      final id = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final key = factory.contextKey<String>('test-key', id);

      expect(key.name, equals('test-key'));
    });

    test('creates tracer provider', () {
      final provider = factory.tracerProvider(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      expect(provider, isA<APITracerProvider>());
      expect(provider.serviceName, equals('test-service'));
      expect(provider.serviceVersion, equals('1.0.0'));
    });

    test('creates meter provider', () {
      final provider = factory.meterProvider(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      expect(provider, isA<APIMeterProvider>());
      expect(provider.serviceName, equals('test-service'));
      expect(provider.serviceVersion, equals('1.0.0'));
    });

    test('creates empty attributes', () {
      final attributes = factory.attributes();
      expect(attributes, isA<Attributes>());
      expect(attributes.length, equals(0));
    });

    test('creates attributes from list', () {
      final stringAttr = factory.attributeString('string-key', 'string-value');
      final intAttr = factory.attributeInt('int-key', 42);

      final attributes = factory.attributesFromList([stringAttr, intAttr]);

      expect(attributes.length, equals(2));
      expect(attributes.getString('string-key'), equals('string-value'));
      // Test that trying to get an int value as a string throws an exception
      expect(() => attributes.getString('int-key'), throwsA(isA<StateError>()));
      // Test getting the value with correct type
      expect(attributes.getInt('int-key'), equals(42));
    });

    test('creates attributes from map with various types', () {
      final dateTime = DateTime(2023, 1, 1, 12, 0, 0);
      final attributesMap = {
        'string-key': 'string-value',
        'int-key': 42,
        'double-key': 3.14,
        'bool-key': true,
        'date-key': dateTime,
        'string-list-key': <String>['value1', 'value2'],
        'int-list-key': <int>[1, 2, 3],
        'double-list-key': <double>[1.1, 2.2, 3.3],
        'bool-list-key': <bool>[true, false, true],
      };

      final attributes = factory.attributesFromMap(attributesMap);

      expect(attributes.length, equals(9));
      expect(attributes.getString('string-key'), equals('string-value'));
      // Test that trying to get an int value as a string throws an exception
      expect(() => attributes.getString('int-key'), throwsA(isA<StateError>()));
      // Test getting the value with correct type
      expect(attributes.getInt('int-key'), equals(42));
      expect(attributes.getDouble('double-key'), equals(3.14));
      expect(attributes.getBool('bool-key'), equals(true));
      expect(attributes.getString('date-key'), equals(dateTime.toUtc().toIso8601String()));
      expect(attributes.getStringList('string-list-key'), equals(['value1', 'value2']));
      expect(attributes.getIntList('int-list-key'), equals([1, 2, 3]));
      expect(attributes.getDoubleList('double-list-key'), equals([1.1, 2.2, 3.3]));
      expect(attributes.getBoolList('bool-list-key'), equals([true, false, true]));
    });

    test('static attrsFromMap creates attributes from map', () {
      final attributesMap = {
        'string-key': 'string-value',
        'int-key': 42,
      };

      final attributes = OTelAPIFactory.attrsFromMap(attributesMap);

      expect(attributes.length, equals(2));
      expect(attributes.getString('string-key'), equals('string-value'));
      // Test that trying to get an int value as a string throws an exception
      expect(() => attributes.getString('int-key'), throwsA(isA<StateError>()));
      // Test getting the value with correct type
      expect(attributes.getInt('int-key'), equals(42));
    });

    test('creates attribute with string value', () {
      final attribute = factory.attributeString('string-key', 'string-value');
      expect(attribute.key, equals('string-key'));
      expect(attribute.value, equals('string-value'));
    });

    test('creates attribute with boolean value', () {
      final attribute = factory.attributeBool('bool-key', true);
      expect(attribute.key, equals('bool-key'));
      expect(attribute.value, equals(true));
    });

    test('creates attribute with integer value', () {
      final attribute = factory.attributeInt('int-key', 42);
      expect(attribute.key, equals('int-key'));
      expect(attribute.value, equals(42));
    });

    test('creates attribute with double value', () {
      final attribute = factory.attributeDouble('double-key', 3.14);
      expect(attribute.key, equals('double-key'));
      expect(attribute.value, equals(3.14));
    });

    test('creates attribute with string list value', () {
      final attribute = factory.attributeStringList('string-list-key', ['value1', 'value2']);
      expect(attribute.key, equals('string-list-key'));
      expect(attribute.value, equals(['value1', 'value2']));
    });

    test('creates attribute with boolean list value', () {
      final attribute = factory.attributeBoolList('bool-list-key', [true, false]);
      expect(attribute.key, equals('bool-list-key'));
      expect(attribute.value, equals([true, false]));
    });

    test('creates attribute with integer list value', () {
      final attribute = factory.attributeIntList('int-list-key', [1, 2, 3]);
      expect(attribute.key, equals('int-list-key'));
      expect(attribute.value, equals([1, 2, 3]));
    });

    test('creates attribute with double list value', () {
      final attribute = factory.attributeDoubleList('double-list-key', [1.1, 2.2, 3.3]);
      expect(attribute.key, equals('double-list-key'));
      expect(attribute.value, equals([1.1, 2.2, 3.3]));
    });

    test('creates trace ID', () {
      final traceId = factory.traceId();
      expect(traceId, isA<TraceId>());
      expect(traceId.toString().length, equals(32)); // 16 bytes = 32 hex chars
    });

    test('creates trace ID from bytes', () {
      final bytes = Uint8List.fromList(List.generate(16, (index) => index));
      final traceId = factory.traceId(bytes);
      expect(traceId.toString(), equals('000102030405060708090a0b0c0d0e0f'));
    });

    test('creates invalid trace ID', () {
      final traceId = factory.traceIdInvalid();
      expect(traceId.toString(), equals('00000000000000000000000000000000'));
      expect(traceId.isValid, equals(false));
    });

    test('creates span ID', () {
      final spanId = factory.spanId();
      expect(spanId, isA<SpanId>());
      expect(spanId.toString().length, equals(16)); // 8 bytes = 16 hex chars
    });

    test('creates span ID from bytes', () {
      final bytes = Uint8List.fromList(List.generate(8, (index) => index));
      final spanId = factory.spanId(bytes);
      expect(spanId.toString(), equals('0001020304050607'));
    });

    test('creates invalid span ID', () {
      final spanId = factory.spanIdInvalid();
      expect(spanId.toString(), equals('0000000000000000'));
      expect(spanId.isValid, equals(false));
    });

    test('creates trace state', () {
      final traceState = factory.traceState({'key1': 'value1', 'key2': 'value2'});
      expect(traceState, isA<TraceState>());
      expect(traceState.get('key1'), equals('value1'));
      expect(traceState.get('key2'), equals('value2'));
    });

    test('creates trace flags', () {
      final traceFlags = factory.traceFlags(1); // Sampled flag
      expect(traceFlags, isA<TraceFlags>());
      expect(traceFlags.isSampled, equals(true));
    });

    test('creates span context', () {
      final traceId = factory.traceId();
      final spanId = factory.spanId();
      final traceFlags = factory.traceFlags(1); // Sampled flag

      final spanContext = factory.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: traceFlags,
      );

      expect(spanContext, isA<SpanContext>());
      expect(spanContext.traceId, equals(traceId));
      expect(spanContext.spanId, equals(spanId));
      expect(spanContext.traceFlags, equals(traceFlags));
    });

    test('creates span context from parent', () {
      final parentTraceId = factory.traceId();
      final parentSpanId = factory.spanId();
      final traceFlags = factory.traceFlags(1); // Sampled flag

      final parentContext = factory.spanContext(
        traceId: parentTraceId,
        spanId: parentSpanId,
        traceFlags: traceFlags,
      );

      final childContext = factory.spanContextFromParent(parentContext);

      expect(childContext, isA<SpanContext>());
      expect(childContext.traceId, equals(parentTraceId)); // Inherited from parent
      expect(childContext.spanId, isNot(equals(parentSpanId))); // New span ID
      expect(childContext.parentSpanId, equals(parentSpanId)); // Parent's span ID
      expect(childContext.traceFlags, equals(traceFlags)); // Inherited from parent
    });

    test('creates invalid span context', () {
      final spanContext = factory.spanContextInvalid();

      expect(spanContext, isA<SpanContext>());
      expect(spanContext.isValid, equals(false));
      expect(spanContext.traceId.isValid, equals(false));
      expect(spanContext.spanId.isValid, equals(false));
    });

    test('creates span link', () {
      final spanContext = factory.spanContext(
        traceId: factory.traceId(),
        spanId: factory.spanId(),
      );

      final attributes = factory.attributesFromMap({'key': 'value'});
      final spanLink = factory.spanLink(spanContext, attributes: attributes);

      expect(spanLink, isA<SpanLink>());
      expect(spanLink.spanContext, equals(spanContext));
      expect(spanLink.attributes, equals(attributes));
    });

    test('creates span event', () {
      final attributes = factory.attributesFromMap({'key': 'value'});
      final timestamp = DateTime.now();
      final spanEvent = factory.spanEvent('test-event', attributes, timestamp);

      expect(spanEvent, isA<SpanEvent>());
      expect(spanEvent.name, equals('test-event'));
      expect(spanEvent.attributes, equals(attributes));
      expect(spanEvent.timestamp, equals(timestamp));
    });

    test('creates span event with current timestamp', () {
      final attributes = factory.attributesFromMap({'key': 'value'});
      final beforeTime = DateTime.now();
      final spanEvent = factory.spanEventNow('test-event', attributes);
      final afterTime = DateTime.now();

      expect(spanEvent, isA<SpanEvent>());
      expect(spanEvent.name, equals('test-event'));
      expect(spanEvent.attributes, equals(attributes));
      expect(spanEvent.timestamp.isAfter(beforeTime) || spanEvent.timestamp.isAtSameMomentAs(beforeTime), isTrue);
      expect(spanEvent.timestamp.isBefore(afterTime) || spanEvent.timestamp.isAtSameMomentAs(afterTime), isTrue);
    });

    test('creates counter instrument', () {
      final counter = factory.createCounter(
        'test-counter',
        description: 'Test counter description',
        unit: 'count',
      );

      expect(counter, isA<APICounter>());
      expect(counter.name, equals('test-counter'));
      expect(counter.description, equals('Test counter description'));
      expect(counter.unit, equals('count'));
    });

    test('creates up-down counter instrument', () {
      final upDownCounter = factory.createUpDownCounter(
        'test-up-down-counter',
        description: 'Test up-down counter description',
        unit: 'count',
      );

      expect(upDownCounter, isA<APIUpDownCounter>());
      expect(upDownCounter.name, equals('test-up-down-counter'));
      expect(upDownCounter.description, equals('Test up-down counter description'));
      expect(upDownCounter.unit, equals('count'));
    });

    test('creates gauge instrument', () {
      final gauge = factory.createGauge(
        'test-gauge',
        description: 'Test gauge description',
        unit: 'ms',
      );

      expect(gauge, isA<APIGauge>());
      expect(gauge.name, equals('test-gauge'));
      expect(gauge.description, equals('Test gauge description'));
      expect(gauge.unit, equals('ms'));
    });

    test('creates histogram instrument', () {
      final boundaries = [0.0, 10.0, 100.0, 1000.0];
      final histogram = factory.createHistogram(
        'test-histogram',
        description: 'Test histogram description',
        unit: 'ms',
        boundaries: boundaries,
      );

      expect(histogram, isA<APIHistogram>());
      expect(histogram.name, equals('test-histogram'));
      expect(histogram.description, equals('Test histogram description'));
      expect(histogram.unit, equals('ms'));
    });

    test('creates observable counter instrument', () {
      callback(result) {}
      final observableCounter = factory.createObservableCounter(
        'test-observable-counter',
        description: 'Test observable counter description',
        unit: 'count',
        callback: callback,
      );

      expect(observableCounter, isA<APIObservableCounter>());
      expect(observableCounter.name, equals('test-observable-counter'));
      expect(observableCounter.description, equals('Test observable counter description'));
      expect(observableCounter.unit, equals('count'));
    });

    test('creates observable gauge instrument', () {
      callback(result) {}
      final observableGauge = factory.createObservableGauge(
        'test-observable-gauge',
        description: 'Test observable gauge description',
        unit: 'ms',
        callback: callback,
      );

      expect(observableGauge, isA<APIObservableGauge>());
      expect(observableGauge.name, equals('test-observable-gauge'));
      expect(observableGauge.description, equals('Test observable gauge description'));
      expect(observableGauge.unit, equals('ms'));
    });

    test('creates observable up-down counter instrument', () {
      callback(result) {}
      final observableUpDownCounter = factory.createObservableUpDownCounter(
        'test-observable-up-down-counter',
        description: 'Test observable up-down counter description',
        unit: 'count',
        callback: callback,
      );

      expect(observableUpDownCounter, isA<APIObservableUpDownCounter>());
      expect(observableUpDownCounter.name, equals('test-observable-up-down-counter'));
      expect(observableUpDownCounter.description, equals('Test observable up-down counter description'));
      expect(observableUpDownCounter.unit, equals('count'));
    });
  });
}
