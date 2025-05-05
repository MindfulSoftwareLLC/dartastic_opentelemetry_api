// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// The log levels supported by OTelLog.
///
/// Higher level values are more verbose (trace is highest, fatal is lowest).
enum LogLevel {
  /// A log level for critical errors that may cause application failure.
  fatal(0),

  /// A log level for error messages.
  error(1),

  /// A log level for warning messages.
  warn(2),

  /// A log level for general informational messages.
  info(3),

  /// A log level for debug information.
  debug(4),

  /// A log level indicating very detailed trace information.
  trace(6);

  /// The numeric value of this log level.
  ///
  /// Higher values indicate more verbose logging.
  final int level;

  const LogLevel(this.level);
}

/// Function type for logging operations
typedef LogFunction = void Function(String);

/// A simple log service that logs messages and signals to the console.
/// It filters messages based on the current log level.
/// Signals are not filtered based on log level
/// Defaults to noop,
class OTelLog {
  /// The current log level for filtering messages.
  ///
  /// Messages with a level lower than the current level are not logged.
  /// Defaults to LogLevel.error.
  static LogLevel currentLevel = LogLevel.error;

  /// To turn on logging at the current level, set this
  /// to `print` (Dart) or `debugPrint` (Flutter) or any other LogFunction.
  /// Logging function for general messages.
  ///
  /// To enable logging, set this to a function like print() or debugPrint().
  /// When null, logging is disabled.
  static LogFunction? logFunction;

  /// To turn on logging for spans, set this
  /// to `print` (Dart) or `debugPrint` (Flutter) or any other LogFunction.
  /// Logging function specifically for span-related messages.
  ///
  /// To enable span logging, set this to a function like print() or debugPrint().
  /// When null, span logging is disabled.
  static LogFunction? spanLogFunction;

  /// To turn on logging for metrics, set this
  /// to `print` (Dart) or `debugPrint` (Flutter) or any other LogFunction.
  /// Logging function specifically for metric-related messages.
  ///
  /// To enable metric logging, set this to a function like print() or debugPrint().
  /// When null, metric logging is disabled.
  static LogFunction? metricLogFunction;

  /// To turn on logging for export, set this
  /// to `print` (Dart) or `debugPrint` (Flutter) or any other LogFunction.
  /// Logging function specifically for export-related messages.
  ///
  /// To enable export logging, set this to a function like print() or debugPrint().
  /// When null, export logging is disabled.
  static LogFunction? exportLogFunction;

  /// Returns true if the current log level includes trace messages.
  static bool isTrace() =>
      logFunction != null && currentLevel.level >= LogLevel.trace.level;

  /// Returns true if the current log level includes debug messages.
  static bool isDebug() =>
      logFunction != null && currentLevel.level >= LogLevel.debug.level;

  /// Returns true if the current log level includes info messages.
  static bool isInfo() =>
      logFunction != null && currentLevel.level >= LogLevel.info.level;

  /// Returns true if the current log level includes warning messages.
  static bool isWarn() =>
      logFunction != null && currentLevel.level >= LogLevel.warn.level;

  /// Returns true if the current log level includes error messages.
  static bool isError() =>
      logFunction != null && currentLevel.level >= LogLevel.error.level;

  /// Returns true if the current log level includes fatal messages.
  static bool isFatal() =>
      logFunction != null && currentLevel.level >= LogLevel.fatal.level;

  /// Returns true if span logging is enabled.
  static bool isLogSpans() => spanLogFunction != null;

  /// Returns true if metric logging is enabled.
  static bool isLogMetrics() => metricLogFunction != null;

  /// Returns true if export logging is enabled.
  static bool isLogExport() => exportLogFunction != null;

  /// Generic log method. It prints the message if the [level] is at or above
  /// the [currentLevel].
  ///
  /// @param level The log level of the message
  /// @param message The message to log
  static void log(LogLevel level, String message) {
    if (logFunction == null) {
      return;
    } else {
      // Only log messages that are of high enough priority.
      if (level.level <= currentLevel.level) {
        final timestamp = DateTime.now().toIso8601String();
        // Extract just the log level name (e.g., 'DEBUG').
        final levelName = level.toString().split('.').last.toUpperCase();
        logFunction!('[$timestamp] [$levelName] $message');
      }
    }
  }

  /// Logs a span-related message.
  ///
  /// Only logs if span logging is enabled via spanLogFunction.
  ///
  /// @param message The message to log
  static void logSpan(String message) {
    if (isLogSpans()) {
      final timestamp = DateTime.now().toIso8601String();
      final String msg = message;
      spanLogFunction!('[$timestamp] [span] $msg ');
    }
  }

  /// Logs a metric-related message.
  ///
  /// Only logs if metric logging is enabled via metricLogFunction.
  ///
  /// @param message The message to log
  static void logMetric(String message) {
    if (isLogMetrics()) {
      final timestamp = DateTime.now().toIso8601String();
      final String msg = message;
      metricLogFunction!('[$timestamp] [metric] $msg ');
    }
  }

  /// Logs an export-related message.
  ///
  /// Only logs if export logging is enabled via exportLogFunction.
  ///
  /// @param message The message to log
  static void logExport(String message) {
    if (isLogExport()) {
      final timestamp = DateTime.now().toIso8601String();
      final String msg = message;
      exportLogFunction!('[$timestamp] [export] $msg ');
    }
  }

  /// Logs a trace-level message.
  ///
  /// Only logs if the current log level is set to trace or higher.
  ///
  /// @param message The message to log
  static void trace(String message) => log(LogLevel.trace, message);

  /// Logs a debug-level message.
  ///
  /// Only logs if the current log level is set to debug or higher.
  ///
  /// @param message The message to log
  static void debug(String message) => log(LogLevel.debug, message);

  /// Logs an info-level message.
  ///
  /// Only logs if the current log level is set to info or higher.
  ///
  /// @param message The message to log
  static void info(String message) => log(LogLevel.info, message);

  /// Logs a warning-level message.
  ///
  /// Only logs if the current log level is set to warn or higher.
  ///
  /// @param message The message to log
  static void warn(String message) => log(LogLevel.warn, message);

  /// Logs an error-level message.
  ///
  /// Only logs if the current log level is set to error or higher.
  ///
  /// @param message The message to log
  static void error(String message) => log(LogLevel.error, message);

  /// Logs a fatal-level message.
  ///
  /// Only logs if the current log level is set to fatal or higher.
  ///
  /// @param message The message to log
  static void fatal(String message) => log(LogLevel.fatal, message);

  /// Sets the current log level to trace.
  ///
  /// This enables logging of all levels (trace, debug, info, warn, error, fatal).
  static void enableTraceLogging() {
    currentLevel = LogLevel.trace;
  }

  /// Sets the current log level to debug.
  ///
  /// This enables logging of debug, info, warn, error, and fatal levels.
  static void enableDebugLogging() {
    currentLevel = LogLevel.debug;
  }

  /// Sets the current log level to info.
  ///
  /// This enables logging of info, warn, error, and fatal levels.
  static void enableInfoLogging() {
    currentLevel = LogLevel.info;
  }

  /// Sets the current log level to warn.
  ///
  /// This enables logging of warn, error, and fatal levels.
  static void enableWarnLogging() {
    currentLevel = LogLevel.warn;
  }

  /// Sets the current log level to error.
  ///
  /// This enables logging of error and fatal levels.
  static void enableErrorLogging() {
    currentLevel = LogLevel.error;
  }

  /// Sets the current log level to fatal.
  ///
  /// This enables logging of only fatal level messages.
  static void enableFatalLogging() {
    currentLevel = LogLevel.fatal;
  }
}
