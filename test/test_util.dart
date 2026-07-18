// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/src/api/factory/otel_api_factory.dart';
import 'package:dartastic_opentelemetry_api/src/factory/otel_factory.dart';
import 'package:test/expect.dart';

class IsBetween extends Matcher {
  final DateTime before;
  final DateTime after;

  const IsBetween(this.before, this.after);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    final timestamp = item as DateTime;
    return timestamp.compareTo(before) >= 0 && timestamp.compareTo(after) <= 0;
  }

  @override
  Description describe(Description description) =>
      description.add('is between $before and $after');
}

/// An [OTelAPIFactory] that reports `isAPIFactory == false`, mimicking an
/// installed SDK. The API's spec-mandated no-SDK behavior (non-recording
/// spans carrying the parent SpanContext, all-zero IDs for roots) only
/// applies when the installed factory is the pure API factory, so tests
/// that exercise the real span-creation engine (ID minting, parent/child
/// validation, attribute recording) install this instead.
class SdkLikeFactory extends OTelAPIFactory {
  /// Creates the SDK-like factory with the standard test configuration.
  SdkLikeFactory({
    required super.apiEndpoint,
    required super.apiServiceName,
    required super.apiServiceVersion,
  });

  @override
  bool get isAPIFactory => false;
}

/// Replaces the installed factory with an [SdkLikeFactory], so span
/// creation behaves as it does with an SDK installed. Call after
/// `OTelAPI.initialize()`.
void installSdkLikeFactory() {
  OTelFactory.otelFactory = SdkLikeFactory(
    apiEndpoint: 'http://localhost:4317',
    apiServiceName: 'test-service',
    apiServiceVersion: '1.0.0',
  );
}
