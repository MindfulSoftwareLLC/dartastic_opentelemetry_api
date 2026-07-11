// Licensed under the Apache License, Version 2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Regression test for
// https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/33
//
// Deserialization is a classic pre-initialization call — a fresh isolate
// receiving serialized Baggage has pristine statics — yet Baggage.fromJson
// threw StateError('Call initialize() first.') instead of lazily installing
// the no-op API factory per the OTel spec.
//
// This must run before anything else in the process installs a factory, so
// it lives in its own file — the `test` package runs each test file in its
// own isolate, giving a pristine (uninitialized) copy of all library statics.
void main() {
  test('Baggage.fromJson works before initialize()', () {
    expect(OTelFactory.otelFactory, isNull);
    final baggage = Baggage.fromJson({
      'userId': {'value': 'user-1', 'metadata': 'meta'},
      'region': {'value': 'us-east-1'},
    });
    expect(baggage.getEntry('userId')?.value, equals('user-1'));
    expect(baggage.getEntry('userId')?.metadata, equals('meta'));
    expect(baggage.getEntry('region')?.value, equals('us-east-1'));
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
  });
}
