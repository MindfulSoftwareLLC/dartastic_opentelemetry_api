// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'measurement.dart';

/// Factory methods for creating [Measurement] instances.
class MeasurementCreate<T extends num> {
  /// Creates a new [Measurement] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createMeasurement()] instead.
  static Measurement<T> create<T extends num>(T value,
      [Attributes? attributes]) {
    return Measurement<T>._(value, attributes);
  }
}
