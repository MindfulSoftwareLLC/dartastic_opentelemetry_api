// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  setUp(OTelAPI.reset);
  tearDown(OTelAPI.reset);

  test('standalone values follow non-OTLP rules without JSON quoting', () {
    final cases = <AnyValue, String>{
      const AnyValueString('hello "world"\n'): 'hello "world"\n',
      const AnyValueString(''): '',
      const AnyValueNull(): '',
      const AnyValueBool(true): 'true',
      const AnyValueBool(false): 'false',
      const AnyValueInt(-123): '-123',
      const AnyValueInt(0): '0',
      const AnyValueDouble(2.5): '2.5',
      const AnyValueDouble(double.nan): 'NaN',
      const AnyValueDouble(double.infinity): 'Infinity',
      const AnyValueDouble(double.negativeInfinity): '-Infinity',
      AnyValue.fromBytes([104, 105]): 'aGk=',
      AnyValue.fromBytes([]): '',
      AnyValueArray([]): '[]',
      AnyValueMap({}): '{}',
    };
    for (final entry in cases.entries) {
      expect(entry.key.toNonOtlpString(), entry.value);
      expect(() => jsonEncode(entry.key.toJsonValue()), returnsNormally);
    }
  });

  test('nested values and escaped keys produce valid JSON', () {
    final input = <String, Object?>{
      'key"\\\n': ['a"b\\c\n\t', true, false, 0, -123, 2.5, null],
      'bytes': Uint8List.fromList([104, 105]),
      'emptyBytes': Uint8List(0),
      'special': [double.nan, double.infinity, double.negativeInfinity],
      'map': {'a': <Object?>[], 'A': <String, Object?>{}},
    };
    final expected = <String, Object?>{
      ...input,
      'bytes': 'aGk=',
      'emptyBytes': '',
      'special': ['NaN', 'Infinity', '-Infinity'],
    };
    final value = AnyValue.fromObject(input);
    final attributes = OTelAPI.attributesFromMap(input);
    expect(value.toJsonValue(), expected);
    expect(jsonDecode(value.toNonOtlpString()), expected);
    expect(attributes.toJsonValue(), expected);
    expect(jsonDecode(attributes.toNonOtlpString()), expected);
    expect(attributes.toMap()['bytes']!.toNonOtlpString(), '{"bytes":"aGk="}');
    expect(attributes.toMap()['special']!.toJsonValue(), {
      'special': ['NaN', 'Infinity', '-Infinity']
    });
  });

  test('null attributes and empty collections are preserved', () {
    final attributes = OTelAPI.attributesFromMap({'null': null});
    expect(attributes.toNonOtlpString(), '{"null":null}');
    expect(attributes.toList().single.toNonOtlpString(), '{"null":null}');
    expect(OTelAPI.attributesFromMap({}).toNonOtlpString(), '{}');
  });

  test('plain Dart unwrap behavior stays unchanged', () {
    final value = AnyValue.fromBytes([104, 105]);
    expect(value.toJson(), [104, 105]);
    expect(value.toJsonValue(), 'aGk=');
    final attributes = OTelAPI.attributesFromMap({'b': value, 'x': double.nan});
    expect(attributes.toJson()['b'], [104, 105]);
    expect((attributes.toJson()['x'] as double).isNaN, isTrue);
    expect(attributes.toJsonValue(), {'b': 'aGk=', 'x': 'NaN'});
  });

  for (final maps in [false, true]) {
    for (final wrappers in [30, 31, 32]) {
      test('depth $wrappers, maps=$maps reports once and resets per call', () {
        final errors = <Object>[];
        OTelAPI.setErrorHandler((error, stack) => errors.add(error));
        AnyValue value = AnyValueArray(List.filled(1000, const AnyValueInt(1)));
        for (var i = 0; i < wrappers; i++) {
          value = maps ? AnyValueMap({'v': value}) : AnyValueArray([value]);
        }
        Object? decoded = jsonDecode(value.toNonOtlpString());
        for (var i = 0; i < wrappers; i++) {
          decoded = maps
              ? (decoded as Map<String, Object?>)['v']
              : (decoded as List<Object?>)[0];
        }
        expect(
            decoded,
            wrappers == 32
                ? isNull
                : List<Object?>.filled(1000, wrappers == 30 ? 1 : null));
        expect(errors, hasLength(wrappers == 30 ? 0 : 1));
        value.toJsonValue();
        expect(errors, hasLength(wrappers == 30 ? 0 : 2));
      });
    }
  }

  test('depth handler exceptions propagate exactly once', () {
    final sentinel = StateError('handler');
    var reports = 0;
    OTelAPI.setErrorHandler((error, stack) {
      reports++;
      throw sentinel;
    });
    AnyValue value = const AnyValueInt(1);
    for (var i = 0; i < 32; i++) {
      value = AnyValueArray([value]);
    }
    expect(() => value.toNonOtlpString(), throwsA(same(sentinel)));
    expect(reports, 1);
  });
}
