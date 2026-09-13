// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:dartastic_opentelemetry_api/src/api/trace/span.dart';
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
      installSdkLikeFactory();

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
      );

      expect(span.isRecording, isTrue);
      expect(span.name, equals('test-span'));
      expect(span.kind, equals(SpanKind.internal));
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
      expect(getReadableSpan(span).statusDescription, isNull);
      expect(span.parentSpan, isNull);
      expect(getReadableSpan(span).attributes.length, equals(0));
    });

    test('creates non-recording span when isRecording is false', () {
      final span = tracer.startSpan(
        'test-span',
        isRecording: false,
      );

      expect(span.isRecording, isFalse);

      // Mutating operations should be no-ops
      span.setStringAttribute<String>('key', 'value');
      span.setStatus(SpanStatusCode.Error, 'Error');
      span.updateName('new-name');
      span.addEventNow('test-event');

      expect(getReadableSpan(span).attributes.length, equals(0));
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
      expect(getReadableSpan(span).statusDescription, isNull);
      expect(span.name, equals('test-span'));
      expect(getReadableSpan(span).spanEvents, isNull);
    });

    test('handles attribute updates correctly', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      final attrs = <String, Object>{
        'string.key': 'value',
        'int.key': 42,
        'bool.key': true,
        'double.key': 3.14,
      }.toAttributes();

      span.attributes = attrs;

      final spanAttrs = getReadableSpan(span).attributes.toMap();
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
      expect(getReadableSpan(span).attributes.getString('string.key'),
          equals('string-value'));
      expect(
          getReadableSpan(span).attributes.getBool('bool.key'), equals(true));
      expect(getReadableSpan(span).attributes.getInt('int.key'), equals(42));
      expect(getReadableSpan(span).attributes.getDouble('double.key'),
          equals(3.14));

      expect(getReadableSpan(span).attributes.getStringList('string.list'),
          equals(['a', 'b', 'c']));
      expect(getReadableSpan(span).attributes.getBoolList('bool.list'),
          equals([true, false, true]));
      expect(getReadableSpan(span).attributes.getIntList('int.list'),
          equals([1, 2, 3]));
      expect(getReadableSpan(span).attributes.getDoubleList('double.list'),
          equals([1.1, 2.2, 3.3]));
    });

    test('handles status updates correctly', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));

      // Create a new status with error and description
      span.setStatus(SpanStatusCode.Error, 'Error occurred');
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Error));
      expect(getReadableSpan(span).statusDescription, equals('Error occurred'));

      // Use the OK constant
      span.setStatus(SpanStatusCode.Ok);
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Ok));
      expect(getReadableSpan(span).statusDescription, isNull);
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
      expect(
          span.endTime!.isAfter(startTime) ||
              span.endTime!.isAtSameMomentAs(startTime),
          isTrue);
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

      expect(getReadableSpan(span).attributes.length, equals(0));
      // end() does not change the status; it stays Unset (trace/api.md)
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
      expect(getReadableSpan(span).statusDescription, isNull);
      expect(span.name, equals('test-span'));
    });

    test('handles events correctly', () {
      final span = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
      );

      // Capture bounds from the same TimeProvider the span uses, so the
      // bracketing assertion is exact on every platform. On Dart-on-JS /
      // Wasm, `tracer.timeProvider` is `WebTimeProvider` (sub-ms via
      // `performance.now`) while `DateTime.now` is `Date.now` (ms-
      // truncated) — bracketing with `DateTime.now` would let the event
      // timestamp fall up to ~1ms past `afterCreation`.
      final beforeCreation = tracer.timeProvider.nowDateTime();
      span.addEventNow(
        'test-event',
        {'event.key': 'value'}.toAttributes(),
      );
      final afterCreation = tracer.timeProvider.nowDateTime();

      final events = getReadableSpan(span).spanEvents;
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

      final events = getReadableSpan(span).spanEvents;
      expect(events?.first.timestamp, equals(timestamp));
    });

    test('handles parent context correctly', () {
      // First create a root span
      final rootSpan = tracer.startSpan('root-span');

      // Now create a child span
      final childSpan = tracer.startSpan(
        'test-span',
        kind: SpanKind.internal,
        context: Context.current
            .withSpan(rootSpan), // This sets up the parent-child relationship
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
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));

      final events = getReadableSpan(span).spanEvents;
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

      final events = getReadableSpan(span).spanEvents;
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

      final events = getReadableSpan(span).spanEvents;
      final eventAttrs = events?.first.attributes?.toMap() ?? {};

      // Should contain the full message with escaping preserved
      expect(
          eventAttrs['exception.message']?.value, equals(exception.toString()));
    });

    test('setAttributes with mixed types', () {
      final span = tracer.startSpan('test');
      span.addAttributes(OTelAPI.attributesFromMap(fullyTypesMapOfKVs));

      expect(getReadableSpan(span).attributes, isNotNull);
      expect(getReadableSpan(span).attributes.getString('str'), isNotNull);
      expect(getReadableSpan(span).attributes.length, equals(8));
    });

    test('getAttribute returns empty with no attributes', () {
      final span = tracer.startSpan('test');
      expect(getReadableSpan(span).attributes.length, equals(0));
    });

    test('getAttribute returns null for missing key', () {
      final span = tracer.startSpan('test',
          attributes: OTelAPI.attributesFromMap(fullyTypesMapOfKVs));
      expect(getReadableSpan(span).attributes, isNotNull);
      expect(getReadableSpan(span).attributes.getString('str'), 'value');
      expect(
          getReadableSpan(span).attributes.getString('str-not-here'), isNull);
    });

    test('addEvent\'s', () {
      final span = tracer.startSpan('test');
      span.addEvent(OTelAPI.spanEvent('something happened'));
      expect(getReadableSpan(span).spanEvents, isNotNull);
      expect(getReadableSpan(span).spanEvents!.length, equals(1));
      span.addEvent(OTelAPI.spanEvent('something else happened',
          OTelAPI.attributesFromMap({'from': 'here'})));
      expect(getReadableSpan(span).spanEvents, isNotNull);
    });

    test('an event with an empty name is dropped, not thrown (api#69)', () {
      // error-handling.md: an API method must not throw when the user
      // calls it incorrectly. Every event path drops the event instead.
      // https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
      final span = tracer.startSpan('test');

      span.addEvent(OTelAPI.spanEvent(''));
      span.addEventNow('');
      span.addEvents({'': null});

      expect(getReadableSpan(span).spanEvents ?? const <SpanEvent>[], isEmpty);
    });

    test('an empty event name reaches the error handler (api#69)', () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((error, stackTrace) => reported.add(error));
      final span = tracer.startSpan('test');

      span.addEventNow('');
      expect(reported, hasLength(1));
      expect(reported.single, isA<ArgumentError>());

      reported.clear();
      span.addEvents({'': null});
      expect(reported, hasLength(1));
      expect(reported.single, isA<ArgumentError>());

      reported.clear();
      OTelAPI.spanEvent('');
      expect(reported, hasLength(1),
          reason: 'making the event reports, even without a span');

      reported.clear();
      span.addEvent(OTelAPI.spanEvent(''));
      expect(reported, hasLength(2),
          reason: 'once when the event is made, once when the span drops it');

      expect(getReadableSpan(span).spanEvents ?? const <SpanEvent>[], isEmpty);
      OTelAPI.setErrorHandler(null);
    });

    test('an empty name drops only that entry of addEvents (api#69)', () {
      final span = tracer.startSpan('test');

      span.addEvents({'': null, 'kept': null});

      expect(getReadableSpan(span).spanEvents, hasLength(1));
      expect(getReadableSpan(span).spanEvents!.single.name, equals('kept'));
    });

    test('end() is idempotent', () {
      final span = tracer.startSpan('test');
      span.end();
      span.end(); // Should not throw
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
    });

    test('end() leaves the status Unset', () {
      // trace/api.md: End takes only an optional timestamp and never
      // changes the status; only setStatus does.
      final span = tracer.startSpan('test');
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
      span.end();
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
    });

    test('end() preserves a status set before ending', () {
      final span = tracer.startSpan('test');
      span.setStatus(SpanStatusCode.Error, 'boom');
      span.end();
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Error));
      expect(getReadableSpan(span).statusDescription, equals('boom'));
    });

    test('end(spanStatus:) applies the setStatus rules, without an Ok default',
        () {
      // The deprecated spanStatus parameter still works but goes through
      // setStatus; passing Unset is ignored per the Set Status rules.
      final okSpan = tracer.startSpan('ok')..end(spanStatus: SpanStatusCode.Ok);
      expect(getReadableSpan(okSpan).status, equals(SpanStatusCode.Ok));

      final errorSpan = tracer.startSpan('error')
        ..end(spanStatus: SpanStatusCode.Error);
      expect(getReadableSpan(errorSpan).status, equals(SpanStatusCode.Error));

      final unsetSpan = tracer.startSpan('unset')
        ..end(spanStatus: SpanStatusCode.Unset);
      expect(getReadableSpan(unsetSpan).status, equals(SpanStatusCode.Unset));
    });

    test('addEvent twice', () {
      final span = tracer.startSpan('test');
      span.addEventNow('first');
      expect(getReadableSpan(span).spanEvents, isNotNull);
      expect(getReadableSpan(span).spanEvents!.length, equals(1));
      span.addEventNow(
        'second',
      );
      expect(getReadableSpan(span).spanEvents, isNotNull);
      expect(getReadableSpan(span).spanEvents!.length, equals(2));
    });

    test('addEvent ignored after end', () {
      final span = tracer.startSpan('test');
      span.addEventNow('nice and early');
      span.end();
      expect(getReadableSpan(span).spanEvents, isNotNull);
      expect(getReadableSpan(span).spanEvents!.length, equals(1));
      span.addEventNow(
        'too late',
      );
      expect(getReadableSpan(span).spanEvents, isNotNull);
      expect(getReadableSpan(span).spanEvents!.length, equals(1));
    });

    test('setStatus ignored after end', () {
      final span = tracer.startSpan('test');
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
      span.end();
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
      span.setStatus(SpanStatusCode.Error);
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
    });

    test('recordException is ignored after end', () {
      final span = tracer.startSpan('test');
      span.end();
      expect(getReadableSpan(span).spanEvents, isNull);
      span.recordException(Exception('test'));
      expect(getReadableSpan(span).spanEvents, isNull);
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

    test('span factory methods with valid context', () {
      final timestamp = DateTime.now();

      // Create a valid span context
      final validSpanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        traceFlags: OTelAPI.traceFlags(),
        isRemote: true,
      );

      final span = tracer.createSpan(
        name: 'test-span',
        context: Context.current
            .copyWithSpanContext(validSpanContext), // Valid span context
        kind: SpanKind.server,
        startTime: timestamp,
        attributes: Attributes.of({'key': 'value'}),
        links: [],
      );

      span.addEventNow('test-event');

      expect(span.name, equals('test-span'));
      expect(span.kind, equals(SpanKind.server));
      expect(
          getReadableSpan(span).attributes.getString('key'), equals('value'));
      expect(getReadableSpan(span).status, equals(SpanStatusCode.Unset));
      expect(getReadableSpan(span).spanEvents?.length, equals(1));
    });
  });
}
