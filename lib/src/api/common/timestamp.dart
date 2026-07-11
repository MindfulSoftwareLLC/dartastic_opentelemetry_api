// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';

import '../../util/time.dart';

/// Utility class for working with OpenTelemetry timestamps.
@immutable
class Timestamp {
  /// Returns the current timestamp in nanoseconds since epoch.
  static Int64 now() => nowAsNanos();

  /// Converts a [DateTime] to nanoseconds since epoch.
  static Int64 fromDateTime(DateTime dateTime) =>
      Int64(dateTime.microsecondsSinceEpoch) * 1000;

  /// Converts nanoseconds since epoch to a [DateTime].
  static DateTime toDateTime(Int64 nanos) =>
      DateTime.fromMicrosecondsSinceEpoch((nanos ~/ 1000).toInt());

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
