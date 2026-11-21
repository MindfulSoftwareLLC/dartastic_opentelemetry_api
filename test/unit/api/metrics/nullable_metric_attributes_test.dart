// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

import 'observable_callback_test.dart' show TestObservableResult;

void main() {
  late _CapturingFactory factory;
  late APIMeter meter;
  const attributeMap = <String, Object?>{'nullable': null, 'label': 'kept'};

  setUp(() {
    OTelAPI.reset();
    factory = _CapturingFactory();
    OTelFactory.otelFactory = factory;
    meter = OTelAPI.meterProvider().getMeter(name: 'nullable-attributes');
  });

  tearDown(OTelAPI.reset);

  void expectConvertedAttributes() {
    final attributes = factory.converted.single;
    expect(attributes.toMap()['nullable']!.value, isA<AnyValueNull>());
    expect(attributes.getString('label'), 'kept');
  }

  test('API counter accepts nullable maps through the installed factory', () {
    final counter = meter.createCounter<int>(name: 'counter');
    counter.addWithMap(1, attributeMap);
    expectConvertedAttributes();
  });

  test('API up-down counter accepts nullable maps', () {
    final counter = meter.createUpDownCounter<int>(name: 'up-down');
    counter.addWithMap(-1, attributeMap);
    expectConvertedAttributes();
  });

  test('API gauge accepts nullable maps', () {
    final gauge = meter.createGauge<double>(name: 'gauge');
    gauge.recordWithMap(1.5, attributeMap);
    expectConvertedAttributes();
  });

  test('API histogram accepts nullable maps', () {
    final histogram = meter.createHistogram<double>(name: 'histogram');
    histogram.recordWithMap(1.5, attributeMap);
    expectConvertedAttributes();
  });

  test('API observable result preserves null attributes in a measurement', () {
    final APIObservableResult<int> result = TestObservableResult<int>();
    result.observeWithMap(3, attributeMap);
    expectConvertedAttributes();
    expect(result.measurements.single.value, 3);
    expect(
        result.measurements.single.attributes, same(factory.converted.single));
  });
}

class _CapturingFactory extends OTelAPIFactory {
  final converted = <Attributes>[];

  _CapturingFactory()
      : super(
          apiEndpoint: 'http://localhost:4318',
          apiServiceName: 'test',
          apiServiceVersion: '1.0.0',
        );

  @override
  Attributes attributesFromMap(Map<String, Object?> namedMap) {
    final attributes = super.attributesFromMap(namedMap);
    converted.add(attributes);
    return attributes;
  }
}
