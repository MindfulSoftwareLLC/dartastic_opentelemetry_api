// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  setUp(OTelAPI.reset);
  tearDown(OTelAPI.reset);

  for (final kind in ['list', 'map']) {
    test('$kind cycle reaches a rethrowing handler exactly once', () {
      final list = <Object?>[];
      final map = <String, Object?>{};
      list.add(list);
      map['self'] = map;
      final reports = <Object>[];
      OTelAPI.setErrorHandler((error, stack) {
        reports.add(error);
        Error.throwWithStackTrace(error, stack ?? StackTrace.current);
      });

      expect(
          () => AnyValue.fromObject(kind == 'list' ? list : map),
          throwsA(isA<ArgumentError>()
              .having((error) => error.message, 'message', contains('cycle'))));
      expect(reports, hasLength(1));
    });

    test('$kind preserves a selectively throwing handler exception', () {
      final sentinel = StateError('custom handler');
      final reports = <Object>[];
      OTelAPI.setErrorHandler((error, stack) {
        reports.add(error);
        if (error.toString().contains('toString() threw')) throw sentinel;
      });

      final input =
          kind == 'list' ? [_ThrowingString()] : {'bad': _ThrowingString()};
      expect(() => AnyValue.fromObject(input), throwsA(same(sentinel)));
      expect(reports, hasLength(1));
    });

    for (final wrappers in [30, 31, 32]) {
      test('$kind depth $wrappers reports once for a wide subtree', () {
        final reports = <Object>[];
        OTelAPI.setErrorHandler((error, stack) => reports.add(error));
        var input = kind == 'list'
            ? List<Object?>.filled(1000, 0)
            : <String, Object?>{for (var i = 0; i < 1000; i++) '$i': 0};
        for (var i = 0; i < wrappers; i++) {
          input = kind == 'list' ? [input] : {'child': input};
        }

        final converted = AnyValue.fromObject(input);
        converted.unwrap();
        converted.toJson();
        expect(reports, hasLength(wrappers == 30 ? 0 : 1));
        // The report marker belongs to one call, not to global state.
        AnyValue.fromObject(input);
        expect(reports, hasLength(wrappers == 30 ? 0 : 2));
      });
    }
  }

  test('nested depth error reaches a strict handler once', () {
    Object input = 0;
    for (var i = 0; i < 33; i++) {
      input = [input];
    }
    final reports = <Object>[];
    OTelAPI.setErrorHandler((error, stack) {
      reports.add(error);
      Error.throwWithStackTrace(error, stack ?? StackTrace.current);
    });
    expect(() => AnyValue.fromObject(input), throwsA(isA<ArgumentError>()));
    expect(reports, hasLength(1));
    expect(reports.single.toString(), contains('maximum depth'));
  });

  test('typed double lists match the explicit double-list attribute factory',
      () {
    final mapped = OTelAPI.attributesFromMap({
      'r': <double>[1.0, 2.5]
    });
    final explicit = OTelAPI.attributes([
      OTelAPI.attributeDoubleList('r', [1.0, 2.5]),
    ]);
    expect(mapped, explicit);
    expect(mapped.hashCode, explicit.hashCode);
    final array = mapped.toMap()['r']!.value as AnyValueArray;
    expect(array.value, everyElement(isA<AnyValueDouble>()));
    final integers = AnyValue.fromObject(<int>[1, 2]) as AnyValueArray;
    expect(integers.value, everyElement(isA<AnyValueInt>()));
  });

  test('typed double lists obey the same depth guard', () {
    Object input = <double>[1.0, 2.5];
    for (var i = 0; i < 31; i++) {
      input = [input];
    }
    final reports = <Object>[];
    OTelAPI.setErrorHandler((error, stack) => reports.add(error));
    final result = AnyValue.fromObject(input);
    expect(reports, hasLength(1));
    result.unwrap();
    expect(reports, hasLength(1));
  });

  test('semconv and custom enum wire values survive nested conversion', () {
    final attrs = OTelAPI.attributesFromMap({
      'rating': BrowserWebVitalRating.needsImprovement,
      'state': HwState.needsCleaning,
      'nested': [_WireValue.custom],
    });
    expect(attrs.getString('rating'), 'needs-improvement');
    expect(attrs.getString('state'), 'needs_cleaning');
    expect(attrs.getStringList('nested'), ['custom-wire']);
  });

  test('semantic-key helpers accept null values', () {
    final byString = OTelAPI.attributesFromMap({'http.request.method': null});
    final bySemantic =
        OTelAPI.attributesFromSemanticMap({Http.httpRequestMethod: null});
    final byEnum = OTelAPI.attributesOf<Http>({Http.httpRequestMethod: null});
    final entry = Http.httpRequestMethod.toMapEntry(null);
    expect(bySemantic, byString);
    expect(byEnum, byString);
    expect(entry.key, 'http.request.method');
    expect(entry.value, isNull);
    expect(byEnum.toMap()['http.request.method']!.value, isA<AnyValueNull>());
  });
}

class _ThrowingString {
  @override
  String toString() => throw StateError('string conversion');
}

enum _WireValue {
  custom;

  @override
  String toString() => 'custom-wire';
}
