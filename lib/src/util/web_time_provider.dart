// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Conditional facade for `WebTimeProvider`. On web targets (Dart-on-JS or
// Wasm) this exports an implementation backed by `window.performance.now()`
// for sub-millisecond span timing; on native targets it exports a stub that
// throws on instantiation, since `package:web` is web-only.

export 'web_time_provider_stub.dart'
    if (dart.library.js_interop) 'web_time_provider_web.dart';
