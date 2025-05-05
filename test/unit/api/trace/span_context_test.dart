// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('SpanContext', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    final traceIdBytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
    final spanIdBytes = [1, 2, 3, 4, 5, 6, 7, 8];
    late TraceId traceId;
    late SpanId spanId;

    setUp(() {
      traceId = OTelAPI.traceIdFromBytes(traceIdBytes);
      spanId = OTelAPI.spanIdFromBytes(spanIdBytes);
    });

    test('create basic span context', () {
      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.none,
        traceState: TraceState.empty(),
        isRemote: false,
      );

      expect(spanContext.traceId, equals(traceId));
      expect(spanContext.spanId, equals(spanId));
      expect(spanContext.traceFlags, equals(TraceFlags.none));
      expect(spanContext.traceState, equals(TraceState.empty()));
      expect(spanContext.isRemote, isFalse);
      expect(spanContext.isValid, isTrue);
    });

    test('create remote span context', () {
      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );

      expect(spanContext.isRemote, isTrue);
      // Use accessor method instead of isSampled property
      expect(spanContext.traceFlags == TraceFlags.sampled, isTrue);
    });

    test('invalid span context with invalid trace ID', () {
      final invalidTraceId = OTelAPI.invalidTraceId();
      final spanContext = OTelAPI.spanContext(
        traceId: invalidTraceId,
        spanId: spanId,
        traceFlags: TraceFlags.none,
        traceState: TraceState.empty(),
        isRemote: false,
      );

      expect(spanContext.isValid, isFalse);
    });

    test('invalid span context with invalid span ID', () {
      // Use factory method instead of invalid getter
      final invalidSpanId = OTelAPI.spanIdInvalid();
      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: invalidSpanId,
        traceFlags: TraceFlags.none,
        traceState: TraceState.empty(),
        isRemote: false,
      );

      expect(spanContext.isValid, isFalse);
    });

    test('create from hex strings', () {
      final traceIdHex = '0102030405060708090a0b0c0d0e0f10';
      final spanIdHex = '0102030405060708';

      // Use factory method instead of fromString
      final spanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceIdFrom(traceIdHex),
        spanId: OTelAPI.spanIdFrom(spanIdHex),
        traceFlags: TraceFlags.fromString('01'), // sampled flag
        traceState: TraceState.fromString('vendor1=value1,vendor2=value2'),
        isRemote: true,
      );

      expect(spanContext.traceId.toString(), equals(traceIdHex));
      expect(spanContext.spanId.toString(), equals(spanIdHex));
      // Use accessor instead of isSampled
      expect(spanContext.traceFlags == TraceFlags.sampled, isTrue);
      expect(spanContext.traceState!.get('vendor1'), equals('value1'));
      expect(spanContext.traceState!.get('vendor2'), equals('value2'));
      expect(spanContext.isRemote, isTrue);
      expect(spanContext.isValid, isTrue);
    });

    test('create from invalid hex strings', () {
      // Invalid trace ID (all zeros)
      final invalidTraceIdHex = '00000000000000000000000000000000';
      final spanIdHex = '0102030405060708';

      // Use factory method instead of fromString
      final spanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceIdFrom(invalidTraceIdHex),
        spanId: OTelAPI.spanIdFrom(spanIdHex),
        traceFlags: TraceFlags.fromString('00'),
        traceState: TraceState.fromString(''),
        isRemote: false,
      );

      expect(spanContext.isValid, isFalse);
    });

    test('create invalidSpanContext', () {
      // Create a valid spanContext just for testing the invalidSpanContext implementation
      final invalidContext = OTelAPI.spanContextInvalid();

      expect(invalidContext.isValid, isFalse);
    });

    test('trace flags indicates sampling state', () {
      final sampledContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: false,
      );

      final notSampledContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.none,
        traceState: TraceState.empty(),
        isRemote: false,
      );

      // Use accessor instead of isSampled
      expect(sampledContext.traceFlags == TraceFlags.sampled, isTrue);
      expect(notSampledContext.traceFlags == TraceFlags.none, isTrue);
    });

    test('toString includes all components', () {
      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.fromMap({'vendor': 'value'}),
        isRemote: true,
      );

      final str = spanContext.toString();
      expect(str.contains(traceId.toString()), isTrue);
      expect(str.contains(spanId.toString()), isTrue);
      expect(str.contains(TraceFlags.sampled.toString()), isTrue);
      expect(str.contains('isRemote: true'), isTrue);
    });

    test('equals compares span contexts correctly', () {
      final context1 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );

      final context2 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );

      final context3 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.none, // Different flags
        traceState: TraceState.empty(),
        isRemote: true,
      );

      expect(context1 == context2, isTrue);
      expect(context1 == context3, isFalse);
      expect(context1 == OTelAPI.spanContextInvalid(), isFalse);
    });

    test('hashCode is consistent', () {
      final context1 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );

      final context2 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );

      expect(context1.hashCode, equals(context2.hashCode));
      expect(context1.hashCode == OTelAPI.spanContext(traceId: OTelAPI.traceIdInvalid()).hashCode, isFalse);
    });
  });
}
