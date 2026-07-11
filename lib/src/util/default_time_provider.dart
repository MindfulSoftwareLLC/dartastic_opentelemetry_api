// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Conditional facade for the platform-default `TimeProvider`. Native
// targets get `SystemTimeProvider` (DateTime.now); web targets (JS or Wasm)
// get `WebTimeProvider` (window.performance.now), so users running on the
// browser automatically pick up sub-millisecond span timestamps without
// having to opt in.

export 'default_time_provider_io.dart'
    if (dart.library.js_interop) 'default_time_provider_web.dart';
