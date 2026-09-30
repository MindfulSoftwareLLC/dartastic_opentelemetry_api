// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'observable_up_down_counter.dart';

/// Factory methods for creating [APIObservableUpDownCounter] instances.
/// This is part of the observable_up_down_counter.dart file to keep related code together.
@internal
class ObservableUpDownCounterCreate<T extends num> {
  /// Creates a new [APIObservableUpDownCounter] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createObservableUpDownCounter()] instead.
  static APIObservableUpDownCounter<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required APIMeter meter,
    InstrumentAdvisory? advisory,
    List<ObservableCallback<T>> callbacks = const [],
  }) {
    return APIObservableUpDownCounter<T>(
      name,
      description,
      unit,
      meter,
      advisory,
      callbacks,
    );
  }
}
