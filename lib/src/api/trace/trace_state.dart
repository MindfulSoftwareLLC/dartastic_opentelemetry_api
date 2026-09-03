// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';
import '../../factory/otel_factory.dart';
import '../../util/otel_error_handler.dart';

part 'trace_state_create.dart';

/// Key-value pairs carried along with a span context.
/// TraceState follows the W3C Trace Context specification.
///
/// Size policy: the grammar limits (W3C §3.3.1.1) — a maximum of 32
/// list-members and the per-key/per-value length rules — are enforced on
/// every path. [toString] serializes exactly what the state holds and
/// does not truncate beyond them; [toHeaderString] applies the §3.3.1.5
/// truncation procedure for callers that need a bounded header value.
/// Vendors SHOULD propagate at least 512 characters of the combined
/// header, so 512 is a floor the procedure keeps whole entries within,
/// not a ceiling imposed on the state itself.
class TraceState {
  static const int _maxKeyValuePairs = 32;
  static final RegExp _simpleKeyFormat = RegExp(r'^[a-z][a-z0-9_\-*/]{0,255}$');
  static final RegExp _tenantIdFormat =
      RegExp(r'^[a-z0-9][a-z0-9_\-*/]{0,240}$');
  static final RegExp _systemIdFormat = RegExp(r'^[a-z][a-z0-9_\-*/]{0,13}$');
  static final RegExp _valueFormat = RegExp(
      r'^[\x20-\x2b\x2d-\x3c\x3e-\x7e]{0,255}[\x21-\x2b\x2d-\x3c\x3e-\x7e]$');

  late final Map<String, String> _entries;

  TraceState._(Map<String, String>? entries) {
    _entries = entries ?? {};
  }

  /// Create TraceState from a W3C trace context header string
  factory TraceState.fromString(String? headerValue) {
    final factory = OTelFactory.getOrCreateDefault();
    if (headerValue == null || headerValue.isEmpty) {
      return factory.traceState({});
    }

    final entries = <String, String>{};
    final pairs = headerValue.split(',');

    for (var pair in pairs) {
      final keyValue = pair.trim().split('=');
      if (keyValue.length == 2 &&
          _isValidKey(keyValue[0]) &&
          _isValidValue(keyValue[1])) {
        entries[keyValue[0]] = keyValue[1];
        if (entries.length >= _maxKeyValuePairs) break;
      }
    }

    return factory.traceState(entries);
  }

  /// Creates a new [TraceState] from a list of key-value pairs.
  factory TraceState.fromMap(Map<String, String> entries) {
    return OTelFactory.getOrCreateDefault().traceState(entries);
  }

  /// Creates an empty [TraceState].
  factory TraceState.empty() {
    return OTelFactory.getOrCreateDefault().traceState({});
  }

  /// Returns an unmodifiable view of all key-value entries in this trace state.
  ///
  /// The returned map cannot be modified, so changes to trace state must be made
  /// through the put() and remove() methods.
  Map<String, String> get entries => Map.unmodifiable(_entries);

  /// Returns the value for the given key, or null if not present.
  String? get(String key) => _entries[key];

  /// Returns true if there are no entries.
  bool get isEmpty => _entries.isEmpty;

  /// Returns an immutable map of the key-value pairs in this trace state.
  Map<String, String> asMap() => Map.unmodifiable(_entries);

  ///  Creates a new [TraceState] with the given key-value pair added.
  ///  If adding this pair would exceed the 32 key-value pair limit,
  ///  the oldest entries are removed to make room.
  TraceState put(String key, String value) {
    if (!_isValidKey(key) || !_isValidValue(value)) {
      OTelErrorHandling.report(
          ArgumentError('Invalid TraceState key or value; entry ignored.'));
      return this;
    }
    final factory = OTelFactory.getOrCreateDefault();

    final newEntries = Map<String, String>.from(_entries);

    // If we already have this key, just update its value
    if (newEntries.containsKey(key)) {
      newEntries[key] = value;
      return factory.traceState(newEntries);
    }

    // If adding a new key would exceed the limit, remove the oldest entry
    if (newEntries.length >= _maxKeyValuePairs) {
      // Remove the first key to make room
      if (newEntries.isNotEmpty) {
        final oldestKey = newEntries.keys.first;
        newEntries.remove(oldestKey);
      }
    }

    newEntries[key] = value;
    return factory.traceState(newEntries);
  }

  ///  Creates a new [TraceState] with the given [key] removed.
  TraceState remove(String key) {
    if (!_entries.containsKey(key)) return this;

    final newEntries = Map<String, String>.from(_entries);
    newEntries.remove(key);
    return OTelFactory.getOrCreateDefault().traceState(newEntries);
  }

  /// Convert to W3C trace context header string
  @override
  String toString() {
    return _entries.entries.map((e) => '${e.key}=${e.value}').join(',');
  }

  /// Produces the W3C `tracestate` header value, applying the truncation
  /// procedure of W3C Trace Context §3.3.1.5.
  ///
  /// Entries over 128 characters are removed first, then entries are removed
  /// from the end until the joined value fits the 512-character budget.
  /// Only whole entries are removed, and every dropped entry is reported
  /// through [OTelErrorHandling]. Unlike [toString], this may return a value
  /// that no longer contains all entries.
  String toHeaderString() {
    final entries = List<MapEntry<String, String>>.from(_entries.entries);

    // W3C §3.3.1.5: entries larger than 128 characters should be removed
    // first. The length of a list-member is its `key=value` size.
    final overlong = entries
        .where((e) => '${e.key}=${e.value}'.length > 128)
        .toList(growable: false);
    for (final entry in overlong) {
      entries.remove(entry);
      OTelErrorHandling.report(StateError(
          'TraceState entry ${entry.key} exceeds 128 characters; dropped.'));
    }

    // Then entries should be removed starting from the end of the
    // tracestate until the value fits the 512-character budget.
    var value = entries.map((e) => '${e.key}=${e.value}').join(',');
    while (value.length > 512 && entries.isNotEmpty) {
      final entry = entries.removeLast();
      OTelErrorHandling.report(StateError(
          'TraceState exceeds 512 characters; entry ${entry.key} dropped.'));
      value = entries.map((e) => '${e.key}=${e.value}').join(',');
    }

    return value;
  }

  /// Validate a tracestate key: a simple key, or a multi-tenant
  /// `tenant-id@system-id` key.
  static bool _isValidKey(String key) {
    final atIndex = key.indexOf('@');
    if (atIndex != -1) {
      if (atIndex != key.lastIndexOf('@')) return false;
      final tenant = key.substring(0, atIndex);
      final system = key.substring(atIndex + 1);
      return _tenantIdFormat.hasMatch(tenant) &&
          _systemIdFormat.hasMatch(system);
    }
    return _simpleKeyFormat.hasMatch(key);
  }

  /// Validate value format
  static bool _isValidValue(String value) {
    return _valueFormat.hasMatch(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraceState &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => toString().hashCode;
}
