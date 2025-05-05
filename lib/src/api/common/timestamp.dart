// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:meta/meta.dart';

/// Utility class for working with OpenTelemetry timestamps.
@immutable
class Timestamp {
  /// Returns the current timestamp in nanoseconds since epoch.
  static int now() => DateTime.now().microsecondsSinceEpoch * 1000;

  /// Converts a [DateTime] to nanoseconds since epoch.
  static int fromDateTime(DateTime dateTime) =>
      dateTime.microsecondsSinceEpoch * 1000;

  /// Converts nanoseconds since epoch to a [DateTime].
  static DateTime toDateTime(int nanos) =>
      DateTime.fromMicrosecondsSinceEpoch(nanos ~/ 1000);

  /// Converts a DateTime value to a string in the format:
  /// "yyyy-MM-ddTHH:mm:ss.SSSZ"
  // Avoids dependency on intl
  static String dateTimeToString(DateTime value) {
    final utc = value.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    final millisecond = utc.millisecond.toString().padLeft(3, '0');
    return '$year-$month-${day}T$hour:$minute:$second.${millisecond}Z';
  }
}
