// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'observable_counter.dart';

/// Factory methods for creating [APIObservableCounter] instances.
/// This is part of the observable_counter.dart file to keep related code together.
class ObservableCounterCreate {
  /// Creates a new [APIObservableCounter] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createObservableCounter()] instead.
  static APIObservableCounter<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required bool enabled,
    required APIMeter meter,
    ObservableCallback<T>? callback,
  }) {
    return APIObservableCounter<T>(
      name,
      description,
      unit,
      enabled,
      meter,
      callback,
    );
  }
}
