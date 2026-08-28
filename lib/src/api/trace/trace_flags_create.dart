// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'trace_flags.dart';

/// Internal constructor access for TraceFlags
@internal
class TraceFlagsCreate {
  /// Creates a TraceFlags, only accessible within library
  ///
  /// [flags] The flags byte, defaults to NONE_FLAG. Only the low byte is kept.
  static TraceFlags create([int? flags]) {
    return TraceFlags._((flags ?? TraceFlags.NONE_FLAG) & 0xff);
  }
}
