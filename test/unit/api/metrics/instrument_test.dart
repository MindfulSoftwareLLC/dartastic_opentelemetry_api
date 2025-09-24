// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('APIInstrument', () {
    late APIMeter meter;

    setUp(() {
      meter = OTelAPI.meterProvider().getMeter(name: 'test-meter');
    });

    test('instrument properties are correctly initialized', () {
      // Arrange
      const name = 'test-instrument';
      const unit = 'ms';
      const description = 'A test instrument';
      const enabled = true;

      // Act
      final instrument = TestAPIInstrument(
        name: name,
        unit: unit,
        description: description,
        enabled: enabled,
        meter: meter,
      );

      // Assert
      expect(instrument.name, equals(name));
      expect(instrument.unit, equals(unit));
      expect(instrument.description, equals(description));
      expect(instrument.enabled, equals(enabled));
      expect(instrument.meter, equals(meter));
    });

    test('instrument works with null unit and description', () {
      // Arrange
      const name = 'test-instrument';
      const enabled = false;

      // Act
      final instrument = TestAPIInstrument(
        name: name,
        unit: null,
        description: null,
        enabled: enabled,
        meter: meter,
      );

      // Assert
      expect(instrument.name, equals(name));
      expect(instrument.unit, isNull);
      expect(instrument.description, isNull);
      expect(instrument.enabled, equals(enabled));
      expect(instrument.meter, equals(meter));
    });

    test('specific instrument types extend APIInstrument', () {
      // Act
      final counter = meter.createCounter<int>(name: 'test-counter');
      final upDownCounter =
          meter.createUpDownCounter<int>(name: 'test-up-down-counter');
      final histogram = meter.createHistogram<double>(name: 'test-histogram');
      final gauge = meter.createGauge<double>(name: 'test-gauge');

      // Assert - verify they have properties from APIInstrument
      expect(counter.name, equals('test-counter'));
      expect(counter.meter, equals(meter));

      expect(upDownCounter.name, equals('test-up-down-counter'));
      expect(upDownCounter.meter, equals(meter));

      expect(histogram.name, equals('test-histogram'));
      expect(histogram.meter, equals(meter));

      expect(gauge.name, equals('test-gauge'));
      expect(gauge.meter, equals(meter));
    });
  });
}

/// Test implementation of APIInstrument for testing purposes
class TestAPIInstrument extends APIInstrument {
  TestAPIInstrument({
    required super.name,
    super.unit,
    super.description,
    required super.enabled,
    required super.meter,
  });
}
