// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Companion to context_uninitialized_test.dart (issue #28).
//
// Per the OpenTelemetry spec, API use before initialization must work as a
// no-op — but lazily installing the no-op factory must not then block a
// later explicit initialization. The lazily-installed factory reports
// `isAPIFactory == true` precisely so initialization can recognize it as
// replaceable and upgrade it, rather than throwing "can only be initialized
// once" at an app that merely touched Context.current too early.
//
// This must run before any other test in the process installs a factory, so
// it lives in its own file — the `test` package runs each test file in its
// own isolate, giving a pristine (uninitialized) copy of all library statics.
void main() {
  test('OTelAPI.initialize() succeeds after pre-init Context access', () {
    // Spec-permitted early API use: lazily installs the no-op API factory.
    expect(() => Context.current, returnsNormally);
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);

    // The auto-installed no-op is replaceable by definition; explicit
    // initialization must upgrade it, not throw.
    expect(
      () => OTelAPI.initialize(
        endpoint: 'http://localhost:4318',
        serviceName: 'late-init-service',
        serviceVersion: '1.0.0',
      ),
      returnsNormally,
    );
  });
}
