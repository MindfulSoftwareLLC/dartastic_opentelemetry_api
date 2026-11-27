// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  setUp(OTelAPI.reset);
  tearDown(OTelAPI.reset);

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
    expect(value.toJson(), expected);
    expect(jsonDecode(jsonEncode(value)), expected);
    expect(attributes.toJson(), expected);
    expect(jsonDecode(jsonEncode(attributes)), expected);
    expect(jsonEncode(attributes.toMap()['bytes']!), '{"bytes":"aGk="}');
    expect(attributes.toMap()['special']!.toJson(), {
      'special': ['NaN', 'Infinity', '-Infinity']
    });
  });

  test('null attributes and empty collections are preserved', () {
    final attributes = OTelAPI.attributesFromMap({'null': null});
    expect(jsonEncode(attributes), '{"null":null}');
    expect(jsonEncode(attributes.toList().single), '{"null":null}');
    expect(jsonEncode(OTelAPI.attributesFromMap({})), '{}');
  });

  test('toObject retains native data while toJson encodes it', () {
    final bytes = AnyValue.fromBytes(Uint8List.fromList([104, 105]));
    const nan = AnyValueDouble(double.nan);
    expect(bytes.toObject(), isA<Uint8List>());
    expect(bytes.toObject(), [104, 105]);
    expect(AnyValue.fromObject(bytes.toObject()), bytes);
    expect((nan.toObject() as double).isNaN, isTrue);
    final attributes = OTelAPI.attributesFromMap({'b': bytes, 'x': nan});
    expect(jsonDecode(jsonEncode(attributes)), {'b': 'aGk=', 'x': 'NaN'});
    final restored = Attributes.fromJson(attributes.toJson());
    expect(restored.getString('b'), 'aGk=');
    expect(restored.getString('x'), 'NaN');
  });

  test('attribute debug rendering is bounded and does not report errors', () {
    OTelAPI.setErrorHandler((error, _) => throw StateError('$error'));
    AnyValue deep = const AnyValueString('hidden leaf');
    for (var i = 0; i < 129; i++) {
      deep = AnyValueArray([deep]);
    }
    final attrs = OTelAPI.attributesFromMap({
      'nan': double.nan,
      'bytes': Uint8List.fromList([1, 2, 3]),
      'deep': deep,
    });

    final output = attrs.toString();
    expect(output, startsWith('{nan: NaN, bytes: <3 bytes>, deep: '));
    expect(output, contains('...'));
    expect(output, isNot(contains('hidden leaf')));
  });

  for (final maps in [false, true]) {
    for (final wrappers in [127, 128]) {
      test('depth $wrappers, maps=$maps reports once and resets per call', () {
        final errors = <Object>[];
        OTelAPI.setErrorHandler((error, stack) => errors.add(error));
        final child = AnyValueArray([const AnyValueInt(2)]);
        AnyValue value = AnyValueArray([
          const AnyValueInt(1),
          ...List.filled(1000, child),
        ]);
        for (var i = 0; i < wrappers; i++) {
          value = maps ? AnyValueMap({'v': value}) : AnyValueArray([value]);
        }
        Object? decoded = jsonDecode(jsonEncode(value));
        for (var i = 0; i < wrappers; i++) {
          decoded = maps
              ? (decoded as Map<String, Object?>)['v']
              : (decoded as List<Object?>)[0];
        }
        expect(decoded,
            wrappers == 128 ? isNull : [1, ...List.filled(1000, null)]);
        expect(errors, hasLength(1));
        expect(jsonEncode(value.toObject()), jsonEncode(value.toJson()));
        expect(errors, hasLength(3));
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
    AnyValue value = AnyValueArray([const AnyValueInt(1)]);
    for (var i = 0; i < 128; i++) {
      value = AnyValueArray([value]);
    }
    expect(() => value.toJson(), throwsA(same(sentinel)));
    expect(reports, 1);
  });
}
