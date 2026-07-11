// Licensed under the Apache License, Version 2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Spec-compliance tests for provider accessors:
//
// - trace/api.md, Get a Tracer: "In case an invalid name (null or empty
//   string) is specified, a working Tracer implementation MUST be returned
//   as a fallback rather than returning null or throwing an exception."
//   The same fallback principle applies to the provider accessors and to
//   getMeter/getLogger.
// - error-handling.md: "API methods MUST NOT throw unhandled exceptions
//   when used incorrectly by end users. The API and SDK SHOULD provide
//   safe defaults for missing or invalid arguments."
void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4318',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('empty provider names fall back to the global default', () {
    test('tracerProvider("") returns the global default', () {
      expect(OTelAPI.tracerProvider(''), same(OTelAPI.tracerProvider()));
    });

    test('meterProvider("") returns the global default', () {
      expect(OTelAPI.meterProvider(''), same(OTelAPI.meterProvider()));
    });

    test('loggerProvider("") returns the global default', () {
      expect(OTelAPI.loggerProvider(''), same(OTelAPI.loggerProvider()));
    });
  });

  group('provider getters work after shutdown', () {
    test('getTracer returns a working tracer after shutdown', () async {
      final provider = OTelAPI.tracerProvider();
      await provider.shutdown();
      final tracer = provider.getTracer('post-shutdown');
      expect(tracer, isA<APITracer>());
    });

    test('getMeter returns a working meter after shutdown', () async {
      final provider = OTelAPI.meterProvider();
      await provider.shutdown();
      final meter = provider.getMeter(name: 'post-shutdown');
      expect(meter, isA<APIMeter>());
    });

    test('getLogger returns a working logger after shutdown', () async {
      final provider = OTelAPI.loggerProvider();
      await provider.shutdown();
      final logger = provider.getLogger('post-shutdown');
      expect(logger, isA<APILogger>());
    });
  });
}
