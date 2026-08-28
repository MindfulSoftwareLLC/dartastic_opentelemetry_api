// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:meta/meta.dart';

import 'instrument_advisory.dart';
import 'measurement.dart';
import 'meter.dart';
import 'observable_callback.dart';

part 'observable_up_down_counter_create.dart';

/// APIObservableUpDownCounter is an asynchronous Instrument which reports
/// values that increase or decrease when the instrument is being observed.
///
/// An ObservableUpDownCounter is intended for capturing values that can increase or
/// decrease, such as the current memory usage, active requests, or items in a queue.
class APIObservableUpDownCounter<T extends num> {
  final String _name;
  final String? _description;
  final String? _unit;
  final APIMeter _meter;
  final InstrumentAdvisory? _advisory;
  final List<ObservableCallback<T>> _callbacks = [];

  /// Creates a new observable up-down counter instrument
  APIObservableUpDownCounter(
      this._name, this._description, this._unit, this._meter,
      [this._advisory, List<ObservableCallback<T>> callbacks = const []]) {
    for (final cb in callbacks) {
      addCallback(cb);
    }
  }

  /// Returns the name of this observable up-down counter.
  String get name => _name;

  /// Returns the description of this observable up-down counter.
  String? get description => _description;

  /// Returns the unit of this observable up-down counter.
  String? get unit => _unit;

  /// Returns the advisory parameters of this observable up-down counter.
  InstrumentAdvisory? get advisory => _advisory;

  /// Returns whether the instrument is enabled and will record measurements.
  ///
  /// The returned value can change over time; instrumentation authors need
  /// to call this before each measurement to ensure they have the most
  /// up-to-date response. The base API implementation always returns false;
  /// SDK subclasses override this to compute the real, current value.
  bool isEnabled() => false;

  /// Returns the meter that created this observable up-down counter.
  APIMeter get meter => _meter;

  /// Returns the current list of callbacks registered to this instrument.
  List<ObservableCallback<T>> get callbacks => List.unmodifiable(_callbacks);

  /// Registers a callback function that will be invoked when the instrument is observed.
  /// Returns a registration handle that can be used to unregister the callback.
  ///
  /// This method returns a handle for idiomatic registration management, while
  /// [removeCallback] is provided for direct reference-based removal (since
  /// single-instrument callbacks are tightly coupled and simple enough to not strictly require a handle).
  APICallbackRegistration<T> addCallback(ObservableCallback<T> callback) {
    _callbacks.add(callback);
    return _CallbackRegistration<T>(this, callback);
  }

  /// Removes a callback from this instrument by direct reference.
  ///
  /// Provided alongside the registration handle returned by [addCallback] because
  /// single-instrument callbacks are simple enough not to strictly require a handle object.
  void removeCallback(ObservableCallback<T> callback) {
    _callbacks.remove(callback);
  }

  /// Collects measurements from all registered callbacks.
  /// This method is typically only called by the SDK during collection.
  List<Measurement> collect() {
    // In the API implementation, this simply returns an empty list
    return <Measurement>[];
  }
}

/// Default implementation of [APICallbackRegistration].
class _CallbackRegistration<T extends num>
    implements APICallbackRegistration<T> {
  final APIObservableUpDownCounter<T> _instrument;
  final ObservableCallback<T> _callback;

  _CallbackRegistration(this._instrument, this._callback);

  @override
  void unregister() {
    _instrument.removeCallback(_callback);
  }
}
