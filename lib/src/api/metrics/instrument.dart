// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'meter.dart';

/// The base interface for all metric instruments.
///
/// Instruments are used to record measurements which are then aggregated into
/// metrics. Different instrument types produce different kinds of measurements
/// and are aggregated differently.
class APIInstrument {
  final String _name;
  final String? _unit;
  final String? _description;
  final bool _enabled;
  final APIMeter _meter;

  /// Creates a new instrument with the specified parameters.
  ///
  /// [name] The name of the instrument (required).
  /// [unit] The optional unit of measurement.
  /// [description] An optional human-readable description.
  /// [enabled] Whether the instrument is enabled and will record measurements.
  /// [meter] The meter that created this instrument.
  APIInstrument({
    required String name,
    String? unit,
    String? description,
    required bool enabled,
    required APIMeter meter,
  })  : _name = name,
        _unit = unit,
        _description = description,
        _enabled = enabled,
        _meter = meter;

  /// The name of the instrument, e.g., 'http.server.request_duration'.
  /// This must be unique within a Meter.
  String get name => _name;

  /// The unit of measurement, e.g., 'ms' for milliseconds.
  String? get unit => _unit;

  /// A human-readable description of the instrument.
  String? get description => _description;

  /// Returns whether the instrument is enabled and will record measurements.
  bool get enabled => _enabled;

  /// The Meter that created this instrument.
  APIMeter get meter => _meter;
}
