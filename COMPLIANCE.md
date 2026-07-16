# OpenTelemetry Specification Compliance

This document tracks the compliance of `dartastic_opentelemetry_api` — the
OpenTelemetry API for Dart — against the
[OpenTelemetry specification](https://opentelemetry.io/docs/specs/otel/)
and the W3C Trace Context Recommendation. It is the durable record of the
2026-07 spec-compliance audit wave coordinated in
[#44](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/44).

## How compliance is verified

Every audited clause follows the same TDD shape:

1. A commit pins the contract with **red** tests that quote the spec
   clause verbatim.
2. A commit turns them **green** — or, where the fix needed design work,
   the red tests were `skip:`-ed behind a linked issue so CI stayed green
   until the fix landed, then unskipped by the fix PR.

Semantic conventions are verified differently: the enums are generated
from the registry model with OTel Weaver, and the generator also emits
audit tests asserting every key, value, metric, event, and entity against
the registry it was generated from (see PR
[#52](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/52)).

## Status matrix

Statuses reflect the repository as of 2026-07-18 — the audit wave is
fully merged. Version numbers refer to the release train in
[CHANGELOG.md](CHANGELOG.md); "beta.10" entries ship with the
`1.0.0-beta.10` release.

| Spec area | Clause(s) | Status | Where |
| --- | --- | --- | --- |
| Context (`context/README.md`) | Context works before/without initialization; keys are unique; immutability | Shipped (beta.8/beta.9) | #27, #31, #32, #34 |
| Propagators (`context/api-propagators.md`) | Global `TextMapPropagator` get/set; "MUST use no-op propagators unless explicitly configured otherwise"; factory-routed like all API objects | Shipped (beta.10) | [#55](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/55) (fixed #42; #43 pinned the contract) |
| Baggage (`baggage/api.md`, `error-handling.md`) | Values are any valid UTF-8 string incl. empty; API methods never throw on misuse | Shipped (beta.10) | [#36](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/36) |
| Trace: no-SDK behavior (`trace/api.md`) | Non-recording spans; parent `SpanContext` passthrough; all-zero empty span; `NonRecordingSpan` wrapper | Shipped (beta.10) | [#54](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/54) (fixed #40; #41 pinned the contracts) |
| Trace: `TraceState` (`trace/api.md`, `error-handling.md`) | Mutations validate input, never throw, never return invalid data | Shipped (beta.10) | [#37](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/37) |
| Trace: `tracestate` grammar (W3C Trace Context) | Key/value grammar incl. multi-tenant `tenant-id@system-id` form (tenant ≤ 241 starting `lcalpha`/DIGIT, system ≤ 14 starting `lcalpha`) | Shipped (beta.7, exact grammar beta.9) | #38 |
| Trace: multi-tenant `tracestate` accessors | Typed multi-tenant key helpers (beyond the spec — W3C conformance prior art) | Parked pre-donation | #48 (ships as a Dartastic extension); upstream proposal: [#53](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/53) (fixes #49) |
| Providers (`trace/api.md`, `error-handling.md`) | `tracerProvider('')`/`meterProvider('')`/`loggerProvider('')` return working defaults, never throw | Shipped (beta.10) | [#39](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/39) |
| API lifecycle | Pre-initialization accessors lazily install the no-op API factory instead of throwing | Shipped (beta.8/beta.9) | #27, #32, #33, #34 |
| Semantic conventions (attribute registry, metrics, events, entities) | Full registry coverage, generated with OTel Weaver, per-namespace files, registry-audit tests | Shipped (beta.10) | [#52](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/52) (fixed #50, #51) |

## Known gaps and posture

- **`telemetry.sdk.language` has no `dart` well-known value upstream** —
  an upstream semantic-conventions gap discovered while generating the
  registry enums; SDKs keep emitting the literal `dart`. Candidate for an
  upstream PR alongside the multi-tenant `tracestate` proposal
  ([doc/proposals/tracestate-multi-tenant.md](doc/proposals/tracestate-multi-tenant.md)
  once merged).
- **Vendor/RUM conventions** are not part of the OTel specification and
  are deprecated for removal from this package (see PR #52); the API
  surface will contain only official conventions.
- **Metrics and Logs API clauses** were not part of this audit wave
  beyond the provider-accessor and lifecycle work; they are the natural
  next audit targets.

## Coordination

This work is part of standing up the **Dart & Flutter SIG**. Discussion
happens publicly on the issues and PRs above (interim home: #44) until
the SIG's CNCF Slack channel exists.
