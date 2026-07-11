// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'up_down_counter.dart';

/// Factory methods for creating [APIUpDownCounter] instances.
/// This is part of the up_down_counter.dart file to keep related code together.
@internal
class UpDownCounterCreate {
  /// Creates a new [APIUpDownCounter] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createUpDownCounter()] instead.
  static APIUpDownCounter<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required bool enabled,
    required APIMeter meter,
  }) {
    return APIUpDownCounter<T>(
      name,
      description,
      unit,
      enabled,
      meter,
    );
  }
}
