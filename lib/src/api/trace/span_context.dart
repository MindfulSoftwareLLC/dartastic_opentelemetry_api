// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library span_context;

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

part 'span_context_create.dart';

/// Immutable representation of a SpanContext.
/// A SpanContext contains the state that must propagate to child Spans
/// and across process boundaries.
/// SpanContext follows the W3C Trace Context specification.
class SpanContext {
  /// The TraceId for this span context.
  ///
  /// This uniquely identifies the trace that this span belongs to.
  final TraceId traceId;

  /// The SpanId for this span context.
  ///
  /// This uniquely identifies this span within the trace.
  final SpanId spanId;

  /// The TraceFlags for this span context.
  ///
  /// This contains the sampling bit and other flags that control tracing behavior.
  final TraceFlags traceFlags;

  /// The TraceState for this span context.
  ///
  /// This contains vendor-specific trace information represented as a list of key-value pairs.
  final TraceState? traceState;

  /// The parent SpanId for this span context, if any.
  ///
  /// For root spans, this will be null.
  final SpanId? parentSpanId;

  /// Whether this span context was propagated from a remote parent.
  ///
  /// Used to identify spans that cross process boundaries.
  final bool _isRemote;

  SpanContext._({
    required this.traceId,
    required this.traceFlags,
    required this.spanId,
    this.parentSpanId,
    this.traceState,
    bool isRemote = false,
  }) : _isRemote = isRemote;

  /// Returns true if this span context is valid.
  ///
  /// A span context is valid if both the traceId and spanId are valid (non-zero).
  bool get isValid => traceId.isValid && spanId.isValid;

  /// Returns true if this span context was propagated from a remote parent.
  bool get isRemote => _isRemote;

  /// Creates a new SpanContext with updated trace flags.
  ///
  /// This creates a copy of this span context with the trace flags updated to the specified value.
  ///
  /// [flags] The new trace flags to use.
  /// Returns a new SpanContext with the updated trace flags.
  SpanContext withTraceFlags(TraceFlags flags) {
    return OTelAPI.spanContext(
      traceId: traceId,
      spanId: spanId,
      parentSpanId: parentSpanId,
      traceFlags: flags,
      traceState: traceState,
      isRemote: _isRemote,
    );
  }

  /// Creates a new SpanContext with updated trace state.
  ///
  /// This creates a copy of this span context with the trace state updated to the specified value.
  ///
  /// [state] The new trace state to use.
  /// Returns a new SpanContext with the updated trace state.
  SpanContext withTraceState(TraceState state) {
    return OTelAPI.spanContext(
      traceId: traceId,
      spanId: spanId,
      parentSpanId: parentSpanId,
      traceFlags: traceFlags,
      traceState: state,
      isRemote: _isRemote,
    );
  }

  /// Converts this SpanContext to a JSON-serializable map.
  ///
  /// This method is used for serializing the SpanContext when passing it across process boundaries.
  /// The map can be deserialized back into a SpanContext using `fromJson`.
  Map<String, dynamic> toJson() {
    final jsonMap = {
      'traceId': traceId.toString(),
      'spanId': spanId.toString(),
      'traceFlags': traceFlags.asByte,
      'isRemote': _isRemote,
    };

    // Always include parentSpanId
    if (parentSpanId != null) {
      jsonMap['parentSpanId'] = parentSpanId!.toString();
    }

    if (traceState != null) {
      jsonMap['traceState'] = traceState!.entries;
    }

    return jsonMap;
  }

  /// Creates a SpanContext instance from a JSON representation.
  ///
  /// This deserializes a SpanContext previously serialized with `toJson()`.
  ///
  /// [json] A map containing the serialized SpanContext properties.
  /// Returns a new SpanContext initialized with the values from the JSON map.
  factory SpanContext.fromJson(Map<String, dynamic> json) {
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }

    SpanId? parentSpanId;
    if (json['parentSpanId'] != null) {
      final parentId = OTelAPI.spanIdFrom(json['parentSpanId'] as String);
      // Only set parentSpanId if it's valid (not all zeros)
      if (parentId.isValid) {
        parentSpanId = parentId;
      }
    }

    return OTelAPI.spanContext(
      traceId: OTelAPI.traceIdFrom(json['traceId'] as String),
      spanId: OTelAPI.spanIdFrom(json['spanId'] as String),
      parentSpanId: parentSpanId,
      traceFlags:
          OTelFactory.otelFactory!.traceFlags(json['traceFlags'] as int),
      traceState: OTelFactory.otelFactory!
          .traceState(json['traceState'] as Map<String, String>? ?? {}),
      isRemote: json['isRemote'] as bool,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanContext &&
          runtimeType == other.runtimeType &&
          traceId == other.traceId &&
          spanId == other.spanId &&
          parentSpanId == other.parentSpanId &&
          traceFlags == other.traceFlags &&
          traceState == other.traceState &&
          _isRemote == other._isRemote;

  @override
  int get hashCode =>
      traceId.hashCode ^
      spanId.hashCode ^
      (parentSpanId?.hashCode ?? 0) ^
      traceFlags.hashCode ^
      (traceState?.hashCode ?? 0) ^
      _isRemote.hashCode;

  @override
  String toString() {
    return 'SpanContext{traceId: $traceId, spanId: $spanId, parentSpanId: $parentSpanId, traceFlags: $traceFlags, traceState: $traceState, isRemote: $_isRemote}';
  }
}
