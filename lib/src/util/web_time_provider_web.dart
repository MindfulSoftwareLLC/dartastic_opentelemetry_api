// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:web/web.dart' as web;

import 'time_provider.dart';

/// Web `TimeProvider` backed by `window.performance.now()` and `timeOrigin`.
///
/// On Dart-on-JS, the default `DateTime.now()` is millisecond-precision —
/// `Date.now()` is the underlying source and `microsecondsSinceEpoch`
/// returns `millisecondsSinceEpoch * 1000`. The browser performance API
/// (`window.performance.now()` + `window.performance.timeOrigin`) returns a
/// `DOMHighResTimeStamp` that is fractional milliseconds with sub-
/// millisecond precision: ~5µs nominal, coarsened by browsers to roughly
/// 100µs as a Spectre-mitigation (Firefox: 1ms unless `crossOriginIsolated`;
/// Chrome: 5µs cross-origin-isolated, else 100µs). That's still 10–200×
/// better than `Date.now()`, and matches what JavaScript OpenTelemetry SDKs
/// use.
///
/// True nanosecond precision is **not available in browsers** regardless of
/// what the OTLP wire format claims to support.
class WebTimeProvider implements TimeProvider {
  /// Constructs a `WebTimeProvider` and snapshots `timeOrigin` once.
  WebTimeProvider();

  /// Time when the page navigation started (or the worker was started),
  /// in fractional milliseconds since Unix Epoch. Snapshotted once because
  /// `timeOrigin` is constant for the lifetime of the document.
  static final double _timeOriginMs = web.window.performance.timeOrigin;

  @override
  DateTime nowDateTime() {
    // performance.now() returns ms since timeOrigin. Total ms since epoch
    // is timeOrigin + now(). Convert fractional ms to integer microseconds
    // for DateTime.fromMicrosecondsSinceEpoch — that preserves sub-ms
    // precision up to the microsecond, which is the floor `DateTime`
    // stores anyway.
    final totalMs = _timeOriginMs + web.window.performance.now();
    final totalMicros = (totalMs * 1000).round();
    return DateTime.fromMicrosecondsSinceEpoch(totalMicros, isUtc: false);
  }
}
