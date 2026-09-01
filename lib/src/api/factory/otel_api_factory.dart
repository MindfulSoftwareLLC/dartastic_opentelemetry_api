// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';

import '../../factory/otel_factory.dart';
import '../../util/otel_error_handler.dart';
import '../baggage/baggage.dart';
import '../baggage/baggage_entry.dart';
import '../common/any_value.dart';
import '../common/attribute.dart';
import '../common/attributes.dart';
import '../common/instrumentation_scope.dart';

import '../context/context.dart';
import '../context/context_key.dart';
import '../id/id_generator.dart';
import '../logs/logger_provider.dart';
import '../metrics/counter.dart';
import '../metrics/gauge.dart';
import '../metrics/histogram.dart';
import '../metrics/meter.dart';
import '../metrics/meter_provider.dart';
import '../metrics/observable_callback.dart';
import '../metrics/observable_counter.dart';
import '../metrics/observable_gauge.dart';
import '../metrics/observable_up_down_counter.dart';
import '../metrics/up_down_counter.dart';
import '../otel_api.dart';
import '../trace/span_context.dart';
import '../trace/span_event.dart';
import '../trace/span_id.dart';
import '../trace/span_link.dart';
import '../trace/trace_flags.dart';
import '../trace/trace_id.dart';
import '../trace/trace_state.dart';
import '../trace/tracer_provider.dart';

/// Factory function that creates an instance of OTelAPIFactory.
///
/// This function is used as the default factory function for creating OTelAPIFactory
/// instances when no SDK is installed.
///
/// [apiEndpoint] The endpoint URL for the OpenTelemetry backend
/// [apiServiceName] The name of the service being instrumented
/// [apiServiceVersion] The version of the service being instrumented
OTelFactory otelApiFactoryFactoryFunction({
  required String apiEndpoint,
  required String apiServiceName,
  required String apiServiceVersion,
}) {
  return OTelAPIFactory(
    apiEndpoint: apiEndpoint,
    apiServiceName: apiServiceName,
    apiServiceVersion: apiServiceVersion,
  );
}

/// The factory used when no SDK is installed. The OpenTelemetry specification
/// requires the API to work without an SDK installed
/// All construction APIs use the factory, such as builders or 'from' helpers.
class OTelAPIFactory extends OTelFactory {
  /// Creates a new instance of OTelAPIFactory with the specified parameters.
  ///
  /// [apiEndpoint] The endpoint URL for the OpenTelemetry backend
  /// [apiServiceName] The name of the service being instrumented
  /// [apiServiceVersion] The version of the service being instrumented
  /// [factoryFactory] Optional factory function for creating OTelFactory instances
  OTelAPIFactory(
      {required super.apiEndpoint,
      required super.apiServiceName,
      required super.apiServiceVersion,
      OTelFactoryCreationFunction? factoryFactory =
          otelApiFactoryFactoryFunction})
      : super(factoryFactory: factoryFactory!);

  /// The pure API factory is the spec-mandated no-op used when no SDK is
  /// installed; SDK initialization may replace it.
  ///
  /// SDK factories extend [OTelAPIFactory], so a real implementation MUST
  /// override this to return `false` — otherwise SDK initialization would
  /// treat it as replaceable.
  @override
  bool get isAPIFactory => true;

  @override
  BaggageEntry baggageEntry(String value, [String? metadata]) {
    return BaggageEntryFactory.create<String>(value, metadata);
  }

  @override
  Baggage baggage([Map<String, BaggageEntry>? entries]) {
    return BaggageCreate.create<Map<String, BaggageEntry>>(entries);
  }

  @override
  Context context({Baggage? baggage}) {
    return ContextCreate.create(baggage: baggage);
  }

  @override
  ContextKey<T> contextKey<T>(String name, Uint8List id,
      {bool isTransferable = false}) {
    return ContextKeyCreate.create<T>(name, id, isTransferable: isTransferable);
  }

  @override
  APITracerProvider tracerProvider(
      {required String endpoint,
      String serviceName = OTelAPI.defaultServiceName,
      String? serviceVersion = OTelAPI.defaultServiceVersion}) {
    return TracerProviderCreate.create(
        endpoint: endpoint,
        serviceName: serviceName,
        serviceVersion: serviceVersion);
  }

  @override
  APIMeterProvider meterProvider(
      {required String endpoint,
      String serviceName = OTelAPI.defaultServiceName,
      String? serviceVersion = OTelAPI.defaultServiceVersion}) {
    return MeterProviderCreate.create(
        endpoint: endpoint,
        serviceName: serviceName,
        serviceVersion: serviceVersion);
  }

