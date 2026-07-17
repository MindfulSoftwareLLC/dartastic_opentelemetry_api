// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// Template-attribute helper for HTTP header keys.
library;

import 'semantics_base.dart';

/// Utility class for creating OpenTelemetry HTTP header attribute keys.
///
/// This class provides a way to generate properly formatted HTTP header
/// attribute keys following the OpenTelemetry specification's template
/// attributes `http.request.header.<key>` / `http.response.header.<key>`.
///
/// Extends [OTelSemantic], so instances can be used directly in
/// `OTelAPI.attributesFromSemanticMap`.
class HttpHeaderAttribute extends OTelSemantic {
  /// Constructor for HTTP request headers
  /// Example usage: HttpHeaderAttribute.request('content-type')
  HttpHeaderAttribute.request(String headerName)
      : super('http.request.header.${headerName.toLowerCase()}');

  /// Constructor for HTTP response headers
  /// Example usage: HttpHeaderAttribute.response('content-type')
  HttpHeaderAttribute.response(String headerName)
      : super('http.response.header.${headerName.toLowerCase()}');
}
