// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// W3C Trace Context multi-tenant tracestate keys (`{tenant-id}@{system-id}`)
// — the spec's second key form, which OpenTelemetry surfaces no API for.
// Validation of the form itself is covered in trace_state_test.dart; these
// tests cover the first-class helpers.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('multiTenantKey', () {
    test('builds the spec form', () {
      expect(TraceState.multiTenantKey('acme', 'dartastic'), 'acme@dartastic');
      // W3C example shape: digit-leading tenant ids are legal.
      expect(TraceState.multiTenantKey('0mgorg', 'dt'), '0mgorg@dt');
    });

    test('throws on invalid parts (fail fast, no silent mangling)', () {
      expect(() => TraceState.multiTenantKey('BAD', 'dartastic'),
          throwsArgumentError); // uppercase tenant
      expect(() => TraceState.multiTenantKey('acme', '1sys'),
          throwsArgumentError); // system-id must start lcalpha
      expect(() => TraceState.multiTenantKey('acme', 'a' * 15),
          throwsArgumentError); // system-id > 14
      expect(() => TraceState.multiTenantKey('a' * 242, 'dt'),
          throwsArgumentError); // tenant-id > 241
    });
  });

  group('put/get multi-tenant entries', () {
    test('round-trips and serializes per W3C', () {
      final ts = OTelAPI.traceState({})
          .putMultiTenant('acme', 'dartastic', 'span-affinity')
          .put('simple', 'x');
      expect(ts.getMultiTenant('acme', 'dartastic'), 'span-affinity');
      expect(ts.toString(), contains('acme@dartastic=span-affinity'));
      // Survives header round-trip.
      final parsed = TraceState.fromString(ts.toString());
      expect(parsed.getMultiTenant('acme', 'dartastic'), 'span-affinity');
    });

    test('getMultiTenant is null when absent', () {
      expect(OTelAPI.traceState({}).getMultiTenant('no', 'body'), isNull);
    });
  });

  group('tenantsForSystem', () {
    test('collects only the system’s tenants', () {
      final ts = OTelAPI.traceState({})
          .putMultiTenant('acme', 'dartastic', 'a')
          .putMultiTenant('globex', 'dartastic', 'b')
          .putMultiTenant('acme', 'dt', 'c')
          .put('plain', 'd');
      expect(ts.tenantsForSystem('dartastic'), {'acme': 'a', 'globex': 'b'});
      expect(ts.tenantsForSystem('dt'), {'acme': 'c'});
      expect(ts.tenantsForSystem('nobody'), isEmpty);
    });

    test('is unmodifiable', () {
      final ts = OTelAPI.traceState({}).putMultiTenant('acme', 'dt', 'v');
      expect(
          () => ts.tenantsForSystem('dt')['x'] = 'y', throwsUnsupportedError);
    });
  });
}
