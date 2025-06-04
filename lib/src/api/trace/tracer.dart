// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/trace/span_context.dart';
import 'package:dartastic_opentelemetry_api/src/api/trace/span_event.dart';
import 'package:dartastic_opentelemetry_api/src/factory/otel_factory.dart';

import '../common/attributes.dart';
import '../common/instrumentation_scope.dart';
import '../context/context.dart';
import 'span.dart';
import 'span_kind.dart';
import 'span_link.dart';

part 'tracer_create.dart';

/// Tracer is responsible for creating [APISpan]s and propagating context in-process.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the TracerProvider from the SDK instead.
class APITracer {
  /// Gets the name of the tracer, usually of a library, package or module
  final String name;

  /// Gets the version, usually of the instrumented library, package or module
  final String? version;

  /// Gets the schema URL of the tracer
  final String? schemaUrl;

  /// Optional attributes associated with this tracer.
  ///
  /// These attributes provide additional metadata about the instrumentation and
  /// can be used for filtering or grouping telemetry data.
  Attributes? attributes;

  /// Creates a new [APITracer].
  /// You cannot create a Tracer directly; you must use [TracerProvider]:
  /// ```dart
  /// var tracer = OTelFactory.tracerProvider().get("my-library");
  /// ```
  APITracer._({
    required this.name,
    this.schemaUrl,
    this.version,
    this.attributes,
  });

  /// Returns true if the tracer is enabled and will create sampling spans.
  /// This should be checked before performing expensive operations to create spans.
  bool get enabled => false;

  /// Gets the currently active span from the current context
  APISpan? get currentSpan => Context.current.span;

  /// Executes the provided function with the given span active in the current context.
  /// The span remains active only for the duration of the function.
  T withSpan<T>(APISpan span, T Function() fn) {
    final originalContext = Context.current;
    try {
      Context.current = Context.current.setCurrentSpan(span);
      return fn();
    } finally {
      Context.current = originalContext;
    }
  }

  /// Executes the provided async function with the given span active in the current context.
  /// The span remains active throughout the entire async execution.
  Future<T> withSpanAsync<T>(APISpan span, Future<T> Function() fn) async {
    final originalContext = Context.current;
    try {
      Context.current = Context.current.setCurrentSpan(span);
      return await fn();
    } finally {
      Context.current = originalContext;
    }
  }

  /// Starts a new [APISpan].
  ///
  /// Context precedence (in order):
  /// 1. If [spanContext] is provided, it will be used as base for the new span's context
  /// 2. If [parentSpan] is provided, it will be used as the parent
  /// 3. If [context] is provided, any span in it will be used as parent
  /// 4. If none of the above, [Context.current] will be checked for a parent span
  ///
  /// Parent-child relationship rules:
  /// - If both [spanContext] and [parentSpan] are provided and [spanContext] has a
  ///   parent ID, it must match [parentSpan]'s span ID
  /// - The new span inherits trace ID from parent if any, otherwise gets new trace ID
  /// - The new span always gets a new span ID
  /// - Parent span ID is set from the parent if any, otherwise invalid
  /// - Trace state and flags are inherited from parent if any
  APISpan startSpan(
    String name, {
    Context? context,
    SpanContext? spanContext,
    APISpan? parentSpan,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
    List<SpanLink>? links,
    bool? isRecording = true,
  }) {
    final span = createSpan(
        name: name,
        spanContext: spanContext,
        parentSpan: parentSpan,
        kind: kind,
        attributes: attributes,
        links: links,
        context: context,
        isRecording: isRecording);

    // Set the span in context and ensure it's properly propagated
    Context.current = (context ?? Context.current).setCurrentSpan(span);
    return span;
  }

  /// Starts a span and makes it active in the provided context.
  APISpan startSpanWithContext({
    required String name,
    required Context context,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
  }) {
    final span = startSpan(
      name,
      context: context,
      kind: kind,
      attributes: attributes,
    );
    Context.current = context.setCurrentSpan(span);
    return span;
  }

  /// Executes the given function with a new active span.
  T startActiveSpan<T>({
    required String name,
    required T Function(APISpan span) fn,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
  }) {
    final span = startSpan(name, kind: kind, attributes: attributes);
    try {
      return withSpan(span, () => fn(span));
    } finally {
      span.end();
    }
  }

  /// Executes the given async function with a new active span.
  Future<T> startActiveSpanAsync<T>({
    required String name,
    required Future<T> Function(APISpan span) fn,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
  }) async {
    final span = startSpan(name, kind: kind, attributes: attributes);
    try {
      return await withSpanAsync(span, () => fn(span));
    } finally {
      span.end();
    }
  }

  /// Records the execution of a function as a span.
  T recordSpan<T>({
    required String name,
    required T Function() fn,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
  }) {
    final span = createSpan(
      name: name,
      kind: kind,
      attributes: attributes,
    );

    try {
      return fn();
    } catch (e, stackTrace) {
      span.recordException(e, stackTrace: stackTrace);
      span.setStatus(SpanStatusCode.Error, e.toString());
      rethrow;
    } finally {
      span.end();
    }
  }

