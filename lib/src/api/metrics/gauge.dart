// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';
import '../common/attributes.dart';
import 'meter.dart';

part 'gauge_create.dart';

/// APIGauge is a synchronous Instrument which reports instantaneous measurements.
///
/// See the OpenTelemetry specification for more details:
/// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#gauge
class APIGauge<T extends num> {
  /// The name of this gauge instrument.
  final String _name;

  /// The optional description of this gauge instrument.
  final String? _description;

  /// The optional unit of measure for this gauge instrument.
  final String? _unit;

  /// The meter that created this gauge instrument.
  final APIMeter _meter;

  /// Creates a new [APIGauge] instrument.
  ///
  /// This constructor is typically not called directly. Instead, use [APIMeter.createGauge].
  ///
  /// [_name] The name of the gauge instrument.
  /// [_description] Optional description of the gauge instrument.
  /// [_unit] Optional unit of measurement for the gauge.
  /// [_meter] The meter that created this gauge instrument.
  APIGauge(
    this._name,
    this._description,
    this._unit,
    this._meter,
  );

  /// Returns the name of this Gauge.
  String get name => _name;

  /// Returns the description of this Gauge.
  String? get description => _description;

  /// Returns the unit of this Gauge.
  String? get unit => _unit;

  /// Returns whether the instrument is enabled and will record measurements.
  ///
  /// The returned value can change over time; instrumentation authors need
  /// to call this before each measurement to ensure they have the most
  /// up-to-date response. The base API implementation always returns false;
  /// SDK subclasses override this to compute the real, current value.
  bool isEnabled() => false;

  /// Returns the meter that created this gauge.
  APIMeter get meter => _meter;

  /// Records the current value of the gauge.
  ///
  /// [value] The current value to record.
  /// [attributes] The set of attributes to associate with this value.
  void record(T value, [Attributes? attributes]) {
    // Base implementation is a no-op
  }

  /// Records a value with the given map of attributes.
  ///
  /// [value] The current value to record.
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

  /// Returns true since this is a Gauge instrument.
  bool get isGauge => true;

  /// Returns false since this is not a Histogram instrument.
  bool get isHistogram => false;
}
