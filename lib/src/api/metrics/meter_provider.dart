// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// ignore_for_file: unnecessary_getters_setters

import '../../../dartastic_opentelemetry_api.dart' show OTelAPI, OTelLog;
import '../common/attributes.dart';
import '../common/signal_instance_key.dart';
import 'meter.dart';

part 'meter_provider_create.dart';

/// APIMeterProvider is the entry point of the OpenTelemetry metrics API.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the MeterProvider from the SDK instead.
/// It provides access to [APIMeter]s which are used to record metrics.
/// You cannot create a MeterProvider directly;
/// you must use [OTelAPI] or more likely, [OTel], for example to get the default meter provider:
/// ```dart
/// var meterProvider = OTel.meterProvider();
/// ```
/// See [OTel] for creating meters in addition to the default.
/// Use [OTelAPI] to run in no-op mode, as required by the specification.
class APIMeterProvider {
  /// The endpoint URL where metrics data is sent.
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

  // Cache for created meters, keyed by _MeterKey.
  final Map<SignalInstanceKey, APIMeter> _meterCache = {};

  /// Creates a new [APIMeterProvider].
  /// You cannot create a MeterProvider directly; you must use [OTelFactory]:
  /// ```dart
  /// var meterProvider = OTelFactory.meterProvider();
  APIMeterProvider._({
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

  /// Gets the endpoint URL where metrics data is sent.
  String get endpoint => _endpoint;

  /// Sets the endpoint URL where metrics data is sent.
  set endpoint(String value) {
    _endpoint = value;
  }

  /// Returns a [APIMeter] with the given [name] and [version].
  ///
  /// [name] The name of the meter, usually the package name of the instrumented library.
  /// [version] The version of the instrumented library.
  /// [schemaUrl] Optional URL of the OpenTelemetry schema being used.
  /// [attributes] Optional Attributes for the Meter.
  APIMeter getMeter(
      {required String name,
      String? version,
      String? schemaUrl,
      Attributes? attributes}) {
    if (_isShutdown) {
      throw StateError('MeterProvider has been shut down');
    }

    // Validate the meter name; if invalid (empty), log a warning and use empty string.
    final validatedName = name.isEmpty ? '' : name;
    if (validatedName.isEmpty) {
      OTelLog.warn(
          'Invalid meter name provided; using empty string as fallback.');
    }

    // Create a cache key based on the provided parameters.
    final key = SignalInstanceKey(
        validatedName, version, schemaUrl, attributes, Signal.metrics);

    if (_meterCache.containsKey(key)) {
      return _meterCache[key]!;
    } else {
      final meter = APIMeterCreate.create(
        name: validatedName,
        version: version,
        schemaUrl: schemaUrl,
        attributes: attributes,
      );
      _meterCache[key] = meter;
      return meter;
    }
  }

  /// Gets the name of the service being instrumented.
  String get serviceName => _serviceName;

  /// Sets the name of the service being instrumented.
  set serviceName(String value) {
    _serviceName = value;
  }

  /// Gets the version of the service being instrumented.
  String? get serviceVersion => _serviceVersion;

  /// Sets the version of the service being instrumented.
  set serviceVersion(String? value) {
    _serviceVersion = value;
  }

  /// Gets whether this meter provider is enabled.
  bool get enabled => _enabled;

  /// Sets whether this meter provider is enabled.
  set enabled(bool value) {
    _enabled = value;
  }

  /// Gets whether this meter provider has been shut down.
  bool get isShutdown => _isShutdown;

  /// Sets whether this meter provider has been shut down.
  /// This should only be called internally during the shutdown process.
  set isShutdown(bool value) {
    _isShutdown = value;
  }

  /// Shuts down the MeterProvider.
  /// After shutdown:
  /// - New metrics will not be recorded
  /// - All pending metrics should be exported
  /// - Resources should be cleaned up
  /// Returns true if shutdown was successful.
  Future<bool> shutdown() async {
    if (_isShutdown) {
      return true; // Already shut down
    }

    try {
      // Mark as shut down immediately to prevent new meters
      _isShutdown = true;

      // Clear the meter cache
      _meterCache.clear();

      // Disable the provider
      _enabled = false;

      return true;
    } catch (e) {
      OTelLog.error('Error during MeterProvider shutdown: $e');
      return false;
    }
  }

  /// Forces the MeterProvider to flush all pending metrics to exporters.
  /// This is useful when the application is about to terminate and you want
  /// to ensure all metrics are exported.
  /// Returns true if the flush was successful, false otherwise.
  Future<bool> forceFlush() async {
    if (_isShutdown) {
      return false; // Already shut down
    }

    try {
      // In the API implementation, this is a no-op
      return true;
    } catch (e) {
      OTelLog.error('Error during MeterProvider forceFlush: $e');
      return false;
    }
  }
}
