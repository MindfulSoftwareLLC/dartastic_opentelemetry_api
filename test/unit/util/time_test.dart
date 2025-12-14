// dart
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:dartastic_opentelemetry_api/src/util/time.dart';

void main() {
  group('Time utils', () {
    test('nowAsNanos returns Int64 within current time bounds', () {
      final before = Int64(DateTime.now().microsecondsSinceEpoch * 1000);
      final n = nowAsNanos();
      final after = Int64(DateTime.now().microsecondsSinceEpoch * 1000);

      expect(n, isA<Int64>());
      expect(n.toInt(), inInclusiveRange(before.toInt(), after.toInt()));
    });

    test('DateTime.toNanos computes microseconds * 1000 for fixed value', () {
      final dt = DateTime.fromMicrosecondsSinceEpoch(123456789);
      final nanos = dt.toNanos();

      expect(nanos, equals(Int64(123456789 * 1000)));
    });

    test('toNanos matches manual calculation for current time', () {
      final now = DateTime.now();
      final expected = Int64(now.microsecondsSinceEpoch * 1000);
      final got = now.toNanos();

      expect(got, equals(expected));
    });
  });
}