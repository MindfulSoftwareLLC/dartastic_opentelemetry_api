// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';
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

  /// Returns whether this logger is enabled for the provided arguments.
  /// Refer https://opentelemetry.io/docs/specs/otel/logs/api/#enabled
  ///
  /// The returned value can change over time; instrumentation authors need
  /// to call this each time before emitting a LogRecord to ensure they have
  /// the most up-to-date response.
  ///
  /// [context] The Context to associate with a would-be LogRecord. Defaults
  /// to the current Context when unspecified, per the spec.
  /// [severityNumber] The optional Severity Number of a would-be LogRecord.
  /// [eventName] The optional Event Name of a would-be LogRecord.
  bool isEnabled(
          {Context? context, Severity? severityNumber, String? eventName}) =>
      false;

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
