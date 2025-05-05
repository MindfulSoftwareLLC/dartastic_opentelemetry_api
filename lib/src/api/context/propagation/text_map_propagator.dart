// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../context.dart';

/// TextMapGetter allows an SDK to read values from a carrier object
abstract interface class TextMapGetter<T> {
  /// Gets a value from the carrier by the key.
  T? get(String key);

  /// Gets all the keys from the carrier.
  Iterable<String> keys();
}

/// TextMapSetter allows an SDK to set values on a carrier object
abstract class TextMapSetter<T> {
  /// Sets a value on the carrier by the key.
  void set(String key, T value);
}

/// Interface for propagating context between processes using text maps
abstract interface class TextMapPropagator<C, V> {
  /// Fields returns the keys whose values are set in carriers
  List<String> fields();

  /// Injects the value into a carrier
  void inject(Context context, C carrier, TextMapSetter<V> setter);

  /// Extracts the value from a carrier
  Context extract(Context context, C carrier, TextMapGetter<V> getter);
}
