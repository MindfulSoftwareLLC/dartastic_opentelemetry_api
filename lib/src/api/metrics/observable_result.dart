// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// Interface for recording observations from observable instruments.
class APIObservableResult<T extends num> {
  List<Measurement<T>>? _measurements;

  APIObservableResult._(this._measurements);

  /// Records a measurement with the given value and attributes.
  void observe(T value, [Attributes? attributes]) {
    _measurements ??= [];
    _measurements!
        .add(OTelFactory.otelFactory!.createMeasurement(value, attributes));
  }

  /// Records a measurement with the given value and attributes as a map.
  void observeWithMap(T value, Map<String, Object> attributes) {
    observe(value, attributes.toAttributes());
  }

  /// Get all recorded measurements
  List<Measurement<T>> get measurements =>
      List.unmodifiable(_measurements ?? []);
}
