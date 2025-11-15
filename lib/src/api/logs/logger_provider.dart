import '../../util/otel_log.dart';
import '../common/attributes.dart';
import '../common/signal_instance_key.dart';
import '../otel_api.dart';
import 'logger.dart';

part 'logger_provider_create.dart';

/// APILoggerProvider is the entry point of the OpenTelemetry logger API.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the LoggerProvider from the SDK instead.
/// It provides access to [APILogger]s which are used to log operations.
/// You cannot create a LoggerProvider directly;
/// you must use [OTelAPI] or more likely [OTel], for example to get the default logger:
/// ```dart
/// final loggerProvider = OTel.loggerProvider();
/// final logger = loggerProvider.getLogger('');
/// ```
/// See [OTel] for creating tracers in addition to the default.
/// Use [OTelAPI] to run in no-op mode, as required by the specification.
class APILoggerProvider {
  String _endpoint;

  /// The name of the service being instrumented.
  String _serviceName;

  /// The version of the service being instrumented.
  String? _serviceVersion;

  /// Whether this meter provider is enabled.
  /// API implementation defaults to false, while SDK defaults to true.
  bool _enabled = false; // API, SDK defaults true

  /// Whether this meter provider has been shut down.
  bool _isShutdown;

  final Map<SignalInstanceKey, APILogger> _loggerCache = {};

  APILoggerProvider._({
    required String endpoint,
    String serviceName = OTelAPI.defaultServiceName,
    String? serviceVersion = OTelAPI.defaultServiceVersion,
    bool enabled = true,
    bool isShutdown = false,
  })  : _endpoint = endpoint,
        _serviceName = serviceName,
        _serviceVersion = serviceVersion,
        _enabled = enabled,
        _isShutdown = isShutdown;

  /// Gets the endpoint URL used by this logger provider.
  ///
  /// This is the URL where telemetry data will be sent.
  String get endpoint => _endpoint;

  /// Sets the endpoint URL used by this logger provider.
  ///
  /// This is the URL where telemetry data will be sent.
  set endpoint(String value) {
    _endpoint = value;
  }

  APILogger getLogger(
    String name, {
    String? version,
    String? schemaUrl,
    Attributes? attributes,
  }) {
    if (_isShutdown) {
      throw StateError('LogProvider has been shut down');
    }

    // Validate the logger name; if invalid (empty), log a warning and use empty string.
    final validatedName = name.isEmpty ? '' : name;
    if (validatedName.isEmpty) {
      OTelLog.warn(
          'Invalid log name provided; using empty string as fallback.');
    }

    // Apply default values if none are provided
    String? effectiveVersion = version;
    String? effectiveSchemaUrl = schemaUrl;

    // Only apply defaults if all optional parameters are missing
    if (version == null && schemaUrl == null && attributes == null) {
      effectiveVersion = OTelAPI.defaultServiceVersion;
      effectiveSchemaUrl = OTelAPI.defaultSchemaUrl;
    }

    // Create a cache key based on the provided parameters.
    final key = SignalInstanceKey(
      validatedName,
      effectiveVersion,
      effectiveSchemaUrl,
      attributes,
    );

    if (_loggerCache.containsKey(key)) {
      return _loggerCache[key]!;
    } else {
      final logger = LoggerCreate.create(
        name: validatedName,
        version: effectiveVersion,
        schemaUrl: effectiveSchemaUrl,
        attributes: attributes,
      );
      _loggerCache[key] = logger;
      return logger;
    }
  }

  /// Gets the service name used by this logger provider.
  ///
  /// The service name is a required resource attribute that uniquely identifies the service.
  String get serviceName => _serviceName;

  /// Sets the service name used by this logger provider.
  ///
  /// The service name is a required resource attribute that uniquely identifies the service.
  set serviceName(String value) {
    _serviceName = value;
  }

  /// Gets the service version used by this logger provider.
  ///
  /// The service version is an optional resource attribute that specifies the version of the service.
  String? get serviceVersion => _serviceVersion;

  /// Sets the service version used by this logger provider.
  ///
  /// The service version is an optional resource attribute that specifies the version of the service.
  set serviceVersion(String? value) {
    _serviceVersion = value;
  }

  /// Returns whether this logger provider is enabled.
  ///
  /// When disabled, loggers will not create spans or send telemetry data.
  bool get enabled => _enabled;

  /// Sets whether this logger provider is enabled.
  ///
  /// When disabled, loggers will not create spans or send telemetry data.
  set enabled(bool value) {
    _enabled = value;
  }

  /// Returns whether this logger provider has been shut down.
  ///
  /// A shut down provider will not create new loggers or spans.
  bool get isShutdown => _isShutdown;

  /// Sets whether this logger provider has been shut down.
  ///
  /// This should only be set internally during the shutdown process.
  set isShutdown(bool value) {
    _isShutdown = value;
  }

  /// Shuts down the loggerProvider.
  /// After shutdown:
  /// - New spans will not be accepted
  /// - All spans in progress should be ended
  /// - Resources should be cleaned up
  /// Returns true if shutdown was successful.
  Future<bool> shutdown() async {
    if (_isShutdown) {
      return true; // Already shut down
    }

    try {
      // Mark as shut down immediately to prevent new loggers/spans
      _isShutdown = true;

      // Clear the logger cache
      _loggerCache.clear();

      // Disable the provider
      _enabled = false;

      return true;
    } catch (e) {
      OTelLog.error('Error during LogProvider shutdown: $e');
      return false;
    }
  }
}
