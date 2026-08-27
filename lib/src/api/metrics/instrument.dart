// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

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
  final APIMeter _meter;

  /// Creates a new instrument with the specified parameters.
  ///
  /// [name] The name of the instrument (required).
  /// [unit] The optional unit of measurement.
  /// [description] An optional human-readable description.
  /// [meter] The meter that created this instrument.
  APIInstrument({
    required String name,
    String? unit,
    String? description,
    required APIMeter meter,
  })  : _name = name,
        _unit = unit,
        _description = description,
        _meter = meter;

  /// The name of the instrument, e.g., 'http.server.request_duration'.
  /// This must be unique within a Meter.
  String get name => _name;

  /// The unit of measurement, e.g., 'ms' for milliseconds.
  String? get unit => _unit;

  /// A human-readable description of the instrument.
  String? get description => _description;

  /// Returns whether the instrument is enabled and will record measurements.
  ///
  /// The returned value can change over time; instrumentation authors need
  /// to call this before each measurement to ensure they have the most
  /// up-to-date response. The base API implementation always returns false;
  /// SDK subclasses override this to compute the real, current value.
  bool isEnabled() => false;

  /// The Meter that created this instrument.
  APIMeter get meter => _meter;
}
