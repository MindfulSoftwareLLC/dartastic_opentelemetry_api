// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../../../dartastic_opentelemetry_api.dart' show OTelAPI;
import '../common/attributes.dart';
import 'counter.dart';
import 'gauge.dart';
import 'histogram.dart';
import 'observable_callback.dart';
import 'observable_counter.dart';
import 'observable_gauge.dart';
import 'observable_up_down_counter.dart';
import 'up_down_counter.dart';

part 'meter_create.dart';

/// Meter is responsible for creating [Instrument]s and recording metrics.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the Meter from the SDK instead.
class APIMeter {
  /// Gets the name of the meter, usually of a library, package or module
  final String name;

  /// Gets the version, usually of the instrumented library, package or module
  final String? version;

  /// Gets the schema URL of the meter
  final String? schemaUrl;

  /// Optional attributes associated with this meter
  final Attributes? attributes;

  /// Creates a new [APIMeter].
  /// You cannot create a Meter directly; you must use [MeterProvider]:
  /// ```dart
  /// var meter = OTel.meterProvider() or more likely, OTel.meterProvider().getMeter("my-library");
  /// ```
  APIMeter._({
    required this.name,
    this.schemaUrl,
    this.version,
    this.attributes,
  });

  /// Returns true if the meter is enabled and will create instruments.
  bool get enabled => false;

  /// Creates a [Counter] with the given name.
  ///
  /// A Counter is a synchronous Instrument which supports non-negative increments.
  ///
  /// [name] The name of the instrument
  /// [unit] Optional unit of the instrument (e.g., "ms" for milliseconds)
  /// [description] Optional description of the instrument
  APICounter<T> createCounter<T extends num>({
    required String name,
    String? unit,
    String? description,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Counter name must not be empty');
    }

    return CounterCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      enabled: enabled,
      meter: this,
    );
  }

  /// Creates an [UpDownCounter] with the given name.
  ///
  /// An UpDownCounter is a synchronous Instrument which supports increments and decrements.
  ///
  /// [name] The name of the instrument
  /// [unit] Optional unit of the instrument (e.g., "ms" for milliseconds)
  /// [description] Optional description of the instrument
  APIUpDownCounter<T> createUpDownCounter<T extends num>({
    required String name,
    String? unit,
    String? description,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('UpDownCounter name must not be empty');
    }

    return UpDownCounterCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      enabled: enabled,
      meter: this,
    );
  }

  /// Creates a [Histogram] with the given name.
  ///
  /// A Histogram is a synchronous Instrument which can be used to report arbitrary values
  /// that are likely to be statistically meaningful.
  ///
  /// [name] The name of the instrument
  /// [unit] Optional unit of the instrument (e.g., "ms" for milliseconds)
  /// [description] Optional description of the instrument
  /// [boundaries] Optional explicit bucket boundaries for the histogram
  APIHistogram<T> createHistogram<T extends num>({
    required String name,
    String? unit,
    String? description,
    List<double>? boundaries,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Histogram name must not be empty');
    }

    return HistogramCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      enabled: enabled,
      meter: this,
      boundaries: boundaries,
    );
  }

  /// Creates a [Gauge] with the given name.
  ///
  /// A Gauge is a synchronous Instrument which can be used to record non-additive value(s)
  /// when changes occur.
  ///
  /// [name] The name of the instrument
  /// [unit] Optional unit of the instrument (e.g., "ms" for milliseconds)
  /// [description] Optional description of the instrument
  APIGauge<T> createGauge<T extends num>({
    required String name,
    String? unit,
    String? description,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Gauge name must not be empty');
    }

    return GaugeCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      enabled: enabled,
      meter: this,
    );
  }

  /// Creates an [ObservableCounter] with the given name.
  ///
  /// An ObservableCounter is an asynchronous Instrument which reports monotonically increasing
  /// value(s) when the instrument is being observed.
  ///
  /// [name] The name of the instrument
  /// [unit] Optional unit of the instrument (e.g., "ms" for milliseconds)
  /// [description] Optional description of the instrument
  /// [callback] Optional callback to provide measurements when the instrument is observed
  APIObservableCounter<T> createObservableCounter<T extends num>({
    required String name,
    String? unit,
    String? description,
    ObservableCallback<T>? callback,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('ObservableCounter name must not be empty');
    }

    return ObservableCounterCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      enabled: enabled,
      meter: this,
      callback: callback,
    );
  }

  /// Creates an [ObservableUpDownCounter] with the given name.
  ///
  /// An ObservableUpDownCounter is an asynchronous Instrument which reports values that increase
  /// or decrease when the instrument is being observed.
  ///
  /// [name] The name of the instrument
  /// [unit] Optional unit of the instrument (e.g., "ms" for milliseconds)
  /// [description] Optional description of the instrument
  /// [callback] Optional callback to provide measurements when the instrument is observed
  APIObservableUpDownCounter<T> createObservableUpDownCounter<T extends num>({
    required String name,
    String? unit,
    String? description,
    ObservableCallback<T>? callback,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('ObservableUpDownCounter name must not be empty');
    }

    return ObservableUpDownCounterCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      enabled: enabled,
      meter: this,
      callback: callback,
    );
  }

  /// Creates an [ObservableGauge] with the given name.
  ///
  /// An ObservableGauge is an asynchronous Instrument which reports non-additive value(s)
  /// when the instrument is being observed.
  ///
  /// [name] The name of the instrument
  /// [unit] Optional unit of the instrument (e.g., "ms" for milliseconds)
  /// [description] Optional description of the instrument
  /// [callback] Optional callback to provide measurements when the instrument is observed
  APIObservableGauge<T> createObservableGauge<T extends num>({
    required String name,
    String? unit,
    String? description,
    ObservableCallback<T>? callback,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('ObservableGauge name must not be empty');
    }

    return ObservableGaugeCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      enabled: enabled,
      meter: this,
      callback: callback,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is APIMeter &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          version == other.version &&
          schemaUrl == other.schemaUrl &&
          attributes == other.attributes;

  @override
  int get hashCode =>
      name.hashCode ^
      version.hashCode ^
      schemaUrl.hashCode ^
      attributes.hashCode;
}
