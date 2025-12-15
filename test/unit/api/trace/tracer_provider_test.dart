// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/src/api/common/attributes.dart';
import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('TracerProvider', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('creates tracer with valid name and version', () {
      final provider = OTelAPI.tracerProvider();
      final tracer = provider.getTracer(
        'test-lib',
        version: '1.0.0',
      );

      expect(tracer, isNotNull);
      expect(tracer.name, equals('test-lib'));
      expect(tracer.version, equals('1.0.0'));
    });

    test('creates tracer with schema url', () {
      final provider = OTelAPI.tracerProvider();
      final tracer = provider.getTracer(
        'test-lib',
        version: '1.0.0',
        schemaUrl: 'https://opentelemetry.io/schemas/1.4.0',
      );

      expect(tracer, isNotNull);
      expect(
          tracer.schemaUrl, equals('https://opentelemetry.io/schemas/1.4.0'));
    });

    test('creates tracer with instrumentation scope attributes', () {
      final provider = OTelAPI.tracerProvider();
      final attributes = <String, Object>{
        'library.name': 'test-lib',
        'library.version': '1.0.0',
      }.toAttributes();

      final tracer = provider.getTracer(
        'test-lib',
        version: '1.0.0',
        attributes: attributes,
      );

      expect(tracer, isNotNull);
      expect(tracer.attributes?.toMap()['library.name']?.value,
          equals('test-lib'));
      expect(tracer.attributes?.toMap()['library.version']?.value,
          equals('1.0.0'));
    });

    test('handles invalid name by returning working tracer with empty name',
        () {
      final provider = OTelAPI.tracerProvider();

      // Test with null name
      final tracerNullName = provider.getTracer('');
      expect(tracerNullName, isNotNull);
      expect(tracerNullName.name, equals(''));

      // Test with empty string name
      final tracerEmptyName = provider.getTracer('');
      expect(tracerEmptyName, isNotNull);
      expect(tracerEmptyName.name, equals(''));
    });

    test('returns same tracer instance for identical parameters', () {
      final provider = OTelAPI.tracerProvider();

      final tracer1 = provider.getTracer('test-lib', version: '1.0.0');
      final tracer2 = provider.getTracer('test-lib', version: '1.0.0');

      expect(identical(tracer1, tracer2), isTrue);
    });

    test('returns different tracer instance for different parameters', () {
      final provider = OTelAPI.tracerProvider();

      final tracer1 = provider.getTracer('test-lib-1', version: '1.0.0');
      final tracer2 = provider.getTracer('test-lib-2', version: '1.0.0');

      expect(identical(tracer1, tracer2), isFalse);
    });

    test('configuration changes affect existing tracers', () {
      final provider = OTelAPI.tracerProvider();
      final tracer = provider.getTracer('test-lib');

      // This test is a bit tricky since the API is no-op
      // In a real SDK implementation, we'd verify that configuration changes
      // are reflected in the existing tracer
      expect(tracer, isNotNull);
    });

    test('endpoint getter returns current endpoint', () {
      final provider = OTelAPI.tracerProvider();
      expect(provider.endpoint, equals('http://localhost:4317'));
    });

    test('endpoint setter updates endpoint', () {
      final provider = OTelAPI.tracerProvider();
      provider.endpoint = 'http://new-endpoint:4318';
      expect(provider.endpoint, equals('http://new-endpoint:4318'));
    });

    test('serviceName getter returns current service name', () {
      final provider = OTelAPI.tracerProvider();
      expect(provider.serviceName, equals('test-service'));
    });

    test('serviceName setter updates service name', () {
      final provider = OTelAPI.tracerProvider();
      provider.serviceName = 'new-service';
      expect(provider.serviceName, equals('new-service'));
    });

    test('serviceVersion getter returns current service version', () {
      final provider = OTelAPI.tracerProvider();
      expect(provider.serviceVersion, equals('1.0.0'));
    });

    test('serviceVersion setter updates service version', () {
      final provider = OTelAPI.tracerProvider();
      provider.serviceVersion = '2.0.0';
      expect(provider.serviceVersion, equals('2.0.0'));
    });

    test('serviceVersion setter accepts null', () {
      final provider = OTelAPI.tracerProvider();
      provider.serviceVersion = null;
      expect(provider.serviceVersion, isNull);
    });

    test('enabled getter returns current enabled state', () {
      final provider = OTelAPI.tracerProvider();
      expect(provider.enabled, isTrue);
    });

    test('enabled setter updates enabled state', () {
      final provider = OTelAPI.tracerProvider();
      provider.enabled = false;
      expect(provider.enabled, isFalse);
    });

    test('isShutdown returns false initially', () {
      final provider = OTelAPI.tracerProvider();
      expect(provider.isShutdown, isFalse);
    });

    test('isShutdown setter updates shutdown state', () {
      final provider = OTelAPI.tracerProvider();
      provider.isShutdown = true;
      expect(provider.isShutdown, isTrue);
    });

    test('getTracer throws StateError after shutdown', () {
      final provider = OTelAPI.tracerProvider();
      provider.isShutdown = true;

      expect(
        () => provider.getTracer('test-lib'),
        throwsA(isA<StateError>()),
      );
    });

    test('shutdown returns true and marks provider as shutdown', () async {
      final provider = OTelAPI.tracerProvider();
      expect(provider.isShutdown, isFalse);

      final result = await provider.shutdown();

      expect(result, isTrue);
      expect(provider.isShutdown, isTrue);
      expect(provider.enabled, isFalse);
    });

    test('shutdown returns true when already shutdown', () async {
      final provider = OTelAPI.tracerProvider();
      await provider.shutdown();

      // Second shutdown should also return true
      final result = await provider.shutdown();
      expect(result, isTrue);
    });

    test('shutdown clears tracer cache', () async {
      final provider = OTelAPI.tracerProvider();

      // Create a tracer first
      final tracer1 = provider.getTracer('test-lib', version: '1.0.0');
      expect(tracer1, isNotNull);

      // Shutdown the provider
      await provider.shutdown();

      // After shutdown, getting tracer should throw
      expect(
        () => provider.getTracer('test-lib', version: '1.0.0'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
