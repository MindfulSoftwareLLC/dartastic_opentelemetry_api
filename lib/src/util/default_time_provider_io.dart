// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'time_provider.dart';

/// Platform default [TimeProvider] for native targets (Dart-VM, AOT,
/// Flutter mobile/desktop): [SystemTimeProvider] backed by `DateTime.now`.
/// Selected at compile time via the conditional export in
/// `default_time_provider.dart`.
const TimeProvider defaultTimeProvider = SystemTimeProvider();
