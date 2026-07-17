// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import '../context.dart';
import 'text_map_propagator.dart';

/// A [TextMapPropagator] that propagates nothing.
///
/// The OpenTelemetry specification (api-propagators.md, "Global Propagators")
/// requires that "The OpenTelemetry API MUST use no-op propagators unless
/// explicitly configured otherwise." This class is that no-op:
/// [inject] writes nothing to the carrier and [extract] returns the passed
/// [Context] unchanged.
///
/// A `NoopTextMapPropagator<dynamic, dynamic>` is the default value of the
/// global [OTelAPI.textMapPropagator].
class NoopTextMapPropagator<C, V> implements TextMapPropagator<C, V> {
  /// Creates a no-op propagator.
  const NoopTextMapPropagator();

  /// Returns an empty list; a no-op propagator sets no carrier fields.
  @override
  List<String> fields() => const <String>[];

  /// Does nothing; the carrier is left untouched.
  @override
  void inject(Context context, C carrier, TextMapSetter<V> setter) {}

  /// Returns [context] unchanged; nothing is read from the carrier.
  @override
  Context extract(Context context, C carrier, TextMapGetter<V> getter) =>
      context;
}
