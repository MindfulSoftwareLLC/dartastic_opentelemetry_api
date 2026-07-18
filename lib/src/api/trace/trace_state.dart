// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import '../../factory/otel_factory.dart';
import '../../util/otel_log.dart';

part 'trace_state_create.dart';

/// Key-value pairs carried along with a span context.
/// TraceState follows the W3C Trace Context specification.
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
      OTelLog.warn('Invalid TraceState key or value; entry ignored.');
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
