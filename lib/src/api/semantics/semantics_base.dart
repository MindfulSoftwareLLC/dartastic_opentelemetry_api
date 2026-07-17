// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// Base interfaces for the OpenTelemetry semantic-convention enums.
///
/// The generated per-namespace enums under `semconv/` (attribute keys,
/// attribute values, metrics, events, and entities) all implement one of
/// the interfaces in this file. Consumers can also implement
/// [OTelSemantic] on their own app-specific enums to mix them into
/// `OTelAPI.attributesFromSemanticMap`.
library;

/// Base interface for OpenTelemetry semantic-convention attribute-key
/// enums. Every generated attribute-key enum implements this; consumers
/// can also implement it on their own app-specific enums to mix into
/// `attributesFromSemanticMap`.
abstract class OTelSemantic {
  /// The attribute key string as defined in the OpenTelemetry specification.
  final String key;

  /// Base const constructor.
  const OTelSemantic(this.key);

  @override
  String toString() => key;
}

/// Extension on [OTelSemantic] to provide utility methods.
extension OTelSemanticExtension on OTelSemantic {
  /// Converts this semantic attribute and its value to a `MapEntry`.
  MapEntry<String, Object> toMapEntry(Object value) => MapEntry(key, value);
}

/// Marker on every string-valued value enum — exposes the on-wire string
/// [value] and a `toString()` that returns it. Modeled on the same shape
/// as [OTelSemantic], but kept separate because these are *values*, not
/// keys.
abstract interface class OTelSemanticValue {
  /// The on-wire attribute value string.
  String get value;
}

/// Marker on every int-valued value enum (e.g. the values of
/// `cpython.gc.generation`) — exposes the on-wire integer [value].
abstract interface class OTelSemanticIntValue {
  /// The on-wire attribute value integer.
  int get value;
}

/// The four OTel instrument kinds.
enum SemanticInstrument { counter, upDownCounter, histogram, gauge }

/// Base interface for metric-name enums.
abstract interface class OTelMetric {
  /// The on-wire metric name (e.g. `http.server.request.duration`).
  String get name;

  /// The OTel instrument kind the spec assigns to this metric.
  SemanticInstrument get instrument;

  /// OTel unit string (UCUM-style: `s` for seconds, `By` for bytes,
  /// `{request}` for a counted entity, `1` for dimensionless).
  String get unit;
}

/// Base interface for event-name enums.
abstract interface class OTelEvent {
  /// The on-wire event name (e.g. `exception`, `feature_flag.evaluation`).
  String get name;
}

/// Base interface for entity enums.
///
/// An entity models a resource the telemetry is about (`service`,
/// `k8s.pod`, `app`, …). Each entity carries the attribute keys that
/// identify it and the ones that merely describe it, wired to the
/// generated attribute-key enums so entities and attributes cannot
/// drift apart.
abstract interface class OTelEntity {
  /// The entity type string as defined in the registry (e.g. `k8s.pod`).
  String get name;

  /// Attributes with the registry role `identifying`.
  List<OTelSemantic> get identifying;

  /// Attributes with the registry role `descriptive` (the registry
  /// default when no role is given).
  List<OTelSemantic> get descriptive;
}
