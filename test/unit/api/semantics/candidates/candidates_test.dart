// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

/// Every candidate attribute key, flattened.
const _candidateEnums = <List<OTelSemantic>>[
  AppCandidate.values,
  BrowserCandidate.values,
  DeviceCandidate.values,
];

Iterable<String> get _candidateKeys =>
    _candidateEnums.expand((e) => e).map((a) => a.key);

void main() {
  group('semconv candidates', () {
    // The keys are pinned so that renaming one is a deliberate, reviewed act
    // rather than a refactor side effect. These are wire values.
    test('app candidate keys', () {
      expect(AppCandidate.values.map((a) => a.key), [
        'app.start.type',
        'app.launch.id',
        'app.screen.previous_id',
        'app.screen.previous_name',
        'app.gesture.direction',
        'app.gesture.delta.x',
        'app.gesture.delta.y',
      ]);
    });

    test('device candidate keys', () {
      expect(DeviceCandidate.values.map((a) => a.key), [
        'device.battery.level',
        'device.battery.state',
        'device.battery.save_mode',
        'device.emulator',
      ]);
    });

    test('browser candidate keys', () {
      expect(BrowserCandidate.values.map((a) => a.key), [
        'browser.languages',
      ]);
    });

    test('candidate value enums carry their wire strings', () {
      expect(AppStartTypeValue.values.map((v) => v.value), [
        'cold',
        'warm',
        'hot',
      ]);
      expect(AppGestureDirectionValue.values.map((v) => v.value), [
        'up',
        'down',
        'left',
        'right',
      ]);
      expect(DeviceBatteryStateValue.values.map((v) => v.value), [
        'charging',
        'discharging',
        'full',
        'not_charging',
        'unknown',
      ]);
    });

    test('no two candidates share a key', () {
      final keys = _candidateKeys.toList();
      expect(keys.toSet().length, keys.length);
    });

    // The graduation guard. When a candidate is accepted upstream it starts
    // being generated into semconv/, and the same key would then exist twice
    // with two different stability promises. This test fails on the very
    // regeneration that accepts it, which is exactly when the candidate
    // should be deleted from candidates/ and callers repointed.
    test('no candidate duplicates a registry attribute', () {
      final registry = SemconvRegistry.allAttributeEnums
          .expand((e) => e)
          .map((a) => a.key)
          .toSet();
      final graduated = _candidateKeys.where(registry.contains).toList()
        ..sort();
      expect(
        graduated,
        isEmpty,
        reason: 'These candidates are now in the registry — delete them from '
            'lib/src/api/semantics/candidates/ and use the generated '
            'semconv/ enum instead: $graduated',
      );
    });

    test('candidates are usable as OTelSemantic', () {
      final entry = DeviceCandidate.deviceBatteryLevel.toMapEntry(0.42);
      expect(entry.key, 'device.battery.level');
      expect(entry.value, 0.42);
      expect(BrowserCandidate.browserLanguages.toString(), 'browser.languages');
    });
  });
}
