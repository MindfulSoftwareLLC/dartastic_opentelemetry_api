// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// A point in a time series of metric data.
/// In the API, this is a minimal implementation mostly for interface purposes.
class MetricPoint {
  /// The timestamp when this point was recorded.
  final DateTime timestamp;

  /// The value recorded at this point.
  final num value;

  /// The attributes associated with this point.
  final Attributes attributes;

  /// Creates a new metric point with the specified timestamp, value, and attributes.
  MetricPoint({
    required this.timestamp,
    required this.value,
    required this.attributes,
  });
}
