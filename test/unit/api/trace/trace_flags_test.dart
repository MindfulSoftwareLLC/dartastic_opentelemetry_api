// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

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

    test('should have correct random flag value', () {
      expect(TraceFlags.RANDOM_FLAG, equals(0x2));
    });

    test('isRandom should correctly report the random flag', () {
      expect(TraceFlags.none.isRandom, isFalse);
      expect(TraceFlags.sampled.isRandom, isFalse);
      expect(TraceFlags.fromString('02').isRandom, isTrue);
      expect(TraceFlags.fromString('03').isRandom, isTrue);
      expect(TraceFlags.fromString('ff').isRandom, isTrue);
      // 0x0d is 1101, so the random bit is clear even though others are set.
      expect(TraceFlags.fromString('0d').isRandom, isFalse);
    });

    test('withRandom should create new TraceFlags with correct random flag',
        () {
      // Test turning the random flag on
      final randomOn = TraceFlags.none.withRandom(true);
      expect(randomOn.isRandom, isTrue);
      expect(randomOn.asByte, equals(0x2));

      // Test turning the random flag off
      final randomOff = TraceFlags.fromString('02').withRandom(false);
      expect(randomOff.isRandom, isFalse);
      expect(randomOff.asByte, equals(0x0));

      // Test setting the random flag to its current value
      expect(TraceFlags.none.withRandom(false).isRandom, isFalse);
      expect(TraceFlags.fromString('02').withRandom(true).isRandom, isTrue);

      // Test with other flags set
      final withOtherFlags = TraceFlags.fromString('0d');
      final withOtherFlagsAndRandom = withOtherFlags.withRandom(true);
      expect(withOtherFlagsAndRandom.asByte, equals(0x0f));
      expect(withOtherFlagsAndRandom.isRandom, isTrue);

      final backToJustOtherFlags = withOtherFlagsAndRandom.withRandom(false);
      expect(backToJustOtherFlags.asByte, equals(0x0d));
      expect(backToJustOtherFlags.isRandom, isFalse);
    });

    test('sampled and random flags should be independent', () {
      // All four combinations of the two defined bits.
      final neither = TraceFlags.fromString('00');
      expect(neither.isSampled, isFalse);
      expect(neither.isRandom, isFalse);

      final sampledOnly = TraceFlags.fromString('01');
      expect(sampledOnly.isSampled, isTrue);
      expect(sampledOnly.isRandom, isFalse);

      final randomOnly = TraceFlags.fromString('02');
      expect(randomOnly.isSampled, isFalse);
      expect(randomOnly.isRandom, isTrue);

      final both = TraceFlags.fromString('03');
      expect(both.isSampled, isTrue);
      expect(both.isRandom, isTrue);

      // Setting one bit must not disturb the other.
      expect(sampledOnly.withRandom(true).asByte, equals(0x03));
      expect(randomOnly.withSampled(true).asByte, equals(0x03));
      expect(both.withSampled(false).asByte, equals(0x02));
      expect(both.withRandom(false).asByte, equals(0x01));

      // Order of application must not matter.
      expect(
        TraceFlags.none.withSampled(true).withRandom(true).asByte,
        equals(TraceFlags.none.withRandom(true).withSampled(true).asByte),
      );
    });

    test('random flag should survive a string round trip', () {
      expect(TraceFlags.fromString('02').toString(), equals('02'));
      expect(TraceFlags.fromString('03').toString(), equals('03'));
      expect(
        TraceFlags.fromString(TraceFlags.none.withRandom(true).toString())
            .isRandom,
        isTrue,
      );
    });

    test('whole-value comparison is not a substitute for bit accessors', () {
      // Guards the bit set contract: 03 is sampled, but it is not equal to
      // the sampled-only constant.
      final both = TraceFlags.fromString('03');
      expect(both.isSampled, isTrue);
      expect(both == TraceFlags.sampled, isFalse);
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
