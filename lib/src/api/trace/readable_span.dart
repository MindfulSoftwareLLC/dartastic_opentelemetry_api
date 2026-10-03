// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

part of 'span.dart';

/// Read access to the data an [APISpan] has recorded.
///
/// trace/api.md, Span: "`Span`s are not meant to be used to propagate
/// information within a process. To prevent misuse, implementations SHOULD NOT
/// provide access to a `Span`'s attributes besides its `SpanContext`."
///
/// An SDK still has to read what it recorded in order to export it, so the
/// accessors live here instead of on [APISpan]. This type is not exported from
/// the package barrel, so application code holding an [APISpan] cannot reach
/// it. An SDK reaches it by importing
/// `package:dartastic_opentelemetry_api/src/api/trace/span.dart` directly.
@internal
class ReadableSpan {
  final APISpan _span;

  const ReadableSpan._(this._span);

  /// The attributes recorded on the span.
  Attributes get attributes => _span._attributes;

  /// The events recorded on the span, or null when none were added.
  List<SpanEvent>? get spanEvents =>
      _span._spanEvents == null ? null : List.unmodifiable(_span._spanEvents!);

  /// The links recorded on the span, or null when none were added.
  List<SpanLink>? get spanLinks =>
      _span._spanLinks == null ? null : List.unmodifiable(_span._spanLinks!);

  /// The status code, [SpanStatusCode.Unset] when never set.
  SpanStatusCode get status => _span._spanStatusCode ?? SpanStatusCode.Unset;

  /// The status description, or null when none was set.
  String? get statusDescription => _span._statusDescription;
}

/// Returns read access to [span]'s recorded data, for SDK and exporter use.
///
/// See [ReadableSpan] for why this is not on [APISpan] itself.
@internal
ReadableSpan getReadableSpan(APISpan span) => ReadableSpan._(span);
