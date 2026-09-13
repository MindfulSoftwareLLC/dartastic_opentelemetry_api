// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'observable_counter.dart';

/// Factory methods for creating [APIObservableCounter] instances.
/// This is part of the observable_counter.dart file to keep related code together.
@internal
class ObservableCounterCreate {
  /// Creates a new [APIObservableCounter] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createObservableCounter()] instead.
  static APIObservableCounter<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required APIMeter meter,
    InstrumentAdvisory? advisory,
    List<ObservableCallback<T>> callbacks = const [],
  }) {
    return APIObservableCounter<T>(
      name,
      description,
      unit,
      meter,
      advisory,
      callbacks,
    );
  }
}
