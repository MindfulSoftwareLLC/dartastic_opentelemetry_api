// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('SpanContext - Additional Coverage Tests', () {
    late OTelFactory originalFactory;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      // Store the original factory
      originalFactory = OTelFactory.otelFactory!;
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
    });

    test('SpanContext toJson serialization', () {
      // Create a complete span context with all fields populated
      final traceId = OTelAPI.traceId();
      final spanId = OTelAPI.spanId();
      final parentSpanId = OTelAPI.spanId();
      final traceFlags = OTelAPI.traceFlags(1); // Sampled flag
      final traceState = OTelAPI.traceState({'key1': 'value1', 'key2': 'value2'});

      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        parentSpanId: parentSpanId,
        traceFlags: traceFlags,
        traceState: traceState,
        isRemote: true,
      );

      // Convert to JSON
      final json = spanContext.toJson();

      // Verify all fields are serialized correctly
      expect(json['traceId'], equals(traceId.toString()));
      expect(json['spanId'], equals(spanId.toString()));
      expect(json['parentSpanId'], equals(parentSpanId.toString()));
      expect(json['traceFlags'], equals(traceFlags.asByte));
      expect(json['isRemote'], isTrue);
      expect(json['traceState'], isA<Map<String, String>>());
      expect(json['traceState']['key1'], equals('value1'));
      expect(json['traceState']['key2'], equals('value2'));
    });

    test('SpanContext fromJson deserialization', () {
      // Create JSON representation of a span context
      final traceIdHex = '00000000000000000000000000000001';
      final spanIdHex = '0000000000000001';
      final parentSpanIdHex = '0000000000000002';

      final json = {
        'traceId': traceIdHex,
        'spanId': spanIdHex,
        'parentSpanId': parentSpanIdHex,
        'traceFlags': 1, // Sampled flag
        'traceState': {'key1': 'value1', 'key2': 'value2'},
        'isRemote': true,
      };

      // Deserialize
      final spanContext = SpanContext.fromJson(json);

      // Verify all fields are deserialized correctly
      expect(spanContext.traceId.toString(), equals(traceIdHex));
      expect(spanContext.spanId.toString(), equals(spanIdHex));
      expect(spanContext.parentSpanId?.toString(), equals(parentSpanIdHex));
      expect(spanContext.traceFlags.isSampled, isTrue);
      expect(spanContext.traceState?.get('key1'), equals('value1'));
      expect(spanContext.traceState?.get('key2'), equals('value2'));
      expect(spanContext.isRemote, isTrue);
    });

    test('SpanContext toJson without traceState', () {
      // Create a span context without traceState
      final traceId = OTelAPI.traceId();
      final spanId = OTelAPI.spanId();

      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
      );

      // Convert to JSON
      final json = spanContext.toJson();

      // Verify traceState is not included
      expect(json.containsKey('traceState'), isFalse);
    });

    test('SpanContext fromJson without parentSpanId', () {
      // Create JSON representation without parentSpanId
      final traceIdHex = '00000000000000000000000000000001';
      final spanIdHex = '0000000000000001';

      final json = {
        'traceId': traceIdHex,
        'spanId': spanIdHex,
        'traceFlags': 0,
        'isRemote': false,
      };

      // Deserialize
      final spanContext = SpanContext.fromJson(json);

      // Verify parentSpanId is invalid
      expect(spanContext.parentSpanId, isNotNull);
      expect(spanContext.parentSpanId!.isValid, isFalse);
    });

    test('SpanContext fromJson without traceState', () {
      // Create JSON representation without traceState
      final traceIdHex = '00000000000000000000000000000001';
      final spanIdHex = '0000000000000001';

      final json = {
        'traceId': traceIdHex,
        'spanId': spanIdHex,
        'traceFlags': 0,
        'isRemote': false,
      };

      // Deserialize
      final spanContext = SpanContext.fromJson(json);

      // Verify traceState
      expect(spanContext.traceState, isNotNull);
      expect(spanContext.traceState?.isEmpty, isTrue);
    });
  });
}
