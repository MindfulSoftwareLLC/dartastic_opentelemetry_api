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
///
/// All methods of this class are safe for concurrent use by default:
/// implementations must remain correct when methods are invoked from
/// interleaved asynchronous tasks within an isolate. See
/// [Trace API, concurrency requirements](https://github.com/open-telemetry/opentelemetry-specification/blob/v1.60.0/specification/trace/api.md#concurrency-requirements).
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

  /// The instrumentation scope for this tracer.
  late final InstrumentationScope _instrumentationScope;

  /// Creates a new [APITracer].
  /// You cannot create a Tracer directly; you must use [APITracerProvider]:
  /// ```dart
  /// var tracer = OTelFactory.tracerProvider().get("my-library");
  /// ```
  APITracer._({
    required this.name,
    this.schemaUrl,
    this.version,
    this.attributes,
    TimeProvider? timeProvider,
  }) : timeProvider = timeProvider ?? defaultTimeProvider {
    _instrumentationScope = InstrumentationScopeCreate.create(
      name: name,
      version: version,
      schemaUrl: schemaUrl,
      attributes: attributes,
    );
  }

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
  bool isEnabled({SpanKind? kind, Context? context}) {
    // No factory means nothing can record, and error-handling.md forbids
    // throwing from an API method, so never dereference a null factory here.
    final factory = OTelFactory.otelFactory;
    return factory != null && !factory.isAPIFactory;
  }

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
  /// the parent is determined exclusively from [context]; when [context]
  /// is omitted, [Context.current] is used. The precedence is:
  ///
  /// 1. If [root] is `true`, a new root span is created regardless of
  ///    context (new trace ID, no parent).
  /// 2. If the context contains a valid remote [SpanContext] (e.g.
  ///    extracted from an incoming `traceparent` header), the new span
  ///    becomes a child of that remote context. The context's span is
  ///    kept as the parent span object only when it is the very span
  ///    that remote [SpanContext] identifies.
  /// 3. If the context contains a local [APISpan] carrying a valid
  ///    [SpanContext], the new span becomes a child of that span.
  /// 4. If the context contains a valid non-remote [SpanContext] but no
  ///    span with a valid [SpanContext] (e.g. set via
  ///    [Context.withSpanContext] or [Context.copyWithSpanContext]), the
  ///    new span becomes a child of that [SpanContext]; it has no parent
  ///    span object.
  /// 5. If none of the above yields a parent, a new root span is created.
  ///
  /// A parent candidate whose [SpanContext] is invalid (all-zero IDs) is
  /// skipped at every level, so a context holding only an invalid span or
  /// span context produces a root span rather than an error.
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
  /// the parent is determined exclusively from [context], in the order
  /// [root] > remote [SpanContext] > local [APISpan] > valid non-remote
  /// [SpanContext] > new root. See [startSpan] for the full precedence
  /// rules and migration guidance.
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
    // (all-zero IDs, unsampled) when the context yields no parent. The SDK
    // delegates span creation here with its own factory installed, so
    // this branch only applies when no SDK is present.
    if (OTelFactory.otelFactory!.isAPIFactory) {
      if (root) {
        return NonRecordingSpan(OTelFactory.otelFactory!.spanContextInvalid());
      }
      // trace/api.md, no-SDK behavior: "If the Span in the parent Context is
      // already non-recording, it SHOULD be returned directly without
      // instantiating a new Span." This is checked on the Context's span
      // before parent resolution, because the resolver skips a parent whose
      // SpanContext is invalid, and the span returned by an earlier no-SDK
      // startSpan is exactly that: the empty, all-zero one. Returning it is
      // still the spec's answer. (#129)
      // Resolve with the same precedence the SDK path uses, so a given
      // Context parents identically with and without an SDK.
      final resolved = _resolveParent(contextOfSpan);
      final contextSpan = contextOfSpan.span;
      // Reuse the Context's span when it is non-recording and it is the
      // parent: either the resolver picked it, or the resolver found nothing
      // usable, which is the empty all-zero span an earlier no-SDK startSpan
      // returned. A bare remote SpanContext that outranks it still wins.
      if (contextSpan != null &&
          !contextSpan.isRecording &&
          (identical(resolved.parentSpan, contextSpan) ||
              resolved.parentSpanContext == null)) {
        return contextSpan;
      }
      return NonRecordingSpan(resolved.parentSpanContext ??
          OTelFactory.otelFactory!.spanContextInvalid());
    }

    // --- Parent resolution (precedence: root > remote spanContext >
    //     local span > valid non-remote spanContext > new root) ---
    SpanContext effectiveSpanContext;
    APISpan? effectiveParentSpan;

    final parent = root ? null : _resolveParent(contextOfSpan);
    final parentSpanContext = parent?.parentSpanContext;

    if (parentSpanContext == null) {
      // Explicit root span (context ignored entirely), or no parent found
      // in the context — either way, a new root.
      effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
        traceId: OTelFactory.otelFactory!.traceId(),
        spanId: OTelFactory.otelFactory!.spanId(),
        parentSpanId: OTelFactory.otelFactory!.spanIdInvalid(),
      );
      effectiveParentSpan = null;
    } else {
      // Child span — inherit the parent's trace ID, trace flags and trace
      // state, mint a new span ID and point parentSpanId at the parent.
      effectiveSpanContext = OTelFactory.otelFactory!.spanContext(
        traceId: parentSpanContext.traceId,
        spanId: OTelFactory.otelFactory!.spanId(),
        parentSpanId: parentSpanContext.spanId,
        traceFlags: parentSpanContext.traceFlags,
        traceState: parentSpanContext.traceState,
      );
      effectiveParentSpan = parent!.parentSpan;
    }

    final apiSpan = APISpanCreate.create(
      name: name,
      instrumentationScope: _instrumentationScope,
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

  /// Resolves the parent a new span created in [context] should get.
  ///
  /// Implements the precedence documented on [startSpan], minus the `root`
  /// case, which callers handle before consulting this. Both the
  /// no-SDK (API-factory) path and the normal path go through here so that
  /// the same Context always resolves to the same parent.
  ///
  /// Returns the parent's [SpanContext] — `null` when the context yields no
  /// parent and the new span is therefore a root — together with the parent
  /// [APISpan] object when the context carries one.
  ///
  /// Every candidate parent must carry a valid [SpanContext]. [Context] does
  /// not validate what is put into it, so a span with an invalid (all-zero)
  /// SpanContext can sit in one; per trace/api.md an invalid parent means the
  /// new span is a root, not an error. Validity is the only filter: an
  /// *ended* span in the context is still a usable parent, which trace/api.md
  /// makes a MUST.
  ///
  /// Do not look for these tiers in the specification. There the lookup is
  /// single: the Span in the Context, with a remote SpanContext reaching a
  /// Context only by being wrapped in a span (trace/api.md, "Wrapping a
  /// SpanContext in a Span"). The tiers exist because this package's
  /// [Context] carries a bare span-context slot alongside the span slot,
  /// which predates context-driven span creation, and both slots have to
  /// resolve to one parent.
  ///
  /// Static because it reads no per-tracer state: the parent depends only
  /// on [context].
  static ({SpanContext? parentSpanContext, APISpan? parentSpan}) _resolveParent(
      Context context) {
    final contextSpanContext = context.spanContext;
    final contextSpan = context.span;

    if (contextSpanContext != null &&
        contextSpanContext.isValid &&
        contextSpanContext.isRemote) {
      // Remote context (propagator extract path). The remote SpanContext
      // takes precedence over any local span in the same context; this is
      // the normal flow when a propagator has extracted a traceparent
      // header onto a Context that already carried a local span.
      //
      // Context.withSpan writes both the span and the span context keys, so
      // a remote SpanContext wrapped in a NonRecordingSpan lands here with
      // the wrapping span also present. Keep that span as the parent object
      // when it is the very span the remote SpanContext identifies. A span
      // from a different trace stays ignored — the remote context wins, and
      // APISpanCreate.create would reject the mismatched trace ID anyway.
      final contextSpanSc = contextSpan?.spanContext;
      final parentSpan = (contextSpanSc != null &&
              contextSpanSc.traceId == contextSpanContext.traceId &&
              contextSpanSc.spanId == contextSpanContext.spanId)
          ? contextSpan
          : null;
      return (parentSpanContext: contextSpanContext, parentSpan: parentSpan);
    }

    if (contextSpan != null && contextSpan.spanContext.isValid) {
      // Local in-process parent span. A span whose SpanContext is invalid
      // parents nothing: it falls through to the root case below, rather
      // than minting an all-zero-trace child that APISpanCreate.create
      // would then reject.
      return (
        parentSpanContext: contextSpan.spanContext,
        parentSpan: contextSpan
      );
    }

    if (contextSpanContext != null && contextSpanContext.isValid) {
      // A valid non-remote SpanContext with no span object behind it, e.g.
      // set via Context.withSpanContext or Context.copyWithSpanContext. It
      // still identifies a parent, so the new span is a child of it rather
      // than a fresh root.
      return (parentSpanContext: contextSpanContext, parentSpan: null);
    }

    // No parent in context — the new span is a root.
    return (parentSpanContext: null, parentSpan: null);
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
