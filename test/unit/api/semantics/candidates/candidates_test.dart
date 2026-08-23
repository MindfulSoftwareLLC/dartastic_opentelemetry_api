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

Set<String> get _registryKeys => SemconvRegistry.allAttributeEnums
    .expand((e) => e)
    .map((a) => a.key)
    .toSet();

/// A key with its delimiters removed, so that names differing only in how
/// they are organized — `previous_id` vs `previous.id` — compare equal.
String _shape(String key) => key.replaceAll(RegExp('[._]'), '').toLowerCase();

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

    // The graduation guard, part 1: exact collision. When a candidate is
    // accepted upstream it starts being generated into semconv/, and the
    // same key would then exist twice under two different stability
    // promises. A key listed in [deprecatedCandidateKeys] is mid-cycle —
    // already @Deprecated in favor of its generated twin — and is exempt
    // for that one release.
    test('no candidate duplicates a registry attribute key', () {
      final graduated = _candidateKeys
          .where(_registryKeys.contains)
          .where((k) => !deprecatedCandidateKeys.contains(k))
          .toList()
        ..sort();
      expect(
        graduated,
        isEmpty,
        reason: 'Now in the registry — mark the candidate @Deprecated in '
            'favor of the generated semconv/ enum, add its key to '
            'deprecatedCandidateKeys, and remove it next release: $graduated',
      );
    });

    // Part 2: near-miss. Upstream may accept the concept but organize the
    // name differently — `app.screen.previous.id` instead of
    // `app.screen.previous_id`, say. That is still a graduation, and an
    // exact-string check would sail straight past it, so compare with the
    // delimiters removed as well.
    //
    // Neither check can catch a graduation under a genuinely different
    // name (`app.previous_screen.id`, or a rename to `app.view.*`). That
    // needs a human reading the registry diff, which is why every
    // regeneration should be reviewed against doc/SEMCONV_CANDIDATES.md.
    test('no candidate near-misses a registry attribute key', () {
      final registryByShape = {
        for (final k in _registryKeys) _shape(k): k,
      };
      final collisions = <String>[];
      for (final key in _candidateKeys) {
        if (deprecatedCandidateKeys.contains(key)) continue;
        final match = registryByShape[_shape(key)];
        if (match != null && match != key) collisions.add('$key ~ $match');
      }
      collisions.sort();
      expect(
        collisions,
        isEmpty,
        reason: 'A registry key differs from a candidate only in how the '
            'name is organized. Treat this as a graduation: deprecate the '
            "candidate in favor of the registry's spelling and add its key "
            'to deprecatedCandidateKeys: $collisions',
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
