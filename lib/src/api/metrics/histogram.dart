// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';
import '../common/attributes.dart';
import 'instrument_advisory.dart';
import 'meter.dart';

part 'histogram_create.dart';

/// APIHistogram is a synchronous Instrument which records a distribution of values.
///
/// See the OpenTelemetry specification for more details:
/// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#histogram
class APIHistogram<T extends num> {
  /// The name of this histogram instrument.
  final String _name;

  /// The optional description of this histogram instrument.
  final String? _description;

  /// The optional unit of measure for this histogram instrument.
  final String? _unit;

  /// The meter that created this histogram instrument.
  final APIMeter _meter;

  /// The optional advisory parameters for this histogram.
  final InstrumentAdvisory? _advisory;

  /// Creates a new [APIHistogram] instrument.
  ///
  /// This constructor is typically not called directly. Instead, use [APIMeter.createHistogram].
  ///
  /// [_name] The name of the histogram instrument.
  /// [_description] Optional description of the histogram instrument.
  /// [_unit] Optional unit of measurement for the histogram.
  /// [_meter] The meter that created this histogram instrument.
  /// [advisory] Optional advisory parameters for the histogram.
  APIHistogram(this._name, this._description, this._unit, this._meter,
      {InstrumentAdvisory? advisory})
      : _advisory = advisory;

  /// Returns the name of this Histogram.
  String get name => _name;

  /// Returns the description of this Histogram.
  String? get description => _description;

  /// Returns the unit of this Histogram.
  String? get unit => _unit;

  /// Returns whether the instrument is enabled and will record measurements.
  ///
  /// The returned value can change over time; instrumentation authors need
  /// to call this before each measurement to ensure they have the most
  /// up-to-date response. The base API implementation always returns false;
  /// SDK subclasses override this to compute the real, current value.
  bool isEnabled() => false;

  /// Returns the meter that created this histogram.
  APIMeter get meter => _meter;

  /// Returns the advisory parameters for this histogram.
  InstrumentAdvisory? get advisory => _advisory;

  /// Returns the explicit bucket boundaries, if specified during creation.
  @Deprecated('Use advisory?.explicitBucketBoundaries instead')
  List<double>? get boundaries => _advisory?.explicitBucketBoundaries;

  /// Records a value in the histogram.
  ///
  /// [value] The value to record.
  /// [attributes] The set of attributes to associate with this value.
  void record(T value, [Attributes? attributes]) {
    // Base implementation is a no-op
  }

  /// Records a value with the given map of attributes.
  ///
  /// [value] The value to record.
  /// [attributeMap] A map of attribute key-value pairs.
  void recordWithMap(T value, Map<String, Object> attributeMap) {
    // Convert map to Attributes and delegate to record
    final attributes =
        attributeMap.isEmpty ? null : attributeMap.toAttributes();
    record(value, attributes);
  }

  /// Type identification getters
  /// Returns false since this is not a Counter instrument.
  bool get isCounter => false;

  /// Returns false since this is not an UpDownCounter instrument.
  bool get isUpDownCounter => false;

  /// Returns false since this is not a Gauge instrument.
  bool get isGauge => false;

  /// Returns true since this is a Histogram instrument.
  bool get isHistogram => true;
}
