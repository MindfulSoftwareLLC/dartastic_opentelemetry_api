# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
