// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('OTelAPI', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('initialize sets up the global factory', () {
      expect(OTelFactory.otelFactory, isNotNull);
    });

    test('tracerProvider returns default TracerProvider when no name provided', () {
      final provider = OTelAPI.tracerProvider();
      expect(provider, isNotNull);
      expect(provider, isA<APITracerProvider>());
    });

    test('tracerProvider returns named provider when name provided', () {
      final provider = OTelAPI.tracerProvider('named-provider');
      expect(provider, isNotNull);
      expect(provider, isA<APITracerProvider>());
    });

    test('meterProvider returns default MeterProvider when no name provided', () {
      final provider = OTelAPI.meterProvider();
      expect(provider, isNotNull);
      expect(provider, isA<APIMeterProvider>());
    });

    test('meterProvider returns named provider when name provided', () {
      final provider = OTelAPI.meterProvider('named-provider');
      expect(provider, isNotNull);
      expect(provider, isA<APIMeterProvider>());
    });

    test('addTracerProvider creates and returns a new TracerProvider', () {
      final provider = OTelAPI.addTracerProvider('custom-tracer-provider', 
        endpoint: 'http://custom-endpoint:4317',
        serviceName: 'custom-service',
        serviceVersion: '2.0.0'
      );
      expect(provider, isNotNull);

      // Verify the provider is cached
      final retrievedProvider = OTelAPI.tracerProvider('custom-tracer-provider');
      expect(retrievedProvider, equals(provider));
    });

    test('addMeterProvider creates and returns a new MeterProvider', () {
      final provider = OTelAPI.addMeterProvider('custom-meter-provider', 
        endpoint: 'http://custom-endpoint:4317',
        serviceName: 'custom-service',
        serviceVersion: '2.0.0'
      );
      expect(provider, isNotNull);

      // Verify the provider is cached
      final retrievedProvider = OTelAPI.meterProvider('custom-meter-provider');
      expect(retrievedProvider, equals(provider));
    });

    test('tracer returns a tracer from the default TracerProvider', () {
      final tracer = OTelAPI.tracer('test-tracer');
      expect(tracer, isNotNull);
      expect(tracer, isA<APITracer>());
      expect(tracer.name, equals('test-tracer'));
    });

    test('tracerProvider throws ArgumentError for empty name', () {
      expect(() => OTelAPI.tracerProvider(''), throwsArgumentError);
    });

    test('meterProvider throws ArgumentError for empty name', () {
      expect(() => OTelAPI.meterProvider(''), throwsArgumentError);
    });

    test('reset clears all providers', () {
      // Create some providers
      OTelAPI.tracerProvider('provider1');
      OTelAPI.meterProvider('provider2');
      
      // Reset
      OTelAPI.reset();
      
      // Initialize again
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      
      // Try to get providers - they should be new instances
      expect(OTelFactory.otelFactory, isNotNull);
    });


    test('initialize throws when called twice', () {
      // Already initialized in setUp, so calling again should throw
      expect(() {
        OTelAPI.initialize(
          endpoint: 'http://localhost:4317',
          serviceName: 'test-service',
          serviceVersion: '1.0.0',
        );
      }, throwsA(isA<StateError>()));
    });

    test('initialize throws with empty endpoint', () {
      OTelAPI.reset();
      expect(() {
        OTelAPI.initialize(
          endpoint: '',
          serviceName: 'test-service',
          serviceVersion: '1.0.0',
        );
      }, throwsA(isA<ArgumentError>()));
    });

    test('initialize throws with empty serviceName', () {
      OTelAPI.reset();
      expect(() {
        OTelAPI.initialize(
          endpoint: 'http://localhost:4317',
          serviceName: '',
          serviceVersion: '1.0.0',
        );
      }, throwsA(isA<ArgumentError>()));
    });

    test('initialize throws with empty serviceVersion', () {
      OTelAPI.reset();
      expect(() {
        OTelAPI.initialize(
          endpoint: 'http://localhost:4317',
          serviceName: 'test-service',
          serviceVersion: '',
        );
      }, throwsA(isA<ArgumentError>()));
    });

  });
}
