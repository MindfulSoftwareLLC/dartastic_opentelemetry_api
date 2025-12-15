// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('OTelFactory', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('globalDefaultTracerProvider returns the same instance', () {
      final factory = OTelFactory.otelFactory!;
      final provider1 = factory.globalDefaultTracerProvider();
      final provider2 = factory.globalDefaultTracerProvider();

      expect(provider1, isNotNull);
      expect(provider2, isNotNull);
      expect(identical(provider1, provider2), isTrue);
    });

    test('globalDefaultMeterProvider returns the same instance', () {
      final factory = OTelFactory.otelFactory!;
      final provider1 = factory.globalDefaultMeterProvider();
      final provider2 = factory.globalDefaultMeterProvider();

      expect(provider1, isNotNull);
      expect(provider2, isNotNull);
      expect(identical(provider1, provider2), isTrue);
    });

    test('getNamedTracerProvider returns null for non-existent provider', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.getNamedTracerProvider('non-existent');

      expect(provider, isNull);
    });

    test('getNamedMeterProvider returns null for non-existent provider', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.getNamedMeterProvider('non-existent');

      expect(provider, isNull);
    });

    test('addTracerProvider creates and caches a provider', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.addTracerProvider('custom-provider');

      expect(provider, isNotNull);
      expect(
          factory.getNamedTracerProvider('custom-provider'), equals(provider));
    });

    test('addMeterProvider creates and caches a provider', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.addMeterProvider('custom-provider');

      expect(provider, isNotNull);
      expect(
          factory.getNamedMeterProvider('custom-provider'), equals(provider));
    });

    test('serialize and deserialize preserve factory configuration', () {
      final factory = OTelFactory.otelFactory!;
      final serialized = factory.serialize();

      expect(serialized, isNotNull);
      expect(serialized['apiEndpoint'], equals('http://localhost:4317'));
      expect(serialized['apiServiceName'], equals('test-service'));
      expect(serialized['apiServiceVersion'], equals('1.0.0'));

      // Test deserialize functionality
      try {
        final deserializedFactory =
            OTelFactory.deserialize(serialized, otelApiFactoryFactoryFunction);
        expect(deserializedFactory, isNotNull);
      } catch (e) {
        fail('Deserialization failed: $e');
      }
    });

    test('getTracerProviders returns empty list initially', () {
      final factory = OTelFactory.otelFactory!;
      final providers = factory.getTracerProviders();

      expect(providers, isNotNull);
      expect(providers, isEmpty);
    });

    test('getTracerProviders returns list with default provider after access',
        () {
      final factory = OTelFactory.otelFactory!;

      // Access the default provider to trigger its creation
      final defaultProvider = factory.globalDefaultTracerProvider();

      final providers = factory.getTracerProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(1));
      expect(providers.first, equals(defaultProvider));
    });

    test('getTracerProviders returns list with named providers only', () {
      final factory = OTelFactory.otelFactory!;

      // Create named providers without accessing default
      final namedProvider1 = factory.addTracerProvider('provider1');
      final namedProvider2 = factory.addTracerProvider('provider2');

      final providers = factory.getTracerProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(2));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));
    });

    test(
        'getTracerProviders returns list with both default and named providers',
        () {
      final factory = OTelFactory.otelFactory!;

      // Access default provider first
      final defaultProvider = factory.globalDefaultTracerProvider();

      // Create named providers
      final namedProvider1 = factory.addTracerProvider('provider1');
      final namedProvider2 = factory.addTracerProvider('provider2');

      final providers = factory.getTracerProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(3));
      expect(providers, contains(defaultProvider));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));

      // Default provider should be first in the list
      expect(providers.first, equals(defaultProvider));
    });

    test('getMeterProviders returns empty list initially', () {
      final factory = OTelFactory.otelFactory!;
      final providers = factory.getMeterProviders();

      expect(providers, isNotNull);
      expect(providers, isEmpty);
    });

    test('getMeterProviders returns list with default provider after access',
        () {
      final factory = OTelFactory.otelFactory!;

      // Access the default provider to trigger its creation
      final defaultProvider = factory.globalDefaultMeterProvider();

      final providers = factory.getMeterProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(1));
      expect(providers.first, equals(defaultProvider));
    });

    test('getMeterProviders returns list with named providers only', () {
      final factory = OTelFactory.otelFactory!;

      // Create named providers without accessing default
      final namedProvider1 = factory.addMeterProvider('provider1');
      final namedProvider2 = factory.addMeterProvider('provider2');

      final providers = factory.getMeterProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(2));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));
    });

    test('getMeterProviders returns list with both default and named providers',
        () {
      final factory = OTelFactory.otelFactory!;

      // Access default provider first
      final defaultProvider = factory.globalDefaultMeterProvider();

      // Create named providers
      final namedProvider1 = factory.addMeterProvider('provider1');
      final namedProvider2 = factory.addMeterProvider('provider2');

      final providers = factory.getMeterProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(3));
      expect(providers, contains(defaultProvider));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));

      // Default provider should be first in the list
      expect(providers.first, equals(defaultProvider));
    });

    test('getTracerProviders returns unmodifiable list', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.addTracerProvider('test-provider');
      final providers = factory.getTracerProviders();

      expect(providers, hasLength(1));

      // Attempting to modify the returned list should throw
      expect(() {
        providers.add(provider);
      }, throwsUnsupportedError);
    });

    test('getMeterProviders returns unmodifiable list', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.addMeterProvider('test-provider');
      final providers = factory.getMeterProviders();

      expect(providers, hasLength(1));

      // Attempting to modify the returned list should throw
      expect(() {
        providers.add(provider);
      }, throwsUnsupportedError);
    });

    test('provider lists are independent and isolated', () {
      final factory = OTelFactory.otelFactory!;

      // Create different types of providers
      final tracerProvider1 = factory.addTracerProvider('tracer1');
      final tracerProvider2 = factory.addTracerProvider('tracer2');
      final meterProvider1 = factory.addMeterProvider('meter1');
      final meterProvider2 = factory.addMeterProvider('meter2');

      final tracerProviders = factory.getTracerProviders();
      final meterProviders = factory.getMeterProviders();

      // Verify correct counts
      expect(tracerProviders, hasLength(2));
      expect(meterProviders, hasLength(2));

      // Verify correct contents
      expect(tracerProviders, containsAll([tracerProvider1, tracerProvider2]));
      expect(meterProviders, containsAll([meterProvider1, meterProvider2]));

      // Verify isolation - no cross-contamination
      expect(tracerProviders, isNot(contains(meterProvider1)));
      expect(tracerProviders, isNot(contains(meterProvider2)));
      expect(meterProviders, isNot(contains(tracerProvider1)));
      expect(meterProviders, isNot(contains(tracerProvider2)));
    });

    test('provider lists reflect dynamic changes', () {
      final factory = OTelFactory.otelFactory!;

      // Initially empty
      expect(factory.getTracerProviders(), isEmpty);
      expect(factory.getMeterProviders(), isEmpty);

      // Add first provider
      final tracerProvider1 = factory.addTracerProvider('tracer1');
      expect(factory.getTracerProviders(), hasLength(1));
      expect(factory.getTracerProviders(), contains(tracerProvider1));
      expect(factory.getMeterProviders(), isEmpty);

      // Add second provider of same type
      final tracerProvider2 = factory.addTracerProvider('tracer2');
      expect(factory.getTracerProviders(), hasLength(2));
      expect(factory.getTracerProviders(),
          containsAll([tracerProvider1, tracerProvider2]));

      // Add different type of provider
      final meterProvider = factory.addMeterProvider('meter1');
      expect(factory.getTracerProviders(), hasLength(2));
      expect(factory.getMeterProviders(), hasLength(1));
      expect(factory.getMeterProviders(), contains(meterProvider));

      // Access default providers
      final defaultTracer = factory.globalDefaultTracerProvider();
      final defaultMeter = factory.globalDefaultMeterProvider();

      // Lists should now include defaults at the beginning
      final finalTracerProviders = factory.getTracerProviders();
      final finalMeterProviders = factory.getMeterProviders();

      expect(finalTracerProviders, hasLength(3));
      expect(finalMeterProviders, hasLength(2));
      expect(finalTracerProviders.first, equals(defaultTracer));
      expect(finalMeterProviders.first, equals(defaultMeter));
    });

    test('provider lists handle edge cases correctly', () {
      final factory = OTelFactory.otelFactory!;

      // Test with only default provider
      final defaultTracer = factory.globalDefaultTracerProvider();
      expect(factory.getTracerProviders(), equals([defaultTracer]));
      expect(factory.getMeterProviders(), isEmpty);

      // Add named provider with same endpoint/service config
      final namedTracer = factory.addTracerProvider(
        'same-config',
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      // Should still be separate providers
      final providers = factory.getTracerProviders();
      expect(providers, hasLength(2));
      expect(providers, contains(defaultTracer));
      expect(providers, contains(namedTracer));
      expect(identical(defaultTracer, namedTracer), isFalse);
    });

    test('provider lists survive multiple factory operations', () {
      final factory = OTelFactory.otelFactory!;

      // Create multiple providers with different configurations
      final tracers = <APITracerProvider>[];
      final meters = <APIMeterProvider>[];

      for (int i = 0; i < 5; i++) {
        tracers.add(factory.addTracerProvider(
          'tracer-$i',
          endpoint: 'http://endpoint-$i:4317',
          serviceName: 'service-$i',
          serviceVersion: '1.$i.0',
        ));

        meters.add(factory.addMeterProvider(
          'meter-$i',
          endpoint: 'http://endpoint-$i:4318',
          serviceName: 'service-$i',
          serviceVersion: '1.$i.0',
        ));
      }

      // Verify all providers are tracked
      expect(factory.getTracerProviders(), hasLength(5));
      expect(factory.getMeterProviders(), hasLength(5));
      expect(factory.getTracerProviders(), containsAll(tracers));
      expect(factory.getMeterProviders(), containsAll(meters));

      // Test access to individual providers
      for (int i = 0; i < 5; i++) {
        expect(factory.getNamedTracerProvider('tracer-$i'), equals(tracers[i]));
        expect(factory.getNamedMeterProvider('meter-$i'), equals(meters[i]));
      }
    });

    test('reset clears all cached providers', () {
      final factory = OTelFactory.otelFactory!;

      // Create some providers and verify they exist
      factory.addTracerProvider('provider1');
      factory.addMeterProvider('provider2');
      expect(factory.getTracerProviders(), hasLength(1));
      expect(factory.getMeterProviders(), hasLength(1));

      // Reset
      factory.reset();

      // Now otelFactory should be null
      expect(OTelFactory.otelFactory, isNull);
    });

    test('apiEndpoint setter updates endpoint', () {
      final factory = OTelFactory.otelFactory!;

      // Serialize to verify initial value
      var serialized = factory.serialize();
      expect(serialized['apiEndpoint'], equals('http://localhost:4317'));

      // Update endpoint
      factory.apiEndpoint = 'http://new-endpoint:4318';

      // Serialize again to verify update
      serialized = factory.serialize();
      expect(serialized['apiEndpoint'], equals('http://new-endpoint:4318'));
    });

    test('apiServiceName setter updates service name', () {
      final factory = OTelFactory.otelFactory!;

      // Serialize to verify initial value
      var serialized = factory.serialize();
      expect(serialized['apiServiceName'], equals('test-service'));

      // Update service name
      factory.apiServiceName = 'new-service';

      // Serialize again to verify update
      serialized = factory.serialize();
      expect(serialized['apiServiceName'], equals('new-service'));
    });

    test('apiServiceVersion setter updates service version', () {
      final factory = OTelFactory.otelFactory!;

      // Serialize to verify initial value
      var serialized = factory.serialize();
      expect(serialized['apiServiceVersion'], equals('1.0.0'));

      // Update service version
      factory.apiServiceVersion = '2.0.0';

      // Serialize again to verify update
      serialized = factory.serialize();
      expect(serialized['apiServiceVersion'], equals('2.0.0'));
    });

    test('globalDefaultLogProvider returns the same instance', () {
      final factory = OTelFactory.otelFactory!;
      final provider1 = factory.globalDefaultLogProvider();
      final provider2 = factory.globalDefaultLogProvider();

      expect(provider1, isNotNull);
      expect(provider2, isNotNull);
      expect(identical(provider1, provider2), isTrue);
    });

    test('getNamedLogProvider returns null for non-existent provider', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.getNamedLogProvider('non-existent');

      expect(provider, isNull);
    });

    test('addLogProvider creates and caches a provider', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.addLogProvider('custom-log-provider');

      expect(provider, isNotNull);
      expect(
          factory.getNamedLogProvider('custom-log-provider'), equals(provider));
    });

    test('addLogProvider with custom configuration', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.addLogProvider(
        'custom-log-provider',
        endpoint: 'http://custom:4317',
        serviceName: 'custom-service',
        serviceVersion: '2.0.0',
      );

      expect(provider, isNotNull);
      expect(
          factory.getNamedLogProvider('custom-log-provider'), equals(provider));
    });

    test('addLogProvider returns existing provider when called with same name',
        () {
      final factory = OTelFactory.otelFactory!;
      final provider1 = factory.addLogProvider('log-provider');
      final provider2 = factory.addLogProvider('log-provider');

      expect(identical(provider1, provider2), isTrue);
    });
  });
}
