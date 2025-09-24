// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';
import '../../../test_util.dart';

void main() {
  group('APISpan', () {
    late APIMeterProvider meterProvider;
    late APITracerProvider tracerProvider;
    late APITracer tracer;

    late Map<String, Object> fullyTypesMapOfKVs;

    setUp(() {
      // Reset API state
      OTelAPI.reset();

      // Re-initialize for this test
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      fullyTypesMapOfKVs = {
        'str': 'value',
        'bool': true,
        'int': 42,
        'double': 1.23,
        'strList': ['a', 'b'],
        'boolList': [true, false],
        'intList': [4, 3],
        'doubleList': [1.1, 2.2]
      };

      meterProvider = OTelAPI.meterProvider();
      tracerProvider = OTelAPI.tracerProvider();
      tracer = tracerProvider.getTracer('test-tracer');
    });

    tearDown(() async {
      await tracerProvider.shutdown();
      await meterProvider.shutdown();
    });

    test('creates span with correct default values', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
        parentSpan: null,
      );

      expect(span.isRecording, isTrue);
      expect(span.name, equals('test-span'));
      expect(span.kind, equals(SpanKind.internal));
      expect(span.status, equals(SpanStatusCode.Unset));
      expect(span.statusDescription, isNull);
      expect(span.parentSpan, isNull);
      expect(span.attributes.length, equals(0));
    });

    test('handles attribute updates correctly', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
        parentSpan: null,
      );

      final attrs = <String, Object>{
        'string.key': 'value',
        'int.key': 42,
        'bool.key': true,
        'double.key': 3.14,
      }.toAttributes();

      span.attributes = attrs;

      final spanAttrs = span.attributes.toMap();
      expect(spanAttrs['string.key']?.value, equals('value'));
      expect(spanAttrs['int.key']?.value, equals(42));
      expect(spanAttrs['bool.key']?.value, equals(true));
      expect(spanAttrs['double.key']?.value, equals(3.14));
    });

    test('handles attribute type-specific setters', () {
      final span = tracer.startSpan('test-span');

      // Test individual attribute setters
      span.setStringAttribute<String>('string.key', 'string-value');
      span.setBoolAttribute('bool.key', true);
      span.setIntAttribute('int.key', 42);
      span.setDoubleAttribute('double.key', 3.14);

      // Set list attributes
      span.setStringListAttribute<List<String>>('string.list', ['a', 'b', 'c']);
      span.setBoolListAttribute('bool.list', [true, false, true]);
      span.setIntListAttribute('int.list', [1, 2, 3]);
      span.setDoubleListAttribute('double.list', [1.1, 2.2, 3.3]);

      // Verify all attributes
      expect(span.attributes.getString('string.key'), equals('string-value'));
      expect(span.attributes.getBool('bool.key'), equals(true));
      expect(span.attributes.getInt('int.key'), equals(42));
      expect(span.attributes.getDouble('double.key'), equals(3.14));

      expect(span.attributes.getStringList('string.list'),
          equals(['a', 'b', 'c']));
      expect(span.attributes.getBoolList('bool.list'),
          equals([true, false, true]));
      expect(span.attributes.getIntList('int.list'), equals([1, 2, 3]));
      expect(span.attributes.getDoubleList('double.list'),
          equals([1.1, 2.2, 3.3]));
    });

    test('handles status updates correctly', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      expect(span.status, equals(SpanStatusCode.Unset));

      // Create a new status with error and description
      span.setStatus(SpanStatusCode.Error, 'Error occurred');
      expect(span.status, equals(SpanStatusCode.Error));
      expect(span.statusDescription, equals('Error occurred'));

      // Use the OK constant
      span.setStatus(SpanStatusCode.Ok);
      expect(span.status, equals(SpanStatusCode.Ok));
      expect(span.statusDescription, isNull);
    });

    test('records end time when ended', () {
      final startTime = DateTime.now();
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      expect(span.isRecording, isTrue);

      span.end();

      expect(span.isRecording, isFalse);
      expect(span.endTime, isNotNull);
      expect(span.endTime!.isAfter(startTime), isTrue);
    });

    test('records specific end time when provided', () {
      final startTime = DateTime.now();
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      expect(span.isRecording, isTrue);

      // End with a specific timestamp
      final endTime = startTime.add(const Duration(milliseconds: 500));
      span.end(endTime: endTime);

      expect(span.isRecording, isFalse);
      expect(span.endTime, equals(endTime));
    });

    test('ignores updates after end', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      span.end();

      // These should all be ignored
      span.setStringAttribute<String>('key', 'value');
      span.setStatus(SpanStatusCode.Error, 'Error');
      span.updateName('new-name');

      expect(span.attributes.length, equals(0));
      expect(span.status, equals(SpanStatusCode.Ok));
      expect(span.statusDescription, isNull);
      expect(span.name, equals('test-span'));
    });

    test('handles events correctly', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      final DateTime beforeCreation = DateTime.now();
      span.addEventNow(
        'test-event',
        {'event.key': 'value'}.toAttributes(),
      );
      final DateTime afterCreation = DateTime.now();

      final events = span.spanEvents;
      expect(events, hasLength(1));

      final event = events?.first;
      expect(event?.name, equals('test-event'));

      expect(event?.attributes?.toMap()['event.key']?.value, equals('value'));
      expect(event?.timestamp, IsBetween(beforeCreation, afterCreation));
    });

    test('addEvent with timestamp', () {
      final span = tracer.startSpan('test-span');
      final timestamp = DateTime.now().subtract(const Duration(minutes: 5));

      span.addEvent(OTelAPI.spanEvent(
        'test-event',
        Attributes.of({'key': 'value'}),
        timestamp,
      ));

      final events = span.spanEvents;
      expect(events?.first.timestamp, equals(timestamp));
    });

    test('handles parent context correctly', () {
      // First create a root span
      final rootSpan = tracer.startSpan('root-span');

      // Now create a child span
      final childSpan = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
        parentSpan: rootSpan, // This sets up the parent-child relationship
      );

      // Verify inheritance of trace ID
      expect(
          childSpan.spanContext.traceId, equals(rootSpan.spanContext.traceId));

      // Verify parent span ID is set correctly
      expect(childSpan.spanContext.parentSpanId,
          equals(rootSpan.spanContext.spanId));

      // Verify a new span ID was generated
      expect(childSpan.spanContext.spanId,
          isNot(equals(rootSpan.spanContext.spanId)));
    });

    test('handles exceptions correctly', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      final exception = Exception('Test error');
      span.recordException(exception);

      // Exceptions don't record an exception status
      expect(span.status, equals(SpanStatusCode.Unset));

      final events = span.spanEvents;
      expect(events, hasLength(1));
      expect(events?.first.name, equals('exception'));

      final eventAttrs = events?.first.attributes?.toMap() ?? {};
      final typeKey = 'exception.type';
      final msgKey = 'exception.message';

      expect(eventAttrs[typeKey]?.value, contains('Exception'));
      expect(eventAttrs[msgKey]?.value, equals(exception.toString()));
    });

    test('recordException with custom attributes', () {
      final span = tracer.startSpan('test-span');
      final exception = Exception('Test error');

      span.recordException(
        exception,
        attributes: Attributes.of({'custom': 'attribute'}),
      );

      final events = span.spanEvents;
      final eventAttrs = events?.first.attributes?.toMap() ?? {};

      // Should contain both standard exception attributes and custom ones
      expect(eventAttrs['exception.type']?.value, contains('Exception'));
      expect(eventAttrs['custom']?.value, equals('attribute'));
    });

    test('recordException with escaped string', () {
      final span = tracer.startSpan('test-span');
      final exception =
          Exception('Error with "quotes" and newlines\nand more\r\nstuff');

      span.recordException(exception);

      final events = span.spanEvents;
      final eventAttrs = events?.first.attributes?.toMap() ?? {};

      // Should contain the full message with escaping preserved
      expect(
          eventAttrs['exception.message']?.value, equals(exception.toString()));
    });

    test('setAttributes with mixed types', () {
      final span = tracer.startSpan('test');
      span.addAttributes(OTelAPI.attributesFromMap(fullyTypesMapOfKVs));

      expect(span.attributes, isNotNull);
      expect(span.attributes.getString('str'), isNotNull);
      expect(span.attributes.length, equals(8));
    });

    test('getAttribute returns empty with no attributes', () {
      final span = tracer.startSpan('test');
      expect(span.attributes.length, equals(0));
    });

    test('getAttribute returns null for missing key', () {
      final span = tracer.startSpan('test',
          attributes: OTelAPI.attributesFromMap(fullyTypesMapOfKVs));
      expect(span.attributes, isNotNull);
      expect(span.attributes.getString('str'), 'value');
      expect(span.attributes.getString('str-not-here'), isNull);
    });

    test('addEvent\'s', () {
      final span = tracer.startSpan('test');
      span.addEvent(OTelAPI.spanEvent('something happened'));
      expect(span.spanEvents, isNotNull);
      expect(span.spanEvents!.length, equals(1));
      span.addEvent(OTelAPI.spanEvent('something else happened',
          OTelAPI.attributesFromMap({'from': 'here'})));
      expect(span.spanEvents, isNotNull);
    });

    test('addEvent throws if name is empty', () {
      final span = tracer.startSpan('test');
      expect(
        () => span.addEvent(OTelAPI.spanEvent('')),
        throwsArgumentError,
      );
    });

    test('end() is idempotent', () {
      final span = tracer.startSpan('test');
      span.end();
      span.end(); // Should not throw
      expect(span.status, equals(SpanStatusCode.Ok));
    });

    test('addEvent twice', () {
      final span = tracer.startSpan('test');
      span.addEventNow('first');
      expect(span.spanEvents, isNotNull);
      expect(span.spanEvents!.length, equals(1));
      span.addEventNow(
        'second',
      );
      expect(span.spanEvents, isNotNull);
      expect(span.spanEvents!.length, equals(2));
    });

    test('addEvent ignored after end', () {
      final span = tracer.startSpan('test');
      span.addEventNow('nice and early');
      span.end();
      expect(span.spanEvents, isNotNull);
      expect(span.spanEvents!.length, equals(1));
      span.addEventNow(
        'too late',
      );
      expect(span.spanEvents, isNotNull);
      expect(span.spanEvents!.length, equals(1));
    });

    test('setStatus ignored after end', () {
      final span = tracer.startSpan('test');
      expect(span.status, equals(SpanStatusCode.Unset));
      span.end();
      expect(span.status, equals(SpanStatusCode.Ok));
      span.setStatus(SpanStatusCode.Error);
      expect(span.status, equals(SpanStatusCode.Ok));
    });

    test('recordException is ignored after end', () {
      final span = tracer.startSpan('test');
      span.end();
      expect(span.spanEvents, isNull);
      span.recordException(Exception('test'));
      expect(span.spanEvents, isNull);
    });

    test('updateName is ignored after end', () {
      final span = tracer.startSpan('test');
      expect(span.name, equals('test'));
      span.updateName('new name');
      expect(span.name, equals('new name'));
      span.end();
      span.updateName('too late');
      expect(span.name, equals('new name'));
    });

    test('spanContext returns valid SpanContext', () {
      final span = tracer.startSpan('test-span');
      final context = span.spanContext;

      expect(context.isValid, isTrue);
      expect(context.traceId.isValid, isTrue);
      expect(context.spanId.isValid, isTrue);
    });

    test('creates span with links', () {
      // Create a span to link to
      final linkedSpan = tracer.startSpan('linked-span');
      final linkedContext = linkedSpan.spanContext;

      // Create links with attributes
      final linkAttrs = Attributes.of({'link.attr': 'value'});
      final links = [OTelAPI.spanLink(linkedContext, linkAttrs)];

      // Create a span with links
      final span = tracer.startSpan(
        'test-span',
        links: links,
      );

      // Links are not directly accessible in the API but are passed to the SDK
      expect(span, isNotNull);
    });

    test('span factory methods throw with invalid context', () {
      final timestamp = DateTime.now();

      // This should throw because we're using an invalid span context
      expect(
          () => tracer.createSpan(
                name: 'test-span',
                spanContext:
                    OTelAPI.spanContextInvalid(), // Invalid span context
                parentSpan: null,
                kind: SpanKind.server,
                startTime: timestamp,
                attributes: Attributes.of({'key': 'value'}),
                links: [],
              ),
          throwsArgumentError);
    });

    test('span factory methods with valid context', () {
      final timestamp = DateTime.now();

      // Create a valid span context
      final validSpanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        traceFlags: OTelAPI.traceFlags(),
      );

      final span = tracer.createSpan(
        name: 'test-span',
        spanContext: validSpanContext, // Valid span context
        parentSpan: null,
        kind: SpanKind.server,
        startTime: timestamp,
        attributes: Attributes.of({'key': 'value'}),
        links: [],
      );

      span.addEventNow('test-event');

      expect(span.name, equals('test-span'));
      expect(span.kind, equals(SpanKind.server));
      expect(span.attributes.getString('key'), equals('value'));
      expect(span.status, equals(SpanStatusCode.Unset));
      expect(span.spanEvents?.length, equals(1));
    });
  });
}
