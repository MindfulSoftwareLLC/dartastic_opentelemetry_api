// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Registry replacement for the removed `LifecycleState` and
// `AppLifecycleStates` enums: app lifecycle is modeled by the
// `device.app.lifecycle` event carrying a platform state attribute
// (`android.app.state` or `ios.app.state`).
// flutterrific_opentelemetry maps Flutter's
// resumed/inactive/paused/detached states onto these platform values.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('App lifecycle semconv', () {
    test('device.app.lifecycle event', () {
      expect(
          DeviceEvent.deviceAppLifecycle.name, equals('device.app.lifecycle'));
      expect(DeviceEvent.deviceAppLifecycle.toString(),
          equals('device.app.lifecycle'));
    });

    test('android.app.state attribute and values', () {
      expect(Android.androidAppState.key, equals('android.app.state'));
      expect(AndroidAppState.created.value, equals('created'));
      expect(AndroidAppState.background.value, equals('background'));
      expect(AndroidAppState.foreground.value, equals('foreground'));
      expect(AndroidAppState.foreground.toString(), equals('foreground'));
    });

    test('ios.app.state attribute and values', () {
      expect(Ios.iosAppState.key, equals('ios.app.state'));
      expect(IosAppState.active.value, equals('active'));
      expect(IosAppState.inactive.value, equals('inactive'));
      expect(IosAppState.background.value, equals('background'));
      expect(IosAppState.foreground.value, equals('foreground'));
      expect(IosAppState.terminate.value, equals('terminate'));
      expect(IosAppState.terminate.toString(), equals('terminate'));
    });

    test('lifecycle state attributes round-trip through Attributes', () {
      final attrs = OTelAPI.attributesFromSemanticMap({
        Android.androidAppState: AndroidAppState.foreground.value,
        Ios.iosAppState: IosAppState.active.value,
      });
      expect(attrs.getString('android.app.state'), equals('foreground'));
      expect(attrs.getString('ios.app.state'), equals('active'));
    });
  });
}
