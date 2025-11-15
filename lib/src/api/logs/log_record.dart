import '../common/attributes.dart';
import '../context/context.dart';
import 'severity.dart';

/// Required parameter for LogRecord. According to the spec
/// in https://opentelemetry.io/docs/specs/otel/logs/api/#emit-a-logrecord
///
/// The API MUST accept the following parameters:
///
/// Timestamp (optional)
/// Observed Timestamp (optional)
/// The Context associated with the LogRecord. When implicit Context is supported, then this parameter SHOULD be optional and if unspecified then MUST use current Context. When only explicit Context is supported, this parameter SHOULD be required.
/// Severity Number (optional)
/// Severity Text (optional)
/// Body (optional)
/// Attributes (optional)
/// Event Name (optional)
abstract class LogRecord {
  DateTime? get timestamp;

  DateTime? get observedTimestamp;

  Context? get context;

  Severity? get severityNumber;

  String? get severityText;

  dynamic get body;

  Attributes? get attributes;

  String? get eventName;
}
