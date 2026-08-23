// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// Candidate `device.*` attribute keys. See `candidates.dart` for the
/// contract: everything here is unstable and staged for upstream.
library;

import 'package:meta/meta.dart';

import '../semantics_base.dart';

/// Candidate `device.*` keys with no registry equivalent.
///
/// The registry covers device identity — `device.id`, `device.manufacturer`,
/// `device.model.identifier`, `device.model.name` — and the
/// `device.app.lifecycle` event. Platform and OS version belong to the `os.*`
/// namespace (`os.name`, `os.version`), not here. These are the gaps.
@experimental
enum DeviceCandidate implements OTelSemantic {
  /// Battery charge as a fraction from 0.0 to 1.0.
  ///
  /// Deliberately a fraction rather than a percentage: the registry expresses
  /// every other proportion that way (`browser.web_vital.value`,
  /// `hw.*.utilization`), and a `0..1` double cannot be misread as `0..100`.
  ///
  /// The `hw.battery.*` attributes exist but describe server hardware
  /// inventory, not the battery of the device an application is running on.
  deviceBatteryLevel('device.battery.level'),

  /// Charging state. Values: [DeviceBatteryStateValue].
  deviceBatteryState('device.battery.state'),

  /// Whether the OS is in a battery-saver / low-power mode.
  ///
  /// Worth its own attribute because it changes application behaviour the
  /// user did not ask for — throttled timers, suspended background work,
  /// reduced frame rates — and so explains performance data that otherwise
  /// looks like a regression.
  deviceBatterySaveMode('device.battery.save_mode'),

  /// Whether the application is running on an emulator or simulator rather
  /// than physical hardware.
  ///
  /// Stated positively as `emulator` rather than negatively as `physical`:
  /// the interesting, filterable case is the emulator, and the negative form
  /// makes `false` the surprising value to reason about.
  deviceEmulator('device.emulator');

  @override
  final String key;

  const DeviceCandidate(this.key);

  @override
  String toString() => key;
}

/// Candidate values for `device.battery.state`.
///
/// `not_charging` is distinct from `discharging`: a device can be connected
/// to power and still not be charging (full, thermally limited, or holding a
/// charge level on purpose), and platforms report that separately.
@experimental
enum DeviceBatteryStateValue implements OTelSemanticValue {
  /// Connected to power and gaining charge.
  charging('charging'),

  /// Not connected to power and losing charge.
  discharging('discharging'),

  /// Connected to power and at full charge.
  full('full'),

  /// Connected to power but not currently gaining charge.
  notCharging('not_charging'),

  /// The platform did not report a state.
  unknown('unknown');

  @override
  final String value;

  const DeviceBatteryStateValue(this.value);

  @override
  String toString() => value;
}
