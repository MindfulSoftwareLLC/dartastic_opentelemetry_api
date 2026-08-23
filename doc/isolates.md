# OpenTelemetry and Dart Isolates

Dart isolates share no mutable state — every isolate has its own copy of
globals, including OpenTelemetry's context, configuration, and error
handler. This page explains what crosses an isolate boundary
automatically, what doesn't, and the patterns to use.

## The short version

- Use **`Context.current.runIsolate(...)`** to run traced work in another
  isolate. It carries your OTel configuration, the active context
  (trace/span identity, baggage), **and your installed error handler**
  into the child for you.
- Isolates you spawn yourself (`Isolate.spawn`, `Isolate.run`, `compute`)
  get **none** of that — each is a fresh, unconfigured OTel world until
  you initialize it.

## What `runIsolate` does

```dart
final result = await Context.current.runIsolate(() async {
  // Runs in a new isolate with:
  //  - the OTel factory configuration re-established,
  //  - this context active (Context.current works),
  //  - the parent's error handler installed (see below).
  final span = tracer.startSpan('child-work');
  // ...
  span.end();
  return computeSomething();
});
```

Under the hood it serializes the factory configuration and the context,
spawns the isolate, and re-establishes both before your computation runs.
The propagated `SpanContext` arrives with `isRemote: true` — crossing an
isolate boundary is treated like any other process boundary, exactly as
if the context had arrived in W3C `traceparent` headers. Child spans
therefore parent correctly onto the calling trace.

On the web (no isolates), `runIsolate` runs the computation inline in the
current context; everything behaves identically.

## The error handler crosses too — with copy semantics

The global error handler installed with `OTelAPI.setErrorHandler` (or the
SDK's `OTel.setErrorHandler`) is a per-isolate static. `runIsolate`
re-installs the parent's handler inside the child so library error
reports behave the same on both sides.

The handler is **copied**, not shared. A handler that logs, prints, or
forwards to a crash reporter behaves identically in the child. A handler
that collects into a local list collects into the **child's copy** — the
parent never sees it. To aggregate reports in the parent, capture a
`SendPort`:

```dart
final reports = ReceivePort();
// Capture the SendPort itself. Capturing the ReceivePort — even
// implicitly, by writing `reports.sendPort` inside the closure — makes
// the handler unsendable.
final sink = reports.sendPort;
OTelAPI.setErrorHandler((error, stackTrace) {
  sink.send(error.toString());
});
reports.listen((message) => log.warning('OTel error: $message'));
```

If a handler's captured state cannot be sent across the boundary (it
closes over a `ReceivePort`, a stream controller, a socket, ...),
`runIsolate` does **not** fail: the child falls back to the default
logging handler and the parent's handler receives one report describing
the degradation.

## Isolates you spawn yourself

`runIsolate` is the only isolate seam this library owns. If you use
`Isolate.spawn` / `Isolate.run` / Flutter's `compute` directly, the new
isolate starts with:

- no OTel configuration (no-op behavior until initialized),
- an empty `Context` (no active span, no baggage),
- the **default** error handler.

Either initialize OTel inside that isolate's entry point and re-install
your handler there, or — usually simpler — route the work through
`Context.current.runIsolate` instead.

## Zones vs. isolates

Within one isolate, context flows through zones: `context.run(...)` and
the `withSpan` helpers make `Context.current` correct across `await`
boundaries with no copying. Zones never cross isolates; `runIsolate` is
the bridge for that.

| Boundary                        | Mechanism                      | Context                   | Error handler                          |
|---------------------------------|--------------------------------|---------------------------|----------------------------------------|
| async/await (same isolate)      | zones (`context.run`)          | shared                    | shared (same static)                   |
| `Context.runIsolate`            | serialize + re-establish       | copied, `isRemote: true`  | copied (SendPort pattern to aggregate) |
| DIY `Isolate.spawn` / `compute` | none                           | empty                     | default                                |
| processes                       | W3C propagators / env carriers | extracted, `isRemote: true` | not propagated                       |
