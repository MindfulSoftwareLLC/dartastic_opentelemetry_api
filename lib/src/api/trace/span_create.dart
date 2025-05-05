// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'span.dart';

/// Internal constructor access for Span
class APISpanCreate {
  /// Creates a new APISpan instance with the specified parameters.
  /// This constructor is only accessible within the library and is used by the internal factory methods.
  /// Users should create spans using Tracer.startSpan() instead of using this directly.
  ///
  /// @param name The name of the span
  /// @param spanContext The span context for this span
  /// @param parentSpan Optional parent span, if this is a child span
  /// @param instrumentationScope The instrumentation scope that created this span
  /// @param spanKind The kind of span (client, server, etc)
  /// @param attributes Optional initial attributes for the span
  /// @param links Optional span links to other spans
  /// @param spanEvents Optional initial events for the span
  /// @param startTime Optional start time, defaults to now
  /// @param isRecording Whether this span should record data
  static APISpan create({
    required String name,
    required SpanContext spanContext,
    required APISpan? parentSpan,
    required InstrumentationScope instrumentationScope,
    SpanKind spanKind = SpanKind.internal,
    Attributes? attributes,
    List<SpanLink>? links,
    List<SpanEvent>? spanEvents,
    DateTime? startTime,
    bool isRecording = true,
  }) {
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    // SpanContext is always required according to spec
    if (!spanContext.isValid) {
      throw ArgumentError('SpanContext must be valid for all spans');
    }

    if (parentSpan != null) {
      // Child span - MUST inherit trace ID
      if (spanContext.traceId != parentSpan.spanContext.traceId) {
        throw ArgumentError('Child span must inherit trace ID from parent');
      }
      // MUST reference parent span ID
      if (spanContext.parentSpanId != parentSpan.spanContext.spanId) {
        throw ArgumentError('Child span must reference parent span ID');
      }
    } else {
      // Root spans should have an invalid (all zeros) parent span ID
      if (spanContext.parentSpanId != null &&
          spanContext.parentSpanId!.bytes == SpanId.invalidSpanIdBytes) {
        throw ArgumentError(
            'Root spans must have invalid (all zeros) parent span ID or no parent span ID');
      }
    }
    return APISpan._(
        name: name,
        spanContext: spanContext,
        parentSpan: parentSpan,
        spanKind: spanKind,
        instrumentationScope: instrumentationScope,
        attributes: attributes ?? OTelFactory.otelFactory!.attributes(),
        spanLinks: links,
        startTime: startTime,
        spanEvents: spanEvents);
  }
}
