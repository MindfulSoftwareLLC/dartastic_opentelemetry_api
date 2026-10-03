// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'logger_provider.dart';

@internal
class LogProviderCreate {
  /// Creates a new [APILoggerProvider] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [OTelAPI.loggerProvider()] or [OTel.loggerProvider()] instead.
  static APILoggerProvider create({
    required String endpoint,
    required String serviceName,
    String? serviceVersion,
    bool enabled = true,
    bool isShutdown = false,
  }) {
    return APILoggerProvider._(
      endpoint: endpoint,
      serviceName: serviceName,
      serviceVersion: serviceVersion,
      enabled: enabled,
      isShutdown: isShutdown,
    );
  }
}
