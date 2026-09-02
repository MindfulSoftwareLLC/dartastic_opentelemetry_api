// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIMeterProvider', () {
    late APIMeterProvider meterProvider;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      meterProvider = OTelAPI.meterProvider();
    });

    test('creates API meters without caching', () {
      final meter1 = meterProvider.getMeter(name: 'test-meter-1');
      final meter2 =
          meterProvider.getMeter(name: 'test-meter-2', version: '1.0.0');

      expect(meter1, isNotNull);
      expect(meter1.name, equals('test-meter-1'));
      expect(identical(meter1, meter2), isFalse); // Not shared
    });

    test('shutdown and forceFlush return true', () async {
      final shutdownResult = await meterProvider.shutdown();
      final flushResult = await meterProvider.forceFlush();

      expect(shutdownResult, isTrue);
      expect(flushResult, isTrue);
    });
  });
}
