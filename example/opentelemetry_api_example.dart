// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// ignore_for_file: unused_local_variable

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// The API does nothing on it's own, it's more typical to use the SDK.
/// However, as required vby the OpenTelementry Specification, the API
/// works (as a no-op) without the SDK installed.
void main() {
  OTelAPI.initialize(endpoint: 'http://localhost:4317');
  final Attribute<String> stringAttribute =
      OTelAPI.attributeString('example_string_key', 'foo');
  final Attribute<bool> boolAttribute =
      OTelAPI.attributeBool('example_bool_key', true);
  final Attribute<int> intAttr = OTelAPI.attributeInt('example_int_key', 42);
  final Attribute<double> doubleAttribute =
      OTelAPI.attributeDouble('example_double_key', 42.1);
  final Attribute<List<String>> stringListAttribute =
      OTelAPI.attributeStringList(
          'example_string_list_key', ['foo', 'bar', 'baz']);
  final Attribute<List<bool>> boolListAttribute =
      OTelAPI.attributeBoolList('example_bool_key', [true, false, true]);
  final Attribute<List<int>> intListAttr =
      OTelAPI.attributeIntList('example_int_list_key', [42, 43, 44]);
  final Attribute<List<double>> doubleListAttribute =
      OTelAPI.attributeDoubleList(
          'example_double_list_key', [42.0, 42.1, 42.2]);

  OTelAPI.attributes([
    stringAttribute,
    boolAttribute,
    intAttr,
    doubleAttribute,
    stringListAttribute,
    boolListAttribute,
    intListAttr,
    doubleListAttribute
  ]);

  final Baggage baggage = OTelAPI.baggageForMap({'userId': 'yoda'});
  //set the current context to one with the new baggage
  Context.current = OTelAPI.context(baggage: baggage);
  final defaultGlobalAPINOOPTracerProvider = OTelAPI.tracerProvider();
  final tracer = defaultGlobalAPINOOPTracerProvider
      .getTracer('dart-otel-api-example-service');
  final APISpan rootSpan = tracer.startSpan('doSomeExampleSpan');
  // Same thing as above, more simply but will some loss of type checking
  // If your Map has anything but the types above and exception will be thrown.
  final Attributes equalToTheAbove = OTelAPI.attributesFromMap({
    'example_string_key': 'foo',
    'example_bool_key': true,
    'example_int_key': 42,
    'example_double_key': 42.1,
    'example_string_list_key': ['foo', 'bar', 'baz'],
    'example_bool_list_key': [true, false, true],
    'example_int_list_key': [42, 43, 44],
    'example_double_list_key': [42.0, 42.1, 42.2]
  });
  rootSpan.attributes = equalToTheAbove;
  rootSpan.addEventNow('data-retrieved',
      OTelAPI.attributes([OTelAPI.attributeString('event-foo', 'bar')]));
  rootSpan.end(
      spanStatus: SpanStatusCode.Ok); //Capitalized Ok to match the OTel spec
}