  /// Creates a new instance of [APILoggerProvider] with the specified parameters.
  ///
  /// [endpoint] The endpoint URL for the OpenTelemetry backend
  /// [serviceName] The name of the service being logged
  /// [serviceVersion] The version of the service being logged
  @override
  APILoggerProvider loggerProvider({
    required String endpoint,
    String serviceName = OTelAPI.defaultServiceName,
    String? serviceVersion = OTelAPI.defaultServiceVersion,
  }) {
    return LogProviderCreate.create(
      endpoint: endpoint,
      serviceName: serviceName,
      serviceVersion: serviceVersion,
    );
  }

  @override
  Attributes attributes([List<Attribute>? entries]) {
    return AttributesCreate.create(entries ?? []);
  }

  @override
  Attributes attributesFromList(List<Attribute> attributeList) {
    return AttributesCreate.create(attributeList);
  }

  @override
  Attributes attributesFromMap(Map<String, Object> namedMap) {
    return attrsFromMap(namedMap);
  }

  static Attributes attrsFromMap(Map<String, Object> namedMap) {
    final attributes = <Attribute>[];
    namedMap.forEach((key, value) {
      if (value is Attribute) {
        attributes.add(value);
      } else {
        try {
          attributes
              .add(AttributeCreate.create(key, AnyValue.fromObject(value)));
        } catch (e) {
          OTelErrorHandling.report(ArgumentError(
              'Ignoring attribute "$key" because it contains unsupported types: $e'));
        }
      }
    });
    return AttributesCreate.create(attributes);
  }

  /// Creates an `Attribute` for the given String.
  @override
  Attribute attributeString(String key, String value) {
    return AttributeCreate.create(key, AnyValueString(value));
  }

  /// Creates an `Attribute` for the given boolean.
  @override
  Attribute attributeBool(String key, bool value) {
    return AttributeCreate.create(key, AnyValueBool(value));
  }

  /// Creates an `Attribute` for the given int.
  @override
  Attribute attributeInt(String key, int value) {
    return AttributeCreate.create(key, AnyValueInt(value));
  }

  /// Creates an `Attribute` for the given double.
  @override
  Attribute attributeDouble(String key, double value) {
    return AttributeCreate.create(key, AnyValueDouble(value));
  }

  /// Creates an `Attribute` for the given String list.
  @override
  Attribute attributeStringList(String key, List<String> value) {
    return AttributeCreate.create(
        key, AnyValueArray(value.map(AnyValueString.new).toList()));
  }

  /// Creates an `Attribute` for the given boolean list.
  @override
  Attribute attributeBoolList(String key, List<bool> value) {
    return AttributeCreate.create(
        key, AnyValueArray(value.map(AnyValueBool.new).toList()));
  }

  /// Creates an `Attribute` for the given int list.
  @override
  Attribute attributeIntList(String key, List<int> value) {
    return AttributeCreate.create(
        key, AnyValueArray(value.map(AnyValueInt.new).toList()));
  }

  /// Creates an `Attribute` for the given double list.
  @override
  Attribute attributeDoubleList(String key, List<double> value) {
    return AttributeCreate.create(
        key, AnyValueArray(value.map(AnyValueDouble.new).toList()));
  }

  @override
  Attribute attributeMap(String key, Map<String, AnyValue> value) {
    return AttributeCreate.create(key, AnyValueMap(value));
  }

  @override
  Attribute attributeArray(String key, List<AnyValue> value) {
    return AttributeCreate.create(key, AnyValueArray(value));
  }

  @override
  Attribute attributeBytes(String key, List<int> value) {
    return AttributeCreate.create(key, AnyValueBytes(value));
  }

  @override
  InstrumentationScope instrumentationScope(
      {required String name,
      String version = '1.0.0',
      String? schemaUrl,
      Attributes? attributes}) {
    return InstrumentationScopeCreate.create(
      name: name,
      version: version,
      schemaUrl: schemaUrl,
      attributes: attributes,
    );
  }

  @override
  TraceId traceId([Uint8List? traceIdBytes]) {
    traceIdBytes ??= IdGenerator.generateTraceId();
    return TraceIdCreate.create(traceIdBytes);
  }

  @override
  SpanId spanId([Uint8List? spanId]) {
    spanId ??= IdGenerator.generateSpanId();
    return SpanIdCreate.create(spanId);
  }

