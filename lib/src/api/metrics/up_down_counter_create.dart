// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'up_down_counter.dart';

/// Factory methods for creating [APIUpDownCounter] instances.
/// This is part of the up_down_counter.dart file to keep related code together.
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
