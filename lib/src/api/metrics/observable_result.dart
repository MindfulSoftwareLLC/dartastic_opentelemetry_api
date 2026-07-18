// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import '../common/attributes.dart';
import 'measurement.dart';

/// Interface for recording observations from observable instruments.
///
/// Implementations are provided by SDKs (the previous API-side
/// implementation had a private constructor and no factory, so it was
/// unconstructible).
abstract class APIObservableResult<T extends num> {
  /// Records a measurement with the given value and attributes.
  void observe(T value, [Attributes? attributes]);

  /// Records a measurement with the given value and attributes as a map.
  void observeWithMap(T value, Map<String, Object> attributes);

  /// Get all recorded measurements
  List<Measurement<T>> get measurements;
}
