// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';
import '../id/id_generator.dart';

part 'context_key_create.dart';

/// Key for Context values
/// Each instance is unique, even if created with the same name.
class ContextKey<T> {
  /// The key name, used for debugging purposes.
  /// As per the specification, this does not uniquely identify the key.
  final String name;

  /// Whether the value of this key should be transferred across isolate boundaries.
  final bool isTransferable;

  /// Unique identifier ensuring each key instance is distinct, even if they have the same name.
  final Uint8List _uniqueId;

  /// Creates a new context key with the given name.
  /// Each instance will be unique
  ContextKey._(this.name, this._uniqueId, {this.isTransferable = false});

  /// Returns an unmodifiable view of the unique ID as a list of integers.
  List<int> get uniqueId => List.unmodifiable(_uniqueId);

  @override
  String toString() => 'ContextKey{name=$name,uniqueId=$_uniqueId}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContextKey) return false;
    if (other.name != name) return false;
    if (other._uniqueId.length != _uniqueId.length) return false;
    for (var i = 0; i < _uniqueId.length; i++) {
      if (other._uniqueId[i] != _uniqueId[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(name, Object.hashAll(_uniqueId));

  /// Generates a unique identifier for the context key.
  static Uint8List generateContextKeyId() {
    // We are re-using the traceId implementation
    // but this is not for a trace, it's for a context
    return IdGenerator.generateTraceId();
  }
}
