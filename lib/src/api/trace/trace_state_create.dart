// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'trace_state.dart';

/// Internal constructor access for TraceState
class TraceStateCreate {
  /// Creates a TraceState, only accessible within library
  /// Enforces 32 key-value pair limit per W3C spec
  static TraceState create(Map<String, String>? entries) {
    if (entries == null || entries.isEmpty) {
      return TraceState._({});
    }

    // Enforce 32 key-value pair limit
    if (entries.length > 32) {
      // Take only the first 32 entries
      final limitedEntries = <String, String>{};
      var count = 0;

      for (final entry in entries.entries) {
        if (count >= 32) break;

        limitedEntries[entry.key] = entry.value;
        count++;
      }

      return TraceState._(limitedEntries);
    }

    return TraceState._(entries);
  }
}
