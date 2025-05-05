// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'observable_result.dart';

/// A callback function for observable instruments.
typedef ObservableCallback<T extends num> = void Function(
    APIObservableResult<T> result);

/// A registration for an observable callback.
abstract class APICallbackRegistration<T extends num> {
  /// Unregisters the callback from the instrument.
  void unregister();
}
