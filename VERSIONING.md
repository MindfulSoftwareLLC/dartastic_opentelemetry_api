# Versioning Strategy

This document outlines the versioning strategy for the OpenTelemetry API for Dart.

## Semantic Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/) with the format MAJOR.MINOR.PATCH:

1. **MAJOR** version increments indicate incompatible API changes
2. **MINOR** version increments indicate new functionality added in a backward-compatible manner
3. **PATCH** version increments indicate backward-compatible bug fixes

## Pre-1.0 Development

While the package is in pre-1.0 development (0.x.y):

- MINOR version increments may include breaking changes
- We will attempt to minimize breaking changes, but they may be necessary as we align with the evolving OpenTelemetry specification
- PATCH version increments will remain backward-compatible bug fixes

## Stability Guarantees

### API Components

Each API component has a stability level:

1. **Stable**: Breaking changes only in major versions after 1.0
2. **Beta**: Generally stable, but breaking changes may occur in minor versions
3. **Alpha**: Experimental, breaking changes may occur in any version

Current stability levels:

| API Component      | Stability Level |
|--------------------|----------------|
| Context API        | Beta           |
| Trace API          | Beta           |
| Metrics API        | Beta           |
| Baggage API        | Beta           |
| Propagation API    | Beta           |

### Deprecation Policy

- Deprecated features will be marked with the `@deprecated` annotation
- Deprecated features will be documented in the CHANGELOG
- Deprecated features will be supported for at least one minor version before removal
- Removal of deprecated features will only occur in major version updates after 1.0

## Alignment with OpenTelemetry Specification

This package aims to align with the OpenTelemetry specification:

- The minor version may increment to align with specification changes
- We track the specification version we implement in our documentation
- Critical specification changes may necessitate breaking changes

## Semantic Conventions Versioning

The semantic-convention enums under `lib/src/api/semantics/semconv/` are
generated from a pinned OpenTelemetry semantic-conventions registry with
OTel Weaver (`tool/semconv/generate.sh`; verify freshness with
`--check`). The pinned registry version and commit are recorded in
`SemconvRegistry` and in every generated file header, and every registry
bump is documented in the CHANGELOG.

Within a major version, registry regenerations are **additive and
deprecating only**:

- New namespaces, attributes, enum members, metrics, events, and
  entities may be added (a MINOR change).
- Attributes the registry deprecates gain `@Deprecated` but remain.
- Registry changes that would rename or remove generated Dart
  identifiers, or change emitted key/value strings, are **held back and
  batched into the next MAJOR release**.
- Exception: spec-fidelity corrections — where a generated member
  emitted a string that did not match the registry — are bug fixes and
  may land in a MINOR release with a prominent wire-format table in the
  CHANGELOG (precedent: 1.0.0-beta.10).

Vendor- and product-specific conventions are not part of this package:
only registry conventions (plus their spec-mandated deprecation
history) appear here. Vendor/RUM conventions live in downstream layers
(e.g. the Flutter RUM layer).

## Long-Term Support (LTS)

- No formal LTS versions currently exist for this pre-1.0 package
- LTS policies will be established when we reach version 1.0

## Release Schedule

- PATCH releases: As needed for bug fixes
- MINOR releases: Roughly monthly, aligned with significant feature completions
- MAJOR releases: Only when necessary for breaking changes

## Upgrading Guidelines

Upgrade guidelines will be provided in the CHANGELOG.md file with each release, highlighting:

- Breaking changes (if any)
- New features
- Deprecations
- Bug fixes
- Migration guides for major version changes
