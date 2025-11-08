import 'package:dartastic_opentelemetry_api/src/api/logs/severity.dart';

import '../common/attributes.dart';
import '../context/context.dart';

part 'logger_create.dart';

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
  /// var meter = OTel.loggerProvider() or more likely, OTel.loggerProvider().getLog("my-library");
  /// ```
  APILogger._({
    required this.name,
    this.schemaUrl,
    this.version,
    this.attributes,
  });

  /// Returns true if the tracer is enabled and will create sampling spans.
  /// This should be checked before performing expensive operations to create spans.
  bool get enabled => false;

  void emit({
    Attributes? attributes,
    Context? context,
    dynamic body,
    DateTime? observedTimestamp,
    Severity? severityNumber,
    String? severityText,
    DateTime? timeStamp,
  }) {
    // Base implementation is a no-op
  }
}
