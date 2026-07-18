// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';

import '../../factory/otel_factory.dart';
import '../../util/otel_log.dart';
import 'baggage_entry.dart';

part 'baggage_create.dart';

/// Immutable Baggage that stores entries with unique string keys.
///
/// Baggage is immutable. Adding or removing entries returns a new instance.
/// The specification states that if an entry is added with a key that already
/// exists, it MUST overwrite the existing entry.
@immutable
class Baggage {
  final Map<String, BaggageEntry> _entries;

  /// Creates a new baggage instance. The provided entries map is copied
  /// and made immutable to ensure baggage immutability. Defaults to empty.
  /// Names must be non-empty per spec; entries with empty names are
  /// ignored and logged. Values may be any valid UTF-8 string, per spec.
  Baggage._([Map<String, BaggageEntry>? entries])
      : _entries = Map.unmodifiable(Map<String, BaggageEntry>.fromEntries(
            (entries ?? {}).entries.where((e) {
          if (e.key.isEmpty) {
            OTelLog.warn('Baggage names must be non-empty; entry ignored.');
            return false;
          }
          return true;
        })));

  /// Retrieves a BaggageEntry for the given key, or `null` if not present.
  BaggageEntry? getEntry(String key) => _entries[key];

  /// Returns all entries in this Baggage as an immutable map.
  Map<String, BaggageEntry> getAllEntries() => _entries;

  /// Retrieves a Baggage value for the given key, or `null` if not present.
  String? getValue(String key) => _entries[key]?.value;

  /// Retrieves all Baggage values for the given key, or `null` if not present.
  List<String> getAllValues() =>
      _entries.values.map((entry) => entry.value).toList();

  /// Operator overload for getting a value
  String? operator [](String key) => getValue(key);

  /// Creates a new Context adding in [moreBaggage], replacing any existing
  /// keys that are the same as the keys in [moreBaggage]
  Baggage copyWithBaggage(Baggage moreBaggage) {
    final combined = {..._entries, ...moreBaggage._entries};
    return OTelFactory.getOrCreateDefault().baggage(combined);
  }

  /// Returns a new Baggage with the given key-value pair added (or replaced).
  /// Names must be non-empty per spec; an empty name is ignored and logged.
  Baggage copyWith(String key, String value, [String? metadata]) {
    if (key.isEmpty) {
      OTelLog.warn('Baggage names must be non-empty; entry ignored.');
      return this;
    }
    final factory = OTelFactory.getOrCreateDefault();
    final updated = Map.of(_entries)
      ..[key] = factory.baggageEntry(value, metadata);
    return factory.baggage(updated);
  }

  /// Returns a new Baggage with the given key removed (if it exists).
  Baggage copyWithout(String key) {
    if (!_entries.containsKey(key)) return this;
    final updated = Map.of(_entries)..remove(key);
    return OTelFactory.getOrCreateDefault().baggage(updated);
  }

  /// Converts the baggage to a JSON representation.
  Map<String, dynamic> toJson() {
    return Map.fromEntries(_entries.entries.map((entry) {
      return MapEntry(entry.key, {
        'value': entry.value.value,
        if (entry.value.metadata != null) 'metadata': entry.value.metadata,
      });
    }));
  }

  /// Creates a baggage instance from a JSON representation.
  /// JSON format must be: { key: { value: string, metadata?: string } }
  factory Baggage.fromJson(Map<String, dynamic> json) {
    final factory = OTelFactory.getOrCreateDefault();
    final entries = <String, BaggageEntry>{};
    for (final entry in json.entries) {
      if (entry.value is Map) {
        final value = entry.value as Map;
        // Try to get the value field first
        final rawValue = value['value'];
        if (rawValue is! String) {
          continue; // Skip entries with non-string values
        }
        final metadata = value['metadata'];
        if (metadata != null && metadata is! String) {
          continue; // Skip entries with non-string metadata
        }
        entries[entry.key] = factory.baggageEntry(
          rawValue,
          metadata as String?,
        );
      }
    }
    return factory.baggage(entries);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Baggage && _mapEquals(_entries, other._entries));
  }

  @override
  int get hashCode {
    return _entries.entries.fold(0, (hash, entry) {
      final entryHash = Object.hash(
          entry.key, Object.hash(entry.value.value, entry.value.metadata));
      return hash ^ entryHash;
    });
  }

  /// Returns true if this Baggage contains no entries.
  bool get isEmpty => _entries.isEmpty;

  /// Utility method to compare two maps of [BaggageEntry] objects.
  /// Returns true if both maps have the same keys and values.
  bool _mapEquals(Map<String, BaggageEntry> a, Map<String, BaggageEntry> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() => 'Baggage($_entries)';
}
