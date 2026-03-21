// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Context Isolate Transfer', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('transfers baggage and span context to isolate', () async {
      final baggage = OTelAPI.baggage({
        'user': OTelAPI.baggageEntry('yoda', null),
      });

      final spanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
      );

      final context = Context.root
          .withBaggage(baggage)
          .withSpanContext(spanContext);

      final result = await context.runIsolate(() async {
        final currentBaggage = Context.current.baggage;
        final currentSpanContext = Context.current.spanContext;

        return {
          'baggageValue': currentBaggage?.getEntry('user')?.value,
          'traceId': currentSpanContext?.traceId.toString(),
          'spanId': currentSpanContext?.spanId.toString(),
        };
      });

      expect(result['baggageValue'], equals('yoda'));
      expect(result['traceId'], equals(spanContext.traceId.toString()));
      expect(result['spanId'], equals(spanContext.spanId.toString()));
    });

    test('transfers custom keys only if marked as transferable', () async {
      final transferableKey =
          OTelAPI.contextKey<String>('transferable', isTransferable: true);
      final nonTransferableKey =
          OTelAPI.contextKey<String>('non-transferable', isTransferable: false);

      final context = Context.root
          .copyWith(transferableKey, 'transferred')
          .copyWith(nonTransferableKey, 'stayed');

      final result = await context.runIsolate(() async {
        return {
          'transferable': Context.current.get(transferableKey),
          'non-transferable': Context.current.get(nonTransferableKey),
        };
      });

      expect(result['transferable'], equals('transferred'));
      expect(result['non-transferable'], isNull);
    });
  });
}
