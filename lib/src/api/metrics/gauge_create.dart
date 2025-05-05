// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'gauge.dart';

/// Factory methods for creating [APIGauge] instances.
/// This is part of the gauge.dart file to keep related code together.
class GaugeCreate {
  /// Creates a new [APIGauge] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createGauge()] instead.
  static APIGauge<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required bool enabled,
    required APIMeter meter,
  }) {
    return APIGauge<T>(
      name,
      description,
      unit,
      enabled,
      meter,
    );
  }
}
