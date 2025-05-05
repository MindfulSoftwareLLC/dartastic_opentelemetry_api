// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'trace_flags.dart';

/// Internal constructor access for TraceFlags
class TraceFlagsCreate {
  /// Creates a TraceFlags, only accessible within library
  static TraceFlags create([int? flags]) {
    return TraceFlags._(flags ?? TraceFlags.NONE_FLAG);
  }
}
