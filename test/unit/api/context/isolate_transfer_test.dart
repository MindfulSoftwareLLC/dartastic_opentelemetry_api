// Licensed under the Apache License, Version 2.0

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

      final context =
          Context.root.withBaggage(baggage).withSpanContext(spanContext);

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

    test('SpanContext is marked isRemote=true after crossing isolate boundary',
        () async {
      // A SpanContext created in the parent isolate is by definition local
      // (isRemote=false). When it crosses an isolate boundary via runIsolate,
      // the receiving isolate should treat it as remote — otherwise
      // tracer.startSpan in the new isolate falls into its "no parent"
      // branch and creates a fresh root span instead of a child of the
      // parent's span. This is the same semantic as W3C trace context
      // extracted from HTTP headers.
      final localSpanContext = OTelAPI.spanContext(
        traceId: OTelAPI.traceId(),
        spanId: OTelAPI.spanId(),
        // Explicitly local in the parent isolate.
      );
      expect(localSpanContext.isRemote, isFalse,
          reason: 'sanity: local SpanContext should not be remote');

      final context = Context.root.withSpanContext(localSpanContext);

      final result = await context.runIsolate(() async {
        final received = Context.current.spanContext;
        return {
          'traceId': received?.traceId.toString(),
          'spanId': received?.spanId.toString(),
          'isRemote': received?.isRemote,
        };
      });

      expect(result['traceId'], equals(localSpanContext.traceId.toString()));
      expect(result['spanId'], equals(localSpanContext.spanId.toString()));
      expect(result['isRemote'], isTrue,
          reason:
              'SpanContext crossing an isolate boundary must be marked isRemote=true so tracer.startSpan in the receiving isolate parents to it.');
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
