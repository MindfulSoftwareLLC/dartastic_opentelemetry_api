// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';

import '../context.dart';
import 'text_map_propagator.dart';

/// A propagator that combines multiple other propagators.
///
/// Created via `OTelAPI.compositePropagator` (or an `OTelFactory`
/// implementation), like every other API object. Per the OpenTelemetry
/// Propagators API specification, the propagators are invoked in the order
/// they were specified, for both injection and extraction. When two
/// propagators write the same Context slot, the last one specified wins.
class CompositePropagator<C, V> implements TextMapPropagator<C, V> {
  final List<TextMapPropagator<C, V>> _propagators;

  CompositePropagator._(List<TextMapPropagator<C, V>> propagators)
      : _propagators = List.unmodifiable(propagators);

  @override
  Context extract(Context context, C carrier, TextMapGetter<V> getter) {
    var ctx = context;
    for (final propagator in _propagators) {
      ctx = propagator.extract(ctx, carrier, getter);
    }
    return ctx;
  }

  @override
  void inject(Context context, C carrier, TextMapSetter<V> setter) {
    for (final propagator in _propagators) {
      propagator.inject(context, carrier, setter);
    }
  }

  @override
  List<String> fields() {
    final set = <String>{};
    for (final propagator in _propagators) {
      set.addAll(propagator.fields());
    }
    return set.toList(growable: false);
  }
}

/// Internal constructor access for [CompositePropagator].
/// Used by `OTelFactory` implementations; users should create composite
/// propagators with `OTelAPI.compositePropagator`.
@internal
class CompositePropagatorCreate {
  /// Creates a [CompositePropagator] delegating to [propagators].
  static CompositePropagator<C, V> create<C, V>(
          List<TextMapPropagator<C, V>> propagators) =>
      CompositePropagator<C, V>._(propagators);
}
