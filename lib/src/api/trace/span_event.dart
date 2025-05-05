// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library span_event;

import 'package:meta/meta.dart';

import '../common/attributes.dart';

part 'span_event_create.dart';

/// Represents an event that occurred during a span's lifetime.
///
/// Span events provide additional context about specific points in time
/// during the execution of a span. They can include information about
/// important state changes, errors, or other notable occurrences.
@immutable
class SpanEvent {
  /// The name of this event.
  ///
  /// This should be a concise, human-readable description of what occurred.
  final String name;

  /// The time at which this event occurred.
  ///
  /// This timestamp should reflect when the event actually happened, not when
  /// it was recorded.
  final DateTime timestamp;

  /// Additional attributes providing context about this event.
  ///
  /// These attributes can include any relevant details about the event
  /// not captured in the name.
  final Attributes? attributes;

  SpanEvent._({
    required this.name,
    required this.timestamp,
    this.attributes,
  });
}
