// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';
import 'span_context.dart' show SpanContext;

part 'trace_flags_create.dart';

/// Trace flags for a [SpanContext].
/// These flags are used to control tracing behavior.
/// TraceFlags follows the W3C Trace Context specification.
///
/// This is a **bit set**, not an enumerated value. Each flag occupies its own
/// bit and the bits are independent of one another, so a single instance may
/// carry several flags at once. A trace that is both sampled and declared
/// random has a flags byte of `03`.
///
/// Because of this, comparing the whole value against a single named flag is
/// incorrect:
///
/// ```dart
/// if (flags == TraceFlags.sampled) { ... }  // WRONG: false when flags are 03
/// if (flags.isSampled) { ... }              // correct
/// ```
///
/// Always test individual bits with the accessors ([isSampled], [isRandom])
/// and set them with the corresponding `with*` methods, which preserve the
/// other bits.
class TraceFlags {
  /// Flag indicating no sampling.
  /// Value is 0x0.
  // ignore: constant_identifier_names
  static const int NONE_FLAG = 0x0;

  /// Flag indicating the trace is sampled.
  /// Value is 0x1.
  // ignore: constant_identifier_names
  static const int SAMPLED_FLAG = 0x1;

  /// Flag indicating the trace ID was generated randomly.
  /// Value is 0x2.
  ///
  /// Defined by W3C Trace Context Level 2 as the second least significant bit
  /// of the trace-flags field. When set, at least the right-most 7 bytes of
  /// the trace ID must have been selected randomly, or pseudo-randomly, with a
  /// uniform distribution over `[0..2^56-1]`.
  ///
  /// See https://www.w3.org/TR/trace-context-2/#random-trace-id-flag
  // ignore: constant_identifier_names
  static const int RANDOM_FLAG = 0x2;

  /// A TraceFlags instance with no flags set (not sampled).
  static TraceFlags none = TraceFlagsCreate.create(NONE_FLAG);

  /// A TraceFlags instance with the sampled flag set.
  static TraceFlags sampled = TraceFlagsCreate.create(SAMPLED_FLAG);

  /// The internal flags byte value.
  final int _flags;

  /// Creates TraceFlags with the given flags value.
  ///
  /// This is an internal constructor that should not be called directly.
  /// Use [TraceFlagsCreate.create] instead.
  ///
  /// [_flags] The binary flags to set, defaults to NONE_FLAG (0x0).
  const TraceFlags._([this._flags = NONE_FLAG]);

  /// Creates TraceFlags from a hexadecimal string representation.
  ///
  /// This parses the provided hex string and creates appropriate TraceFlags.
  /// If the string cannot be parsed, returns TraceFlags with no flags set.
  ///
  /// [hex] A hexadecimal string representation of the flags.
  ///
  /// Returns a new TraceFlags instance with the parsed flags.
  factory TraceFlags.fromString(String hex) {
    final flags = int.tryParse(hex, radix: 16) ?? NONE_FLAG;
    return TraceFlagsCreate.create(flags);
  }

  /// Returns the byte representation of the TraceFlags
  int get asByte => _flags;

  /// Returns true if the sampled flag is set
  bool get isSampled => (_flags & SAMPLED_FLAG) == SAMPLED_FLAG;

  /// Returns a new trace flags with sampling enabled or disabled.
  ///
  /// All other bits, including [RANDOM_FLAG], are preserved.
  TraceFlags withSampled(bool isSampled) {
    if (isSampled) {
      return TraceFlagsCreate.create(_flags | SAMPLED_FLAG);
    } else {
      return TraceFlagsCreate.create(_flags & ~SAMPLED_FLAG);
    }
  }

  /// Returns true if the random flag is set.
  ///
  /// A set flag declares that the trace ID satisfies the W3C Trace Context
  /// Level 2 randomness requirement. This is an assertion made by whoever
  /// generated the trace ID; it is not verified here, and cannot be, since
  /// randomness is not a property observable from a single value.
  ///
  /// When continuing a trace, a set flag on the incoming `traceparent` must be
  /// carried through to every outgoing `traceparent` that uses the same trace
  /// ID.
  bool get isRandom => (_flags & RANDOM_FLAG) == RANDOM_FLAG;

  /// Returns a new trace flags with the random flag enabled or disabled.
  ///
  /// All other bits, including [SAMPLED_FLAG], are preserved.
  ///
  /// Only set this when the trace ID actually meets the randomness
  /// requirement described on [RANDOM_FLAG]. Setting it for an ID that does
  /// not produces a non-conforming `traceparent`, and downstream systems are
  /// entitled to rely on the guarantee.
  TraceFlags withRandom(bool isRandom) {
    if (isRandom) {
      return TraceFlagsCreate.create(_flags | RANDOM_FLAG);
    } else {
      return TraceFlagsCreate.create(_flags & ~RANDOM_FLAG);
    }
  }

  /// Convert flags to hex string
  @override
  String toString() => _flags.toRadixString(16).padLeft(2, '0');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraceFlags &&
          runtimeType == other.runtimeType &&
          _flags == other._flags;

  @override
  int get hashCode => _flags.hashCode;
}
