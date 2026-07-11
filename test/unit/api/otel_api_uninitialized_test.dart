// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Regression tests for
// https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/27
//
// Per the OpenTelemetry spec, the API MUST NOT require explicit
// initialization. Before this fix, instrumentationScope() recursed into
// itself when no factory was installed (immediate StackOverflowError), and
// tracer()/logger() dereferenced the null global factory instead of lazily
// installing the no-op.
//
// The first test must run before anything else in the process installs a
// factory, so this lives in its own file — the `test` package runs each test
// file in its own isolate, giving a pristine (uninitialized) copy of all
// library statics. Later tests restore that state with OTelAPI.reset().
void main() {
  test('instrumentationScope() does not recurse before initialize()', () {
    expect(OTelFactory.otelFactory, isNull);
    final scope = OTelAPI.instrumentationScope(name: 'pre-init-scope');
    expect(scope.name, equals('pre-init-scope'));
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
  });

  test('tracer() lazily installs the no-op factory before initialize()', () {
    OTelAPI.reset();
    expect(OTelFactory.otelFactory, isNull);
    final tracer = OTelAPI.tracer('pre-init-tracer');
    expect(tracer, isA<APITracer>());
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
  });

  test('logger() lazily installs the no-op factory before initialize()', () {
    OTelAPI.reset();
    expect(OTelFactory.otelFactory, isNull);
    final logger = OTelAPI.logger('pre-init-logger');
    expect(logger, isA<APILogger>());
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
  });
}
