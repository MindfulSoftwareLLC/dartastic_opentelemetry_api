// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:isolate';

export 'dart:isolate';

/// Runs a computation in a new isolate and returns the result.
/// This implementation uses the standard dart:isolate implementation.
Future<T> runIsolateComputation<T>(
    Future<T> Function() computation,
    Map<String, dynamic> serializedContext,
    Map<String, dynamic> serializedFactory,
    Function factoryFactory) async {
  return await Isolate.run(() async {
    // Actual implementation is in context.dart
    // This just re-exports dart:isolate for non-web platforms
    throw UnimplementedError(
        'runIsolateComputation should never be called directly');
  });
}
