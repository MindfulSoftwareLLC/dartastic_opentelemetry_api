// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';

import '../../util/otel_error_handler.dart';
import '../common/attributes.dart';
import 'batch_callback.dart';
import 'counter.dart';
import 'gauge.dart';
import 'histogram.dart';
import 'instrument_advisory.dart';
import 'observable_callback.dart';
import 'observable_counter.dart';
import 'observable_gauge.dart';
import 'observable_instrument.dart';
import 'observable_up_down_counter.dart';
import 'up_down_counter.dart';

part 'meter_create.dart';

/// Meter is responsible for creating [APIInstrument]s and recording metrics.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the Meter from the SDK instead.
/// This is the no-op meter. It accepts every argument unvalidated, including
/// an empty instrument name, and never logs or reports: metrics/noop.md says
/// the Meter MUST NOT return a non-empty error or log any message. Name
/// validation belongs to the SDK meter.
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
  /// You cannot create a Meter directly; you must use [APIMeterProvider]:
  /// ```dart
  /// var meter = OTel.meterProvider() or more likely, OTel.meterProvider().getMeter("my-library");
  /// ```
  APIMeter._({
    required this.name,
    this.schemaUrl,
    this.version,
    this.attributes,
  });

  /// Returns whether the meter is enabled and will create instruments.
  ///
  /// The returned value can change over time; instrumentation authors need
  /// to call this before creating instruments to ensure they have the most
  /// up-to-date response. The base API implementation always returns false;
  /// SDK subclasses override this to compute the real, current value.
  bool isEnabled() => false;

  /// Creates a [APICounter] with the given name.
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
    InstrumentAdvisory? advisory,
  }) {
    return CounterCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      meter: this,
      advisory: advisory,
    );
  }

  /// Creates a [APIUpDownCounter] with the given name.
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
    InstrumentAdvisory? advisory,
  }) {
    return UpDownCounterCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      meter: this,
      advisory: advisory,
    );
  }

  /// Creates a [APIHistogram] with the given name.
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
    @Deprecated(
        'Use advisory: InstrumentAdvisory(explicitBucketBoundaries: ...) instead')
    List<double>? boundaries,
    InstrumentAdvisory? advisory,
  }) {
    // The deprecated boundaries parameter wins over
    // advisory.explicitBucketBoundaries, so existing callers keep their
    // buckets. Everything else on the advisory is kept.
    final effectiveAdvisory = boundaries != null
        ? InstrumentAdvisory(
            explicitBucketBoundaries: boundaries,
            attributeKeys: advisory?.attributeKeys,
          )
        : advisory;

    return HistogramCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      meter: this,
      advisory: effectiveAdvisory,
    );
  }

  /// Creates a [APIGauge] with the given name.
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
    InstrumentAdvisory? advisory,
  }) {
    return GaugeCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      meter: this,
      advisory: advisory,
    );
  }

  /// Creates a [APIObservableCounter] with the given name.
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
    InstrumentAdvisory? advisory,
    List<ObservableCallback<T>> callbacks = const [],
    @Deprecated('Use callbacks instead') ObservableCallback<T>? callback,
  }) {
    final merged = [if (callback != null) callback, ...callbacks];

    return ObservableCounterCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      meter: this,
      advisory: advisory,
      callbacks: merged,
    );
  }

  /// Creates a [APIObservableUpDownCounter] with the given name.
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
    InstrumentAdvisory? advisory,
    List<ObservableCallback<T>> callbacks = const [],
    @Deprecated('Use callbacks instead') ObservableCallback<T>? callback,
  }) {
    final merged = [if (callback != null) callback, ...callbacks];

    return ObservableUpDownCounterCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      meter: this,
      advisory: advisory,
      callbacks: merged,
    );
  }

  /// Creates a [APIObservableGauge] with the given name.
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
    InstrumentAdvisory? advisory,
    List<ObservableCallback<T>> callbacks = const [],
    @Deprecated('Use callbacks instead') ObservableCallback<T>? callback,
  }) {
    final merged = [if (callback != null) callback, ...callbacks];

    return ObservableGaugeCreate.create<T>(
      name: name,
      unit: unit,
      description: description,
      meter: this,
      advisory: advisory,
      callbacks: merged,
    );
  }

  /// Registers a batch callback for multiple observable instruments.
  APIBatchCallbackRegistration registerBatchCallback(
    BatchObservableCallback callback,
    Set<APIObservableInstrument> instruments,
  ) {
    // metrics/api.md: a multiple-instrument callback MUST be associated
    // with instruments from the same Meter. The type already rules out a
    // synchronous instrument; a foreign meter is reported and the callback
    // is not registered. error-handling.md: never throw at the user.
    for (final instrument in instruments) {
      if (!identical(instrument.meter, this)) {
        OTelErrorHandling.report(ArgumentError(
          'registerBatchCallback: instrument "${instrument.name}" belongs '
          'to a different Meter; the callback was not registered.',
        ));
        return _NoopBatchCallbackRegistration();
      }
    }
    // No-op: return a stateless registration
    return _NoopBatchCallbackRegistration();
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

class _NoopBatchCallbackRegistration implements APIBatchCallbackRegistration {
  @override
  void unregister() {}
}
