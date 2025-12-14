// Helper function for getting current time in OTel nano format with microsecond precision
import 'package:fixnum/fixnum.dart';

Int64 nowAsNanos() => Int64(DateTime.now().microsecondsSinceEpoch * 1000);

// Extension for getting current time in OTel nano format with microsecond precision
extension DateTimeToNanos on DateTime {
// returns the current time in OTel nano format with microsecond precision
  Int64 toNanos() => Int64(microsecondsSinceEpoch * 1000);
}
