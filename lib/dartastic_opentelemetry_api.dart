// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// OpenTelemetry API for Dart
///
/// This library provides the OpenTelemetry API implementation for Dart,
/// following the OpenTelemetry specification. It includes support for
/// tracing, metrics, baggage, and context propagation.
///
/// For more information, see the OpenTelemetry specification at
/// https://opentelemetry.io/docs/specs/otel/
library dartastic_opentelemetry_api;

// Baggage
export 'src/api/baggage/baggage.dart';
export 'src/api/baggage/baggage_entry.dart';
// Common
export 'src/api/common/attribute.dart';
export 'src/api/common/attributes.dart';
export 'src/api/common/instrumentation_scope.dart';
export 'src/api/common/timestamp.dart';
// Context
export 'src/api/context/context.dart';
export 'src/api/context/context_key.dart';
export 'src/api/context/propagation/composite_propagator.dart';
export 'src/api/context/propagation/context_propagator.dart';
export 'src/api/context/propagation/text_map_propagator.dart';
export 'src/api/factory/otel_api_factory.dart';
// Id
export 'src/api/id/id_generator.dart';
//Metrics
export 'src/api/metrics/counter.dart';
export 'src/api/metrics/gauge.dart';
export 'src/api/metrics/histogram.dart';
export 'src/api/metrics/instrument.dart';
export 'src/api/metrics/measurement.dart';
export 'src/api/metrics/meter.dart';
export 'src/api/metrics/meter_provider.dart';
export 'src/api/metrics/observable_callback.dart';
export 'src/api/metrics/observable_counter.dart';
export 'src/api/metrics/observable_gauge.dart';
export 'src/api/metrics/observable_result.dart';
export 'src/api/metrics/observable_up_down_counter.dart';
export 'src/api/metrics/up_down_counter.dart';
// API
export 'src/api/otel_api.dart';
export 'src/api/semantics/lifecycle_state.dart';
export 'src/api/semantics/navigation_action.dart';
export 'src/api/semantics/resource_semantics.dart';
// Semantics
export 'src/api/semantics/semantics.dart';
export 'src/api/semantics/ui_semantics.dart';
// Trace
export 'src/api/trace/span.dart';
export 'src/api/trace/span_context.dart';
export 'src/api/trace/span_event.dart';
export 'src/api/trace/span_id.dart';
export 'src/api/trace/span_kind.dart';
export 'src/api/trace/span_link.dart';
export 'src/api/trace/trace_flags.dart';
export 'src/api/trace/trace_id.dart';
export 'src/api/trace/trace_state.dart';
export 'src/api/trace/tracer.dart';
export 'src/api/trace/tracer_provider.dart';
export 'src/factory/otel_factory.dart';
// Util
export 'src/util/otel_log.dart';
// Log
export 'src/api/logs/logger.dart';
export 'src/api/logs/logger_provider.dart';
