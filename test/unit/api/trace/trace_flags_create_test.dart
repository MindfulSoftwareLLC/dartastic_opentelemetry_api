// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('TraceFlagsCreate', () {
    test('keeps an in-range value unchanged', () {
      expect(OTelAPI.traceFlags(0x00).asByte, equals(0x00));
      expect(OTelAPI.traceFlags(0x01).asByte, equals(0x01));
      expect(OTelAPI.traceFlags(0x0f).asByte, equals(0x0f));
      expect(OTelAPI.traceFlags(0xff).asByte, equals(0xff));
    });

    test('defaults to no flags when none are given', () {
      expect(OTelAPI.traceFlags(), equals(TraceFlags.none));
    });

    test('keeps only the low byte of an out-of-range value', () {
      expect(OTelAPI.traceFlags(0x100).asByte, equals(0x00));
      expect(OTelAPI.traceFlags(0x1ff).asByte, equals(0xff));
      expect(OTelAPI.traceFlags(300).asByte, equals(0x2c));
      expect(OTelAPI.traceFlags(-1).asByte, equals(0xff));
    });

    test('produces flags that render as exactly two hex digits', () {
      for (final flags in [0x00, 0xff, 0x100, 0x1ff, 300, -1]) {
        expect(OTelAPI.traceFlags(flags).toString(), hasLength(2),
            reason: 'flags $flags');
      }
    });
  });
}
