// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// Example-only attribute keys used in this file. Prefer enums over raw
/// strings — the API's built-in semantic-convention enums (UserSemantics,
/// HttpResource, DatabaseResource, etc.) cover the OTel-defined keys; this
/// enum holds the keys that aren't in any convention. In your own app,
/// rename this to something domain-specific (e.g. `CheckoutAttribute`).
enum ExampleAttribute implements OTelSemantic {
  // Generic demo keys showing attribute types.
  exampleString('example.string'),
  exampleBool('example.bool'),
  exampleInt('example.int'),
  exampleDouble('example.double'),
  exampleStringList('example.string_list'),
  exampleBoolList('example.bool_list'),
  exampleIntList('example.int_list'),
  exampleDoubleList('example.double_list'),
  eventFoo('event.foo'),
  // Auth / cache / batch / payment / retry — none of these are in the
  // OTel semantic conventions, so they're app-defined here.
  authMethod('auth.method'),
  cacheKey('cache.key'),
  cacheRegion('cache.region'),
  batchId('batch.id'),
  jobsTotal('jobs.total'),
  paymentUserId('payment.user_id'),
  paymentMethod('payment.method'),
  paymentGateway('payment.gateway'),
  retryCount('retry.count');

  @override
  final String key;

  @override
  String toString() => key;

  const ExampleAttribute(this.key);
}

/// The API does nothing on its own; it's more typical to use the SDK.
/// However, as required by the OpenTelemetry Specification, the API
/// works (as a no-op) without the SDK installed.
void main() {
  OTelAPI.initialize(endpoint: 'http://localhost:4317');
  // Use typed enum keys — never raw strings.
  final stringAttribute =
      OTelAPI.attributeString(ExampleAttribute.exampleString.key, 'foo');
  final boolAttribute =
      OTelAPI.attributeBool(ExampleAttribute.exampleBool.key, true);
  final intAttr = OTelAPI.attributeInt(ExampleAttribute.exampleInt.key, 42);
  final doubleAttribute =
      OTelAPI.attributeDouble(ExampleAttribute.exampleDouble.key, 42.1);
  final stringListAttribute = OTelAPI.attributeStringList(
      ExampleAttribute.exampleStringList.key, ['foo', 'bar', 'baz']);
  final boolListAttribute = OTelAPI.attributeBoolList(
      ExampleAttribute.exampleBoolList.key, [true, false, true]);
  final intListAttr = OTelAPI.attributeIntList(
      ExampleAttribute.exampleIntList.key, [42, 43, 44]);
  final doubleListAttribute = OTelAPI.attributeDoubleList(
      ExampleAttribute.exampleDoubleList.key, [42.0, 42.1, 42.2]);

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

  final baggage = OTelAPI.baggageForMap({'userId': 'yoda'});
  // Create a context with the baggage and run the example within it.
  // This ensures correct propagation across asynchronous boundaries.
  OTelAPI.context(baggage: baggage).runSync(() {
    //Trace Signal
    final defaultGlobalAPINOOPTracerProvider = OTelAPI.tracerProvider();
    final tracer = defaultGlobalAPINOOPTracerProvider
        .getTracer('dart-otel-api-example-service');

    // Use withSpan to make the span active within its scope. Wrap the work
    // in try/catch/finally so the span is always ended and any thrown
    // exception is recorded with SpanStatusCode.Error per the OTel spec.
    final span = tracer.startSpan('doSomeExampleSpan');
    try {
      tracer.withSpan(span, () {
        // Same thing as above, more compactly. attributesFromSemanticMap
        // takes the typed enum directly (no `.key` on each entry) and
        // accepts any mix of OTelSemantic-implementing enums, including
        // your own. Throws at construction if a value isn't a supported
        // attribute type.
        final equalToTheAbove = OTelAPI.attributesFromSemanticMap({
          ExampleAttribute.exampleString: 'foo',
          ExampleAttribute.exampleBool: true,
          ExampleAttribute.exampleInt: 42,
          ExampleAttribute.exampleDouble: 42.1,
          ExampleAttribute.exampleStringList: ['foo', 'bar', 'baz'],
          ExampleAttribute.exampleBoolList: [true, false, true],
          ExampleAttribute.exampleIntList: [42, 43, 44],
          ExampleAttribute.exampleDoubleList: [42.0, 42.1, 42.2],
        });
        span.attributes = equalToTheAbove;
        span.addEventNow(
          'data-retrieved',
          OTelAPI.attributes(
              [OTelAPI.attributeString(ExampleAttribute.eventFoo.key, 'bar')]),
        );
      });
      // Capitalized Ok to match the OTel spec.
      span.setStatus(SpanStatusCode.Ok);
    } catch (e, stackTrace) {
      span.recordException(e, stackTrace: stackTrace);
      span.setStatus(SpanStatusCode.Error, e.toString());
      rethrow;
    } finally {
      span.end();
    }

    //Log Signal
    final defaultGlobalAPINOOPLoggerProvider = OTelAPI.loggerProvider();
    final logger = defaultGlobalAPINOOPLoggerProvider
        .getLogger('dart-otel-api-example-service');

    logger.emit(eventName: 'heartbeat', body: 'Service is healthy.');

    logger.emit(
      eventName: 'user_login',
      severityNumber: Severity.INFO,
      body: 'User successfully logged in.',
      attributes: OTelAPI.attributesFromSemanticMap({
        UserSemantics.userId: 42,
        ExampleAttribute.authMethod: 'password',
      }),
    );

    logger.emit(
      eventName: 'cache_miss',
      severityText: 'WARN',
      body: 'Cache miss for requested key.',
      attributes: OTelAPI.attributesFromSemanticMap({
        ExampleAttribute.cacheKey: 'profile_42',
        ExampleAttribute.cacheRegion: 'us-east-1',
      }),
    );

    final attrs = OTelAPI.attributesFromSemanticMap({
      DatabaseResource.dbOperation: 'update',
      DatabaseResource.dbCollectionName: 'orders',
      DatabaseResource.dbResponseReturnedRows: 3,
    });

    logger.emit(
      eventName: 'order_update',
      severityNumber: Severity.INFO,
      body: 'Order update completed.',
      attributes: attrs,
    );

    logger.emit(
      eventName: 'batch_job_summary',
      severityNumber: Severity.INFO,
      // Body is a user-defined structure (per the OTel logs spec) — its
      // inner keys are not span/log attributes, so they don't go through
      // an OTelSemantic enum.
      body: [
        {'job': 'resize_images', 'status': 'ok'},
        {'job': 'generate_thumbnails', 'status': 'ok'},
        {'job': 'sync_metadata', 'status': 'failed'},
      ],
      attributes: OTelAPI.attributesFromSemanticMap({
        ExampleAttribute.batchId: 'batch-2025-11-15-01',
        ExampleAttribute.jobsTotal: 3,
      }),
    );

    logger.emit(
      eventName: 'payment_failure',
      severityText: 'ERROR',
      body: 'Payment could not be processed.',
      attributes: OTelAPI.attributesFromSemanticMap({
        ExampleAttribute.paymentUserId: 101,
        ExampleAttribute.paymentMethod: 'credit_card',
        ExampleAttribute.paymentGateway: 'stripe',
        ExampleAttribute.retryCount: 2,
      }),
    );
  });
}
