// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'time_provider.dart';

/// Native-target stub for [WebTimeProvider].
///
/// `WebTimeProvider` is a web-only `TimeProvider` backed by
/// `window.performance.now()`. On native (Dart-VM, Flutter mobile/desktop),
/// `package:web` is unavailable, so the conditional facade in
/// `web_time_provider.dart` exports this stub instead. Constructing it
/// throws — native consumers should use [SystemTimeProvider] (or, for true
/// nanosecond timing on native, the Pro `dartastic_native_time` package).
class WebTimeProvider implements TimeProvider {
  /// Throws — `WebTimeProvider` requires a web target.
  WebTimeProvider() {
    throw UnsupportedError(
      'WebTimeProvider is only available on web targets. '
      'Use SystemTimeProvider on native or import from a web entry point.',
    );
  }

  @override
  DateTime nowDateTime() {
    throw UnsupportedError('WebTimeProvider is only available on web targets.');
  }
}
