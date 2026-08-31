// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';
import '../../factory/otel_factory.dart';
import '../../util/default_time_provider.dart';
import '../../util/time_provider.dart';
import '../common/attributes.dart';
import '../common/instrumentation_scope.dart';
import '../context/context.dart';
import 'span.dart';
import 'span_context.dart';
import 'span_event.dart';
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

  /// Clock used for span start, end, and event timestamps. Inherited from
  /// the [APITracerProvider] that created this tracer; spans created via
  /// [createSpan] are constructed with this clock so all timestamps in a
  /// trace are consistent. Defaults to the platform-aware
  /// `defaultTimeProvider` (native: `SystemTimeProvider`; web:
  /// `WebTimeProvider`).
  final TimeProvider timeProvider;

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
    TimeProvider? timeProvider,
  }) : timeProvider = timeProvider ?? defaultTimeProvider;

  /// Returns whether this tracer is enabled for the provided arguments.
  /// This should be checked before performing expensive operations to create spans.
  ///
  /// The returned value can change over time; instrumentation authors need
  /// to call this each time they create a new span to ensure they have the
  /// most up-to-date response.
  ///
  /// No parameters are currently required by the spec, but this is a method
  /// (not a getter) so parameters such as [kind] and [context] can be added
  /// later without a breaking change.
  bool isEnabled({SpanKind? kind, Context? context}) => false;

  /// Gets the currently active span from the current context
  APISpan? get currentSpan => Context.current.span;

  /// Executes the provided function with the given span active in the current context.
  /// The span remains active only for the duration of the function.
  T withSpan<T>(APISpan span, T Function() fn) {
    final newContext = Context.current.withSpan(span);
    return newContext.runSync(fn);
  }

  /// Executes the provided async function with the given span active in the current context.
  /// The span remains active throughout the entire async execution.
  Future<T> withSpanAsync<T>(APISpan span, Future<T> Function() fn) async {
    final newContext = Context.current.withSpan(span);
    return newContext.run(fn);
  }

  /// Starts a new [APISpan].
  ///
  /// Per the OpenTelemetry specification (trace/api.md, Span Creation),
  /// the parent is determined exclusively from [context]:
  ///
  /// 1. If [root] is `true`, a new root span is created regardless of
  ///    context (new trace ID, no parent).
  /// 2. If [context] is provided and contains a remote [SpanContext]
  ///    (e.g. extracted from an incoming `traceparent` header), the new
  ///    span becomes a child of that remote context.
  /// 3. If [context] is provided and contains a local [APISpan], the new
  ///    span becomes a child of that span.
  /// 4. If [context] is omitted, [Context.current] is used.
  /// 5. If none of the above yields a parent, a new root span is created.
  ///
  /// [startTime] overrides the span's start timestamp; defaults to now.
  ///
  /// Note: This method does NOT make the span active in the current
  /// context. To make the span active, use [withSpan] or [withSpanAsync].
  ///
  /// **Migration from pre-1.0.0-rc.4:**
  ///
  /// The `parentSpan` and `spanContext` parameters have been removed. To
  /// set a parent, put the parent span into a Context first:
  /// ```dart
  /// // Before:
  /// tracer.startSpan('child', parentSpan: parent);
  ///
  /// // After:
  /// final ctx = Context.current.withSpan(parent);
  /// tracer.startSpan('child', context: ctx);
  /// ```
  ///
  /// To propagate a remote [SpanContext] (e.g. from an incoming request):
  /// ```dart
  /// final remoteSpan = OTelAPI.nonRecordingSpan(remoteSpanContext);
  /// final ctx = Context.current.withSpan(remoteSpan);
  /// tracer.startSpan('server-handler', context: ctx);
  /// ```
  APISpan startSpan(
    String name, {
    Context? context,
    bool root = false,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
    List<SpanLink>? links,
    DateTime? startTime,
    bool? isRecording = true,
  }) {
    return createSpan(
        name: name,
        root: root,
        kind: kind,
        attributes: attributes,
        links: links,
        startTime: startTime,
        context: context,
        isRecording: isRecording);
  }

  /// Creates a span with specific options without making it active in any
  /// context.
  ///
  /// This method provides fine-grained control over span creation. Unlike
  /// [startSpan], it also accepts [spanEvents].
  ///
  /// Per the OpenTelemetry specification (trace/api.md, Span Creation),
  /// the parent is determined exclusively from [context]. See [startSpan]
  /// for the full precedence rules and migration guidance.
  ///
  /// @param name The name of the span
  /// @param kind The kind of span (client, server, etc.)
  /// @param attributes Optional initial attributes for the span
  /// @param links Optional links to other spans
  /// @param spanEvents Optional initial events for the span
  /// @param startTime Optional explicit start time for the span
  /// @param isRecording Whether the span should record data
  /// @param context Optional context to use for parent determination
  /// @param root If true, forces creation of a root span regardless of
  ///   context
  /// @return A new APISpan instance that is not active in any context
  APISpan createSpan({
    required String name,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
    List<SpanLink>? links,
    List<SpanEvent>? spanEvents,
    DateTime? startTime,
    bool? isRecording,
    Context? context,
    bool root = false,
  }) {
    // Get current context.
    final contextOfSpan = context ?? Context.current;

    // trace/api.md, "Behavior of the API in the absence of an installed
    // SDK": with only the API installed, return a non-recording span
    // carrying the SpanContext from the parent context (explicit or
    // implicit) unchanged — no new IDs are minted — or an empty one
    // (all-zero IDs, unsampled) when the context has no span. The SDK
    // delegates span creation here with its own factory installed, so
    // this branch only applies when no SDK is present.
    if (OTelFactory.otelFactory!.isAPIFactory) {
      if (root) {
        return NonRecordingSpan(OTelFactory.otelFactory!.spanContextInvalid());
      }
      final parentSpanContext =
          contextOfSpan.spanContext ?? contextOfSpan.span?.spanContext;
      return NonRecordingSpan(
          parentSpanContext ?? OTelFactory.otelFactory!.spanContextInvalid());
    }

    // --- Parent resolution (precedence: root > remote spanContext >
    //     local span > new root) ---
    SpanContext effectiveSpanContext;
    APISpan? effectiveParentSpan;

    if (root) {
      // Explicit root span — ignore everything in context.
      effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
        traceId: OTelFactory.otelFactory!.traceId(),
        spanId: OTelFactory.otelFactory!.spanId(),
        parentSpanId: OTelFactory.otelFactory!.spanIdInvalid(),
      );
      effectiveParentSpan = null;
    } else {
      final contextSpanContext = contextOfSpan.spanContext;
      final contextSpan = contextOfSpan.span;

      if (contextSpanContext != null &&
          contextSpanContext.isValid &&
          contextSpanContext.isRemote) {
        // Remote context (propagator extract path) — create child using
        // the remote context's trace ID. The remote SpanContext takes
        // precedence over any local span in the same context; this is
        // the normal flow when a propagator has extracted a traceparent
        // header onto a Context that already carried a local span.
        effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
          traceId: contextSpanContext.traceId,
          spanId: OTelFactory.otelFactory!.spanId(),
          parentSpanId: contextSpanContext.spanId,
          traceFlags: contextSpanContext.traceFlags,
          traceState: contextSpanContext.traceState,
        );
        effectiveParentSpan = null;
      } else if (contextSpan != null) {
        // Local in-process parent span.
        effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
          traceId: contextSpan.spanContext.traceId,
          spanId: OTelFactory.otelFactory!.spanId(),
          parentSpanId: contextSpan.spanContext.spanId,
          traceFlags: contextSpan.spanContext.traceFlags,
          traceState: contextSpan.spanContext.traceState,
        );
        effectiveParentSpan = contextSpan;
      } else {
        // No parent in context — create a new root.
        effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
          traceId: OTelFactory.otelFactory!.traceId(),
          spanId: OTelFactory.otelFactory!.spanId(),
          parentSpanId: OTelFactory.otelFactory!.spanIdInvalid(),
        );
        effectiveParentSpan = null;
      }
    }

    final apiSpan = APISpanCreate.create(
      name: name,
      instrumentationScope: InstrumentationScopeCreate.create(
          name: this.name,
          version: version,
          schemaUrl: schemaUrl,
          attributes: attributes),
      spanContext: effectiveSpanContext,
      parentSpan: effectiveParentSpan,
      spanKind: kind,
      attributes: attributes,
      links: links,
      spanEvents: spanEvents,
      startTime: startTime,
      isRecording: (isRecording ?? true) &&
          isEnabled(kind: kind, context: contextOfSpan),
      timeProvider: timeProvider,
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
