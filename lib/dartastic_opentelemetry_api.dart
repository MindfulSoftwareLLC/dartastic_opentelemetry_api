// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// OpenTelemetry API for Dart
///
/// This library provides the OpenTelemetry API implementation for Dart,
/// following the OpenTelemetry specification. It includes support for
/// tracing, metrics, baggage, and context propagation.
///
/// For more information, see the OpenTelemetry specification at
/// https://opentelemetry.io/docs/specs/otel/
library;

// Baggage
export 'src/api/baggage/baggage.dart' hide BaggageCreate;
export 'src/api/baggage/baggage_entry.dart';
// Common
export 'src/api/common/attribute.dart' hide AttributeCreate;
export 'src/api/common/attributes.dart' hide AttributesCreate;
export 'src/api/common/instrumentation_scope.dart'
    hide InstrumentationScopeCreate;
export 'src/api/common/timestamp.dart';
// Context
export 'src/api/context/context.dart' hide ContextCreate;
export 'src/api/context/context_key.dart' hide ContextKeyCreate;
export 'src/api/context/propagation/composite_propagator.dart'
    hide CompositePropagatorCreate;
export 'src/api/context/propagation/context_propagator.dart';
export 'src/api/context/propagation/noop_text_map_propagator.dart';
export 'src/api/context/propagation/text_map_propagator.dart';
export 'src/api/factory/otel_api_factory.dart';
// Id
export 'src/api/id/id_generator.dart';
// Log
export 'src/api/logs/log_record.dart';
export 'src/api/logs/logger.dart' hide LoggerCreate;
export 'src/api/logs/logger_provider.dart' hide LogProviderCreate;
export 'src/api/logs/severity.dart';
//Metrics
export 'src/api/metrics/counter.dart' hide CounterCreate;
export 'src/api/metrics/gauge.dart' hide GaugeCreate;
export 'src/api/metrics/histogram.dart' hide HistogramCreate;
export 'src/api/metrics/instrument.dart';
export 'src/api/metrics/measurement.dart' hide MeasurementCreate;
export 'src/api/metrics/meter.dart' hide APIMeterCreate;
export 'src/api/metrics/meter_provider.dart' hide MeterProviderCreate;
export 'src/api/metrics/observable_callback.dart';
export 'src/api/metrics/observable_counter.dart' hide ObservableCounterCreate;
export 'src/api/metrics/observable_gauge.dart' hide ObservableGaugeCreate;
export 'src/api/metrics/observable_result.dart';
export 'src/api/metrics/observable_up_down_counter.dart'
    hide ObservableUpDownCounterCreate;
export 'src/api/metrics/up_down_counter.dart' hide UpDownCounterCreate;
// API
export 'src/api/otel_api.dart';
// Semantics
export 'src/api/semantics/http_header_attribute.dart';
export 'src/api/semantics/rum.dart';
export 'src/api/semantics/semantics_base.dart';
export 'src/api/semantics/semconv/semconv.dart';
// Trace
export 'src/api/trace/span.dart' hide APISpanCreate;
export 'src/api/trace/span_context.dart' hide SpanContextCreate;
export 'src/api/trace/span_event.dart' hide SpanEventCreate;
export 'src/api/trace/span_id.dart' hide SpanIdCreate;
export 'src/api/trace/span_kind.dart';
export 'src/api/trace/span_link.dart' hide SpanLinkCreate;
export 'src/api/trace/trace_flags.dart' hide TraceFlagsCreate;
export 'src/api/trace/trace_id.dart' hide TraceIdCreate;
export 'src/api/trace/trace_state.dart' hide TraceStateCreate;
export 'src/api/trace/tracer.dart' hide TracerCreate;
export 'src/api/trace/tracer_provider.dart' hide TracerProviderCreate;
export 'src/factory/otel_factory.dart';
// Util
export 'src/util/default_time_provider.dart';
export 'src/util/otel_log.dart';
export 'src/util/time_provider.dart';
export 'src/util/web_time_provider.dart';
