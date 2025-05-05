// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// Application lifecycle states
enum LifecycleState {
  /// App is visible and responding to user input
  resumed('resumed'),

  /// App is visible but not responding to user input
  inactive('inactive'),

  /// App is not visible (in the background)
  paused('paused'),

  /// App is being shut down or detached from Flutter engine
  detached('detached');

  /// String representation of the lifecycle state, used for serialization.
  final String value;
  const LifecycleState(this.value);

  @override
  String toString() => value;
}
