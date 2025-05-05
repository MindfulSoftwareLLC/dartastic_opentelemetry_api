// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:meta/meta.dart';

import '../context.dart';

/// A propagator for binary values that can inject into and extract from a carrier.
@immutable
abstract class ContextPropagator<C> {
  /// Injects the value from [Context] into the carrier.
  void inject(Context context, C carrier);

  /// Extracts the value from the carrier into a [Context].
  Context extract(Context context, C carrier);
}
