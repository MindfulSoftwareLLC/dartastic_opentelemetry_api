// Licensed under the Apache License, Version 2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Regression test for https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/28
//
// Per the OpenTelemetry spec, the API MUST NOT require explicit
// initialization: calls made before an SDK/API is installed must operate as
// no-ops rather than throwing. This must run before any other test in the
// process calls OTelAPI.initialize(), so it lives in its own file — the
// `test` package runs each test file in its own isolate, giving a pristine
// (uninitialized) copy of all library statics.
void main() {
  test('Context.current does not throw before OTelAPI.initialize() is called',
      () {
    expect(() => Context.current, returnsNormally);
    expect(Context.current.span, isNull);
    expect(Context.current.baggage, isNull);
  });

  test('Context.root does not throw before OTelAPI.initialize() is called', () {
    expect(() => Context.root, returnsNormally);
  });

  test('Context.current.withBaggage does not throw before initialization', () {
    final baggage = OTelAPI.baggageForMap({'key': 'value'});
    expect(() => Context.current.withBaggage(baggage), returnsNormally);
  });
}
