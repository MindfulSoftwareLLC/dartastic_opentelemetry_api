// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Regression tests for
// https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/33
//
// OTelAPI.attributesFromMap bypassed the factory unconditionally via the
// static OTelAPIFactory.attrsFromMap "cheat" — a workaround from when
// factory access threw before initialize(). Since 1.0.0-beta.8 the factory
// lazily installs and is upgraded in place, so the cheat is obsolete, and
// it silently ignored any installed factory that overrides
// attributesFromMap.
//
// The pre-init test must run before anything else in the process installs a
// factory, so this lives in its own file — the `test` package runs each test
// file in its own isolate, giving a pristine (uninitialized) copy of all
// library statics.
void main() {
  test('attributesFromMap works before initialize()', () {
    expect(OTelFactory.otelFactory, isNull);
    final attributes = OTelAPI.attributesFromMap({'key': 'value', 'num': 42});
    expect(attributes.getString('key'), equals('value'));
    expect(attributes.getInt('num'), equals(42));
  });

  test('attributesFromMap delegates to the installed factory', () {
    final factory = _CountingFactory(
      apiEndpoint: 'http://localhost:4318',
      apiServiceName: 'svc',
      apiServiceVersion: '1.0.0',
    );
    OTelFactory.otelFactory = factory;

    OTelAPI.attributesFromMap({'key': 'value'});
    expect(factory.attributesFromMapCalls, equals(1),
        reason: 'attributesFromMap must delegate to the installed factory, '
            'not bypass it via the static attrsFromMap cheat');
  });
}

/// Records whether OTelAPI actually delegates attribute creation to the
/// installed factory, as an SDK factory overriding attributesFromMap would
/// expect.
class _CountingFactory extends OTelAPIFactory {
  int attributesFromMapCalls = 0;

  _CountingFactory({
    required super.apiEndpoint,
    required super.apiServiceName,
    required super.apiServiceVersion,
  });

  @override
  Attributes attributesFromMap(Map<String, Object> namedMap) {
    attributesFromMapCalls++;
    return super.attributesFromMap(namedMap);
  }
}
