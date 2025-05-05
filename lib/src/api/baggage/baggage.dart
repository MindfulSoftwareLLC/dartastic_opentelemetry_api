// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:meta/meta.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

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
  Baggage._([Map<String, BaggageEntry>? entries])
      : _entries =
            Map.unmodifiable(Map<String, BaggageEntry>.from(entries ?? {})) {
    // Validate that no keys are empty strings
    for (final key in _entries.keys) {
      if (key.isEmpty) {
        throw ArgumentError('Baggage keys must not be empty strings');
      }
    }
    // Validate that no values are null
    for (final entry in _entries.values) {
      if (entry.value.isEmpty) {
        throw ArgumentError('Baggage values must not be empty strings');
      }
    }
  }

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
    return OTelFactory.otelFactory!.baggage(combined);
  }

  /// Returns a new Baggage with the given key-value pair added (or replaced).
  Baggage copyWith(String key, String value, [String? metadata]) {
    if (key.isEmpty) throw ArgumentError('Baggage key must not be empty');
    if (value.isEmpty) throw ArgumentError('Baggage value must not be empty');
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    final updated = Map.of(_entries)
      ..[key] = OTelFactory.otelFactory!.baggageEntry(value, metadata);
    return OTelFactory.otelFactory!.baggage(updated);
  }

  /// Returns a new Baggage with the given key removed (if it exists).
  Baggage copyWithout(String key) {
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    if (!_entries.containsKey(key)) return this;
    final updated = Map.of(_entries)..remove(key);
    return OTelFactory.otelFactory!.baggage(updated);
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
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    final entries = <String, BaggageEntry>{};
    for (final entry in json.entries) {
      if (entry.value is Map) {
        final value = entry.value as Map;
        // Try to get the value field first
        final rawValue = value['value'];
        if (rawValue is! String || rawValue.isEmpty) {
          continue; // Skip entries with non-string or empty values
        }
        final metadata = value['metadata'];
        if (metadata != null && metadata is! String) {
          continue; // Skip entries with non-string metadata
        }
        entries[entry.key] = OTelFactory.otelFactory!.baggageEntry(
          rawValue,
          metadata as String?,
        );
      }
    }
    return OTelFactory.otelFactory!.baggage(entries);
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
