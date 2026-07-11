// Licensed under the Apache License, Version 2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Regression tests for
// https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/33
//
// tracerProviders()/meterProviders()/loggerProviders() read OTelAPI's
// private factory cache instead of the global OTelFactory.otelFactory. When
// a factory is installed without going through an OTelAPI accessor — an SDK
// installing itself is the normal case — the cache is still null and the
// lists come back empty even though the global factory has providers. The
// lists must reflect the global; the same staleness class was fixed for
// Context in 1.0.0-beta.8.
//
// Pre-init the lists must stay [] WITHOUT installing a factory: a list
// query is a read, not a use of the API, so it should not force-install.
//
// This must run before anything else in the process installs a factory, so
// it lives in its own file — the `test` package runs each test file in its
// own isolate, giving a pristine (uninitialized) copy of all library statics.
void main() {
  test('provider lists are empty pre-init and do not install a factory', () {
    expect(OTelAPI.tracerProviders(), isEmpty);
    expect(OTelAPI.meterProviders(), isEmpty);
    expect(OTelAPI.loggerProviders(), isEmpty);
    expect(OTelFactory.otelFactory, isNull);
  });

  test('provider lists reflect a factory installed without OTelAPI accessors',
      () {
    // Simulate an SDK: install the global factory directly, never touching
    // an OTelAPI accessor that would populate OTelAPI's private cache.
    final factory = OTelAPIFactory(
      apiEndpoint: 'http://localhost:4318',
      apiServiceName: 'sdk-service',
      apiServiceVersion: '1.0.0',
    );
    OTelFactory.otelFactory = factory;
    final tracerProvider = factory.globalDefaultTracerProvider();
    final meterProvider = factory.globalDefaultMeterProvider();
    final loggerProvider = factory.globalDefaultLogProvider();

    expect(OTelAPI.tracerProviders(), contains(tracerProvider));
    expect(OTelAPI.meterProviders(), contains(meterProvider));
    expect(OTelAPI.loggerProviders(), contains(loggerProvider));
  });
}
