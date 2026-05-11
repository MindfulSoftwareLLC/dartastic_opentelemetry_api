# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-beta.6-wip]

### Added
- **Comprehensive semconv-enum coverage of the OTel
  [attribute registry](https://opentelemetry.io/docs/specs/semconv/attributes-registry/).**
  Every top-level registry namespace that wasn't already represented
  now has a typed enum. Consumers can keep using raw strings for
  app-specific keys, but for spec-defined attributes there is now a
  typed-enum entry, making typos at the call site a compile error.

  New enums (33):

  - `AndroidResource` — `android.os.api_level`, `android.app.state`,
    `android.state`
  - `ArtifactResource` — software-artifact / supply-chain
    (`artifact.attestation.*`, `artifact.hash`, `artifact.purl`,
    `artifact.version`, etc.)
  - `AwsResource` — ECS / EKS / Lambda / S3 / CloudWatch Logs /
    DynamoDB attributes (`aws.ecs.*`, `aws.eks.cluster.arn`,
    `aws.lambda.invoked_arn`, `aws.s3.*`, `aws.dynamodb.*`,
    `aws.log.*`, `aws.request_id`)
  - `AzureResource` — `azure.client.id`, `azure.cosmosdb.*`, plus the
    legacy `az.namespace` / `az.service_request_id` keys still emitted
    by some SDKs
  - `BrowserResource` — `browser.brands`, `browser.language`,
    `browser.mobile`, `browser.platform` (matches what the SDK web
    detector emits)
  - `CassandraResource` — `cassandra.consistency.level`,
    `cassandra.coordinator.dc`, etc.
  - `CicdResource` — pipeline / task / worker attributes
    (`cicd.pipeline.*`, `cicd.worker.*`, `cicd.system.component`)
  - `CloudEventsResource` — `cloudevents.event_id`,
    `cloudevents.event_source`, `cloudevents.event_spec_version`,
    `cloudevents.event_subject`, `cloudevents.event_type`
  - `CloudfoundryResource` — Cloud Foundry platform attrs
    (`cloudfoundry.app.*`, `cloudfoundry.org.*`,
    `cloudfoundry.process.*`, `cloudfoundry.space.*`,
    `cloudfoundry.system.*`)
  - `CodeResource` — source-link attrs (`code.function.name`,
    `code.file.path`, `code.line.number`, `code.column.number`,
    `code.namespace`, `code.stacktrace`)
  - `DestinationResource` — `destination.address`,
    `destination.port` (mirror of `ServerResource` for outbound non-HTTP)
  - `DnsResource` — `dns.question.name`, `dns.answers`
  - `ElasticsearchResource` — `elasticsearch.cluster.name`,
    `elasticsearch.node.name`, `elasticsearch.node.version`
  - `EnduserResource` — `enduser.id`, `enduser.role`, `enduser.scope`
    (separate from `user.*`; `enduser.*` is what services set about
    the end user they're serving)
  - `EventResource` — `event.name` (used by the logs signal)
  - `FaasResource` — Function-as-a-Service attrs (`faas.coldstart`,
    `faas.invoked_*`, `faas.trigger`, etc.)
  - `GcpResource` — `gcp.client.service`, `gcp.cloud_run.job.*`,
    `gcp.gce.instance.*`
  - `GeoResource` — `geo.continent.code`, `geo.country.iso_code`,
    `geo.locality.name`, `geo.location.lat`, `geo.location.lon`,
    `geo.postal_code`, `geo.region.iso_code`
  - `HardwareResource` — `hardware.id`, `hardware.name`,
    `hardware.parent`, `hardware.type`, `hardware.serial_number`,
    `hardware.vendor`, `hardware.model`
  - `HerokuResource` — `heroku.app.id`, `heroku.release.commit`,
    `heroku.release.creation_timestamp`
  - `IosResource` — `ios.app.state`, `ios.state`
  - `LogResource` — `log.iostream`, `log.file.*`, `log.record.original`,
    `log.record.uid`
  - `NetworkResource` — added `networkProtocolName`
    (`network.protocol.name`), `networkProtocolVersion`
    (`network.protocol.version`), and `networkTransport`
    (`network.transport`) — current OTel semconv keys for the wire
    protocol an HTTP client / server is speaking over
  - `OciResource` — `oci.manifest.digest`
  - `OpentracingResource` — `opentracing.ref_type`
  - `OtelResource` — `otel.scope.name`, `otel.scope.version`,
    `otel.status_code`, `otel.status_description`,
    `otel.span.sampling_result`, plus the deprecated-but-still-emitted
    `otel.library.name` / `otel.library.version`
  - `PeerResource` — `peer.service`
  - `ProfileResource` — `profile.frame.type` (experimental profiling
    signal)
  - `SourceResource` — `source.address`, `source.port` (mirror of
    `ClientResource` for inbound non-HTTP)
  - `SystemResource` — system-level metric attrs for CPU / memory /
    disk / network / filesystem / paging / process (used by the SDK's
    auto-collected runtime metrics)
  - `TestResource` — `test.case.name`, `test.case.result.status`,
    `test.suite.name`, `test.suite.run.status`
  - `ThreadResource` — `thread.id`, `thread.name`
  - `TlsResource` — full TLS connection attribute set
    (`tls.cipher`, `tls.protocol.*`, `tls.client.*`, `tls.server.*`)
  - `UserAgentResource` — `user_agent.original`, `user_agent.name`,
    `user_agent.version` — the OTel semconv user-agent attributes set
    by HTTP-client instrumentation (e.g. `dartastic_dio_otel`) on
    each outbound request
  - `VcsResource` — version-control attrs
    (`vcs.repository.url.full`, `vcs.ref.head.*`, `vcs.change.*`,
    `vcs.owner.name`, `vcs.provider.name`, etc.)
  - `WebengineResource` — `webengine.description`, `webengine.name`,
    `webengine.version`

- **Backfilled current-spec keys on `DatabaseResource`** — the older
  `db.system` / `db.name` / `db.statement` / `db.operation` entries
  are retained for back-compat, with the newer formalized keys added
  alongside them: `dbSystemName` (`db.system.name`), `dbNamespace`
  (`db.namespace`), `dbOperationName` (`db.operation.name`),
  `dbOperationBatchSize` (`db.operation.batch.size`), `dbQueryText`
  (`db.query.text`), `dbQuerySummary` (`db.query.summary`),
  `dbResponseStatusCode` (`db.response.status_code`),
  `dbStoredProcedureName` (`db.stored_procedure.name`),
  `dbClientConnectionState` (`db.client.connection.state`),
  `dbClientConnectionPoolName` (`db.client.connection.pool.name`),
  `dbClientConnectionUsedState` (`db.client.connection.used.state`).

- **Backfilled current-spec keys on `ComputeUnitResource`** (which
  holds the `container.*` registry): `containerImageTags`
  (`container.image.tags`, the pluralized form that replaces the
  legacy `container.image.tag`), `containerImageId`
  (`container.image.id`), `containerImageRepoDigests`
  (`container.image.repo_digests`), `containerCommand`
  (`container.command`), `containerCommandArgs`
  (`container.command_args`), `containerCommandLine`
  (`container.command_line`), `containerCsiPluginName`
  (`container.csi.plugin.name`), `containerCsiVolumeId`
  (`container.csi.volume.id`), `containerLabels`
  (`container.labels`).

## [1.0.0-beta.5] - 2026-05-10

### Added
- **Pluggable `TimeProvider` for span timestamps.** New abstraction with three pieces:
  - `TimeProvider` (interface) and `SystemTimeProvider` (default, `DateTime.now`) — `lib/src/util/time_provider.dart`.
  - `WebTimeProvider` — `window.performance.now()` + `timeOrigin` for sub-millisecond span timestamps on web. Lives in `lib/src/util/web_time_provider.dart` as a conditional facade (`web_time_provider_web.dart` on Dart-on-JS / Wasm; `web_time_provider_stub.dart` throws on native).
  - `defaultTimeProvider` — platform-aware constant exported from `lib/src/util/default_time_provider.dart`. Native targets resolve to `SystemTimeProvider`; web targets to `WebTimeProvider`. Selected at compile time via `dart.library.js_interop`, the modern Wasm-compatible check.

  Plumbed through `APITracerProvider.timeProvider` → `APITracer.timeProvider` → `APISpan._timeProvider` so span starts, ends, and events all source their timestamps from the same clock. `APISpan.addEventNow` and `addEvents(Map)` now route through the span's `_timeProvider` rather than the static `OTelFactory.spanEventNow` shortcut, which was hardcoded to `DateTime.now` and silently dropped sub-millisecond precision when the provider was a `WebTimeProvider`.

  **Why this matters on web.** `DateTime.now()` on Dart-on-JS is millisecond-precision — the underlying source is JS `Date.now()`, and `microsecondsSinceEpoch` returns `millisecondsSinceEpoch × 1000` (the lower three digits are always zero, regardless of the Int64 storage type used by OTLP). `WebTimeProvider` routes through the browser performance API: ~5µs nominal precision, browser-coarsened to ~100µs as a Spectre mitigation, still 10–200× better than `Date.now()`. Native targets are unaffected and stay at `DateTime.now`'s 1µs floor.

  **Auto-default on web.** Web users do not have to opt in — constructing an `APITracerProvider` on a web target automatically gets `WebTimeProvider` via `defaultTimeProvider`. To override (e.g., a fake clock in tests), assign `tracerProvider.timeProvider = customProvider`.
### Changed
- README and the API example now use `OTelAPI.attributesFromSemanticMap({Enum.value: ...})` for typed-enum-keyed attribute maps in place of `OTelAPI.attributesFromMap({Enum.value.key: ...})` / `Attributes.of({Enum.value.key: ...})` / `<String, Object>{...}.toAttributes()`. The shorter form drops the `.key` accessor on every entry while keeping the typed-enum-key principle. Mixing different semconv enum types in one map is fine — the param is `Map<OTelSemantic, Object>` and every semconv enum implements `OTelSemantic`. No API surface change; `attributesFromSemanticMap` has existed since beta-era.

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
