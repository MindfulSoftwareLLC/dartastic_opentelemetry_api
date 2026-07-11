// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Companion to context_uninitialized_test.dart (issue #28).
//
// When Context lazily installs the no-op API factory before an SDK
// initializes, it must not hold on to that no-op after the SDK replaces the
// global factory. OTelAPI already re-reads OTelFactory.otelFactory on every
// access for exactly this reason ("a potentially better factory may have
// been installed"); Context must track the global the same way, or every
// factory product Context creates (context keys, contexts) keeps coming
// from the stale no-op — the same staleness class as
// dartastic_opentelemetry issue #50.
//
// This must run before any other test in the process installs a factory, so
// it lives in its own file — the `test` package runs each test file in its
// own isolate, giving a pristine (uninitialized) copy of all library statics.
void main() {
  test(
      'Context uses an SDK-installed factory after lazily installing the no-op',
      () {
    // Spec-permitted early API use: Context lazily installs (and caches) the
    // no-op API factory.
    expect(() => Context.current, returnsNormally);
    expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);

    // An SDK initializes: it replaces the replaceable no-op with its own
    // factory, the documented upgrade mechanism on OTelFactory.otelFactory.
    final sdkFactory = _RecordingFactory(
      apiEndpoint: 'http://localhost:4318',
      apiServiceName: 'sdk-service',
      apiServiceVersion: '1.0.0',
    );
    OTelFactory.otelFactory = sdkFactory;

    // OTelAPI re-reads the global and picks up the new factory.
    OTelAPI.contextKey<String>('via-otel-api');
    expect(sdkFactory.contextKeyCalls, 1,
        reason: 'OTelAPI must delegate to the newly installed factory');

    // Context must do the same: copyWithValue creates its key through the
    // factory, which must now be the SDK-installed one, not the cached no-op.
    Context.current.copyWithValue<String>('via-context', 'value');
    expect(sdkFactory.contextKeyCalls, 2,
        reason: 'Context must delegate to the newly installed factory, '
            'not a no-op factory cached before the SDK initialized');
  });
}

/// Stands in for an SDK factory: extends [OTelAPIFactory] (as all SDK
/// factories do), reports itself as a real implementation, and records
/// whether Context actually delegates to it.
class _RecordingFactory extends OTelAPIFactory {
  int contextKeyCalls = 0;

  _RecordingFactory({
    required super.apiEndpoint,
    required super.apiServiceName,
    required super.apiServiceVersion,
  });

  @override
  bool get isAPIFactory => false;

  @override
  ContextKey<T> contextKey<T>(String name, Uint8List id,
      {bool isTransferable = false}) {
    contextKeyCalls++;
    return super.contextKey<T>(name, id, isTransferable: isTransferable);
  }
}
