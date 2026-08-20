// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'otel_log.dart';

/// Signature of a global OpenTelemetry error handler.
///
/// Invoked whenever the library suppresses an error that would otherwise
/// have surfaced to the user, per the OpenTelemetry specification
/// (error-handling.md):
///
/// > OpenTelemetry implementations MUST NOT throw unhandled exceptions
/// > at runtime.
///
/// > SDK implementations MUST allow end users to change the library's
/// > default error handling behavior for relevant errors.
///
/// [error] is the suppressed error, typically an [ArgumentError] or
/// [StateError] describing the invalid API use. [stackTrace] is the stack
/// at the point the error was reported, when one is available.
typedef OTelErrorHandler = void Function(Object error, StackTrace? stackTrace);

/// The global error-handling policy hook for OpenTelemetry.
///
/// Per error-handling.md, "Configuring Error Handlers", replacing
/// [handler] is the supported way for end users to change the library's
/// default error handling behavior — for example, to fail fast on invalid
/// API usage in a staging environment:
///
/// ```dart
/// OTelErrorHandling.handler = (error, stackTrace) =>
///     Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
/// ```
///
/// The default handler logs through [OTelLog.error], following the
/// self-diagnostics guidance ("the library SHOULD log the error using
/// language-specific conventions"), and never throws itself.
///
/// Library code reports suppressed errors through [report]. An exception
/// deliberately thrown by a user-installed handler propagates to the
/// caller: per the spec, "configuring a custom error handler in this way
/// is the only exception to the basic error handling principles".
class OTelErrorHandling {
  OTelErrorHandling._();

  /// The currently installed error handler.
  ///
  /// Assign a new [OTelErrorHandler] to replace the default logging
  /// behavior. Use [resetToDefault] to restore [defaultErrorHandler].
  static OTelErrorHandler handler = defaultErrorHandler;

  /// Restores the [defaultErrorHandler].
  static void resetToDefault() => handler = defaultErrorHandler;

  /// Reports a suppressed [error] to the installed [handler].
  ///
  /// Used by the library wherever the specification forbids throwing and
  /// an invalid input or internal failure is swallowed instead. With the
  /// default handler this never throws; a user-installed handler that
  /// throws (e.g. strict mode in staging) propagates by design.
  static void report(Object error, [StackTrace? stackTrace]) {
    handler(error, stackTrace);
  }

  /// The default error handler: logs the error (and stack trace, when
  /// present) through [OTelLog.error].
  static void defaultErrorHandler(Object error, StackTrace? stackTrace) {
    if (OTelLog.isError()) {
      OTelLog.error('$error');
      if (stackTrace != null) {
        OTelLog.error('Stack trace: $stackTrace');
      }
    }
  }
}
