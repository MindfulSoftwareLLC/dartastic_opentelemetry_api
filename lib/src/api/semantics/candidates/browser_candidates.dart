// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// Candidate `browser.*` attribute keys. See `candidates.dart` for the
/// contract: everything here is unstable and staged for upstream.
library;

import 'package:meta/meta.dart';

import '../semantics_base.dart';

/// Candidate `browser.*` keys with no registry equivalent.
///
/// The registry defines `browser.brands`, `browser.language`,
/// `browser.mobile`, `browser.platform`, `browser.document.url.full` and the
/// `browser.web_vital.*` set. Use those.
@experimental
enum BrowserCandidate implements OTelSemantic {
  /// Every language the user accepts, in descending order of preference,
  /// from `navigator.languages`.
  ///
  /// The registry's `browser.language` carries only the single most-preferred
  /// language. The ordered list is what actually explains behaviour: content
  /// negotiation, locale fallback chains, and which of an application's
  /// supported locales a user ended up on.
  ///
  /// The value is a **`List<String>`**, not a joined string, per the naming
  /// rule that "if the attribute can represent multiple entities, the
  /// attribute name SHOULD be pluralized and the value type SHOULD be an
  /// array" — the same shape the registry gives `browser.brands`.
  ///
  /// Unlike the UA Client Hints-sourced `browser.*` attributes,
  /// `navigator.languages` is a plain Navigator API available in Chromium,
  /// WebKit and Gecko alike, so this one is implementable everywhere.
  browserLanguages('browser.languages');

  @override
  final String key;

  const BrowserCandidate(this.key);

  @override
  String toString() => key;
}
