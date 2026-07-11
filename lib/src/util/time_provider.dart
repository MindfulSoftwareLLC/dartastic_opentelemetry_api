// Licensed under the Apache License, Version 2.0

/// A clock for span start, end, and event timestamps.
///
/// The default [SystemTimeProvider] uses [DateTime.now], which is microsecond-
/// precision on Dart-VM native and **millisecond-precision on Dart-on-JS web**
/// (`Date.now()` is the JS source — `microsecondsSinceEpoch` returns
/// `millisecondsSinceEpoch * 1000`, so the lower three digits are always
/// zero). For sub-millisecond spans on web, see [WebTimeProvider] in
/// `lib/src/util/web_time_provider.dart`, which routes through
/// `window.performance.now()` (~5µs nominal, browser-coarsened to ~100µs
/// for Spectre mitigation).
///
/// The provider is held on [APITracerProvider]; tracers and spans created
/// from a provider inherit its clock so that all timestamps in a trace are
/// consistent. SDK consumers configure it via `OTel.initialize(timeProvider:
/// ...)`; API-only consumers can pass it to the API tracer-provider factory.
abstract class TimeProvider {
  /// Returns the current wall-clock time as a [DateTime].
  ///
  /// Used by `APITracer.startSpan` for span start times, by `APISpan.end`
  /// for span end times, and by `APISpan.addEventNow` for span-event
  /// timestamps.
  DateTime nowDateTime();
}

/// Default [TimeProvider] backed by [DateTime.now].
///
/// On native (VM, AOT, FFI): microsecond precision.
/// On Dart-on-JS web: millisecond precision (the browser ceiling on
/// `Date.now()`). Use `WebTimeProvider` on web for sub-millisecond timing.
class SystemTimeProvider implements TimeProvider {
  /// Constructs the default time provider. `const`-constructible so it can
  /// serve as a default-parameter value.
  const SystemTimeProvider();

  @override
  DateTime nowDateTime() => DateTime.now();
}
