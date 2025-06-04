// Test file to verify InstrumentationScopeCreate is accessible
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('API instrumentationScope creation', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-instrumentation-scope',
        serviceVersion: '1.0.1',
      );
    });

    test('identical collections are equal', () {
      var testName = 'test.i.scope';
      var testVersion = '1.2.3';
      var testSchemaUrl = 'https://dartastic.io/schema/test';
      var testAttributes = Attributes.of({'foo': 'bar', 'baz': true});
      final scope = OTelAPI.instrumentationScope(
          name: testName,
          version: testVersion,
          schemaUrl: testSchemaUrl,
          attributes: testAttributes);

      expect(scope.name, testName);
      expect(scope.version, testVersion);
      expect(scope.schemaUrl, testSchemaUrl);
      expect(scope.attributes, testAttributes);
      print('InstrumentationScope created successfully: ${scope.name}');
    });
  });
}
