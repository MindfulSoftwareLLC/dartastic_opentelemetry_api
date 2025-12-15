// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:test/test.dart';
import 'package:dartastic_opentelemetry_api/src/api/common/timestamp.dart';

void main() {
  group('Timestamp', () {
    test('now returns nanoseconds since epoch', () {
      final before = DateTime.now().microsecondsSinceEpoch * 1000;
      final timestamp = Timestamp.now();
      final after = DateTime.now().microsecondsSinceEpoch * 1000;

      expect(timestamp, greaterThanOrEqualTo(before));
      expect(timestamp, lessThanOrEqualTo(after));
    });

    test('fromDateTime converts DateTime to nanoseconds', () {
      final dateTime = DateTime.fromMicrosecondsSinceEpoch(1000000);
      final nanos = Timestamp.fromDateTime(dateTime);

      expect(nanos, equals(1000000 * 1000));
    });

    test('toDateTime converts nanoseconds to DateTime', () {
      final nanos = 1000000000; // 1 second in nanos
      final dateTime = Timestamp.toDateTime(nanos);

      expect(dateTime.microsecondsSinceEpoch, equals(1000000));
    });

    test('fromDateTime and toDateTime are inverse operations', () {
      final original = DateTime.now();
      final nanos = Timestamp.fromDateTime(original);
      final recovered = Timestamp.toDateTime(nanos);

      // They should be equal within microsecond precision
      expect(recovered.microsecondsSinceEpoch,
          equals(original.microsecondsSinceEpoch));
    });

    test('dateTimeToString formats UTC time correctly', () {
      // Create a specific UTC datetime
      final dateTime = DateTime.utc(2024, 1, 15, 10, 30, 45, 123);
      final result = Timestamp.dateTimeToString(dateTime);

      expect(result, equals('2024-01-15T10:30:45.123Z'));
    });

    test('dateTimeToString converts local time to UTC', () {
      // Create a local datetime and convert it
      final localTime = DateTime(2024, 6, 20, 14, 25, 30, 500);
      final result = Timestamp.dateTimeToString(localTime);

      // The result should end with Z (UTC indicator)
      expect(result, endsWith('Z'));
      // Should follow ISO format
      expect(result,
          matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')));
    });

    test('dateTimeToString pads single digit values correctly', () {
      // Test with single digit month, day, hour, minute, second
      final dateTime = DateTime.utc(2024, 3, 5, 8, 5, 3, 7);
      final result = Timestamp.dateTimeToString(dateTime);

      expect(result, equals('2024-03-05T08:05:03.007Z'));
    });

    test('dateTimeToString handles year padding', () {
      // Test with year that needs padding (though rare)
      final dateTime = DateTime.utc(999, 12, 31, 23, 59, 59, 999);
      final result = Timestamp.dateTimeToString(dateTime);

      expect(result, equals('0999-12-31T23:59:59.999Z'));
    });

    test('dateTimeToString handles midnight correctly', () {
      final dateTime = DateTime.utc(2024, 1, 1, 0, 0, 0, 0);
      final result = Timestamp.dateTimeToString(dateTime);

      expect(result, equals('2024-01-01T00:00:00.000Z'));
    });

    test('dateTimeToString handles end of day correctly', () {
      final dateTime = DateTime.utc(2024, 12, 31, 23, 59, 59, 999);
      final result = Timestamp.dateTimeToString(dateTime);

      expect(result, equals('2024-12-31T23:59:59.999Z'));
    });
  });
}
