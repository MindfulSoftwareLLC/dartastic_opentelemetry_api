// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// On native targets the conditional facade exports this stub, whose
// whole contract is to throw: WebTimeProvider requires a web target.

@TestOn('vm')
library;

import 'package:dartastic_opentelemetry_api/src/util/web_time_provider_stub.dart';
import 'package:test/test.dart';

void main() {
  test('WebTimeProvider cannot be constructed on native targets', () {
    expect(WebTimeProvider.new, throwsUnsupportedError);
  });
}
