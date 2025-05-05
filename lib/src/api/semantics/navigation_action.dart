// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// Navigation actions in a UI context
enum NavigationAction {
  /// Navigation to a new screen via push
  push('push'),

  /// Navigation back via pop
  pop('pop'),

  /// Replace current screen
  replace('replace'),

  /// Remove a screen from navigation stack
  remove('remove'),

  /// Return to a previous screen that's still in the stack
  returnTo('return_to'),

  /// Initial route when app starts
  initial('initial'),

  /// Deep link navigation
  deepLink('deep_link'),

  /// Redirect to another route
  redirect('redirect');

  /// String representation of the navigation action, used for serialization.
  final String value;
  const NavigationAction(this.value);

  @override
  String toString() => value;
}
