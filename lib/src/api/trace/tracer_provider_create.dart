// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'tracer_provider.dart';

/// Internal constructor access for TracerProvider
class TracerProviderCreate {
  /// Creates a TracerProvider, only accessible within library
  static APITracerProvider create(
      {required String endpoint,
      String serviceName = OTelAPI.defaultServiceName,
      String? serviceVersion = OTelAPI.defaultServiceVersion}) {
    return APITracerProvider._(
        endpoint: endpoint,
        serviceName: serviceName,
        serviceVersion: serviceVersion,
        enabled: true,
        isShutdown: false);
  }
}
