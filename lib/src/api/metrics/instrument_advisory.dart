// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// Advisory parameters for metric instrument creation.
///
/// Advisory parameters are hints from the instrument author to the SDK.
/// SDKs MAY ignore them. Views always take precedence over advisories.
class InstrumentAdvisory {
  /// Recommended bucket boundaries for Histogram aggregation.
  /// Status: Stable. Applies to Histogram instruments only.
  final List<double>? explicitBucketBoundaries;

  /// Recommended set of attribute keys for the resulting metrics.
  /// Status: Development. Applies to all instrument types.
  final List<String>? attributeKeys;

  const InstrumentAdvisory({
    this.explicitBucketBoundaries,
    this.attributeKeys,
  });
}
