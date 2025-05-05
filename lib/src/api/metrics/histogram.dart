// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../common/attributes.dart';
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

  /// Whether this histogram is enabled for recording measurements.
  final bool _enabled;

  /// The meter that created this histogram instrument.
  final APIMeter _meter;

  /// The optional explicit bucket boundaries for this histogram.
  final List<double>? _boundaries;

  /// Creates a new [APIHistogram] instrument.
  ///
  /// This constructor is typically not called directly. Instead, use [APIMeter.createHistogram].
  ///
  /// [_name] The name of the histogram instrument.
  /// [_description] Optional description of the histogram instrument.
  /// [_unit] Optional unit of measurement for the histogram.
  /// [_enabled] Whether this histogram is enabled for recording measurements.
  /// [_meter] The meter that created this histogram instrument.
  /// [boundaries] Optional explicit bucket boundaries for the histogram.
  APIHistogram(
      this._name, this._description, this._unit, this._enabled, this._meter,
      {List<double>? boundaries})
      : _boundaries = boundaries != null ? List.unmodifiable(boundaries) : null;

  /// Returns the name of this Histogram.
  String get name => _name;

  /// Returns the description of this Histogram.
  String? get description => _description;

  /// Returns the unit of this Histogram.
  String? get unit => _unit;

  /// Returns whether this histogram is enabled.
  bool get enabled => _enabled;

  /// Returns the meter that created this histogram.
  APIMeter get meter => _meter;

  /// Returns the explicit bucket boundaries, if specified during creation.
  List<double>? get boundaries => _boundaries;

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
