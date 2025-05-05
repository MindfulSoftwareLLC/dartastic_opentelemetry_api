// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../common/attributes.dart';

part 'measurement_create.dart';

/// Represents a data point reported via the metrics API.
///
/// A Measurement includes a value and optional attributes.
class Measurement<T extends num> {
  /// The value of the measurement.
  final T value;

  /// Attributes associated with this measurement.
  final Attributes? attributes;

  /// Creates a new Measurement with the specified value and attributes.
  ///
  /// [value] The value of the measurement.
  /// [attributes] Optional attributes to associate with the measurement.
  /// If null, empty attributes will be used.
  Measurement._(this.value, [this.attributes]);

  /// Returns true if this measurement has non-empty attributes.
  bool get hasAttributes => attributes != null && attributes!.length > 0;

  @override
  String toString() {
    return 'Measurement{value: $value, attributes: $attributes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measurement &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          attributes == other.attributes;

  @override
  int get hashCode => value.hashCode ^ attributes.hashCode;
}
