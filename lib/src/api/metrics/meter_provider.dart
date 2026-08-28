// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';
import '../common/attributes.dart';
import 'meter.dart';

part 'meter_provider_create.dart';

/// APIMeterProvider is the entry point of the OpenTelemetry metrics API.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the MeterProvider from the SDK instead.
/// It provides access to [APIMeter]s which are used to record metrics.
/// You cannot create a MeterProvider directly;
/// you must use [OTelAPI] or more likely, [OTel], for example to get the default meter provider:
/// ```dart
/// var meterProvider = OTel.meterProvider();
/// ```
/// See [OTel] for creating meters in addition to the default.
/// Use [OTelAPI] to run in no-op mode, as required by the specification.
class APIMeterProvider {
  /// Creates a new [APIMeterProvider].
  /// You cannot create a MeterProvider directly; you must use [OTelFactory]:
  /// ```dart
  /// var meterProvider = OTelFactory.meterProvider();
  APIMeterProvider._();

  /// Returns a [APIMeter] with the given [name] and [version].
  ///
  /// [name] The name of the meter, usually the package name of the instrumented library.
  /// [version] The version of the instrumented library.
  /// [schemaUrl] Optional URL of the OpenTelemetry schema being used.
  /// [attributes] Optional Attributes for the Meter.
  APIMeter getMeter(
      {required String name,
      String? version,
      String? schemaUrl,
      Attributes? attributes}) {
    return APIMeterCreate.create(
      name: name,
      version: version,
      schemaUrl: schemaUrl,
      attributes: attributes,
    );
  }

  /// Shuts down the MeterProvider.
  /// After shutdown:
  /// - New metrics will not be recorded
  /// - All pending metrics should be exported
  /// - Resources should be cleaned up
  /// Returns true if shutdown was successful.
  Future<bool> shutdown() async => true;

  /// Forces the MeterProvider to flush all pending metrics to exporters.
  /// This is useful when the application is about to terminate and you want
  /// to ensure all metrics are exported.
  /// Returns true if the flush was successful, false otherwise.
  Future<bool> forceFlush() async => true;
}
