// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'trace_flags.dart';

/// Internal constructor access for TraceFlags
@internal
class TraceFlagsCreate {
  /// Creates a TraceFlags, only accessible within library
  static TraceFlags create([int? flags]) {
    return TraceFlags._(flags ?? TraceFlags.NONE_FLAG);
  }
}
