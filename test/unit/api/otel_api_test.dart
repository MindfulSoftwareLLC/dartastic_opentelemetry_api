// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

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

    test('tracerProvider returns default TracerProvider when no name provided',
        () {
      final provider = OTelAPI.tracerProvider();
      expect(provider, isNotNull);
      expect(provider, isA<APITracerProvider>());
    });

    test('tracerProvider returns named provider when name provided', () {
      final provider = OTelAPI.tracerProvider('named-provider');
      expect(provider, isNotNull);
      expect(provider, isA<APITracerProvider>());
    });

    test('meterProvider returns default MeterProvider when no name provided',
        () {
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
          serviceVersion: '2.0.0');
      expect(provider, isNotNull);

      // Verify the provider is cached
      final retrievedProvider =
          OTelAPI.tracerProvider('custom-tracer-provider');
      expect(retrievedProvider, equals(provider));
    });

    test('addMeterProvider creates and returns a new MeterProvider', () {
      final provider = OTelAPI.addMeterProvider('custom-meter-provider',
          endpoint: 'http://custom-endpoint:4317',
          serviceName: 'custom-service',
          serviceVersion: '2.0.0');
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

    test('tracerProvider falls back to the global default for empty name', () {
      expect(OTelAPI.tracerProvider(''), same(OTelAPI.tracerProvider()));
    });

    test('meterProvider falls back to the global default for empty name', () {
      expect(OTelAPI.meterProvider(''), same(OTelAPI.meterProvider()));
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

    test('tracerProviders returns list with both default and named providers',
        () {
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

    test('meterProviders returns list with both default and named providers',
        () {
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

    // -----------------------------------------------------------------------
    // loggerProviders() — added in beta.4 so OTel.shutdown can iterate
    // over named LoggerProviders the way it does for tracer/meter.
    // -----------------------------------------------------------------------

    test('loggerProviders returns empty list initially', () {
      final providers = OTelAPI.loggerProviders();
      expect(providers, isNotNull);
      expect(providers, isEmpty);
    });

    test('loggerProviders returns list with default provider after access', () {
      OTelAPI.loggerProvider();

      final providers = OTelAPI.loggerProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(1));
      expect(providers.first, isA<APILoggerProvider>());
    });

    test('loggerProviders returns list with named providers', () {
      final namedProvider1 = OTelAPI.addLoggerProvider('provider1');
      final namedProvider2 = OTelAPI.addLoggerProvider('provider2');

      final providers = OTelAPI.loggerProviders();
      expect(providers, isNotNull);
      expect(providers, hasLength(2));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));
    });

    test('loggerProviders returns list with both default and named providers',
        () {
      final defaultProvider = OTelAPI.loggerProvider();
      final namedProvider1 = OTelAPI.addLoggerProvider('provider1');
      final namedProvider2 = OTelAPI.addLoggerProvider('provider2');

      final providers = OTelAPI.loggerProviders();
      expect(providers, hasLength(3));
      expect(providers, contains(defaultProvider));
      expect(providers, contains(namedProvider1));
      expect(providers, contains(namedProvider2));
      // Default first (matches tracer/meter ordering).
      expect(providers.first, equals(defaultProvider));
    });

    test('loggerProviders returns unmodifiable list', () {
      final provider = OTelAPI.addLoggerProvider('test-provider');
      final providers = OTelAPI.loggerProviders();

      expect(providers, hasLength(1));
      expect(() {
        providers.add(provider);
      }, throwsUnsupportedError);
    });

    test('loggerProviders does not include tracer or meter providers', () {
      final tracerProvider = OTelAPI.addTracerProvider('tracer-x');
      final meterProvider = OTelAPI.addMeterProvider('meter-x');
      final loggerProvider = OTelAPI.addLoggerProvider('logger-x');

      final loggerProviders = OTelAPI.loggerProviders();
      expect(loggerProviders, hasLength(1));
      expect(loggerProviders, contains(loggerProvider));
      expect(loggerProviders, isNot(contains(tracerProvider)));
      expect(loggerProviders, isNot(contains(meterProvider)));
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
      expect(OTelAPI.tracerProviders(),
          containsAll([tracerProvider, tracerProvider2]));
      expect(OTelAPI.meterProviders(),
          containsAll([meterProvider, meterProvider2]));
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

    test('initialize replaces an installed API factory instead of throwing',
        () {
      // The API factory is the spec-mandated no-op — whether auto-installed
      // by early API use or installed by a prior initialize(), it is
      // replaceable; re-initializing applies the new configuration.
      expect(OTelFactory.otelFactory!.isAPIFactory, isTrue);
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'replacement-service',
        serviceVersion: '2.0.0',
      );
      expect(OTelFactory.otelFactory!.serialize()['apiServiceName'],
          equals('replacement-service'));
    });

    test('initialize throws when a real (non-API) factory is installed', () {
      // A factory that is not the no-op API factory means initialization
      // already happened (e.g. an SDK installed itself) and must not be
      // silently discarded.
      OTelFactory.otelFactory = _FakeSDKFactory(
        apiEndpoint: 'http://localhost:4317',
        apiServiceName: 'sdk-service',
        apiServiceVersion: '1.0.0',
      );
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

/// Stands in for an SDK factory: extends [OTelAPIFactory] (as all SDK
/// factories do) and reports itself as a real implementation, so
/// initialization must refuse to replace it.
class _FakeSDKFactory extends OTelAPIFactory {
  _FakeSDKFactory({
    required super.apiEndpoint,
    required super.apiServiceName,
    required super.apiServiceVersion,
  });

  @override
  bool get isAPIFactory => false;
}
