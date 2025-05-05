// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'span_link.dart';

/// Internal constructor access for SpanLink
class SpanLinkCreate {
  /// Creates a SpanLink, only accessible within library
  static SpanLink create({
    required SpanContext spanContext,
    Attributes? attributes,
  }) {
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    return SpanLink._(
      spanContext: spanContext,
      attributes: attributes ?? OTelFactory.otelFactory!.attributes([]),
    );
  }
}
