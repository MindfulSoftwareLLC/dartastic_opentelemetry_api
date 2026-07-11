// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Regression tests for
// https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/33
//
// Per the OpenTelemetry spec, the API MUST NOT require explicit
// initialization. TraceState.fromString parses the W3C `tracestate` header —
// exactly what a propagator/extractor does, plausibly before initialize() —
// yet all three TraceState factory constructors threw
// StateError('Call initialize() first.') instead of lazily installing the
// no-op API factory.
//
// The first test must run before anything else in the process installs a
// factory, so this lives in its own file — the `test` package runs each test
// file in its own isolate, giving a pristine (uninitialized) copy of all
// library statics. Later tests restore that state with OTelAPI.reset().
void main() {
  test('TraceState.fromString works before initialize()', () {
    expect(OTelFactory.otelFactory, isNull);
    final traceState = TraceState.fromString('vendor1=value1,vendor2=value2');
    expect(traceState.get('vendor1'), equals('value1'));
    expect(traceState.get('vendor2'), equals('value2'));
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
  });

  test('TraceState.fromMap works before initialize()', () {
    OTelAPI.reset();
    expect(OTelFactory.otelFactory, isNull);
    final traceState = TraceState.fromMap({'vendor': 'value'});
    expect(traceState.get('vendor'), equals('value'));
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
  });

  test('TraceState.empty works before initialize()', () {
    OTelAPI.reset();
    expect(OTelFactory.otelFactory, isNull);
    final traceState = TraceState.empty();
    expect(traceState.isEmpty, isTrue);
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
  });
}
