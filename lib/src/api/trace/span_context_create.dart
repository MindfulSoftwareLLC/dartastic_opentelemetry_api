// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'span_context.dart';

/// Internal constructor access for Span
@internal
class SpanContextCreate {
  /// Creates a Span, only accessible within library
  static SpanContext create({
    TraceId? traceId,
    SpanId? spanId,
    SpanId? parentSpanId,
    TraceFlags? traceFlags,
    TraceState? traceState,
    bool? isRemote = false,
  }) {
    // For root spans, ensure the parentSpanId is set to zeros (invalid span ID)
    final effectiveParentSpanId =
        parentSpanId ?? OTelFactory.otelFactory!.spanIdInvalid();

    return SpanContext._(
        traceId: traceId ?? OTelFactory.otelFactory!.traceId(),
        spanId: spanId ?? OTelFactory.otelFactory!.spanId(),
        parentSpanId: effectiveParentSpanId,
        traceFlags: traceFlags ?? OTelFactory.otelFactory!.traceFlags(),
        traceState: traceState,
        isRemote: isRemote ?? false);
  }
}
