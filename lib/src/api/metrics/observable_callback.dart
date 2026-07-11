// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'observable_result.dart';

/// A callback function for observable instruments.
typedef ObservableCallback<T extends num> = void Function(
    APIObservableResult<T> result);

/// A registration for an observable callback.
abstract class APICallbackRegistration<T extends num> {
  /// Unregisters the callback from the instrument.
  void unregister();
}
