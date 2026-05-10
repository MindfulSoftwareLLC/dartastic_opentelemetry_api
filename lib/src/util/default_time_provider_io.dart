// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'time_provider.dart';

/// Platform default [TimeProvider] for native targets (Dart-VM, AOT,
/// Flutter mobile/desktop): [SystemTimeProvider] backed by `DateTime.now`.
/// Selected at compile time via the conditional export in
/// `default_time_provider.dart`.
const TimeProvider defaultTimeProvider = SystemTimeProvider();
