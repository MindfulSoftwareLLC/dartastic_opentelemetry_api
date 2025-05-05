// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'context_key.dart';

/// Factory class for creating ContextKey instances.
///
/// This is a part of the Context library and not meant to be used directly.
class ContextKeyCreate<T> {
  /// Creates a new ContextKey with the specified name and unique identifier.
  ///
  /// [name] The name for the context key, used for debugging purposes
  /// [id] The unique identifier for this context key
  static ContextKey<T> create<T>(String name, Uint8List id) {
    return ContextKey<T>._(name, id);
  }
}
