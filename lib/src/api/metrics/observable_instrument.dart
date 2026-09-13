// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'meter.dart';

/// An asynchronous instrument that reports through a callback.
///
/// The three observable instruments implement this so that
/// [APIMeter.registerBatchCallback] can accept them with a real type, and so
/// a batch callback can name the instrument each measurement belongs to,
/// which metrics/api.md requires of multiple-instrument callbacks.
abstract class APIObservableInstrument {
  /// The instrument name.
  String get name;

  /// The [APIMeter] that created this instrument.
  APIMeter get meter;
}