  /// Records the execution of an async function as a span.
  Future<T> recordSpanAsync<T>({
    required String name,
    required Future<T> Function() fn,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
  }) async {
    final span = createSpan(
      name: name,
      kind: kind,
      attributes: attributes,
    );

    try {
      return await fn();
    } catch (e, stackTrace) {
      span.recordException(e, stackTrace: stackTrace);
      span.setStatus(SpanStatusCode.Error, e.toString());
      rethrow;
    } finally {
      span.end();
    }
  }

  /// Creates a span with specific options
  /// Creates a span with the specified parameters without making it active in any context.
  ///
  /// This method provides fine-grained control over span creation, allowing you to specify
  /// all aspects of the span including its context, parent, attributes, links, and more.
  /// Unlike startSpan, this method does not set the span as active in any context.
  ///
  /// @param name The name of the span
  /// @param spanContext Optional explicit span context to use
  /// @param parentSpan Optional parent span for this span
  /// @param kind The kind of span (client, server, etc.)
  /// @param attributes Optional initial attributes for the span
  /// @param links Optional links to other spans
  /// @param spanEvents Optional initial events for the span
  /// @param startTime Optional explicit start time for the span
  /// @param isRecording Whether the span should record data
  /// @param context Optional context to use for parent determination
  /// @return A new APISpan instance that is not active in any context
  APISpan createSpan({
    required String name,
    SpanContext? spanContext,
    APISpan? parentSpan,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
    List<SpanLink>? links,
    List<SpanEvent>? spanEvents,
    DateTime? startTime,
    bool? isRecording,
    Context? context,
  }) {
    // If spanContext is not provided, we need to create one
    SpanContext effectiveSpanContext;
    if (spanContext != null) {
      effectiveSpanContext = spanContext;
    } else {
      // Get current context and determine parent
      final contextOfSpan = context ?? Context.current;
      final contextSpan = contextOfSpan.span;
      final effectiveParentSpan = parentSpan ?? contextSpan;
      final contextSpanContext = contextOfSpan.spanContext;

      if (contextSpanContext != null &&
          contextSpanContext.isValid &&
          contextSpanContext.isRemote) {
        // Handle remote context - create child using remote context's trace ID
        effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
          traceId: contextSpanContext.traceId,
          spanId: OTelFactory.otelFactory!.spanId(),
          parentSpanId: contextSpanContext.spanId,
          traceFlags: contextSpanContext.traceFlags,
          traceState: contextSpanContext.traceState,
        );
      } else if (effectiveParentSpan != null) {
        // Create child context from parent
        effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
          traceId: effectiveParentSpan.spanContext.traceId,
          spanId: OTelFactory.otelFactory!.spanId(),
          parentSpanId: effectiveParentSpan.spanContext.spanId,
          traceFlags: effectiveParentSpan.spanContext.traceFlags,
          traceState: effectiveParentSpan.spanContext.traceState,
        );
      } else {
        // Create new root context
        effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
          traceId: OTelFactory.otelFactory!.traceId(),
          spanId: OTelFactory.otelFactory!.spanId(),
          parentSpanId: OTelFactory.otelFactory!.spanIdInvalid(),
        );
      }
    }

    // Validate parent span and span context compatibility
    if (parentSpan != null) {
      if (effectiveSpanContext.traceId != parentSpan.spanContext.traceId) {
        throw ArgumentError(
            'Parent and child span context traceIds must be the same');
      }

      // Ensure child context has a proper parent span ID reference
      if (effectiveSpanContext.parentSpanId == null ||
          effectiveSpanContext.parentSpanId.toString() !=
              parentSpan.spanContext.spanId.toString()) {
        // Create a new span context with the proper parent span ID
        effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
            traceId: effectiveSpanContext.traceId,
            spanId: effectiveSpanContext.spanId,
            parentSpanId: parentSpan.spanContext.spanId,
            traceFlags: effectiveSpanContext.traceFlags,
            traceState: effectiveSpanContext.traceState,
            isRemote: effectiveSpanContext.isRemote);
      }
    }

    final apiSpan = APISpanCreate.create(
      name: name,
      instrumentationScope: InstrumentationScopeCreate.create(
          name: this.name,
          version: version ?? '1.0.0',
          schemaUrl: schemaUrl,
          attributes: attributes),
      spanContext: effectiveSpanContext,
      parentSpan: parentSpan,
      spanKind: kind,
      attributes: attributes,
      links: links,
      spanEvents: spanEvents,
      startTime: startTime,
      isRecording: isRecording ?? true && enabled,
    );
    return apiSpan;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is APITracer &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          version == other.version &&
          schemaUrl == other.schemaUrl &&
          attributes == other.attributes;

  @override
  int get hashCode =>
      name.hashCode ^
      version.hashCode ^
      schemaUrl.hashCode ^
      attributes.hashCode;
}
