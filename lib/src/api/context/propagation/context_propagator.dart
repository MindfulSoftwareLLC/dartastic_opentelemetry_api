// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

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
