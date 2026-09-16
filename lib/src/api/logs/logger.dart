// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';
import '../../util/otel_error_handler.dart';
import '../common/any_value.dart';
import '../common/attributes.dart';
import '../context/context.dart';
import 'severity.dart';

part 'logger_create.dart';

/// Logger is responsible for creating [LogRecords]s.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the Logger from the SDK instead.
///
/// All methods of this class are safe for concurrent use by default:
/// implementations must remain correct when methods are invoked from
/// interleaved asynchronous tasks within an isolate. See
/// [Logs API, concurrency requirements](https://github.com/open-telemetry/opentelemetry-specification/blob/v1.60.0/specification/logs/api.md#concurrency-requirements).
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
  /// [body] takes either a plain Dart object or an [AnyValue]; an SDK boxes it
  /// with [bodyToAnyValue], and [LogRecord.body] holds the resulting
  /// [AnyValue].
  ///
  /// This implementation does nothing at all, per logs/noop.md: the No-Op
  /// Logger accepts the parameters and neither validates them nor records
  /// anything. It deliberately does not convert [body] — no record is produced
  /// without an SDK, so there is nothing for an unrepresentable body to
  /// corrupt, and traversing it would charge users who installed no SDK for
  /// work whose result is discarded. An SDK reports the unrepresentable body,
  /// because there the record is real.
  ///
  /// More info https://opentelemetry.io/docs/specs/otel/logs/api/#emit-a-logrecord
  void emit({
    DateTime? timeStamp,
    DateTime? observedTimestamp,
    Context? context,
    Severity? severityNumber,
    String? severityText,
    Object? body,
    Attributes? attributes,
    String? eventName,
  }) {
    // Intentionally empty. See the dartdoc: a no-op Logger does nothing, and
    // that includes not touching the body.
  }

  /// Boxes an [emit] body into the [AnyValue] that [LogRecord.body] holds.
  ///
  /// An [AnyValue] passes through unchanged, so a record read back from
  /// [LogRecord.body] can be forwarded to [emit] without being re-wrapped.
  /// Anything else is converted by [AnyValue.fromObject].
  ///
  /// Returns null when [body] is null or cannot be represented. A value the
  /// data model cannot carry is reported through [OTelErrorHandling] and the
  /// body dropped, never thrown: error-handling.md makes throwing on end-user
  /// misuse a MUST NOT, and failing telemetry must not take down the caller's
  /// logging path. This mirrors what `attrsFromMap` does for attributes.
  ///
  /// Static, not an instance method: SDK loggers `implement` [APILogger] and
  /// delegate rather than extending it, so an instance member would oblige
  /// every one of them to supply its own implementation — the opposite of
  /// sharing this one. Call it as `APILogger.bodyToAnyValue(body)`.
  static AnyValue? bodyToAnyValue(Object? body) {
    if (body == null) return null;
    // Already boxed: emit(body: record.body) is the natural way to forward a
    // record, and converting an AnyValue would report it as unsupported.
    if (body is AnyValue) return body;
    try {
      return AnyValue.fromObject(body);
    } catch (e) {
      OTelErrorHandling.report(ArgumentError(
          'Dropping the log record body because it contains unsupported '
          'types: $e'));
      return null;
    }
  }
}
