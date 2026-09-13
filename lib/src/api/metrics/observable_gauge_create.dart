// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'observable_gauge.dart';

/// Factory methods for creating [APIObservableGauge] instances.
/// This is part of the observable_gauge.dart file to keep related code together.
@internal
class ObservableGaugeCreate {
  /// Creates a new [APIObservableGauge] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createObservableGauge()] instead.
  static APIObservableGauge<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required APIMeter meter,
    InstrumentAdvisory? advisory,
    List<ObservableCallback<T>> callbacks = const [],
  }) {
    return APIObservableGauge<T>(
      name,
      description,
      unit,
      meter,
      advisory,
      callbacks,
    );
  }
}
