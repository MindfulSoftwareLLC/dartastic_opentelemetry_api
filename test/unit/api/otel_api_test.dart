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

    test('tracerProviders returns empty list initially', () {
      final providers = OTelAPI.tracerProviders();
      expect(providers, isNotNull);
      expect(providers, isEmpty);
    });

    test('tracerProviders returns list with default provider after access', () {
      // Access the default provider to trigger its creation
      OTelAPI.tracerProvider();
      
      final providers = OTelAPI.tracerProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(1));
      expect(providers.first, isA<APITracerProvider>());
    });

    test('tracerProviders returns list with named providers', () {
      // Create some named providers
      final namedProvider1 = OTelAPI.addTracerProvider('provider1');
      final namedProvider2 = OTelAPI.addTracerProvider('provider2');
      
      final providers = OTelAPI.tracerProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(2));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));
    });

    test('tracerProviders returns list with both default and named providers', () {
      // Access default provider
      final defaultProvider = OTelAPI.tracerProvider();
      
      // Create named providers
      final namedProvider1 = OTelAPI.addTracerProvider('provider1');
      final namedProvider2 = OTelAPI.addTracerProvider('provider2');
      
      final providers = OTelAPI.tracerProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(3));
      expect(providers, contains(defaultProvider));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));
      
      // Default provider should be first
      expect(providers.first, equals(defaultProvider));
    });

    test('meterProviders returns empty list initially', () {
      final providers = OTelAPI.meterProviders();
      expect(providers, isNotNull);
      expect(providers, isEmpty);
    });

    test('meterProviders returns list with default provider after access', () {
      // Access the default provider to trigger its creation
      OTelAPI.meterProvider();
      
      final providers = OTelAPI.meterProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(1));
      expect(providers.first, isA<APIMeterProvider>());
    });

    test('meterProviders returns list with named providers', () {
      // Create some named providers
      final namedProvider1 = OTelAPI.addMeterProvider('provider1');
      final namedProvider2 = OTelAPI.addMeterProvider('provider2');
      
      final providers = OTelAPI.meterProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(2));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));
    });

    test('meterProviders returns list with both default and named providers', () {
      // Access default provider
      final defaultProvider = OTelAPI.meterProvider();
      
      // Create named providers
      final namedProvider1 = OTelAPI.addMeterProvider('provider1');
      final namedProvider2 = OTelAPI.addMeterProvider('provider2');
      
      final providers = OTelAPI.meterProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(3));
      expect(providers, contains(defaultProvider));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));
      
      // Default provider should be first
      expect(providers.first, equals(defaultProvider));
    });

    test('tracerProviders returns unmodifiable list', () {
      final provider = OTelAPI.addTracerProvider('test-provider');
      final providers = OTelAPI.tracerProviders();
      
      expect(providers, hasLength(1));
      
      // Attempting to modify the list should throw
      expect(() {
        providers.add(provider);
      }, throwsUnsupportedError);
    });

    test('meterProviders returns unmodifiable list', () {
      final provider = OTelAPI.addMeterProvider('test-provider');
      final providers = OTelAPI.meterProviders();
      
      expect(providers, hasLength(1));
      
      // Attempting to modify the list should throw
      expect(() {
        providers.add(provider);
      }, throwsUnsupportedError);
    });

    test('provider lists reflect changes after adding new providers', () {
      // Initially empty
      expect(OTelAPI.tracerProviders(), isEmpty);
      expect(OTelAPI.meterProviders(), isEmpty);
      
      // Add tracer provider
      final tracerProvider = OTelAPI.addTracerProvider('tracer1');
      expect(OTelAPI.tracerProviders(), hasLength(1));
      expect(OTelAPI.tracerProviders(), contains(tracerProvider));
      expect(OTelAPI.meterProviders(), isEmpty);
      
      // Add meter provider
      final meterProvider = OTelAPI.addMeterProvider('meter1');
      expect(OTelAPI.tracerProviders(), hasLength(1));
      expect(OTelAPI.meterProviders(), hasLength(1));
      expect(OTelAPI.meterProviders(), contains(meterProvider));
      
      // Add more providers
      final tracerProvider2 = OTelAPI.addTracerProvider('tracer2');
      final meterProvider2 = OTelAPI.addMeterProvider('meter2');
      
      expect(OTelAPI.tracerProviders(), hasLength(2));
      expect(OTelAPI.meterProviders(), hasLength(2));
      expect(OTelAPI.tracerProviders(), containsAll([tracerProvider, tracerProvider2]));
      expect(OTelAPI.meterProviders(), containsAll([meterProvider, meterProvider2]));
    });

    test('provider lists are independent', () {
      // Add providers of different types
      final tracerProvider = OTelAPI.addTracerProvider('tracer-only');
      final meterProvider = OTelAPI.addMeterProvider('meter-only');
      
      final tracerProviders = OTelAPI.tracerProviders();
      final meterProviders = OTelAPI.meterProviders();
      
      expect(tracerProviders, hasLength(1));
      expect(meterProviders, hasLength(1));
      expect(tracerProviders, contains(tracerProvider));
      expect(meterProviders, contains(meterProvider));
      
      // Lists should not contain providers of different types
      expect(tracerProviders, isNot(contains(meterProvider)));
      expect(meterProviders, isNot(contains(tracerProvider)));
    });

    test('providers list survives after reset', () {
      // Create providers
      OTelAPI.addTracerProvider('provider1');
      OTelAPI.addMeterProvider('provider2');
      
      expect(OTelAPI.tracerProviders(), hasLength(1));
      expect(OTelAPI.meterProviders(), hasLength(1));
      
      // Reset
      OTelAPI.reset();
      
      // Re-initialize
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      
      // Lists should be empty again
      expect(OTelAPI.tracerProviders(), isEmpty);
      expect(OTelAPI.meterProviders(), isEmpty);
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
