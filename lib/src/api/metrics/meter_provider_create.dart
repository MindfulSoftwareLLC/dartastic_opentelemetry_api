// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'meter_provider.dart';

/// Factory methods for creating [APIMeterProvider] instances.
class MeterProviderCreate {
  /// Creates a new [APIMeterProvider] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [OTelAPI.meterProvider()] or [OTel.meterProvider()] instead.
  static APIMeterProvider create({
    required String endpoint,
    required String serviceName,
    String? serviceVersion,
    bool enabled = true,
    bool isShutdown = false,
  }) {
    return APIMeterProvider._(
      endpoint: endpoint,
      serviceName: serviceName,
      serviceVersion: serviceVersion,
      enabled: enabled,
      isShutdown: isShutdown,
    );
  }
}
