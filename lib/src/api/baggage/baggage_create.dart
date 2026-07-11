// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'baggage.dart';

/// Factory for creating Baggage instances.
/// This is used internally by the OpenTelemetry API implementation.
@internal
class BaggageCreate {
  /// Creates a new Baggage instance with the specified entries.
  ///
  /// @param entries Optional map of key-value pairs to include in the baggage.
  /// @return A new Baggage instance.
  static Baggage create<T>([Map<String, BaggageEntry>? entries]) {
    return Baggage._(entries);
  }
}
