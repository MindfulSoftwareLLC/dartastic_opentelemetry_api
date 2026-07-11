// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';

import '../../factory/otel_factory.dart';
import '../common/attributes.dart';
import 'span_context.dart';

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
