// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'counter.dart';

/// Factory methods for creating [APICounter] instances.
/// This is part of the counter.dart file to keep related code together.
@internal
class CounterCreate {
  /// Creates a new [APICounter] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createCounter()] instead.
  static APICounter<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required bool enabled,
    required APIMeter meter,
  }) {
    return APICounter<T>(
      name,
      description,
      unit,
      enabled,
      meter,
    );
  }
}
