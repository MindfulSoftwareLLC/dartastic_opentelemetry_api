// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

// Spec-compliance test for context/api-propagators.md, "Global Propagators":
//
// - "The OpenTelemetry API MUST provide a way to obtain a propagator for
//   each supported Propagator type" — with Get/Set global methods.
// - "The OpenTelemetry API MUST use no-op propagators unless explicitly
//   configured otherwise."

// Minimal test double reading from a Map<String, String> carrier.
class MapTextMapGetter implements TextMapGetter<String> {
  final Map<String, String> _values;

  MapTextMapGetter(this._values);

  @override
  String? get(String key) => _values[key];

  @override
  Iterable<String> keys() => _values.keys;
}

// Minimal test double writing to a Map<String, String> carrier.
class MapTextMapSetter implements TextMapSetter<String> {
  final Map<String, String> _values;

  MapTextMapSetter(this._values);

  @override
  void set(String key, String value) {
    _values[key] = value;
  }
}

// A distinguishable propagator to install as the global.
class MarkerPropagator implements TextMapPropagator<dynamic, dynamic> {
  static const String field = 'x-marker';

  @override
  List<String> fields() => const [field];

  @override
  void inject(Context context, dynamic carrier, TextMapSetter<dynamic> setter) {
    setter.set(field, 'marked');
  }

  @override
  Context extract(
          Context context, dynamic carrier, TextMapGetter<dynamic> getter) =>
      context;
}

// A replacement factory that substitutes its own default global
// propagator — the factory is the substitution seam for every API
// object, the global propagator included.
class MarkerDefaultFactory extends OTelAPIFactory {
  MarkerDefaultFactory({
    required super.apiEndpoint,
    required super.apiServiceName,
    required super.apiServiceVersion,
  });

  @override
  TextMapPropagator<dynamic, dynamic> get textMapPropagator =>
      MarkerPropagator();
}

void main() {
  setUp(() {
    OTelAPI.reset();
    OTelAPI.initialize(
      endpoint: 'http://localhost:4317',
      serviceName: 'test-service',
      serviceVersion: '1.0.0',
    );
  });

  group('Global TextMapPropagator', () {
    test('the default global propagator is a no-op TextMapPropagator', () {
      final propagator = OTelAPI.textMapPropagator;
      expect(propagator, isA<TextMapPropagator<dynamic, dynamic>>());
      expect(propagator, isA<NoopTextMapPropagator<dynamic, dynamic>>());
      expect(propagator.fields(), isEmpty);
    });

    test('the no-op extract returns the identical context unchanged', () {
      final context = OTelAPI.context();
      final carrier = {'traceparent': '00-abc-def-01'};

      final extracted = OTelAPI.textMapPropagator
          .extract(context, carrier, MapTextMapGetter(carrier));

      expect(extracted, same(context));
    });

    test('the no-op inject writes nothing to the carrier', () {
      final context = OTelAPI.context();
      final carrier = <String, String>{};

      OTelAPI.textMapPropagator
          .inject(context, carrier, MapTextMapSetter(carrier));

      expect(carrier, isEmpty);
    });

    test('set replaces the global propagator and get returns it', () {
      final custom = MarkerPropagator();

      OTelAPI.textMapPropagator = custom;

      expect(OTelAPI.textMapPropagator, same(custom));

      // The installed propagator is the one instrumentation obtains and uses.
      final carrier = <String, String>{};
      OTelAPI.textMapPropagator
          .inject(OTelAPI.context(), carrier, MapTextMapSetter(carrier));
      expect(carrier, equals({MarkerPropagator.field: 'marked'}));
    });

    test('OTelAPI.reset() restores the no-op default', () {
      final custom = MarkerPropagator();
      OTelAPI.textMapPropagator = custom;
      expect(OTelAPI.textMapPropagator, same(custom));

      OTelAPI.reset();

      final propagator = OTelAPI.textMapPropagator;
      expect(propagator, isNot(same(custom)));
      expect(propagator, isA<NoopTextMapPropagator<dynamic, dynamic>>());
    });

    test('a replacement factory substitutes its own global propagator', () {
      OTelFactory.otelFactory = MarkerDefaultFactory(
        apiEndpoint: 'http://localhost:4317',
        apiServiceName: 'test-service',
        apiServiceVersion: '1.0.0',
      );
      expect(OTelAPI.textMapPropagator, isA<MarkerPropagator>());
    });

    test('setting the global propagator logs at debug level when enabled', () {
      final logged = <String>[];
      final priorLogFunction = OTelLog.logFunction;
      final priorLevel = OTelLog.currentLevel;
      OTelLog.logFunction = logged.add;
      OTelLog.currentLevel = LogLevel.debug;
      addTearDown(() {
        OTelLog.logFunction = priorLogFunction;
        OTelLog.currentLevel = priorLevel;
      });

      OTelAPI.textMapPropagator = MarkerPropagator();

      expect(
        logged.join('\n'),
        allOf(contains('NoopTextMapPropagator'), contains('MarkerPropagator')),
      );
    });
  });
}
