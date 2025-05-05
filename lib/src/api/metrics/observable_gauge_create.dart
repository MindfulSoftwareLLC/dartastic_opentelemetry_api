// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'observable_gauge.dart';

/// Factory methods for creating [APIObservableGauge] instances.
/// This is part of the observable_gauge.dart file to keep related code together.
class ObservableGaugeCreate {
  /// Creates a new [APIObservableGauge] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createObservableGauge()] instead.
  static APIObservableGauge<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required bool enabled,
    required APIMeter meter,
    ObservableCallback<T>? callback,
  }) {
    return APIObservableGauge<T>(
      name,
      description,
      unit,
      enabled,
      meter,
      callback,
    );
  }
}
