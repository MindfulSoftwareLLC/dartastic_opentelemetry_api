// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('UI Semantics', () {
    test('AppLifecycleStates toString returns key', () {
      expect(AppLifecycleStates.active.toString(), equals('device.app.lifecycle.active'));
      expect(AppLifecycleStates.resumed.toString(), equals('device.app.lifecycle.resumed'));
      expect(AppLifecycleStates.detached.toString(), equals('device.app.lifecycle.detached'));
      expect(AppLifecycleStates.inactive.toString(), equals('device.app.lifecycle.inactive'));
      expect(AppLifecycleStates.hidden.toString(), equals('device.app.lifecycle.hidden'));
      expect(AppLifecycleStates.paused.toString(), equals('device.app.lifecycle.paused'));
    });

    test('AppLifecycleSemantics toString returns key', () {
      expect(AppLifecycleSemantics.appLaunchId.toString(), equals('app.launch.id'));
      expect(AppLifecycleSemantics.appLifecycleState.toString(), equals('app_lifecycle.state'));
    });

    test('AppStartType toString returns key', () {
      expect(AppStartType.cold.toString(), equals('cold'));
      expect(AppStartType.hot.toString(), equals('hot'));
    });

    test('AppInfoSemantics toString returns key', () {
      expect(AppInfoSemantics.appId.toString(), equals('app.id'));
      expect(AppInfoSemantics.appName.toString(), equals('app.name'));
    });

    test('DeviceSemantics toString returns key', () {
      expect(DeviceSemantics.deviceId.toString(), equals('device.id'));
      expect(DeviceSemantics.deviceModel.toString(), equals('device.model'));
    });

    test('BatterySemantics toString returns key', () {
      expect(BatterySemantics.batteryLevel.toString(), equals('battery.level'));
      expect(BatterySemantics.batteryState.toString(), equals('battery.state'));
    });

    test('NavigationSemantics toString returns key', () {
      expect(NavigationSemantics.navigationAction.toString(), equals('navigation.action'));
      expect(NavigationSemantics.navigationTrigger.toString(), equals('navigation.trigger'));
    });

    test('InteractionType toString returns key', () {
      expect(InteractionType.click.toString(), equals('click'));
      expect(InteractionType.tap.toString(), equals('tap'));
    });

    test('InteractionSemantics toString returns key', () {
      expect(InteractionSemantics.userInteraction.toString(), equals('user_interaction'));
      expect(InteractionSemantics.interactionType.toString(), equals('interaction.type'));
    });

    test('PerformanceSemantics toString returns key', () {
      expect(PerformanceSemantics.renderDuration.toString(), equals('render.duration'));
      expect(PerformanceSemantics.firstPaint.toString(), equals('first.paint'));
    });

    test('ErrorSemantics toString returns key', () {
      expect(ErrorSemantics.errorType.toString(), equals('error.type'));
      expect(ErrorSemantics.errorMessage.toString(), equals('error.message'));
    });

    test('NetworkSemantics toString returns key', () {
      expect(NetworkSemantics.networkConnectivity.toString(), equals('network.connectivity'));
      expect(NetworkSemantics.networkType.toString(), equals('network.type'));
    });

    test('SessionViewSemantics toString returns key', () {
      expect(SessionViewSemantics.sessionId.toString(), equals('session.id'));
      expect(SessionViewSemantics.rumSessionId.toString(), equals('session_id'));
    });

    test('UserSemantics toString returns key', () {
      expect(UserSemantics.userId.toString(), equals('user.id'));
      expect(UserSemantics.userRole.toString(), equals('user.role'));
    });
  });
}
