// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('RUM/vendor semantics (deprecated)', () {
    test('AppLifecycleStates toString returns key', () {
      expect(AppLifecycleStates.active.toString(),
          equals('device.app.lifecycle.active'));
      expect(AppLifecycleStates.resumed.toString(),
          equals('device.app.lifecycle.resumed'));
      expect(AppLifecycleStates.detached.toString(),
          equals('device.app.lifecycle.detached'));
      expect(AppLifecycleStates.inactive.toString(),
          equals('device.app.lifecycle.inactive'));
      expect(AppLifecycleStates.hidden.toString(),
          equals('device.app.lifecycle.hidden'));
      expect(AppLifecycleStates.paused.toString(),
          equals('device.app.lifecycle.paused'));
    });

    test('AppLifecycleStates.appLifecycleStateFor maps platform strings', () {
      expect(AppLifecycleStates.appLifecycleStateFor('detached'),
          equals(AppLifecycleStates.detached));
      expect(AppLifecycleStates.appLifecycleStateFor('resumed'),
          equals(AppLifecycleStates.resumed));
      expect(AppLifecycleStates.appLifecycleStateFor('inactive'),
          equals(AppLifecycleStates.inactive));
      expect(AppLifecycleStates.appLifecycleStateFor('hidden'),
          equals(AppLifecycleStates.hidden));
      expect(AppLifecycleStates.appLifecycleStateFor('paused'),
          equals(AppLifecycleStates.paused));
      // Unknown / unspecified strings fall back to active.
      expect(AppLifecycleStates.appLifecycleStateFor('active'),
          equals(AppLifecycleStates.active));
      expect(AppLifecycleStates.appLifecycleStateFor('garbage'),
          equals(AppLifecycleStates.active));
      expect(AppLifecycleStates.appLifecycleStateFor(''),
          equals(AppLifecycleStates.active));
    });

    test('AppLifecycleSemantics toString returns key', () {
      expect(AppLifecycleSemantics.appLaunchId.toString(),
          equals('app.launch.id'));
      expect(AppLifecycleSemantics.appLifecycleId.toString(),
          equals('app_lifecycle.id'));
      expect(AppLifecycleSemantics.appLifecycleChange.toString(),
          equals('app_lifecycle.changed'));
      expect(AppLifecycleSemantics.appLifecycleState.toString(),
          equals('app_lifecycle.state'));
      expect(AppLifecycleSemantics.appLifecycleStateId.toString(),
          equals('app_lifecycle.state_id'));
      expect(AppLifecycleSemantics.appLifecyclePreviousState.toString(),
          equals('app_lifecycle.previous_state'));
      expect(AppLifecycleSemantics.appLifecyclePreviousStateId.toString(),
          equals('app_lifecycle.previous_state_id'));
      expect(AppLifecycleSemantics.appLifecyclePreviousLifecycleId.toString(),
          equals('app_lifecycle.previous_lifecycle_id'));
      expect(AppLifecycleSemantics.appLifecycleTimestamp.toString(),
          equals('app_lifecycle.timestamp'));
      expect(AppLifecycleSemantics.appLifecycleDuration.toString(),
          equals('app_lifecycle.duration'));
      expect(AppLifecycleSemantics.appStartType.toString(),
          equals('app.start.type'));
    });

    test('AppStartType toString returns key', () {
      expect(AppStartType.cold.toString(), equals('cold'));
      expect(AppStartType.hot.toString(), equals('hot'));
    });

    test('AppInfoSemantics toString returns key', () {
      expect(AppInfoSemantics.appId.toString(), equals('app.id'));
      expect(AppInfoSemantics.appName.toString(), equals('app.name'));
      expect(AppInfoSemantics.appVersion.toString(), equals('app.version'));
      expect(AppInfoSemantics.appBuildNumber.toString(),
          equals('app.build_number'));
      expect(AppInfoSemantics.appPackageName.toString(),
          equals('app.package_name'));
    });

    test('DeviceSemantics toString returns key', () {
      expect(DeviceSemantics.deviceId.toString(), equals('device.id'));
      expect(DeviceSemantics.deviceModel.toString(), equals('device.model'));
      expect(
          DeviceSemantics.devicePlatform.toString(), equals('device.platform'));
      expect(DeviceSemantics.deviceOsVersion.toString(),
          equals('device.os_version'));
      expect(DeviceSemantics.isPhysicalDevice.toString(),
          equals('device.physical'));
      expect(DeviceSemantics.isiOSAppOnMac.toString(),
          equals('device.ios_on_mac'));
    });

    test('BatterySemantics toString returns key', () {
      expect(BatterySemantics.batteryLevel.toString(), equals('battery.level'));
      expect(BatterySemantics.batteryState.toString(), equals('battery.state'));
      expect(BatterySemantics.batteryStateFull.toString(),
          equals('battery.state.full'));
      expect(BatterySemantics.batteryStateCharging.toString(),
          equals('battery.state.charging'));
      expect(BatterySemantics.batteryStateConnectedNotCharging.toString(),
          equals('battery.state.connected_not_charging'));
      expect(BatterySemantics.batteryStateDischanrging.toString(),
          equals('battery.state.discharging'));
      expect(BatterySemantics.batteryStateUnknown.toString(),
          equals('battery.state.unknown'));
      expect(BatterySemantics.batterySaveMode.toString(),
          equals('battery.save_mode'));
    });

    test('NavigationSemantics toString returns key', () {
      expect(NavigationSemantics.navigationAction.toString(),
          equals('navigation.action'));
      expect(NavigationSemantics.navigationTrigger.toString(),
          equals('navigation.trigger'));
      expect(NavigationSemantics.navigationTimestamp.toString(),
          equals('navigation.timestamp'));
      expect(NavigationSemantics.routeName.toString(),
          equals('navigation.route.name'));
      expect(NavigationSemantics.routeId.toString(),
          equals('navigation.route.id'));
      expect(NavigationSemantics.routeKey.toString(),
          equals('navigation.route.key'));
      expect(NavigationSemantics.routePath.toString(),
          equals('navigation.route.path'));
      expect(NavigationSemantics.routeArguments.toString(),
          equals('navigation.route.arguments'));
      expect(NavigationSemantics.routeTimestamp.toString(),
          equals('navigation.route.timestamp'));
      expect(NavigationSemantics.previousRouteName.toString(),
          equals('navigation.previous_route_name'));
      expect(NavigationSemantics.previousRouteId.toString(),
          equals('navigation.previous_route_id'));
      expect(NavigationSemantics.previousRoutePath.toString(),
          equals('navigation.previous_route_path'));
      expect(NavigationSemantics.previousRouteDuration.toString(),
          equals('route.previous_route_duration'));
      expect(NavigationSemantics.routeTransitionDuration.toString(),
          equals('route.transition_duration'));
    });

    test('InteractionType toString returns key', () {
      expect(InteractionType.click.toString(), equals('click'));
      expect(InteractionType.drag.toString(), equals('drag'));
      expect(InteractionType.focusChange.toString(), equals('focus_change'));
      expect(InteractionType.formSubmit.toString(), equals('form_submit'));
      expect(InteractionType.keydown.toString(), equals('keydown'));
      expect(InteractionType.keyup.toString(), equals('keyup'));
      expect(
          InteractionType.listSelection.toString(), equals('list_selection'));
      expect(InteractionType.listSelectionIndex.toString(),
          equals('list_selected_index'));
      expect(InteractionType.longPress.toString(), equals('long_press'));
      expect(InteractionType.menuSelect.toString(), equals('menu_select'));
      expect(InteractionType.menuSelectedItem.toString(),
          equals('menu_selected_item'));
      expect(InteractionType.scroll.toString(), equals('scroll'));
      expect(InteractionType.swipe.toString(), equals('swipe'));
      expect(InteractionType.tap.toString(), equals('tap'));
      expect(InteractionType.textInput.toString(), equals('text_input'));
      expect(
          InteractionType.gestureDeltaX.toString(), equals('gesture.delta_x'));
      expect(
          InteractionType.gestureDeltaY.toString(), equals('gesture.delta_y'));
      expect(InteractionType.gestureDirection.toString(),
          equals('gesture.direction'));
    });

    test('InteractionSemantics toString returns key', () {
      expect(InteractionSemantics.userInteraction.toString(),
          equals('user_interaction'));
      expect(InteractionSemantics.interactionType.toString(),
          equals('interaction.type'));
      expect(InteractionSemantics.interactionTarget.toString(),
          equals('interaction.target'));
      expect(InteractionSemantics.interactionResult.toString(),
          equals('interaction.result'));
      expect(InteractionSemantics.inputDelay.toString(), equals('input.delay'));
    });

    test('PerformanceSemantics toString returns key', () {
      expect(PerformanceSemantics.renderDuration.toString(),
          equals('render.duration'));
      expect(PerformanceSemantics.firstPaint.toString(), equals('first.paint'));
      expect(PerformanceSemantics.firstContentfulPaint.toString(),
          equals('first.contentful.paint'));
      expect(PerformanceSemantics.timeToInteractive.toString(),
          equals('time.to.interactive'));
      expect(PerformanceSemantics.frameTime.toString(), equals('frame.time'));
      expect(PerformanceSemantics.frameRate.toString(), equals('frame.rate'));
      expect(PerformanceSemantics.jankCount.toString(), equals('jank.count'));
      expect(
          PerformanceSemantics.memoryUsage.toString(), equals('memory.usage'));
      expect(PerformanceSemantics.rumFirstInputDelay.toString(),
          equals('first_input_delay'));
    });

    test('ErrorSemantics toString returns key', () {
      expect(ErrorSemantics.errorType.toString(), equals('error.type'));
      expect(ErrorSemantics.errorSource.toString(), equals('error.source'));
      expect(ErrorSemantics.errorMessage.toString(), equals('error.message'));
      expect(ErrorSemantics.errorStacktrace.toString(),
          equals('error.stacktrace'));
      expect(ErrorSemantics.crashFreeSessionRate.toString(),
          equals('crash.free.session.rate'));
    });

    test('NetworkSemantics toString returns key', () {
      expect(NetworkSemantics.networkConnectivity.toString(),
          equals('network.connectivity'));
      expect(NetworkSemantics.networkType.toString(), equals('network.type'));
      expect(NetworkSemantics.networkRequestUrl.toString(),
          equals('network.request.url'));
      expect(NetworkSemantics.networkRequestDuration.toString(),
          equals('network.request.duration'));
    });

    test('Session (OTel spec) toString returns key', () {
      expect(Session.sessionId.toString(), equals('session.id'));
      expect(
          Session.sessionPreviousId.toString(), equals('session.previous_id'));
    });

    test('RumSessionView (non-spec) toString returns key', () {
      expect(RumSessionView.rumSessionId.toString(), equals('session_id'));
      expect(RumSessionView.sessionStart.toString(), equals('session.start'));
      expect(RumSessionView.sessionDuration.toString(),
          equals('session.duration'));
      expect(RumSessionView.viewName.toString(), equals('view.name'));
      expect(RumSessionView.rumViewName.toString(), equals('view_name'));
      expect(RumSessionView.rumViewId.toString(), equals('view_id'));
      expect(RumSessionView.viewStart.toString(), equals('view.start'));
      expect(RumSessionView.viewDuration.toString(), equals('view.duration'));
      expect(
          RumSessionView.rumViewLoadTime.toString(), equals('view_load_time'));
      expect(RumSessionView.rumActionCount.toString(), equals('action.count'));
      expect(RumSessionView.rumUserSatisfactionScore.toString(),
          equals('user_satisfaction_score'));
    });

    test('User (OTel spec) toString returns key', () {
      expect(User.userId.toString(), equals('user.id'));
      expect(User.userRoles.toString(), equals('user.roles'));
    });
  });
}
