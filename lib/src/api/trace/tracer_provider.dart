// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// ignore_for_file: unnecessary_getters_setters

import '../../util/default_time_provider.dart';
import '../../util/otel_log.dart';
import '../../util/time_provider.dart';
import '../common/attributes.dart';
import '../common/signal_instance_key.dart';
import '../context/context.dart';
import '../otel_api.dart';
import 'tracer.dart';

part 'tracer_provider_create.dart';

/// APITracerProvider is the entry point of the OpenTelemetry tracing API.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the TracerProvider from the SDK instead.
/// It provides access to [APITracer]s which are used to trace operations.
/// You cannot create a TracerProvider directly;
/// you must use [OTelAPI] or more likely [OTel], for example to get the default tracer:
/// ```dart
/// var tracerProvider = OTel.tracerProvider();
/// ```
/// See [OTel] for creating tracers in addition to the default.
/// Use [OTelAPI] to run in no-op mode, as required by the specification.
class APITracerProvider {
  String _endpoint;
  String _serviceName;
  String? _serviceVersion;
  bool _enabled;
  bool _isShutdown;

  // Cache for created tracers, keyed by _TracerKey.
  final Map<SignalInstanceKey, APITracer> _tracerCache = {};

  /// Clock used for span start, end, and event timestamps. Tracers and
  /// spans created from this provider inherit this clock so all timestamps
  /// in a trace are consistent.
  ///
  /// **Defaults are platform-aware**: native targets get `SystemTimeProvider`
  /// (`DateTime.now`, microsecond precision); web targets (Dart-on-JS or
  /// Wasm) get `WebTimeProvider` (`window.performance.now()`, sub-
  /// millisecond precision). Override only if you want different behaviour
  /// — e.g., a fake clock in tests or a Pro `NativeNanosecondTimeProvider`
  /// for FFI-backed nanosecond timing on native servers.
  TimeProvider timeProvider;

  /// Creates a new [APITracerProvider].
  APITracerProvider._({
    required String endpoint,
    String serviceName = OTelAPI.defaultServiceName,
    String? serviceVersion = OTelAPI.defaultServiceVersion,
    bool enabled = true,
    bool isShutdown = false,
    TimeProvider? timeProvider,
  })  : _endpoint = endpoint,
        _serviceName = serviceName,
        _serviceVersion = serviceVersion,
        _enabled = enabled,
        _isShutdown = isShutdown,
        timeProvider = timeProvider ?? defaultTimeProvider;

  /// Gets the endpoint URL used by this tracer provider.
  ///
  /// This is the URL where telemetry data will be sent.
  String get endpoint => _endpoint;

  /// Sets the endpoint URL used by this tracer provider.
  ///
  /// This is the URL where telemetry data will be sent.
  set endpoint(String value) {
    _endpoint = value;
  }

  /// Returns a [APITracer] with the given [name] and [version].
  ///
  /// [name] The name of the tracer, usually the package name of the instrumented library.
  /// [version] The version of the instrumented library.
  /// [schemaUrl] Optional URL of the OpenTelemetry schema being used.
  /// [attributes] Optional Attributes for the Tracer.
  APITracer getTracer(String name,
      {String? version, String? schemaUrl, Attributes? attributes}) {
    if (_isShutdown) {
      throw StateError('TracerProvider has been shut down');
    }

    // Validate the tracer name; if invalid (empty), log a warning and use empty string.
    final validatedName = name.isEmpty ? '' : name;
    if (validatedName.isEmpty) {
      OTelLog.warn(
          'Invalid tracer name provided; using empty string as fallback.');
    }

    // Apply default values if none are provided
    var effectiveVersion = version;
    var effectiveSchemaUrl = schemaUrl;

    // Only apply defaults if all optional parameters are missing
    if (version == null && schemaUrl == null && attributes == null) {
      effectiveVersion = OTelAPI.defaultServiceVersion;
      effectiveSchemaUrl = OTelAPI.defaultSchemaUrl;
    }

    // Create a cache key based on the provided parameters.
    final key = SignalInstanceKey(validatedName, effectiveVersion,
        effectiveSchemaUrl, attributes, Signal.traces);

    if (_tracerCache.containsKey(key)) {
      return _tracerCache[key]!;
    } else {
      final tracer = TracerCreate.create(
        name: validatedName,
        version: effectiveVersion,
        schemaUrl: effectiveSchemaUrl,
        attributes: attributes,
        timeProvider: timeProvider,
      );
      _tracerCache[key] = tracer;
      return tracer;
    }
  }

  /// Gets the service name used by this tracer provider.
  ///
  /// The service name is a required resource attribute that uniquely identifies the service.
  String get serviceName => _serviceName;

  /// Sets the service name used by this tracer provider.
  ///
  /// The service name is a required resource attribute that uniquely identifies the service.
  set serviceName(String value) {
    _serviceName = value;
  }

  /// Gets the service version used by this tracer provider.
  ///
  /// The service version is an optional resource attribute that specifies the version of the service.
  String? get serviceVersion => _serviceVersion;

  /// Sets the service version used by this tracer provider.
  ///
  /// The service version is an optional resource attribute that specifies the version of the service.
  set serviceVersion(String? value) {
    _serviceVersion = value;
  }

  /// Returns whether this tracer provider is enabled.
  ///
  /// When disabled, tracers will not create spans or send telemetry data.
  bool get enabled => _enabled;

  /// Sets whether this tracer provider is enabled.
  ///
  /// When disabled, tracers will not create spans or send telemetry data.
  set enabled(bool value) {
    _enabled = value;
  }

  /// Returns whether this tracer provider has been shut down.
  ///
  /// A shut down provider will not create new tracers or spans.
  bool get isShutdown => _isShutdown;

  /// Sets whether this tracer provider has been shut down.
  ///
  /// This should only be set internally during the shutdown process.
  set isShutdown(bool value) {
    _isShutdown = value;
  }

  /// Shuts down the TracerProvider.
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
      // Mark as shut down immediately to prevent new tracers/spans
      _isShutdown = true;

      // Clear the tracer cache
      _tracerCache.clear();

      // Disable the provider
      _enabled = false;

      // Reset current context through context API
      // Clear any active spans from context
      Context.root.setCurrentSpan(null);

      return true;
    } catch (e) {
      OTelLog.error('Error during TracerProvider shutdown: $e');
      return false;
    }
  }
}
