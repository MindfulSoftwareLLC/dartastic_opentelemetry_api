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
      expect(factory.getNamedTracerProvider('custom-provider'), equals(provider));
    });
    
    test('addMeterProvider creates and caches a provider', () {
      final factory = OTelFactory.otelFactory!;
      final provider = factory.addMeterProvider('custom-provider');
      
      expect(provider, isNotNull);
      expect(factory.getNamedMeterProvider('custom-provider'), equals(provider));
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
        final deserializedFactory = OTelFactory.deserialize(serialized, otelApiFactoryFactoryFunction);
        expect(deserializedFactory, isNotNull);
      } catch (e) {
        fail('Deserialization failed: $e');
      }
    });
    
    test('reset clears all cached providers', () {
      final factory = OTelFactory.otelFactory!;
      
      // Create some providers
      factory.addTracerProvider('provider1');
      factory.addMeterProvider('provider2');
      
      // Reset
      factory.reset();
      
      // Now otelFactory should be null
      expect(OTelFactory.otelFactory, isNull);
    });
  });
}
