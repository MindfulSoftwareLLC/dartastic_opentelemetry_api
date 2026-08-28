// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import '../common/attributes.dart';

/// Callback for batch observations across multiple instruments.
typedef BatchObservableCallback = void Function(BatchObservableResult result);

/// Passed to a [BatchObservableCallback] to record observations.
///
/// The observe method accepts [num] (not a generic T) because a single
/// batch callback may observe across instruments with different numeric
/// types (e.g., `Counter<int>` and `Gauge<double>`). The no-op API layer
/// does not validate the value type; the SDK may runtime-check it.
abstract class BatchObservableResult {
  /// Records a measurement for [instrument] with [value] and optional [attributes].
  void observe(dynamic instrument, num value, [Attributes? attributes]);
}

/// Registration handle returned by [APIMeter.registerBatchCallback].
abstract class APIBatchCallbackRegistration {
  /// Removes the batch callback. After this call the callback will not fire.
  void unregister();
}
