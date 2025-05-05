// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'context.dart';

/// Factory class for creating Context instances.
///
/// This is a part of the Context library and not meant to be used directly.
class ContextCreate {
  /// Creates a new Context with the given context map and optional baggage.
  ///
  /// If baggage is provided, it will be added to the context map.
  static Context create(
      {Map<ContextKey<Object?>, Object?>? contextMap, Baggage? baggage}) {
    if (baggage != null) {
      (contextMap ??= {})[Context._baggageKey] = baggage;
    }
    return Context._(contextMap);
  }
}
