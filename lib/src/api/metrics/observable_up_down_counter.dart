// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

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
  final bool _enabled;
  final APIMeter _meter;
  final List<ObservableCallback<T>> _callbacks = [];

  /// Creates a new observable up-down counter instrument
  APIObservableUpDownCounter(
      this._name, this._description, this._unit, this._enabled, this._meter,
      [ObservableCallback<T>? callback]) {
    if (callback != null) {
      addCallback(callback);
    }
  }

  /// Returns the name of this observable up-down counter.
  String get name => _name;

  /// Returns the description of this observable up-down counter.
  String? get description => _description;

  /// Returns the unit of this observable up-down counter.
  String? get unit => _unit;

  /// Returns whether this observable up-down counter is enabled.
  bool get enabled => _enabled;

  /// Returns the meter that created this observable up-down counter.
  APIMeter get meter => _meter;

  /// Returns the current list of callbacks registered to this instrument.
  List<ObservableCallback<T>> get callbacks => List.unmodifiable(_callbacks);

  /// Registers a callback function that will be invoked when the instrument is observed.
  APICallbackRegistration<T> addCallback(ObservableCallback<T> callback) {
    _callbacks.add(callback);
    return _CallbackRegistration<T>(this, callback);
  }

  /// Removes a callback from this instrument.
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
