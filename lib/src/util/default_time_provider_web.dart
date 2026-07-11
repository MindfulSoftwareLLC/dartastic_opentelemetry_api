// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'time_provider.dart';
import 'web_time_provider.dart';

/// Platform default [TimeProvider] for web targets (Dart-on-JS, Wasm):
/// [WebTimeProvider] backed by `window.performance.now()` for sub-
/// millisecond span timestamps. Selected at compile time via the
/// conditional export in `default_time_provider.dart`. Lazily constructed
/// on first read so the `timeOrigin` snapshot happens at the right time.
final TimeProvider defaultTimeProvider = WebTimeProvider();
