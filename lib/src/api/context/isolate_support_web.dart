// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// Web platform implementation - no dart:isolate

/// Mocked version of the Isolate class for web platforms.
///
/// Since web platforms don't support true isolates, this class provides a simple
/// implementation that just runs code in the current context.
class Isolate {
  /// Web platform version of Isolate.run - runs synchronously in the same context
  /// since web doesn't support true isolates
  static Future<T> run<T>(Future<T> Function() computation) async {
    // For web, we simply run the computation directly
    return await computation();
  }
}

/// Runs a computation with the given context in a web environment.
/// For web, this just runs the computation directly, as true isolates
/// are not supported in web platforms.
Future<T> runIsolateComputation<T>(
    Future<T> Function() computation,
    Map<String, dynamic> serializedContext,
    Map<String, dynamic> serializedFactory,
    Function factoryFactory) async {
  // On web, we just run the computation in the current context
  return await computation();
}
