// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// The native isolate-support shim re-exports dart:isolate; its
// runIsolateComputation body is a guard that must never be called
// directly. This locks down that contract.

@TestOn('vm')
library;

import 'package:dartastic_opentelemetry_api/src/api/context/isolate_support.dart';
import 'package:test/test.dart';

void main() {
  test('runIsolateComputation must not be called directly', () {
    expect(
      runIsolateComputation<int>(() async => 1, {}, {}, () {}),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
