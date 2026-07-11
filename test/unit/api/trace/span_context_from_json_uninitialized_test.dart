// Licensed under the Apache License, Version 2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Regression test for
// https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/33
//
// Deserialization is a classic pre-initialization call — a fresh isolate
// receiving a serialized SpanContext has pristine statics — yet
// SpanContext.fromJson threw StateError('Call initialize() first.') instead
// of lazily installing the no-op API factory per the OTel spec.
//
// This must run before anything else in the process installs a factory, so
// it lives in its own file — the `test` package runs each test file in its
// own isolate, giving a pristine (uninitialized) copy of all library statics.
void main() {
  test('SpanContext.fromJson works before initialize()', () {
    expect(OTelFactory.otelFactory, isNull);
    final spanContext = SpanContext.fromJson({
      'traceId': '0123456789abcdef0123456789abcdef',
      'spanId': '0123456789abcdef',
      'traceFlags': 1,
      'isRemote': true,
    });
    expect(spanContext.traceId.toString(),
        equals('0123456789abcdef0123456789abcdef'));
    expect(spanContext.spanId.toString(), equals('0123456789abcdef'));
    expect(spanContext.isRemote, isTrue);
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
  });
}
