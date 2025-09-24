// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('TraceFlags', () {
    test('should have correct predefined values', () {
      expect(TraceFlags.none.asByte, equals(0x0));
      expect(TraceFlags.sampled.asByte, equals(0x1));
    });

    test('should create TraceFlags from hex string', () {
      expect(TraceFlags.fromString('00'), equals(TraceFlags.none));
      expect(TraceFlags.fromString('01'), equals(TraceFlags.sampled));
      expect(TraceFlags.fromString('ff').asByte, equals(0xff));
      expect(TraceFlags.fromString('0f').asByte, equals(0x0f));
    });

    test('should handle invalid hex string', () {
      expect(TraceFlags.fromString(''), equals(TraceFlags.none));
      expect(TraceFlags.fromString('zz'), equals(TraceFlags.none));
      expect(TraceFlags.fromString('randomtext'), equals(TraceFlags.none));
    });

    test('asByte should return the correct value', () {
      expect(TraceFlags.none.asByte, equals(0x0));
      expect(TraceFlags.sampled.asByte, equals(0x1));
      expect(TraceFlags.fromString('0f').asByte, equals(0x0f));
    });

    test('isSampled should correctly report sampling state', () {
      expect(TraceFlags.none.isSampled, isFalse);
      expect(TraceFlags.sampled.isSampled, isTrue);
      expect(TraceFlags.fromString('01').isSampled, isTrue);
      expect(TraceFlags.fromString('00').isSampled, isFalse);
      expect(TraceFlags.fromString('0f').isSampled,
          isTrue); // 0x0f has the sampled bit set
      expect(TraceFlags.fromString('0e').isSampled,
          isFalse); // 0x0e doesn't have the sampled bit set
    });

    test('withSampled should create new TraceFlags with correct sampling', () {
      // Test turning sampling on
      final sampledOn = TraceFlags.none.withSampled(true);
      expect(sampledOn.isSampled, isTrue);
      expect(sampledOn.asByte, equals(0x1));

      // Test turning sampling off
      final sampledOff = TraceFlags.sampled.withSampled(false);
      expect(sampledOff.isSampled, isFalse);
      expect(sampledOff.asByte, equals(0x0));

      // Test setting sampling to current value
      final sameValue1 = TraceFlags.none.withSampled(false);
      expect(sameValue1.isSampled, isFalse);

      final sameValue2 = TraceFlags.sampled.withSampled(true);
      expect(sameValue2.isSampled, isTrue);

      // Test with other flags set
      final withOtherFlags = TraceFlags.fromString('0e');
      expect(withOtherFlags.asByte, equals(0x0e));

      final withOtherFlagsAndSampled = withOtherFlags.withSampled(true);
      expect(withOtherFlagsAndSampled.asByte, equals(0x0f));
      expect(withOtherFlagsAndSampled.isSampled, isTrue);

      final backToJustOtherFlags = withOtherFlagsAndSampled.withSampled(false);
      expect(backToJustOtherFlags.asByte, equals(0x0e));
      expect(backToJustOtherFlags.isSampled, isFalse);
    });

    test('toString should convert to hex string', () {
      expect(TraceFlags.none.toString(), equals('00'));
      expect(TraceFlags.sampled.toString(), equals('01'));
      expect(TraceFlags.fromString('0f').toString(), equals('0f'));
      expect(TraceFlags.fromString('ff').toString(), equals('ff'));
      expect(TraceFlags.fromString('42').toString(), equals('42'));
    });

    test('equals should compare TraceFlags correctly', () {
      expect(TraceFlags.none == TraceFlags.none, isTrue);
      expect(TraceFlags.sampled == TraceFlags.sampled, isTrue);
      expect(TraceFlags.none == TraceFlags.sampled, isFalse);

      final customFlags1 = TraceFlags.fromString('0f');
      final customFlags2 = TraceFlags.fromString('0f');
      final customFlags3 = TraceFlags.fromString('0e');

      expect(customFlags1 == customFlags2, isTrue);
      expect(customFlags1 == customFlags3, isFalse);
      expect(customFlags1 == TraceFlags.sampled, isFalse);
    });

    test('hashCode should be consistent', () {
      expect(TraceFlags.none.hashCode, equals(TraceFlags.none.hashCode));
      expect(TraceFlags.sampled.hashCode, equals(TraceFlags.sampled.hashCode));
      expect(TraceFlags.fromString('0f').hashCode,
          equals(TraceFlags.fromString('0f').hashCode));

      // Different flags should have different hash codes
      expect(TraceFlags.none.hashCode == TraceFlags.sampled.hashCode, isFalse);
    });
  });
}
