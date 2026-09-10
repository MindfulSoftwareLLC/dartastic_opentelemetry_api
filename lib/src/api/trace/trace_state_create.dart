// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'trace_state.dart';

/// Internal constructor access for TraceState
@internal
class TraceStateCreate {
  /// Creates a TraceState, only accessible within library.
  /// Enforces the W3C 32 key-value pair limit. Entries with an invalid key
  /// or value are dropped and reported via [OTelErrorHandling.report]
  /// rather than throwing, per trace/api.md.
  static TraceState create(Map<String, String>? entries) {
    if (entries == null || entries.isEmpty) {
      return TraceState._({});
    }

    final validEntries = <String, String>{};
    for (final entry in entries.entries) {
      if (validEntries.length >= 32) break;
      if (TraceState._isValidKey(entry.key) &&
          TraceState._isValidValue(entry.value)) {
        validEntries[entry.key] = entry.value;
      } else {
        OTelErrorHandling.report(ArgumentError(
            'Invalid TraceState key or value: "${entry.key}"; entry dropped.'));
      }
    }

    return TraceState._(validEntries);
  }
}
