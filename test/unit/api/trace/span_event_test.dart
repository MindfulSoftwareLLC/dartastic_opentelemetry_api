// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('SpanEvent', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('creates SpanEvent with name and timestamp', () {
      final timestamp = DateTime.now();
      final event = OTelAPI.spanEvent('test-event', null, timestamp);

      expect(event.name, equals('test-event'));
      expect(event.timestamp, equals(timestamp));
      expect(event.attributes, isNull);
    });

    test('creates SpanEvent with attributes', () {
      final timestamp = DateTime.now();
      final attrs = OTelAPI.attributesFromMap({'key': 'value'});
      final event = OTelAPI.spanEvent('test-event', attrs, timestamp);

      expect(event.name, equals('test-event'));
      expect(event.attributes, isNotNull);
      expect(event.attributes!.getString('key'), equals('value'));
    });

    test('toString returns expected format', () {
      final timestamp = DateTime.utc(2024, 1, 15, 10, 30, 0);
      final event = OTelAPI.spanEvent('test-event', null, timestamp);

      final str = event.toString();

      expect(str, contains('SpanEvent'));
      expect(str, contains('name: test-event'));
      expect(str, contains('timestamp:'));
    });

    test('toString includes attributes when present', () {
      final timestamp = DateTime.now();
      final attrs = OTelAPI.attributesFromMap({'key': 'value'});
      final event = OTelAPI.spanEvent('test-event', attrs, timestamp);

      final str = event.toString();

      expect(str, contains('attributes:'));
    });

    test('toString shows null attributes when not present', () {
      final timestamp = DateTime.now();
      final event = OTelAPI.spanEvent('test-event', null, timestamp);

      final str = event.toString();

      expect(str, contains('attributes: null'));
    });

    test('spanEventNow creates event with current timestamp', () {
      final before = DateTime.now();
      final attrs = OTelAPI.attributesFromMap({'key': 'value'});
      final event = OTelAPI.spanEventNow('test-event', attrs);
      final after = DateTime.now();

      expect(event.name, equals('test-event'));
      expect(
          event.timestamp.isAfter(before) || event.timestamp == before, isTrue);
      expect(
          event.timestamp.isBefore(after) || event.timestamp == after, isTrue);
      expect(event.attributes, isNotNull);
    });
  });
}
