# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-beta.5-wip]

## [1.0.0-beta.4] - 2026-05-10

### Added
- `OTelAPI.loggerProviders()` — returns the global default `APILoggerProvider` plus any named providers added via `OTelAPI.addLoggerProvider(name)`. Parallel to the existing `tracerProviders()` and `meterProviders()`. Backed by a new `OTelFactory.getLoggerProviders()` so SDK implementations get the same enumeration. Lets `OTel.shutdown()` in the SDK iterate over named LoggerProviders the way it already does for tracer / meter providers — without this, `OTel.addLoggerProvider(name)` consumers had to remember to shut each one down manually.

## [1.0.0-beta.3] - 2026-05-10

### Fixed
- **Breaking:** `ServiceResource.serviceResourcepace` (key `service.Resourcepace`) was a mangled find/replace artifact (`Name` → `Resource` accidentally hit `serviceNamespace`). Restored the correct OTel semconv entry: `ServiceResource.serviceNamespace` with key `service.namespace`. Migration: replace `ServiceResource.serviceResourcepace` with `ServiceResource.serviceNamespace`.

## [1.0.0-beta.2] - 2026-05-08

### Added
- `DatabaseResource.dbCollectionName` (`db.collection.name`) — current OTel semconv key, replaces the deprecated `db.sql.table`.
- `DatabaseResource.dbResponseReturnedRows` (`db.response.returned_rows`) — current OTel semconv key for the row count returned by a database operation.
- `UserSemantics.userRoles` (`user.roles`) — current OTel semconv key, an array of roles assigned to a user.

### Changed
- README and example renamed the placeholder `AppAttribute` enum to `ExampleAttribute` (so readers can't blindly copy the name) and dropped the redundant `app.` prefix from invented demo keys. Where current OTel semconv keys exist, the example now uses the API's typed enums (e.g. `DatabaseResource.dbCollectionName`, `UserSemantics.userRoles`) instead of an app-defined fallback.

### Removed
- **Breaking:** `UserSemantics.userRole` (singular `user.role`). The singular form is an anti-pattern — users typically have multiple roles. Use `UserSemantics.userRoles` (`user.roles`) and pass a `List<String>` instead.

## [1.0.0-beta.1] - 2026-05-07

### Fixed
- `Context.runIsolate()` now marks the deserialized `SpanContext` as `isRemote = true` on the receiving side. Previously the parent isolate's local SpanContext (with `isRemote = false`) was restored verbatim, so `tracer.startSpan` in the new isolate fell into the "no parent" branch and produced a fresh root span instead of a child of the parent. This now matches the W3C trace-context-from-HTTP semantic — a SpanContext that crossed a process or isolate boundary is treated as remote and parented correctly.

## [1.0.0-beta] - 2026-05-07

### Added
- (Thank you to Kevin Moore [@kevmoo](https://github.com/kevmoo)) `Context.run()` and `Context.runSync()` — Zone-based implicit context propagation. These are the spec-aligned way to attach a context for a scope of execution and ensure it propagates correctly across `await`s and async callbacks.
- (Thank you to Kevin Moore [@kevmoo](https://github.com/kevmoo)) `isTransferable` flag on `ContextKey` (default `false`) to opt custom keys into cross-isolate transfer via `Context.runIsolate()`.
- `ServerResource` and `UrlResource` semantic resource enums.

### Changed
- **Breaking:** `tracer.startSpan()` no longer automatically activates the span in the current context, aligning with the OpenTelemetry specification. Use `tracer.withSpan` / `withSpanAsync` (or `Context.runSync` / `Context.run`) to make a span active for a scope.
- **Breaking:** `Context.currentWithBaggage()` is now pure — it returns a Context with Baggage but no longer mutates `Context.current`. Pair the returned Context with `runSync` / `run` if you need it active.
- **Breaking:** Custom values stored via `ContextKey` are no longer transferred across isolate boundaries by default. Pass `isTransferable: true` when creating the key to opt in. Built-in `Baggage` and `SpanContext` continue to transfer unconditionally.
- `APITracer.withSpan()` and `withSpanAsync()` now use Zone-based context propagation (`Context.runSync` / `Context.run`) for correct behavior across async boundaries (no-op implementation only).
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
