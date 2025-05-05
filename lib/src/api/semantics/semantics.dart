// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// Base Enum with Custom Constructor
/// Base interface for OpenTelemetry semantic convention enums.
///
/// This abstract class provides the foundation for all semantic convention
/// enums in the OpenTelemetry API, providing a consistent interface for
/// accessing the attribute key.
abstract class OTelSemantic {
  /// The attribute key string as defined in the OpenTelemetry specification.
  final String key;

  /// An abtract base class for all semantics
  const OTelSemantic(this.key);

  /// Returns the string representation of this semantic attribute.
  ///
  /// Returns the key as a string, which can be used as an attribute key
  /// in maps and for serialization.
  @override
  String toString() => key;
}
