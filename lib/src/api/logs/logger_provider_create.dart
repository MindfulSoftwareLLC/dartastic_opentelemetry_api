part of 'logger_provider.dart';

class LogProviderCreate {
  /// Creates a new [APIMeterProvider] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [OTelAPI.meterProvider()] or [OTel.meterProvider()] instead.
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
