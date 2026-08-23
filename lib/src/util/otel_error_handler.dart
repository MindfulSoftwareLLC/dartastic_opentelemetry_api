// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';

import '../factory/otel_factory.dart';
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

/// Buffers a handler installed before any [OTelFactory] exists. Factory
/// installation adopts it (see the [OTelFactory.otelFactory] setter), so
/// installing a handler before `initialize()` never throws and is never
/// lost.
OTelErrorHandler? _pendingHandler;

/// The global error-handling policy hook for OpenTelemetry.
///
/// Per error-handling.md, "Configuring Error Handlers", installing a
/// handler (via [OTelAPI.setErrorHandler], or [handler] directly) is the
/// supported way for end users to change the library's default error
/// handling behavior — for example, to fail fast on invalid API usage in
/// a staging environment:
///
/// ```dart
/// OTelAPI.setErrorHandler((error, stackTrace) =>
///     Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current));
/// ```
///
/// Like every other OpenTelemetry global in this library, the handler is
/// held by the installed [OTelFactory]: the user-installed handler lives
/// in [OTelFactory.errorHandler], and when none is installed reports fall
/// back to [OTelFactory.defaultErrorHandler] — which SDK factories may
/// override. Before any factory exists, an installed handler is buffered
/// and adopted by the first factory installation, so configuration order
/// never matters.
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
  OTelErrorHandling._(); // coverage:ignore-line

  /// The handler [report] currently resolves to.
  ///
  /// Resolution order: the user-installed handler (factory-held, or
  /// buffered when no factory exists yet), then the installed factory's
  /// [OTelFactory.defaultErrorHandler], then [defaultErrorHandler].
  /// Reading this never installs a factory as a side effect.
  static OTelErrorHandler get handler {
    final factory = OTelFactory.otelFactory;
    if (factory != null) {
      return factory.errorHandler ?? factory.defaultErrorHandler;
    }
    return _pendingHandler ?? defaultErrorHandler;
  }

  /// Installs [value] as the user handler, replacing the default
  /// behavior. Stored on the installed [OTelFactory]; buffered until one
  /// exists. Use [resetToDefault] to restore the default behavior.
  static set handler(OTelErrorHandler value) {
    final factory = OTelFactory.otelFactory;
    if (factory != null) {
      factory.errorHandler = value;
    } else {
      _pendingHandler = value;
    }
  }

  /// The user-installed handler, or `null` when only defaults (the
  /// logging default, or a factory subclass's default) are in effect.
  static OTelErrorHandler? get installedHandler {
    final factory = OTelFactory.otelFactory;
    return factory != null ? factory.errorHandler : _pendingHandler;
  }

  /// Restores the default behavior: clears the user-installed handler
  /// (factory-held and buffered alike), so [report] falls back to the
  /// installed factory's [OTelFactory.defaultErrorHandler] — the logging
  /// [defaultErrorHandler] unless a factory subclass overrides it.
  static void resetToDefault() {
    _pendingHandler = null;
    OTelFactory.otelFactory?.errorHandler = null;
  }

  /// Moves a handler buffered before [factory] existed into the factory's
  /// [OTelFactory.errorHandler] slot. Called by the [OTelFactory.otelFactory]
  /// setter on every factory installation; not part of the public API.
  @internal
  static void adoptPendingHandler(OTelFactory factory) {
    final pending = _pendingHandler;
    if (pending != null) {
      _pendingHandler = null;
      factory.errorHandler = pending;
    }
  }

  /// Reports a suppressed [error] to the resolved [handler].
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
