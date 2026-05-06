# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-alpha.1] - TBD

### Added
- `Context.run()` and `Context.runSync()` — Zone-based implicit context propagation. These are the spec-aligned way to attach a context for a scope of execution and ensure it propagates correctly across `await`s and async callbacks.
- `isTransferable` flag on `ContextKey` (default `false`) to opt custom keys into cross-isolate transfer via `Context.runIsolate()`, default is false.

### Changed
- **Breaking:** `tracer.startSpan()` no longer automatically activates the span in the current context, aligning with the OpenTelemetry specification. Use `tracer.withSpan` / `withSpanAsync` (or `Context.runSync` / `Context.run`) to make a span active for a scope.
- **Breaking:** `Context.currentWithBaggage()` is now pure — it returns a Context with Baggage but no longer mutates `Context.current`. Pair the returned Context with `runSync`/`run` if you need it active.
- **Breaking:** Custom values stored via `ContextKey` are no longer transferred across isolate boundaries by default. Pass `isTransferable: true` when creating the key to opt in. Built-in `Baggage` and `SpanContext` continue to transfer unconditionally.
- `APITracer.withSpan()` and `withSpanAsync()` now use Zone-based context propagation (`Context.runSync` / `Context.run`) for correct behavior across async boundaries. This only for the no-op implementation.
- README and example updated to demonstrate Zone-based context management.

### Deprecated
- The static `Context.current` setter. Setting it does not propagate across `Zone`s, which produces incorrect context inside async callbacks. Use `Context.run()` or `Context.runSync()` instead.

### Fixed
- `APITracer.createSpan()` now correctly inherits parent spans from the provided `context` parameter or `Context.current`. Previously these were ignored.
- `Context.runIsolate()` now serializes the specific Context instance it was called on, not the global `Context.current`.
- `Context.runIsolate()` no longer mutates the parent isolate's `_currentContext` on return — eliminates a case where Zone-bound context could leak into the parent's static field.
- `nowAsNanos()` no longer loses precision on JS. The 64-bit wrap now happens before the multiplication by 1000.

## [1.0.0-alpha] - 2025-12-22

### Changed
Documentation, updated to 1.0.0-alpha release candidate, matching dartastic_opentelemetry

## [0.9.0] - 2025-12-14

### Added
Logs signal, kudos to https://github.com/yuzurihaaa

## [0.8.8] - 2025-10-08

### Changed
Fixed default logging behavior to log INFO

## [0.8.7] - 2025-09-25

### Changed
- adjusted meta dependency down to 1.16

## [0.8.6] - 2025-09-24

### Changed
- bumped all dependencies to latest

## [0.8.5] - 2025-07-25

### Changed
- added span addXXXAttribute
- InstrumentationScope toString

## [0.8.4] - 2025-07-25

### Changed
- SpanEvent toString

## [0.8.3] - 2025-06-06

### Changed
- Attributes toString uses toJson

### Removed
- tracer recordSpan, recordSpanAsync, startActiveSpan, startActiveSpanAsync, startSpanWithContext

## [0.8.2] - 2025-06-05

### Changed
- Added instrumentationScope() to API
- Removed _getAndCacheOtelFactory() check from getTracerProviders/getMeterProviders

## [0.8.1] - 2025-06-04

### Added
- getTracerProviders/getMeterProviders

## [0.8.0] - 2025-05-01

### Added
- Initial public release of the OpenTelemetry API for Dart
- Core abstractions for traces, metrics and common (baggage, context)
- Context propagation mechanisms
- Implementation of the OpenTelemetry specification
- No-op implementations of all interfaces
- Comprehensive test suite
- Basic examples

### Compliance
- Implements OpenTelemetry API specification v1.42
