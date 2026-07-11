// Licensed under the Apache License, Version 2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Spec-compliance tests for the Baggage API
// (specification/baggage/api.md):
//
// - "Baggage values are any valid UTF-8 strings. Language API MUST accept
//   any valid UTF-8 string as baggage value in `Set` and return the same
//   value from `Get`." — the empty string is a valid UTF-8 string.
// - "Baggage names are any valid, non-empty UTF-8 strings." — an empty name
//   is invalid, but per error-handling ("API methods MUST NOT throw
//   unhandled exceptions when used incorrectly by end users") an invalid
//   name is ignored, not thrown.
// - "The Baggage API MUST be fully functional in the absence of an
//   installed SDK."
void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4318',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('Baggage values (any valid UTF-8 string, including empty)', () {
    test('copyWith accepts an empty value and Get returns it', () {
      final baggage = OTelAPI.baggage().copyWith('key', '');
      expect(baggage.getValue('key'), equals(''));
    });

    test('baggageForMap accepts an empty value', () {
      final baggage = OTelAPI.baggageForMap({'key': ''});
      expect(baggage.getValue('key'), equals(''));
    });

    test('empty values survive a toJson/fromJson round trip', () {
      final baggage = OTelAPI.baggage().copyWith('key', '');
      final restored = Baggage.fromJson(baggage.toJson());
      expect(restored.getValue('key'), equals(''));
    });

    test('OTelAPI.baggageFromJson accepts an empty value', () {
      final baggage = OTelAPI.baggageFromJson({
        'key': {'value': ''}
      });
      expect(baggage.getValue('key'), equals(''));
    });
  });

  group('Baggage names (invalid names ignored, never thrown)', () {
    test('copyWith with an empty name returns the baggage unchanged', () {
      final baggage = OTelAPI.baggage().copyWith('valid', 'v');
      final result = baggage.copyWith('', 'ignored');
      expect(result.getAllEntries().keys, equals(['valid']));
    });
  });

  group('Baggage is fully functional without an installed SDK', () {
    test('copyWith works after reset', () {
      final baggage = OTelAPI.baggage();
      OTelAPI.reset();
      final result = baggage.copyWith('key', 'value');
      expect(result.getValue('key'), equals('value'));
    });

    test('copyWithout works after reset', () {
      final baggage = OTelAPI.baggage().copyWith('key', 'value');
      OTelAPI.reset();
      final result = baggage.copyWithout('key');
      expect(result.getEntry('key'), isNull);
    });

    test('copyWithBaggage works after reset', () {
      final a = OTelAPI.baggage().copyWith('a', '1');
      final b = OTelAPI.baggage().copyWith('b', '2');
      OTelAPI.reset();
      final merged = a.copyWithBaggage(b);
      expect(merged.getValue('a'), equals('1'));
      expect(merged.getValue('b'), equals('2'));
    });
  });
}
