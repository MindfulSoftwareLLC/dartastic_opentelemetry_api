// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Nearest registry replacement for the removed vendor `NavigationAction`
// enum. The registry has no navigation-action convention (push, pop,
// replace, deep link, ...); what it does define is the screen/widget
// surface: `app.screen.*` / `app.widget.*` attributes and the
// `app.screen.click` / `app.widget.click` events. Navigation actions
// remain vendor semantics in the RUM layer (flutterrific_opentelemetry)
// until a convention exists upstream.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('App screen semconv', () {
    test('app.screen attributes', () {
      expect(App.appScreenId.key, equals('app.screen.id'));
      expect(App.appScreenName.key, equals('app.screen.name'));
      expect(App.appScreenCoordinateX.key, equals('app.screen.coordinate.x'));
      expect(App.appScreenCoordinateY.key, equals('app.screen.coordinate.y'));
    });

    test('app.widget attributes', () {
      expect(App.appWidgetId.key, equals('app.widget.id'));
      expect(App.appWidgetName.key, equals('app.widget.name'));
    });

    test('screen and widget click events', () {
      expect(AppEvent.appScreenClick.name, equals('app.screen.click'));
      expect(AppEvent.appWidgetClick.name, equals('app.widget.click'));
    });

    test('screen attributes round-trip through Attributes', () {
      final attrs = OTelAPI.attributesFromSemanticMap({
        App.appScreenName: 'HomeScreen',
        App.appScreenId: 'home',
        App.appWidgetName: 'CheckoutButton',
      });
      expect(attrs.getString('app.screen.name'), equals('HomeScreen'));
      expect(attrs.getString('app.screen.id'), equals('home'));
      expect(attrs.getString('app.widget.name'), equals('CheckoutButton'));
    });
  });
}
