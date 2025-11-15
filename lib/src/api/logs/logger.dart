import '../common/attributes.dart';
import '../context/context.dart';
import 'severity.dart';

part 'logger_create.dart';

/// Logger is responsible for creating [LogRecords]s.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the Logger from the SDK instead.
class APILogger {
  /// Gets the name of the logger, usually of a library, package or module
  final String name;

  /// Gets the version, usually of the instrumented library, package or module
  final String? version;

  /// Gets the schema URL of the meter
  final String? schemaUrl;

  /// Optional attributes associated with this meter
  final Attributes? attributes;

  /// Creates a new [APILogger].
  /// You cannot create a Logger directly; you must use [LoggerProvider]:
  /// ```dart
  /// final logProvider = OTel.loggerProvider() or more likely, OTel.loggerProvider().getLogger("my-library");
  /// ```
  APILogger._({
    required this.name,
    this.schemaUrl,
    this.version,
    this.attributes,
  });

  /// Returns true if the logger is enabled.
  /// Refer https://opentelemetry.io/docs/specs/otel/logs/api/#enabled
  bool get enabled => false;

  /// Emit a LogRecord.
  ///
  /// More info https://opentelemetry.io/docs/specs/otel/logs/api/#emit-a-logrecord
  void emit({
    DateTime? timeStamp,
    DateTime? observedTimestamp,
    Context? context,
    Severity? severityNumber,
    String? severityText,
    dynamic body,
    Attributes? attributes,
    String? eventName,
  }) {
    // Base implementation is a no-op
  }
}
