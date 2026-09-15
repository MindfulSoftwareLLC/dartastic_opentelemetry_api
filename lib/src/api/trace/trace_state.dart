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

  /// Creates a TraceState from a W3C trace context header string.
  ///
  /// The parser drops a list member that breaks the W3C grammar. The result
  /// holds only the entries that this package can send on again.
  ///
  /// Only one entry per key is allowed, because the entry represents that
  /// last position in the trace; vendors must overwrite their entry upon
  /// reentry to their tracing system. If a key repeats, the parser keeps the
  /// first entry and drops the later ones.
  ///
  /// A member with an invalid key or value is reported to the error handler
  /// (see `OTelAPI.setErrorHandler`) and dropped.
  ///
  /// An empty member and a whitespace-only member are dropped without a
  /// report. The W3C grammar allows them: `list-member = (key "=" value) / OWS`.
  ///
  /// The parser stops at the limit of 32 members.
  factory TraceState.fromString(String? headerValue) {
    final factory = OTelFactory.getOrCreateDefault();
    if (headerValue == null || headerValue.isEmpty) {
      return factory.traceState({});
    }

    final entries = <String, String>{};
    final pairs = headerValue.split(',');

    for (var pair in pairs) {
      final member = pair.trim();
      // W3C Trace Context allows an empty or a whitespace-only list member:
      // `list-member = (key "=" value) / OWS`. Such a member is not an error.
      if (member.isEmpty) continue;
      final keyValue = member.split('=');
      if (keyValue.length != 2 ||
          !_isValidKey(keyValue[0]) ||
          !_isValidValue(keyValue[1])) {
        OTelErrorHandling.report(ArgumentError(
            'Invalid TraceState list member "$pair"; entry ignored.'));
        continue;
      }
      // Only one entry per key is allowed, because the entry represents that
      // last position in the trace; vendors must overwrite their entry upon
      // reentry to their tracing system. The first entry stays and the later
      // ones are dropped.
      if (entries.containsKey(keyValue[0])) continue;
      entries[keyValue[0]] = keyValue[1];
      if (entries.length >= _maxKeyValuePairs) break;
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

  ///  Creates a new [TraceState] with the given key-value pair added or
  ///  updated. Per W3C Trace Context, the new or updated entry moves to
  ///  the beginning of the list; entries further to the right are older.
  ///  If adding this pair would exceed the 32 key-value pair limit, the
  ///  oldest (rightmost) entries are removed to make room.
  TraceState put(String key, String value) {
    if (!_isValidKey(key) || !_isValidValue(value)) {
      OTelErrorHandling.report(
          ArgumentError('Invalid TraceState key or value; entry ignored.'));
      return this;
    }
    final factory = OTelFactory.getOrCreateDefault();

    // Per W3C Trace Context, an updated or new entry moves to the front
    // (left) of the list, so build the new map starting with it.
    final newEntries = <String, String>{key: value};
    for (final entry in _entries.entries) {
      if (entry.key == key) continue;
      if (newEntries.length >= _maxKeyValuePairs) {
        // Cap reached; remaining entries are older (further right) and
        // are evicted.
        break;
      }
      newEntries[entry.key] = entry.value;
    }
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
  /// The procedure only runs when the value needs to be truncated: if the
  /// joined value fits the 512-character budget it is returned as-is,
  /// including entries over 128 characters. When it does not fit, whole
  /// entries are removed, entries larger than 128 characters first, then
  /// entries from the end. Removals stop as soon as the value fits the
  /// budget, so no entry is dropped that the budget could still hold.
  /// Every dropped entry is reported through [OTelErrorHandling]. Unlike
  /// [toString], this may return a value that no longer contains all
  /// entries.
  String toHeaderString() {
    final entries = _entries.entries.toList(growable: false);
    final parts =
        entries.map((e) => '${e.key}=${e.value}').toList(growable: false);
    var length = parts.isEmpty
        ? 0
        : parts.fold<int>(0, (sum, part) => sum + part.length) +
            parts.length -
            1;
    if (length <= 512) {
      return parts.join(',');
    }

    // W3C §3.3.1.5: "Entries larger than 128 characters long SHOULD be
    // removed first", as part of truncating a value that does not fit.
    // The length of a list-member is its `key=value` size. Entries are
    // dropped in order only while the value is still over budget.
    final kept = List<bool>.filled(parts.length, true);
    var remaining = parts.length;
    for (var i = 0; i < parts.length && length > 512; i++) {
      if (parts[i].length <= 128) continue;
      kept[i] = false;
      remaining--;
      length = remaining == 0 ? 0 : length - parts[i].length - 1;
      OTelErrorHandling.report(StateError(
          'TraceState entry ${entries[i].key} exceeds 128 characters; '
          'dropped.'));
    }

    // Then entries should be removed starting from the end of the
    // tracestate until the value fits the 512-character budget.
    for (var i = parts.length - 1; i >= 0 && length > 512; i--) {
      if (!kept[i]) continue;
      kept[i] = false;
      remaining--;
      length = remaining == 0 ? 0 : length - parts[i].length - 1;
      OTelErrorHandling.report(StateError(
          'TraceState exceeds 512 characters; entry '
          '${entries[i].key} dropped.'));
    }

    final value = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (kept[i]) value.add(parts[i]);
    }
    return value.join(',');
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
