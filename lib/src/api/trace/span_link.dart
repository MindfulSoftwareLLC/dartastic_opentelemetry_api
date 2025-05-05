// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:meta/meta.dart';
import 'package:dartastic_opentelemetry_api/src/api/trace/span_context.dart';

import '../../factory/otel_factory.dart';
import '../common/attributes.dart';

part 'span_link_create.dart';

/// Represents a link between spans in potentially different traces.
@immutable
class SpanLink {
  /// The context of the linked span
  final SpanContext spanContext;

  /// The attributes describing this link
  final Attributes attributes;

  /// Creates a new [SpanLink].
  SpanLink._({
    required this.spanContext,
    required this.attributes,
  });
}
