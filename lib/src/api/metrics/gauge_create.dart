// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'gauge.dart';

/// Factory methods for creating [APIGauge] instances.
/// This is part of the gauge.dart file to keep related code together.
@internal
class GaugeCreate {
  /// Creates a new [APIGauge] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createGauge()] instead.
  static APIGauge<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required APIMeter meter,
    InstrumentAdvisory? advisory,
  }) {
    return APIGauge<T>(
      name,
      description,
      unit,
      meter,
      advisory,
    );
  }
}
