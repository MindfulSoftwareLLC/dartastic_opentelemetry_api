// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'observable_up_down_counter.dart';

/// Factory methods for creating [APIObservableUpDownCounter] instances.
/// This is part of the observable_up_down_counter.dart file to keep related code together.
class ObservableUpDownCounterCreate<T extends num> {
  /// Creates a new [APIObservableUpDownCounter] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createObservableUpDownCounter()] instead.
  static APIObservableUpDownCounter<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required bool enabled,
    required APIMeter meter,
    ObservableCallback<T>? callback,
  }) {
    return APIObservableUpDownCounter<T>(
      name,
      description,
      unit,
      enabled,
      meter,
      callback,
    );
  }
}