  @override
  TraceId traceIdInvalid() {
    return TraceIdCreate.create(TraceId.invalidTraceIdBytes);
  }

  @override
  SpanId spanIdInvalid([Uint8List? spanId]) {
    return SpanIdCreate.create(SpanId.invalidSpanIdBytes);
  }

  @override
  TraceState traceState(Map<String, String>? entries) {
    return TraceStateCreate.create(entries);
  }

  @override
  TraceFlags traceFlags([int? flags]) {
    return TraceFlagsCreate.create(flags);
  }

  @override
  SpanContext spanContext(
      {TraceId? traceId,
      SpanId? spanId,
      SpanId? parentSpanId,
      TraceFlags? traceFlags,
      TraceState? traceState,
      bool? isRemote}) {
    return SpanContextCreate.create(
        traceId: traceId,
        spanId: spanId,
        parentSpanId: parentSpanId,
        traceFlags: traceFlags,
        traceState: traceState,
        isRemote: isRemote);
  }

  @override
  SpanContext spanContextFromParent(SpanContext parent) {
    return spanContext(
      traceId: parent.traceId,
      // MUST inherit trace ID from parent
      spanId: spanId(),
      // Generate new span ID
      parentSpanId: parent.spanId,
      // Set parent's span ID as parent
      traceFlags: parent.traceFlags,
      // Inherit trace flags
      traceState: parent.traceState,
      // Inherit trace state
      isRemote: false, // Local spans are not remote
    );
  }

  @override
  SpanContext spanContextInvalid() {
    return spanContext(
      traceId: traceIdInvalid(),
      spanId: spanIdInvalid(),
    );
  }

  @override
  SpanLink spanLink(SpanContext spanContext, {Attributes? attributes}) {
    return SpanLinkCreate.create(
        spanContext: spanContext, attributes: attributes);
  }

  @override
  SpanEvent spanEvent(String name,
      [Attributes? attributes, DateTime? timestamp]) {
    return SpanEventCreate.create(
      name: name,
      attributes: attributes,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  @override
  SpanEvent spanEventNow(String name, [Attributes? attributes]) {
    return SpanEventCreate.create(
        name: name, timestamp: DateTime.now(), attributes: attributes);
  }

  @override
  APICounter createCounter(String name, {String? description, String? unit}) {
    return CounterCreate.create(
      name: name,
      description: description,
      unit: unit,
      meter: APIMeterCreate.create(name: '@api/default'),
    );
  }

  @override
  APIUpDownCounter createUpDownCounter(String name,
      {String? description, String? unit}) {
    return UpDownCounterCreate.create(
      name: name,
      description: description,
      unit: unit,
      meter: APIMeterCreate.create(name: '@api/default'),
    );
  }

  @override
  APIGauge createGauge(String name, {String? description, String? unit}) {
    return GaugeCreate.create(
      name: name,
      description: description,
      unit: unit,
      meter: APIMeterCreate.create(name: '@api/default'),
    );
  }

  @override
  APIHistogram createHistogram(String name,
      {String? description, String? unit, List<double>? boundaries}) {
    return HistogramCreate.create(
      name: name,
      description: description,
      unit: unit,
      meter: APIMeterCreate.create(name: '@api/default'),
      boundaries: boundaries,
    );
  }

  @override
  APIObservableCounter createObservableCounter(String name,
      {String? description, String? unit, ObservableCallback? callback}) {
    return ObservableCounterCreate.create(
      name: name,
      description: description,
      unit: unit,
      meter: APIMeterCreate.create(name: '@api/default'),
      callback: callback,
    );
  }

  @override
  APIObservableGauge createObservableGauge(String name,
      {String? description, String? unit, ObservableCallback? callback}) {
    return ObservableGaugeCreate.create(
      name: name,
      description: description,
      unit: unit,
      meter: APIMeterCreate.create(name: '@api/default'),
      callback: callback,
    );
  }

  @override
  APIObservableUpDownCounter createObservableUpDownCounter(String name,
      {String? description, String? unit, ObservableCallback? callback}) {
    return ObservableUpDownCounterCreate.create(
      name: name,
      description: description,
      unit: unit,
      meter: APIMeterCreate.create(name: '@api/default'),
      callback: callback,
    );
  }

  @override
  Baggage baggageForMap(Map<String, String> keyValuePairs) {
    final entries = <String, BaggageEntry>{};
    for (var key in keyValuePairs.keys) {
      entries[key] = baggageEntry(keyValuePairs[key]!);
    }
    return baggage(entries);
  }
}
