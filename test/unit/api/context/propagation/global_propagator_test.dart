// Licensed under the Apache License, Version 2.0

import 'package:test/test.dart';

// Spec-compliance test for context/api-propagators.md, "Global Propagators":
//
// - "The OpenTelemetry API MUST provide a way to obtain a propagator for
//   each supported Propagator type" — with Get/Set global methods.
// - "The OpenTelemetry API MUST use no-op propagators unless explicitly
//   configured otherwise."
void main() {
  test('the API provides a global TextMapPropagator with a no-op default',
      () {
    fail('No global propagator accessor or no-op TextMapPropagator exists '
        'in the API; instrumentation libraries cannot obtain "the" '
        'propagator as the spec requires.');
  });
}
