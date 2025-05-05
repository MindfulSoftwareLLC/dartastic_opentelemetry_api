// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// ignore_for_file: public_member_api_docs

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

//TODO geo
//https://opentelemetry.io/docs/specs/semconv/attributes-registry/geo/

/// Defines the UI lifecycle, values for AppLifecycleSemantics.lifecycleState
enum AppLifecycleStates implements OTelSemantic {
  active('device.app.lifecycle.active'),
  resumed('device.app.lifecycle.resumed'),
  detached('device.app.lifecycle.detached'),
  inactive('device.app.lifecycle.inactive'),
  hidden('device.app.lifecycle.hidden'),
  paused('device.app.lifecycle.paused');

  @override
  final String key;

  @override
  String toString() => key;

  const AppLifecycleStates(this.key);

  /// Converts a platform-specific lifecycle state string to the corresponding AppLifecycleStates enum value.
  ///
  /// [state] The platform-specific lifecycle state string (e.g., 'resumed', 'inactive')
  /// Returns the matching AppLifecycleStates value, or AppLifecycleStates.active if no match is found.
  static AppLifecycleStates appLifecycleStateFor(String state) {
    if (state == 'detached') {
      return AppLifecycleStates.detached;
    }
    if (state == 'resumed') {
      return AppLifecycleStates.resumed;
    }
    if (state == 'inactive') {
      return AppLifecycleStates.inactive;
    }
    if (state == 'hidden') {
      return AppLifecycleStates.hidden;
    }
    if (state == 'paused') {
      return AppLifecycleStates.paused;
    }
    return AppLifecycleStates.active;
  }
}

/// RUM Semantics related to application lifecycle events
enum AppLifecycleSemantics implements OTelSemantic {
  appLaunchId('app.launch.id'),
  appLifecycleId('app_lifecycle.id'),
  appLifecycleChange('app_lifecycle.changed'),
  // App lifecycle state key, value is one of the AppLifecycleState
  appLifecycleState('app_lifecycle.state'),
  appLifecycleStateId('app_lifecycle.state_id'),
  appLifecyclePreviousState('app_lifecycle.previous_state'),
  appLifecyclePreviousStateId('app_lifecycle.previous_state_id'),
  appLifecyclePreviousLifecycleId('app_lifecycle.previous_lifecycle_id'),
  appLifecycleTimestamp('app_lifecycle.timestamp'),
  appLifecycleDuration('app_lifecycle.duration'),
  appStartType('app.start.type'); //cold/hot

  @override
  final String key;

  @override
  String toString() => key;

  const AppLifecycleSemantics(this.key);
}

/// RUM Semantic values for AppLifecycleSemantics.appStartType key
enum AppStartType implements OTelSemantic {
  cold('cold'),
  hot('hot');

  @override
  final String key;

  @override
  String toString() => key;

  const AppStartType(this.key);
}

/// RUM Semantics related to application information
enum AppInfoSemantics implements OTelSemantic {
  appId('app.id'),
  appName('app.name'),
  appVersion('app.version'),
  appBuildNumber('app.build_number'),
  appPackageName('app.package_name'),
  ;

  @override
  final String key;

  @override
  String toString() => key;

  const AppInfoSemantics(this.key);
}

/// RUM Semantics related to device information
enum DeviceSemantics implements OTelSemantic {
  deviceId('device.id'),
  deviceModel('device.model'),
  devicePlatform('device.platform'),
  deviceOsVersion('device.os_version'),
  isPhysicalDevice('device.physical'),
  isiOSAppOnMac('device.ios_on_mac'),
  ;

  @override
  final String key;

  @override
  String toString() => key;

  const DeviceSemantics(this.key);
}

enum BatterySemantics implements OTelSemantic {
  batteryLevel('battery.level'),
  batteryState('battery.state'),

  /// Battery state values
  batteryStateFull('battery.state.full'),
  batteryStateCharging('battery.state.charging'),
  batteryStateConnectedNotCharging('battery.state.connected_not_charging'),
  batteryStateDischanrging('battery.state.discharging'),
  batteryStateUnknown('battery.state.unknown'),
  batterySaveMode('battery.save_mode');

  @override
  final String key;

  @override
  String toString() => key;

  const BatterySemantics(this.key);
}

