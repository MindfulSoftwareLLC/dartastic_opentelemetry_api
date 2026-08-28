// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'meter_provider.dart';

/// Factory methods for creating [APIMeterProvider] instances.
@internal
class MeterProviderCreate {
  /// Creates a new [APIMeterProvider] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [OTelAPI.meterProvider()] or [OTel.meterProvider()] instead.
  static APIMeterProvider create() => APIMeterProvider._();
}
