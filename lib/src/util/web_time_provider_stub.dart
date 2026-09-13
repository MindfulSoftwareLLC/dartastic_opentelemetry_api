// coverage:ignore-file
// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'time_provider.dart';

/// Native-target stub for [WebTimeProvider].
///
/// `WebTimeProvider` is a web-only `TimeProvider` backed by
/// `window.performance.now()`. On native (Dart-VM, Flutter mobile/desktop),
/// `package:web` is unavailable, so the conditional facade in
/// `web_time_provider.dart` exports this stub instead. Constructing it
/// throws — native consumers should use [SystemTimeProvider].
class WebTimeProvider implements TimeProvider {
  /// Throws — `WebTimeProvider` requires a web target.
  WebTimeProvider([bool throwError = true]) {
    if (throwError) {
      throw UnsupportedError(
        'WebTimeProvider is only available on web targets. '
        'Use SystemTimeProvider on native or import from a web entry point.',
      );
    }
  }

  // Unreachable in normal use: the constructor always throws, so no instance can exist
  // to call this on. Kept only to satisfy the TimeProvider interface.
  @override
  DateTime nowDateTime() {
    throw UnsupportedError('WebTimeProvider is only available on web targets.');
  }
}
