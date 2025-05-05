// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'histogram.dart';

/// Factory methods for creating [APIHistogram] instances.
/// This is part of the histogram.dart file to keep related code together.
class HistogramCreate {
  /// Creates a new [APIHistogram] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createHistogram()] instead.
  static APIHistogram<T> create<T extends num>({
    required String name,
    String? unit,
    String? description,
    required bool enabled,
    required APIMeter meter,
    List<double>? boundaries,
  }) {
    return APIHistogram<T>(
      name,
      description,
      unit,
      enabled,
      meter,
      boundaries: boundaries,
    );
  }
}
