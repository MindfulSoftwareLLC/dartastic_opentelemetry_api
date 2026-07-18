// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Registry replacements for the removed vendor RUM enums: the keys those
// enums carried are covered by registry conventions — device.*,
// session.*, network.connection.type, error.type, service.*, and the
// app.* crash/jank surface.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Mobile semconv', () {
    test('device identity (was DeviceSemantics)', () {
      expect(Device.deviceId.key, equals('device.id'));
      expect(Device.deviceManufacturer.key, equals('device.manufacturer'));
      expect(
          Device.deviceModelIdentifier.key, equals('device.model.identifier'));
      expect(Device.deviceModelName.key, equals('device.model.name'));
    });

    test('session attributes and events (was RumSessionView)', () {
      expect(Session.sessionId.key, equals('session.id'));
      expect(Session.sessionPreviousId.key, equals('session.previous_id'));
      expect(SessionEvent.sessionStart.name, equals('session.start'));
      expect(SessionEvent.sessionEnd.name, equals('session.end'));
    });

    test('network connection type (was NetworkSemantics)', () {
      expect(
          Network.networkConnectionType.key, equals('network.connection.type'));
      expect(NetworkConnectionType.wifi.value, equals('wifi'));
      expect(NetworkConnectionType.cell.value, equals('cell'));
      expect(NetworkConnectionType.unavailable.value, equals('unavailable'));
    });

    test('error type (was ErrorSemantics)', () {
      expect(ErrorAttributes.errorType.key, equals('error.type'));
    });

    test('app identity (was AppInfoSemantics)', () {
      expect(Service.serviceName.key, equals('service.name'));
      expect(Service.serviceVersion.key, equals('service.version'));
      expect(App.appBuildId.key, equals('app.build_id'));
      expect(App.appInstallationId.key, equals('app.installation.id'));
    });

    test('crash and jank (was PerformanceSemantics)', () {
      expect(AppEvent.appCrash.name, equals('app.crash'));
      expect(AppEvent.appJank.name, equals('app.jank'));
      expect(App.appCrashId.key, equals('app.crash.id'));
      expect(App.appJankFrameCount.key, equals('app.jank.frame_count'));
      expect(App.appJankPeriod.key, equals('app.jank.period'));
      expect(App.appJankThreshold.key, equals('app.jank.threshold'));
    });

    test('mobile attributes round-trip through Attributes', () {
      final attrs = OTelAPI.attributesFromSemanticMap({
        Device.deviceId: 'a1b2c3',
        Session.sessionId: 'sess-42',
        Network.networkConnectionType: NetworkConnectionType.wifi.value,
        ErrorAttributes.errorType: 'java.net.UnknownHostException',
      });
      expect(attrs.getString('device.id'), equals('a1b2c3'));
      expect(attrs.getString('session.id'), equals('sess-42'));
      expect(attrs.getString('network.connection.type'), equals('wifi'));
      expect(attrs.getString('error.type'),
          equals('java.net.UnknownHostException'));
    });
  });
}
