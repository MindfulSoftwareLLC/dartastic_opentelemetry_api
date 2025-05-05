// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('LifecycleState', () {
    test('has correct values', () {
      expect(LifecycleState.resumed.value, equals('resumed'));
      expect(LifecycleState.inactive.value, equals('inactive'));
      expect(LifecycleState.paused.value, equals('paused'));
      expect(LifecycleState.detached.value, equals('detached'));
    });

    test('toString returns the value', () {
      expect(LifecycleState.resumed.toString(), equals('resumed'));
      expect(LifecycleState.inactive.toString(), equals('inactive'));
      expect(LifecycleState.paused.toString(), equals('paused'));
      expect(LifecycleState.detached.toString(), equals('detached'));
    });
  });
}
