# Upstream proposal: W3C multi-tenant `tracestate` keys (`tenant-id@system-id`)

| Field          | Value                                                                                                                          |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **Status**     | Ready to post                                                                                                                    |
| **Target**     | [open-telemetry/opentelemetry-specification](https://github.com/open-telemetry/opentelemetry-specification) (new issue)          |
| **Tracking**   | [MindfulSoftwareLLC/dartastic_opentelemetry_api#49](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/issues/49) |
| **Author**     | Michael Bushe (@michaelbushe) — posts upstream himself; this document is the copy-paste artifact                                 |

This document contains the finalized text for an upstream
`opentelemetry-specification` issue, followed by supporting notes for the
discussion that follows it. Section 2 is the paste; section 3 is not.

## 1. Summary

The W3C Trace Context specification defines a second key form for
`tracestate` list members — `tenant-id@system-id`, for multi-tenant tracing
systems. The OpenTelemetry specification's TraceState API section never
mentions it, and implementations are left to hand-roll the key grammar, with
divergent results. The proposal below asks the specification to (a) require
that TraceState implementations accept the W3C multi-tenant key form
(a conformance fix) and (b) optionally specify vendor-neutral convenience
accessors for it — while placing automatic stamping of tenant identity
explicitly out of scope, because that privacy constraint is the likely reason
no implementation has touched the form.

## 2. Ready-to-post issue text

Copy the title and body below into a new issue at
`open-telemetry/opentelemetry-specification`. View this file raw to copy the
Markdown source of the body.

**Title**

```text
TraceState API ignores W3C's multi-tenant key form (tenant-id@system-id)
```

**Body** — copy everything between the `BEGIN ISSUE BODY` and
`END ISSUE BODY` markers.

<!-- ═══════════════════ BEGIN ISSUE BODY — copy from here ═══════════════════ -->

There is likely a reason no OpenTelemetry language API supports the W3C
multi-tenant `tracestate` key form, and it is worth naming up front: naive
support reads as *automatic tenant propagation*. `tracestate` flows to every
downstream hop of a distributed trace — including third-party services the
instrumented application calls — so an API that stamped tenant identity into
`tracestate` by default would broadcast that identity beyond the operator's
trust boundary. This proposal is therefore explicitly **not** a request for
automatic stamping of tenant identity. It asks for two narrower things:
validation conformance (accept the key form W3C defines) and, optionally,
explicit typed accessors that a caller must deliberately invoke. That
constraint is the design premise of the proposal, not an objection to it.

### What W3C defines

W3C Trace Context (Recommendation, 23 November 2021) defines two key forms
for `tracestate` list members
([§ 3.3.1.3.1 Key](https://www.w3.org/TR/trace-context/#key)):

```abnf
key = simple-key / multi-tenant-key
simple-key = lcalpha 0*255( lcalpha / DIGIT / "_" / "-"/ "*" / "/" )
multi-tenant-key = tenant-id "@" system-id
tenant-id = ( lcalpha / DIGIT ) 0*240( lcalpha / DIGIT / "_" / "-"/ "*" / "/" )
system-id = lcalpha 0*13( lcalpha / DIGIT / "_" / "-"/ "*" / "/" )
lcalpha    = %x61-7A ; a-z
```

The accompanying prose:

> The second type of key is used by multi-tenant tracing systems where each
> tenant requires a unique tracestate entry.

> Multi-tenant keys consist of a tenant ID followed by the `@` character
> followed by a system ID. This allows for fast and robust parsing. For
> example, tracing system `xyz` can easily find all of its tracestate entries
> by searching for all instances of `@xyz=`.

This is the key form W3C provides for multi-tenant vendors, and it is used in
production today — for example Dynatrace's `{tenant}@dt` entries.

### The gap in OpenTelemetry

The OpenTelemetry specification's
[TraceState API section](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md#tracestate)
requires only the four generic operations (get, add, update, delete) and
delegates the rest to W3C:

> These operations MUST follow the rules described in the
> [W3C Trace Context specification](https://www.w3.org/TR/trace-context/#tracestate-header).

> `TraceState` MUST at all times be valid according to rules specified in
> [W3C Trace Context specification](https://www.w3.org/TR/trace-context/#tracestate-header-field-values).
> Every mutating operations MUST validate input parameters.

Neither the TraceState section nor the semantic conventions mention the
multi-tenant key form anywhere, so every implementation hand-rolls the key
grammar, and validators in the wild diverge: some SDK validators are stricter
than W3C and reject `@` in keys outright (dropping or refusing the entry),
while others accept `@` but diverge from the per-part grammar — for example
rejecting a digit-leading `tenant-id` (W3C allows `lcalpha / DIGIT` in the
first position) or missing the per-part length caps (241 for `tenant-id`, 14
for `system-id`). An implementation that refuses or mangles a valid
`{tenant-id}@{system-id}` entry is non-conformant with W3C when
interoperating with multi-tenant vendors' tracestate entries.

### Proposal

1. **Required — conformance fix.** The TraceState API section should
   acknowledge W3C's second key form and state that implementations MUST
   accept multi-tenant keys (`tenant-id@system-id`, validated per the W3C
   per-part grammar) wherever tracestate keys are validated: parsing incoming
   headers, `put`-style mutations, and serialization.

2. **Optional — convenience accessors.** Specify a small, vendor-neutral
   accessor surface for the form:

   - build/validate a multi-tenant key from `(tenantId, systemId)`, failing
     fast on grammar violations;
   - get/put an entry by `(tenantId, systemId)` pair, with the same
     freshness/limit semantics as the generic operations;
   - enumerate a given system's tenant entries.

   Explicitly out of scope: any automatic stamping of tenant identity into
   `tracestate`. The accessors are inert unless a caller deliberately invokes
   them; whether and when to propagate tenant identity remains an application
   or vendor decision.

### Prior art

The [Dart OpenTelemetry reference API](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api)
validates the multi-tenant key form per the W3C grammar — accepted since
1.0.0-beta.7, with the per-part grammar tightened to exact W3C conformance
(digit-leading `tenant-id`, 241/14 length caps) in 1.0.0-beta.9
([PR #38](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/38);
implementation in
[`trace_state.dart`](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/blob/main/lib/src/api/trace/trace_state.dart)).
A vendor-neutral accessor surface matching proposal (2) —
`TraceState.multiTenantKey(tenantId, systemId)`,
`putMultiTenant`/`getMultiTenant`, and `tenantsForSystem(systemId)` — exists
as prior art in
[PR #48](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/pull/48)
(parked from the canonical repo pre-CNCF-donation; shipping as an extension
in the Dartastic maintained release). It carries no vendor-specific behavior:
any `(tenant, system)` pair works, and nothing is stamped automatically.

<!-- ═══════════════════ END ISSUE BODY — copy to here ═══════════════════ -->

## 3. Supporting notes for the discussion (not part of the paste)

### 3.1 Exact shipped validation grammar

From
[`lib/src/api/trace/trace_state.dart`](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/blob/main/lib/src/api/trace/trace_state.dart):

```dart
static final RegExp _simpleKeyFormat = RegExp(r'^[a-z][a-z0-9_\-*/]{0,255}$');
static final RegExp _tenantIdFormat =
    RegExp(r'^[a-z0-9][a-z0-9_\-*/]{0,240}$');
static final RegExp _systemIdFormat = RegExp(r'^[a-z][a-z0-9_\-*/]{0,13}$');
```

A key containing `@` must contain exactly one `@`; the substring before it
must match `_tenantIdFormat` and the substring after it `_systemIdFormat`.

Per-part limits and their derivation from the W3C ABNF:

| Part        | First character   | Max length | Derivation                          |
| ----------- | ----------------- | ---------- | ----------------------------------- |
| simple key  | `lcalpha`         | 256        | `lcalpha` + `0*255(...)`            |
| `tenant-id` | `lcalpha / DIGIT` | 241        | `( lcalpha / DIGIT )` + `0*240(...)` |
| `system-id` | `lcalpha`         | 14         | `lcalpha` + `0*13(...)`             |

The multi-tenant form partitions the same 256-character key budget as the
simple form: 241 (`tenant-id`) + 1 (`@`) + 14 (`system-id`) = 256. That is
where the otherwise odd-looking 241 and 14 come from, and why per-part caps
matter — a validator that only checks a 256-char total accepts keys W3C
rejects (for example a 250-char tenant-id).

### 3.2 Platform posture / non-goals (recorded in #49 so it is not relitigated)

Stamping `{orgId}@dartastic` from SDKs is not enabled by default anywhere:
`tracestate` propagates to every downstream hop, *including third-party
services the app calls*, so broadcasting tenant identity is an opt-in
decision for a feature that consumes it (cross-service per-tenant sampling,
edge diagnostics). Ingest tenancy remains derived from the verified key —
the tracestate tenant is context, never authorization.

### 3.3 SIG positioning

Dart's reference implementation is the first OpenTelemetry API with
first-class support for the W3C multi-tenant key form — useful prior art for
the proposal, and a good visibility point for the Dart/Flutter SIG formation.

### 3.4 Verify before posting

The "some SDK validators reject `@` outright" claim comes from the survey
recorded in #49 (Java, Go, JS, Python). Re-check the current main-branch
validators before posting; if the majors all accept `@` today, keep the
per-part-grammar divergence (digit-leading `tenant-id`, missing 241/14 caps)
as the concrete conformance example — the Dart implementation itself had
exactly that bug until PR #38, which demonstrates the class of defect the
spec's silence produces.
