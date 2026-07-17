// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'span.dart';

/// A non-recording [APISpan] that carries a [SpanContext] without
/// recording anything.
///
/// This is the span the OpenTelemetry specification requires in two
/// places (trace/api.md):
///
/// - "Wrapping a SpanContext in a Span": "The API MUST provide an
///   operation for wrapping a `SpanContext` with an object implementing
///   the `Span` interface. [...] SHOULD be named `NonRecordingSpan`."
///   `getContext` (the [spanContext] getter) returns the wrapped
///   context, [isRecording] returns `false`, and all other operations
///   are no-ops.
/// - "Behavior of the API in the absence of an installed SDK": the API
///   returns a non-recording span carrying the `SpanContext` from the
///   parent `Context` unchanged, or an empty one (all-zero IDs, empty
///   `TraceState`, unsampled `TraceFlags`) when the context has no span.
///
/// Unlike other spans, a [NonRecordingSpan] may carry an invalid
/// (all-zero) [SpanContext].
class NonRecordingSpan extends APISpan {
  /// Wraps [spanContext] in a non-recording span.
  ///
  /// Also available as `OTelAPI.nonRecordingSpan`. [OTelAPI.initialize]
  /// must have been called first.
  factory NonRecordingSpan(SpanContext spanContext) {
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    return NonRecordingSpan._(
      spanContext: spanContext,
      instrumentationScope:
          InstrumentationScopeCreate.create(name: 'noop-tracer'),
      attributes: OTelFactory.otelFactory!.attributes(),
    );
  }

  NonRecordingSpan._({
    required super.spanContext,
    required super.instrumentationScope,
    required super.attributes,
  }) : super._(name: '');

  /// Always `false`: this span never records, per the spec.
  @override
  bool get isRecording => false;

  /// Never modifiable: every mutating operation is a no-op, per the
  /// spec ("all other operations MUST be no-op").
  @override
  bool get _modifiable => false;
}
