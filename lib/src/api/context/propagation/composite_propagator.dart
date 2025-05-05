// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// A propagator that combines multiple other propagators
class CompositePropagator<C, V> implements TextMapPropagator<C, V> {
  final List<TextMapPropagator<C, V>> _propagators;

  /// Creates a new CompositePropagator with the given list of propagators.
  /// The propagators are applied in order for injection and in reverse order for extraction.
  CompositePropagator(List<TextMapPropagator<C, V>> propagators)
      : _propagators = List.unmodifiable(propagators);

  @override
  Context extract(Context context, C carrier, TextMapGetter<V> getter) {
    var ctx = context;
    // Apply propagators in reverse order
    for (final propagator in _propagators.reversed) {
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
