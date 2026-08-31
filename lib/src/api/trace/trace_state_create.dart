// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'trace_state.dart';

/// Internal constructor access for TraceState
@internal
class TraceStateCreate {
  /// Drops invalid entries; keeps at most 32.
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
