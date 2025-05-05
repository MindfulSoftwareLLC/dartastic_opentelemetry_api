// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../common/attributes.dart';
import 'meter.dart';

part 'counter_create.dart';

/// APICounter is a synchronous Instrument which supports non-negative increments.
///
/// See the OpenTelemetry specification for more details:
/// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#counter
class APICounter<T extends num> {
  /// The name of this counter instrument.
  final String _name;

  /// The optional description of this counter instrument.
  final String? _description;

  /// The optional unit of measure for this counter instrument.
  final String? _unit;

  /// Whether this counter is enabled for recording measurements.
  final bool _enabled;

  /// The meter that created this counter instrument.
  final APIMeter _meter;

  /// Creates a new [APICounter] instrument.
  ///
  /// This constructor is typically not called directly. Instead, use [APIMeter.createCounter].
  ///
  /// [_name] The name of the counter instrument.
  /// [_description] Optional description of the counter instrument.
  /// [_unit] Optional unit of measurement for the counter.
  /// [_enabled] Whether this counter is enabled for recording measurements.
  /// [_meter] The meter that created this counter instrument.
  APICounter(
    this._name,
    this._description,
    this._unit,
    this._enabled,
    this._meter,
  );

  /// Returns the name of this Counter.
  String get name => _name;

  /// Returns the description of this Counter.
  String? get description => _description;

  /// Returns the unit of this Counter.
  String? get unit => _unit;

  /// Returns whether this counter is enabled.
  bool get enabled => _enabled;

  /// Returns the meter that created this counter.
  APIMeter get meter => _meter;

  /// Adds a value to the counter's sum.
  ///
  /// The value must be non-negative.
  ///
  /// [value] The increment amount. Must be non-negative.
  /// [attributes] The set of attributes to associate with this value.
  void add(T value, [Attributes? attributes]) {
    // Base implementation is a no-op
  }

  /// Adds a value to the counter's sum using a map of attributes.
  ///
  /// [value] The increment amount. Must be non-negative.
  /// [attributeMap] A map of attribute key-value pairs.
  void addWithMap(T value, Map<String, Object> attributeMap) {
    // Convert map to Attributes and delegate to add
    final attributes =
        attributeMap.isEmpty ? null : attributeMap.toAttributes();
    add(value, attributes);
  }

  /// Type identification getters
  /// Returns true since this is a Counter instrument.
  bool get isCounter => true;

  /// Returns false since this is not an UpDownCounter instrument.
  bool get isUpDownCounter => false;

  /// Returns false since this is not a Gauge instrument.
  bool get isGauge => false;

  /// Returns false since this is not a Histogram instrument.
  bool get isHistogram => false;
}
