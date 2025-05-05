// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'baggage_entry.dart';

/// Factory for creating BaggageEntry instances.
/// This is used internally by the OpenTelemetry API implementation.
class BaggageEntryFactory {
  /// Creates a new BaggageEntry with the specified value and optional metadata.
  ///
  /// @param value The baggage entry value.
  /// @param metadata Optional metadata associated with this entry.
  /// @return A new BaggageEntry instance.
  static BaggageEntry create<T>(String value, [String? metadata]) {
    return BaggageEntry._(value, metadata);
  }
}