/// RUM Semantics related to navigation and routing
enum NavigationSemantics implements OTelSemantic {
  navigationAction('navigation.action'),
  navigationTrigger('navigation.trigger'),
  navigationTimestamp('navigation.timestamp'),
  routeName('navigation.route.name'),
  routeId('navigation.route.id'),
  routeKey('navigation.route.key'),
  routePath('navigation.route.path'),
  routeArguments('navigation.route.arguments'),
  routeTimestamp('navigation.route.timestamp'),
  previousRouteName('navigation.previous_route_name'),
  previousRouteId('navigation.previous_route_id'),
  previousRoutePath('navigation.previous_route_path'),
  previousRouteDuration('route.previous_route_duration'),
  routeTransitionDuration('route.transition_duration');

  @override
  final String key;

  @override
  String toString() => key;

  const NavigationSemantics(this.key);
}

enum InteractionType implements OTelSemantic {
  click('click'),
  drag('drag'),
  focusChange('focus_change'),
  formSubmit('form_submit'),
  keydown('keydown'),
  keyup('keyup'),
  listSelection('list_selection'),
  listSelectionIndex('list_selected_index'),
  longPress('long_press'),
  menuSelect('menu_select'),
  menuSelectedItem('menu_selected_item'),
  scroll('scroll'),
  swipe('swipe'),
  tap('tap'),
  textInput('text_input'),

  // Gesture details
  gestureDeltaX('gesture.delta_x'),
  gestureDeltaY('gesture.delta_y'),
  gestureDirection('gesture.direction');

  @override
  final String key;

  @override
  String toString() => key;

  const InteractionType(this.key);
}

/// Semantics related to user interactions
enum InteractionSemantics implements OTelSemantic {
  userInteraction('user_interaction'),
  interactionType('interaction.type'),
  interactionTarget('interaction.target'),
  interactionResult('interaction.result'),
  inputDelay('input.delay');

  @override
  final String key;

  @override
  String toString() => key;

  const InteractionSemantics(this.key);
}

/// RUM Semantics related to performance measurements
enum PerformanceSemantics implements OTelSemantic {
  renderDuration('render.duration'),
  firstPaint('first.paint'),
  firstContentfulPaint('first.contentful.paint'),
  timeToInteractive('time.to.interactive'),
  frameTime('frame.time'),
  frameRate('frame.rate'),
  jankCount('jank.count'),
  memoryUsage('memory.usage'),
  rumFirstInputDelay('first_input_delay');

  @override
  final String key;

  @override
  String toString() => key;

  const PerformanceSemantics(this.key);
}

/// RUM Semantics related to errors and crashes
enum ErrorSemantics implements OTelSemantic {
  errorType('error.type'),
  errorSource('error.source'),
  errorMessage('error.message'),
  errorStacktrace('error.stacktrace'),
  crashFreeSessionRate('crash.free.session.rate');

  @override
  final String key;

  @override
  String toString() => key;

  const ErrorSemantics(this.key);
}

/// RUM Semantics related to network
enum NetworkSemantics implements OTelSemantic {
  networkConnectivity('network.connectivity'),
  networkType('network.type'),
  networkRequestUrl('network.request.url'),
  networkRequestDuration('network.request.duration');

  @override
  final String key;

  @override
  String toString() => key;

  const NetworkSemantics(this.key);
}

/// RUM Semantics related to session and view information
enum SessionViewSemantics implements OTelSemantic {
  sessionId('session.id'),
  rumSessionId('session_id'),
  sessionStart('session.start'),
  sessionDuration('session.duration'),

  viewName('view.name'),
  rumViewName('view_name'),
  rumViewId('view_id'),
  viewStart('view.start'),
  viewDuration('view.duration'),
  rumViewLoadTime('view_load_time'),
  rumActionCount('action.count'),
  rumUserSatisfactionScore('user_satisfaction_score');

  @override
  final String key;

  @override
  String toString() => key;

  const SessionViewSemantics(this.key);
}

/// RUM Semantics related to user information
enum UserSemantics implements OTelSemantic {
  userId('user.id'),
  userRole('user.role'),
  userSession('user.session');

  @override
  final String key;

  @override
  String toString() => key;

  const UserSemantics(this.key);
}
